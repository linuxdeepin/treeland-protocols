# DDE 桌面组件协议

面向 DDE 桌面组件。通过 `TREELAND_PROTOCOL_DDE_XML_FILES` 安装。

| 文件 | 协议 | 接口 | 用途 |
|------|----------|-----------|---------|
| `treeland-foreign-toplevel-manager-v1.xml` | `treeland_foreign_toplevel_manager_v1` | `treeland_foreign_toplevel_manager_v1`, `treeland_foreign_toplevel_handle_v1`, `treeland_dock_preview_context_v1` | 顶层窗口观察、激活、状态管理和 Dock 预览 |
| `treeland-input-manager-unstable-v1.xml` | `treeland_input_manager_unstable_v1` | `treeland_input_manager_v1`, `treeland_pointer_device_configuration_v1`, `treeland_mouse_settings_v1`, `treeland_touchpad_settings_v1`, `treeland_keyboard_settings_v1` | 逐设备输入配置：指针加速、发送事件模式、键盘切换状态 |
| `treeland-keyboard-state-notify-unstable-v1.xml` | `treeland_keyboard_state_notify_unstable_v1` | `treeland_keyboard_state_notify_manager_v1`, `treeland_keyboard_state_watcher_v1` | 监听键盘修饰键（Caps/Num Lock）状态变化 |
| `treeland-output-manager-v1.xml` | `treeland_output_manager_v1` | `treeland_output_manager_v1`, `treeland_output_color_control_v1` | 主输出选择、逐输出色温和亮度控制 |
| `treeland-personalization-manager-v1.xml` | `treeland_personalization_manager_v1` | `treeland_personalization_manager_v1`, `treeland_personalization_cursor_context_v1`, `treeland_personalization_window_context_v1`, `treeland_personalization_font_context_v1`, `treeland_personalization_appearance_context_v1` | 光标主题/大小、逐窗口混合/阴影/边框/标题栏、全局字体、全局外观（图标主题、活跃色、不透明度、主题类型、标题栏高度） |
| `treeland-shortcut-manager-v2.xml` | `treeland_shortcut_manager_v2` | `treeland_shortcut_manager_v2`, `treeland_shortcut_capture_v1` | 全局键盘快捷键绑定，支持按键/触摸/多点触摸手势 |
| `treeland-virtual-output-manager-v1.xml` | `treeland_virtual_output_manager_v1` | `treeland_virtual_output_manager_v1`, `treeland_virtual_output_v1` | 虚拟（镜像）输出创建和管理 |
| `treeland-wallpaper-manager-unstable-v1.xml` | `treeland_wallpaper_manager_unstable_v1` | `treeland_wallpaper_manager_v1`, `treeland_wallpaper_v1` | 逐输出壁纸配置，支持图片/视频来源 |
| `treeland-show-desktop-unstable-v1.xml` | `treeland_show_desktop_unstable_v1` | `treeland_show_desktop_v1` | 显示桌面模式控制：请求模式切换并观察合成器驱动的状态变化 |

## 破坏性变更

破坏性变更按版本分组。每个版本标题下，每个受影响协议有一个子节说明变更内容、替代方案以及现有消费者如何适配。

### 0.6.0

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
