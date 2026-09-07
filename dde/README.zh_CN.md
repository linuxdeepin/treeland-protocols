# DDE 桌面组件协议

面向 DDE 桌面组件。通过 `TREELAND_PROTOCOL_DDE_XML_FILES` 安装。

| 文件 | 协议 | 接口 | 用途 |
|------|----------|-----------|---------|
| `treeland-foreign-toplevel-manager-unstable-v2.xml` | `treeland_foreign_toplevel_manager_unstable_v2` | `treeland_foreign_toplevel_manager_v2`, `treeland_foreign_toplevel_handle_v2`, `treeland_dock_preview_context_v2` | 重新设计的顶层窗口观察和 Dock 预览；修正了命名、成员顺序、destroy 位置和描述质量 |
| `treeland-input-manager-unstable-v1.xml` | `treeland_input_manager_unstable_v1` | `treeland_input_manager_v1`, `treeland_pointer_device_configuration_v1`, `treeland_mouse_settings_v1`, `treeland_touchpad_settings_v1`, `treeland_keyboard_settings_v1` | 逐设备输入配置：指针加速、发送事件模式、键盘切换状态 |
| `treeland-keyboard-state-notify-unstable-v1.xml` | `treeland_keyboard_state_notify_unstable_v1` | `treeland_keyboard_state_notify_manager_v1`, `treeland_keyboard_state_watcher_v1` | 监听键盘修饰键（Caps/Num Lock）状态变化 |
| `treeland-output-manager-v1.xml` | `treeland_output_manager_v1` | `treeland_output_manager_v1`, `treeland_output_color_control_v1` | 主输出选择、逐输出色温和亮度控制 |
| `treeland-shortcut-manager-unstable-v3.xml` | `treeland_shortcut_manager_unstable_v3` | `treeland_shortcut_manager_v3`, `treeland_shortcut_capture_v3` | 全局键盘快捷键绑定，支持按键/触摸/多点触摸手势及一次性快捷键捕获 |
| `treeland-appearance-manager-unstable-v1.xml` | `treeland_appearance_manager_unstable_v1` | `treeland_appearance_manager_v1` | 特权用户级外观配置：光标主题/大小、全局字体、图标主题、强调色、窗口不透明度、配色方案、标题栏高度、全局圆角 |
| `treeland-virtual-output-manager-v1.xml` | `treeland_virtual_output_manager_v1` | `treeland_virtual_output_manager_v1`, `treeland_virtual_output_v1` | 虚拟（镜像）输出创建和管理 |
| `treeland-wallpaper-manager-unstable-v1.xml` | `treeland_wallpaper_manager_unstable_v1` | `treeland_wallpaper_manager_v1`, `treeland_wallpaper_v1` | 逐输出壁纸配置，支持图片/视频来源 |
| `treeland-show-desktop-unstable-v1.xml` | `treeland_show_desktop_unstable_v1` | `treeland_show_desktop_v1` | 显示桌面模式控制：请求模式切换并观察合成器驱动的状态变化 |

## 破坏性变更

破坏性变更按版本分组。每个版本标题下，每个受影响协议有一个子节说明变更内容、替代方案以及现有消费者如何适配。

### 0.6.0

#### `treeland-personalization-manager-v1.xml`

被 `treeland-decoration-unstable-v1.xml` 和 `treeland-appearance-unstable-v1.xml`（在 `public/`）以及 `treeland-appearance-manager-unstable-v1.xml`（在 `dde/`）取代；逐窗口背景模糊由上游 `ext-background-effect-v1` 协议承接。旧 v1 文件原样移至 `deprecated/`。

主要变更：
1. **协议拆分与职责分离**：
   - 服务端装饰（SSD）定制（窗口圆角、阴影、边框、服务端标题栏）拆分为 `treeland-decoration-unstable-v1.xml`（在 `public/`）。需先经 xdg-decoration 申请服务端装饰，支持“半 CSD、半 SSD”配置（保留合成器边框/圆角/阴影，隐藏其标题栏）。
   - 逐窗口背景模糊由上游 `ext-background-effect-v1` 协议（wayland-protocols staging）承接，与装饰模式无关，通过其 `capabilities` 事件通告模糊能力。旧协议的 `wallpaper` 混合模式废弃且无替代；消费者不得依赖该模式。
   - 只读用户级外观查询与订阅（光标主题/大小、字体、图标主题、强调色、窗口不透明度、配色方案、标题栏高度、圆角）拆分为 `treeland-appearance-unstable-v1.xml`（在 `public/`），面向所有常规应用。
   - 特权用户级外观配置（修改光标、字体、视觉主题）拆分为 `treeland-appearance-manager-unstable-v1.xml`（在 `dde/`），面向桌面控制中心与系统设置组件。
2. **Push 模型状态同步**：
   - 移除冗余的同步 `get_*` 查询请求。合成器在创建 context 时立即推送当前值，并在变更时广播给所有已绑定的 context。
3. **光标设置简化**：
   - 移除 `commit` 请求和 `verfity` 事件。`set_theme` 和 `set_size` 现立即生效，与字体和外观 context 语义一致。
4. **配色方案枚举重命名与规范化**：
   - `theme_type` 重命名为 `color_scheme`，移除 `auto`，规范为 `light`（0）和 `dark`（1）；动态自动切换策略交由客户端处理。
5. **标准化生命周期与结构**：
   - 为 `destroy` 请求显式添加 `type="destructor"`，并移至每个接口的首个请求位置；
   - 将所有 `enum` 定义置于 requests 之前，所有 `event` 定义置于 requests 之后。
6. **数值表示规范化（线缆不兼容）**：
   - `window_opacity`：旧的无范围定义的 `uint` 值改为 `fixed` 值，范围为 `[0.0, 1.0]`（1.0 全不透明，0.0 全透明）。`set_window_opacity` 请求参数与 `window_opacity` 事件参数的类型与刻度均变更；消费者须从整数百分比处理改为定点数处理。
   - `active_color`：旧的单个 `string` 参数（颜色描述）改为四个 `uint` 分量 `r, g, b, a`，范围 `[0, 255]`，`set_accent_color` 请求与 `accent_color` 事件均如此。

#### `treeland-window-management-v1.xml`

被 `treeland-show-desktop-unstable-v1.xml` 取代；旧 v1 文件已移至 `deprecated/`。协议被重命名以反映其实际范围（仅显示桌面模式）。与旧 `treeland_window_management_v1` 接口相比：

1. 接口重命名为 `treeland_show_desktop_v1`。
2. `destroy` 请求移至第一个请求位置。
3. `show_desktop` 事件重命名为 `show_desktop_state`。
4. `desktop_state` 枚举重命名为 `state`。
5. `preview_show` 枚举项被移除，因为从未实现且不再需要。
6. `set_desktop` 请求重命名为 `set_show_desktop_state`。
7. 描述被修正和扩充。

消费者应将全局对象重新绑定为 `treeland_show_desktop_v1`，发送 `set_show_desktop_state` 请求切换模式，监听 `show_desktop_state` 观察合成器驱动的变化；旧 v1 XML 在迁移期间仍会安装，但不得用于新代码。

#### `treeland-foreign-toplevel-manager-v1.xml`

被 `treeland-foreign-toplevel-manager-unstable-v2.xml` 取代；旧 v1 文件已移至 `deprecated/`。协议被重新设计，修正了命名、成员顺序并改进了描述。与旧 `treeland_foreign_toplevel_manager_v1` 接口相比：

1. 命名修正：文件名和协议名添加 `unstable`；三个接口升级为 `_v2`。
2. 三个接口的 `destroy` 析构请求均位于第一个请求位置（管理器接口为新增，另两个接口为位置前移）。
3. 枚举移至请求之前。
4. 事件移至请求之后。
5. `finished` 事件从析构事件改为普通事件，且 `stop` 请求不再禁止一切后续请求。合成器不再自动销毁管理器对象；客户端须显式发送 `destroy`，建议先 `stop` 并等待 `finished`。
6. `set_rectangle` 请求重命名为 `set_icon_geometry`，`invalid_rectangle` 错误枚举项重命名为 `invalid_geometry`。
7. Dock 预览 `show` 请求的 `surfaces` 参数重命名为 `identifiers`，以反映其携带的是 uint32 顶层窗口标识符而非 wl_surface 对象。
8. 管理器接口新增 `error` 枚举，含 `invalid_surface`，当传入 `get_dock_preview_context` 的 `relative_surface` 不是调用客户端拥有的有效 wl_surface 时触发。
9. 描述被修正和扩充。

消费者应将全局对象重新绑定为 `treeland_foreign_toplevel_manager_v2`，从 `toplevel` 事件获取 `treeland_foreign_toplevel_handle_v2` 对象，并使用 `treeland_dock_preview_context_v2` 进行预览；旧 v1 XML 在迁移期间仍会安装，但不得用于新代码。
#### `treeland-shortcut-manager-v2.xml`

被 `treeland-shortcut-manager-unstable-v3.xml` 取代；旧 v2 文件原样移至 `deprecated/`。协议按 unstable 命名规范重命名，接口随新主版本重命名。与旧 `treeland_shortcut_manager_v2` 接口相比：

1. 协议重命名为 `treeland_shortcut_manager_unstable_v3`；接口重命名为 `treeland_shortcut_manager_v3` 和 `treeland_shortcut_capture_v3`。
2. 管理器接口版本从 3 重置为 1，并移除所有 `since` 属性（这些属性标记的是 v2 接口第 2、3 版新增的成员：`capture_next_shortcut`、`invalid_surface` 错误以及 `tile_left`/`tile_right` action）。
3. `action` 枚举重新编号：所有枚举值整体前移一位（`notify` 现为 0，`tile_right` 现为 28）；未增删枚举项。
4. 移除 commit 机制：`bind_key`、`bind_swipe_gesture`、`bind_hold_gesture` 立即生效，被拒绝的绑定通过新增的 `bind_failure` 事件逐个报告，`commit` 请求、`commit_success` 与 `commit_failure` 事件以及 `error.invalid_commit` 枚举项不复存在。`error.invalid_surface` 枚举项从 4 重编号为 3。与旧模型不同，单个绑定失败不再回滚同批次的其他绑定。
5. 文档完善（无线缆变更）：销毁管理器对象现明确说明会隐式释放经由 `acquire` 获取的独占控制权；`capture_next_shortcut` 请求与捕获接口语义重写以对齐合成器实现（触发时机、seat/focus 校验、`busy`/`aborted` 失败条件及有效快捷键规则）。

消费者应将全局对象重新绑定为 `treeland_shortcut_manager_v3`，在发送任何 bind 或 unbind 请求前先 `acquire`，并通过 `capture_next_shortcut` 创建捕获对象；旧 v2 XML 在迁移期间仍会安装，但不得用于新代码。
