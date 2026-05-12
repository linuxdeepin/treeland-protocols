# treeland_cross_subsurface_unstable_v1 设计文档

## 1. 背景与问题

### 1.1 Wayland 的进程隔离限制

标准 `wl_subcompositor` 要求 parent 和 child 的 `wl_surface` 来自同一个 `wl_compositor`（即同一个客户端连接）。这意味着跨进程的 subsurface 关系在标准协议下是不可能的。

### 1.2 X11 的做法

X11 中 `XReparentWindow()` 是服务端操作，任何 X 客户端都可以把窗口 reparent 到另一个 X 窗口下，没有进程隔离限制。所有 Wine 进程共享同一个 `gdi_display`，跨进程父子窗口关系天然支持。

X11 驱动中 `attach_client_window()`（`winex11.drv/window.c:2309`）通过 `XReparentWindow()` 将 client window 嵌入 parent 的 `whole_window`，即使 parent 属于另一个进程也能正常工作。当跨进程 parent 查找失败时（`get_win_data(toplevel)` 返回 NULL），X11 只是跳过坐标偏移修正，client window 仍然正常存在和渲染。

### 1.3 Wine Wayland 后端的现状

Wine 的 `winewayland.drv` 中有两类 subsurface：

1. **wayland_surface 的 wl_subsurface**（`wayland_surface.c:305`）：WS_CHILD 窗口作为 toplevel 的 subsurface
2. **wayland_client_surface 的 wl_subsurface**（`wayland_surface.c:1179`）：OpenGL/Vulkan 渲染区域作为 toplevel 的 subsurface

两者都通过 `wl_subcompositor_get_subsurface()` 创建，必须在同一进程内。

`wayland_client_surface_attach()`（`wayland_surface.c:1150`）中，当 toplevel 属于另一个进程时：

```c
if (!(toplevel_data = wayland_win_data_get_nolock(toplevel)) || !(surface = toplevel_data->wayland_surface))
{
    wayland_client_surface_attach(client, NULL);  // 直接 detach，渲染丢失
    return;
}
```

`wayland_win_data_get_nolock()` 只能查找当前进程的红黑树，跨进程查找返回 NULL，导致 client_surface 被 detach。

### 1.4 触发场景

实际触发跨进程失败需要同时满足三个条件：

1. 窗口使用 OpenGL/Vulkan 渲染（有 `wayland_client_surface`）
2. 窗口 `!managed`（无 caption/thickframe/sysmenu/WS_EX_APPWINDOW）
3. `owner_hint`（来自 `GW_OWNER` 或 `NtUserWindowFromPoint`）指向另一个进程

这在真实应用中极为罕见，因为使用 GPU 渲染的窗口几乎总是有 caption 或 thickframe，会被判为 managed。但协议设计应覆盖这类场景以保证完整性。

### 1.5 place_above 的实际使用模式

Wine 中 `place_above` 只引用两种目标（`wayland_surface.c:611-694`）：

- **parent 的 `wl_surface`**（toplevel 窗口表面本身）
- **parent 的 `client_surface->wl_surface`**（OpenGL/Vulkan 渲染区域）

并且只在 if/else 分支中使用，不需要引用任意中间 subsurface。

## 2. 设计目标

1. **通用性**：协议不耦合 Wine，任何 Wayland 客户端都可以使用
2. **兼容性**：语义尽可能对齐 `wl_subcompositor`，减少客户端适配成本
3. **统一 ID 空间**：parent、sibling（标准 + 跨进程）共用一个 uint32 命名空间
4. **compositor 透明**：标准 `wl_subcompositor` 创建的 subsurface 也能被自动纳入 ID 管理

## 3. 协议设计

### 3.1 整体架构

```
treeland_subsurface_manager_v1 (global)
├── export_surface(surface) → treeland_exported_surface_v1
│   ├── surface_id 事件：分配 parent ID
│   ├── child_entered 事件：标准 wl_subsurface 进入时分配 sibling ID
│   └── child_left 事件：标准 wl_subsurface 离开时回收 ID
│
└── create_remote_subsurface(surface, parent_id) → treeland_remote_subsurface_v1
    ├── subsurface_id 事件：分配跨进程 subsurface 的 sibling ID
    ├── parent_geometry 事件：parent 几何信息（坐标换算用）
    └── parent_destroyed 事件：parent 销毁通知
```

### 3.2 ID 命名空间

所有 ID（surface_id 和 subsurface_id）在同一个 uint32 命名空间中：

```
值范围              | 含义
[1, 0xFFFFFFFE]    | compositor 分配的有效 ID
0                  | 保留（无效值，触发 bad_sibling 错误）
0xFFFFFFFF         | 保留（sibling_ref.top，放到 sibling 栈顶）
```

ID 来源有三个：

| 来源 | 接口 | 分配时机 |
|------|------|---------|
| exported surface | `treeland_exported_surface_v1.surface_id` | export_surface 后立即 |
| standard subsurface | `treeland_exported_surface_v1.child_entered` | wl_subcompositor.get_subsurface 时自动 |
| remote subsurface | `treeland_remote_subsurface_v1.subsurface_id` | create_remote_subsurface 后立即 |

compositor 内部维护一个全局 ID 分配器，保证三个来源不重复。

### 3.3 核心机制：标准 subsurface 的自动发现

compositor 在以下时机自动追踪标准 `wl_subcompositor` subsurface：

1. 监听 `wl_subcompositor.get_subsurface(surface, parent)` 请求
2. 如果 parent 是一个已 export 的 surface，为其 child 分配 subsurface_id
3. 通过 `child_entered` 事件通知 export owner
4. 通过 `child_left` 事件通知 export owner（wl_subsurface 销毁时）

这个机制不需要改动标准 `wl_subcompositor` 协议，完全在 compositor 侧实现。

### 3.4 与 wl_subcompositor 的对应关系

| wl_subcompositor | treeland_cross_subsurface | 变化 |
|-----------------|--------------------------|------|
| `get_subsurface(id, surface, parent)` | `create_remote_subsurface(id, surface, parent_id)` | parent: wl_surface → uint32 |
| `set_position(x, y)` | `set_position(x, y)` | 不变 |
| `place_above(sibling: wl_surface)` | `place_above(sibling_ref: uint32)` | sibling: wl_surface → uint32 |
| `place_below(sibling: wl_surface)` | `place_below(sibling_ref: uint32)` | 同上 |
| `set_sync()` | `set_sync()` | 不变 |
| `set_desync()` | `set_desync()` | 不变 |
| (无) | `subsurface_id` 事件 | 新增：跨进程标识 |
| (无) | `parent_geometry` 事件 | 新增：坐标换算依据 |
| (无) | `parent_destroyed` 事件 | 新增：生命周期通知 |
| (无) | `export_surface` + `surface_id` | 新增：parent export 机制 |
| (无) | `child_entered` / `child_left` | 新增：标准 subsurface 自动发现 |

### 3.5 place_above / place_below 的 sibling_ref 语义

```xml
<!-- sibling_ref 值 -->  <!-- 含义 -->
parent_id             <!-- parent surface 自身 -->
sibling_subsurface_id <!-- 任意 sibling（标准或跨进程） -->
0xFFFFFFFF            <!-- 栈顶 -->
0                     <!-- 无效，触发 bad_sibling 错误 -->
```

示例：`place_above(sibling_ref = parent_id)` 等价于标准协议中的
`place_above(parent_wl_surface)`。

### 3.6 parent_geometry 事件

跨进程后，子进程没有 parent 的 `wl_surface` proxy，无法直接获取 parent 的
buffer_scale 和 buffer_transform。`parent_geometry` 事件提供这些信息：

- `x, y`：parent 在 compositor 全局逻辑坐标系中的原点位置
- `scale`：parent 的 `wl_surface.buffer_scale`
- `transform`：parent 的 `wl_surface.buffer_transform`（遵循 `wl_output.transform` 语义）

子进程使用这些值将自身逻辑坐标转换为 parent 的 surface-local 坐标后传给 `set_position()`。

## 4. Compositor 侧实现要点

### 4.1 ID 管理

```cpp
class SubsurfaceIdAllocator {
    uint32_t next_id = 1;

    uint32_t allocate() {
        // 跳过 0 和 0xFFFFFFFF
        uint32_t id = next_id++;
        if (id == 0) id = next_id++;
        if (id == 0xFFFFFFFF) id = next_id++;
        return id;
    }
};
```

所有 ID（exported surface、standard subsurface、remote subsurface）通过同一个分配器管理。

### 4.2 标准 subsurface 监听

compositor 在处理 `wl_subcompositor.get_subsurface` 时：

```cpp
void on_subcompositor_get_subsurface(wl_subcompositor *subcompositor,
                                     wl_surface *surface,
                                     wl_surface *parent)
{
    // 检查 parent 是否是已 export 的 surface
    auto export = find_export(parent);
    if (!export) return;  // 标准 subsurface，不干预

    // 分配 subsurface_id，通知 export owner
    uint32_t id = allocator.allocate();
    export->send_child_entered(id, surface);
    track_standard_subsurface(surface, export, id);
}
```

### 4.3 place_above / place_below 处理

```cpp
void on_place_above(RemoteSubsurface *self, uint32_t sibling_ref)
{
    Surface *sibling;

    if (sibling_ref == 0) {
        // 错误：无效值
        self->send_bad_sibling();
        return;
    }

    if (sibling_ref == 0xFFFFFFFF) {
        // 栈顶
        restack_to_top(self);
        return;
    }

    // 在 parent 的所有 subsurface（标准 + 跨进程）中查找
    sibling = find_surface_by_id(self->parent, sibling_ref);
    if (!sibling || !is_sibling_of(self, sibling)) {
        self->send_bad_sibling();
        return;
    }

    restack_above(self, sibling);
}
```

### 4.4 安全策略

compositor 应通过以下机制限制访问：

1. **绑定控制**：只允许受信任的客户端绑定 `treeland_subsurface_manager_v1`（通过 app-id 或 PID 白名单）
2. **parent_id 验证**：`create_remote_subsurface` 时验证 parent_id 对应的 export 属于受信任的客户端
3. **进程隔离**：child_entered 事件中的 `wl_surface` 参数只在 export owner 的连接中有效，其他客户端无法通过这个 proxy 操作 surface

## 5. Wine 集成方案

### 5.1 与现有 wine_window_management 的关系

`treeland_wine_window_management_v1` 的 `window_id` 和本协议的 `surface_id`
是两个独立系统，各自有独立的命名空间。Wine driver 需要在 wineserver 共享内存
中同时维护两套映射：

```
wineserver 共享内存布局:
{
    HWND -> {
        window_id,       // 来自 wine_window_management（z-order 用）
        surface_id,      // 来自 cross_subsurface（subsurface parent/sibling 用）
    }
}
```

### 5.2 集成流程

```
进程 A (parent):
  1. wine_window_management.get_window_control(toplevel)
     → window_id = 42
  2. cross_subsurface.export_surface(toplevel)
     → surface_id = 100
  3. wl_subcompositor.get_subsurface(client_surface, toplevel)
     → compositor 自动触发 child_entered(subsurface_id=200, client_surface)
  4. wineserver 共享: {toplevel: surface_id=100, client_surface: subsurface_id=200}

进程 B (child):
  1. wineserver 查表 → parent surface_id = 100, sibling client_surface subsurface_id = 200
  2. cross_subsurface.create_remote_subsurface(my_surface, parent_id=100)
     → subsurface_id = 300
  3. set_desync()
  4. set_position(x, y)              // 用 parent_geometry 事件算坐标
  5. place_above(sibling_ref=200)    // above parent 的 OpenGL 渲染区
  6. place_above(sibling_ref=100)    // above parent 自身（window frame）
  7. place_above(0xFFFFFFFF)         // 栈顶
```

### 5.3 修改点（winewayland.drv）

需要修改的函数：

| 函数 | 文件:行 | 当前行为 | 修改后 |
|------|--------|---------|--------|
| `wayland_client_surface_attach()` | wayland_surface.c:1169 | 找不到 toplevel 时 detach | 尝试通过 surface_id 创建 remote_subsurface |
| `wayland_surface_make_subsurface()` | wayland_surface.c:294 | 只找本进程 toplevel_surface | 跨进程时使用 create_remote_subsurface |
| `wayland_surface_reconfigure_subsurface()` | wayland_surface.c:673 | 调用 wl_subsurface_set_position | 跨进程时使用 remote_subsurface.set_position |
| `wayland_surface_reconfigure_client()` | wayland_surface.c:588 | 调用 wl_subsurface_place_above | 跨进程时使用 remote_subsurface.place_above |

## 6. 与 xdg-foreign-v2 的对比

| 特性 | xdg-foreign-v2 | treeland_cross_subsurface |
|------|---------------|--------------------------|
| 目标 | 窗口间 stacking（类似 X11 transient） | 完整的 subsurface 语义 |
| 导出粒度 | 仅 xdg_toplevel | 任意 wl_surface |
| 子 surface 的位置控制 | 无（依赖 WM） | set_position |
| 同步/异步模式 | 无 | set_sync/set_desync |
| sibling 排序 | 无 | place_above/place_below |
| 内容渲染 | 子进程独立渲染 | 子进程独立渲染 |
| 适用场景 | 对话框、弹出菜单 | 嵌入式渲染、子窗口 |

xdg-foreign-v2 只解决了 "把我的窗口放在另一个窗口上面" 的问题，而
treeland_cross_subsurface 解决的是 "把我的 surface 作为另一个 surface 的子 surface"
——包括定位、同步、排序在内的完整 subsurface 语义。
