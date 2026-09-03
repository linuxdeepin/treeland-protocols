# 公共协议

面向通用应用开发者。通过 `TREELAND_PROTOCOL_XML_FILES` 安装。

| 文件 | 协议 | 接口 | 用途 |
|------|----------|-----------|---------|
| `treeland-dde-shell-v1.xml` | `treeland_dde_shell_v1` | `treeland_dde_shell_manager_v1`, `treeland_window_overlap_checker`, `treeland_dde_shell_surface_v1`, `treeland_dde_active_v1`, `treeland_multitaskview_v1`, `treeland_window_picker_v1`, `treeland_lockscreen_v1` | DDE Shell 集成：surface 角色、重叠检测、活跃事件、多任务视图、窗口选取、锁屏 |
| `treeland-appearance-unstable-v1.xml` | `treeland_appearance_unstable_v1` | `treeland_appearance_v1` | 查询与订阅用户级外观设置：光标主题/大小、字体、图标主题、强调色、窗口不透明度、配色方案、标题栏高度、圆角 |
| `treeland-decoration-unstable-v1.xml` | `treeland_decoration_unstable_v1` | `treeland_decoration_manager_v1`, `treeland_decoration_context_v1` | 逐窗口服务端装饰（SSD）定制：圆角、阴影、边框、标题栏可见性；需先经 xdg-decoration 申请 SSD |

## 破坏性变更

破坏性变更按版本分组。每个版本标题下，每个受影响协议有一个子节说明变更内容、替代方案以及现有消费者如何适配。

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
