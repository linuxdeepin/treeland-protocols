# 公共协议

面向通用应用开发者。通过 `TREELAND_PROTOCOL_XML_FILES` 安装。

| 文件 | 协议 | 接口 | 用途 |
|------|----------|-----------|---------|
| `treeland-window-transition-unstable-v1.xml` | `treeland_window_transition_unstable_v1` | `treeland_window_transition_manager_v1`, `treeland_window_transition_rect_v1` | 相对某个矩形的窗口打开/关闭转场，可附带源图像 |
| `treeland-dde-shell-v1.xml` | `treeland_dde_shell_v1` | `treeland_dde_shell_manager_v1`, `treeland_window_overlap_checker`, `treeland_dde_shell_surface_v1`, `treeland_dde_active_v1`（已废弃）, `treeland_multitaskview_v1`, `treeland_window_picker_v1`, `treeland_lockscreen_v1` | DDE Shell 集成：surface 角色、重叠检测、活跃事件、多任务视图、窗口选取、锁屏；`treeland_dde_active_v1` 接口及 `set_xwindow_position_relative` 请求已废弃且不可用，由 `dde/treeland-active-notify-unstable-v1.xml` 和 `dde/treeland-xwindow-control-unstable-v1.xml` 取代 |
| `treeland-appearance-unstable-v1.xml` | `treeland_appearance_unstable_v1` | `treeland_appearance_v1` | 查询与订阅用户级外观设置：光标主题/大小、字体、图标主题、强调色、窗口不透明度、配色方案、标题栏高度、圆角 |
| `treeland-decoration-unstable-v1.xml` | `treeland_decoration_unstable_v1` | `treeland_decoration_manager_v1`, `treeland_decoration_context_v1` | 逐窗口服务端装饰（SSD）定制：圆角、阴影、边框、标题栏可见性；需先经 xdg-decoration 申请 SSD |

## 破坏性变更

破坏性变更按版本分组。每个版本标题下，每个受影响协议有一个子节说明变更内容、替代方案以及现有消费者如何适配。

### 0.7.0

#### `treeland-appearance-unstable-v1.xml`

`accent_color` 事件移除了 `a`（alpha）参数。活动色现以不透明 RGB 三元组 `r, g, b` 上报（每个为 `[0, 255]` 范围内的 `uint`）；alpha 通道不再上线缆传输。消费者须停止读取末尾的 `a` 参数，且不得从该事件推断活动色不透明度；不透明度不在活动色设置范围内。

#### `treeland-dde-shell-v1.xml`

管理器的 `set_xwindow_position_relative` 请求及 `treeland_dde_active_v1` 接口（含其创建请求 `get_treeland_dde_active`）现标注为已废弃且不可用：请求无任何效果，也不会发出任何事件。文件暂保留原位；整个 `treeland-dde-shell` 协议计划在未来版本彻底移除。

二者由 `dde/` 下两个新的独立协议取代：
- `treeland-xwindow-control-unstable-v1.xml`（`treeland_xwindow_control_v1`）：XWayland 窗口定位——`set_xwindow_position_relative` 请求，结果经 `wl_callback` 回报，线缆语义不变。
- `treeland-active-notify-unstable-v1.xml`（`treeland_active_notify_manager_v1`、`treeland_active_notify_v1`）：座席活跃通知——`get_active_notify` 请求创建按座席的通知对象，其 `activity_enter`/`activity_leave` 事件携带 `reason` 枚举（由 `active_in`/`active_out` 更名），并新增 `start_drag`/`drop` 事件。

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
