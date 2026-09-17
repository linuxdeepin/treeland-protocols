# 公共协议

面向通用应用开发者。通过 `TREELAND_PROTOCOL_XML_FILES` 安装。

| 文件 | 协议 | 接口 | 用途 |
|------|----------|-----------|---------|
| `treeland-window-transition-unstable-v1.xml` | `treeland_window_transition_unstable_v1` | `treeland_window_transition_manager_v1`, `treeland_window_transition_rect_v1` | 相对某个矩形的窗口打开/关闭转场，可附带源图像 |
| `treeland-appearance-unstable-v1.xml` | `treeland_appearance_unstable_v1` | `treeland_appearance_v1` | 查询与订阅用户级外观设置：光标主题/大小、字体、图标主题、强调色、窗口不透明度、配色方案、标题栏高度、圆角 |
| `treeland-decoration-unstable-v1.xml` | `treeland_decoration_unstable_v1` | `treeland_decoration_manager_v1`, `treeland_decoration_context_v1` | 逐窗口服务端装饰（SSD）定制：圆角、阴影、边框、标题栏可见性；需先经 xdg-decoration 申请 SSD |

## 破坏性变更

破坏性变更按版本分组。每个版本标题下，每个受影响协议有一个子节说明变更内容、替代方案以及现有消费者如何适配。

### 0.7.0

#### `treeland-appearance-unstable-v1.xml`

`accent_color` 事件移除了 `a`（alpha）参数。活动色现以不透明 RGB 三元组 `r, g, b` 上报（每个为 `[0, 255]` 范围内的 `uint`）；alpha 通道不再上线缆传输。消费者须停止读取末尾的 `a` 参数，且不得从该事件推断活动色不透明度；不透明度不在活动色设置范围内。

#### `treeland-dde-shell-v1.xml`

整个文件已废弃并移至 `deprecated/`。由 `treeland-dde-shell-unstable-v2.xml`（在 `dde/`，surface 角色功能）连同上述专用协议取代；`treeland_window_picker_v1` 接口无替代直接移除。

v1 与 v2 的线缆级差异：

1. 仅 surface 角色得以保留。管理器只暴露 `get_shell_surface` 并新增 `already_shell_surface` 错误；被取代接口的工厂请求（`get_window_overlap_checker`、`get_treeland_dde_active`、`get_treeland_multitaskview`、`get_treeland_window_picker`、`get_treeland_lockscreen`）及 `set_xwindow_position_relative` 请求不再保留。
2. `role` 枚举改为 0 基编号：`overlay` 由 1 改为 0，且语义明确化（高于普通顶层窗口、低于 layer-shell surface）。
3. 三个 skip 请求（`set_skip_switcher`、`set_skip_dock_preview`、`set_skip_muti_task_view`，最后一个同时修正 "muti" 拼写错误）合并为单一的 `set_skip_flags` 请求，携带 `skip_flag` 位域（`switcher` 0x1、`dock_preview` 0x2、`multitask_view` 0x4）。
4. `set_auto_placement` 的 y_offset 改为 `int`（v1 为 `uint`），并明确两种放置请求（`set_surface_position` 与 `set_auto_placement`）的互斥关系（最近发送的请求生效）。
5. v2 全局对象必须拒绝非特权客户端绑定。

消费者应改绑为 `treeland_dde_shell_manager_v2`，通过 `get_shell_surface` 重建 shell surface，改用 `set_skip_flags`，并将 `overlay` 视为 0；窗口选取消费者无替代，须移除该功能。旧 XML 在迁移期间仍会安装，但不得用于新代码。

管理器的 `set_xwindow_position_relative` 请求及 `treeland_dde_active_v1`、`treeland_window_overlap_checker` 接口（含其创建请求 `get_treeland_dde_active`、`get_window_overlap_checker`）已废弃且不可用：请求无任何效果，也不会发出任何事件（`destroy` 请求仍然可用，客户端可借此释放对象）。

二者由 `dde/` 下三个新的独立协议取代：
- `treeland-xwindow-control-unstable-v1.xml`（`treeland_xwindow_control_v1`）：XWayland 窗口定位——`set_xwindow_position_relative` 请求，结果经 `wl_callback` 回报，线缆语义不变。
- `treeland-active-notify-unstable-v1.xml`（`treeland_active_notify_manager_v1`、`treeland_active_notify_v1`）：Seat 活跃通知——`get_active_notify` 请求创建按 Seat 限定的通知对象，其 `activity_changed` 事件携带 `reason` 与 `activity_state` 枚举（由 `active_in`/`active_out` 更名；鼠标跟踪左键状态，滚轮为逐事件脉冲），并新增携带 `drag_state` 枚举（started/dropped/cancelled）的 `drag_changed` 事件。
- `treeland-region-watch-unstable-v1.xml`（`treeland_region_watch_manager_v1`、`treeland_region_watch_v1`）：沿输出边缘的区域重叠监控——沿输出边缘的区域注册（`set_region`）与 `enter`/`leave` 状态事件及显式错误回报；watcher 接口由 `treeland_window_overlap_checker` 更名并补上 `_v1` 后缀，设区域请求由 `update` 更名为 `set_region`。

`treeland_multitaskview_v1` 和 `treeland_lockscreen_v1` 接口（含其创建请求 `get_treeland_multitaskview`、`get_treeland_lockscreen`）已废弃，由新的特权协议 `dde/treeland-compositor-action-unstable-v1.xml` 的对应动作取代（`toggle_multitask_view`/`open_multitask_view`/`close_multitask_view` 与 `lockscreen`/`shutdown_menu`/`show_user_switch`）。

消费者应改绑新的全局对象，不得在新代码中使用已废弃的请求与接口。

### 0.6.0

#### `treeland-personalization-manager-v1.xml`

由 `dde/treeland-personalization-manager-v1.xml` 拆分而来。该协议按受众拆分为三个职责清晰的协议：
- `treeland-decoration-unstable-v1.xml`（在 `public/`）：逐窗口服务端装饰（SSD）定制（圆角、阴影、边框、标题栏可见性），需先经 xdg-decoration 申请服务端装饰，支持“半 CSD、半 SSD”配置。
- `treeland-appearance-unstable-v1.xml`（在 `public/`）：只读用户级外观查询与订阅，面向所有常规应用。
- `treeland-appearance-manager-unstable-v1.xml`（在 `dde/`）：特权用户级外观配置，面向桌面控制中心与系统设置组件。

逐窗口背景模糊应改用上游 `ext-background-effect-v1` 协议（wayland-protocols staging），其通过 `capabilities` 事件通告模糊能力。旧协议的 `wallpaper` 混合模式废弃且无替代；消费者不得依赖该模式。

旧 v1 文件已原样移至 `deprecated/`。消费者应改用上述按职责拆分的新协议以及上游 `ext-background-effect-v1`；旧 XML 在迁移期间仍会安装，但不得用于新代码。

#### `treeland-capture-unstable-v1.xml`

从 `public/` 移除。被上游 `ext-image-capture-source-v1` 和 `ext-image-copy-capture-v1` 取代；此协议已弃用，文件移至 `deprecated/`。消费者应改用上游 `ext-image-capture-*` 协议；旧 XML 在迁移期间仍会安装，但不得用于新代码。
