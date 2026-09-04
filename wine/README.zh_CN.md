# Wine 兼容协议

Wine Windows 兼容层协议。通过 `TREELAND_PROTOCOL_WINE_XML_FILES` 安装。

| 文件 | 协议 | 接口 | 用途 |
|------|----------|-----------|---------|
| `treeland-remote-subsurface-unstable-v1.xml` | `treeland_remote_subsurface_unstable_v1` | `treeland_remote_subsurface_manager_v1`, `treeland_exported_surface_v1`, `treeland_remote_subsurface_v1` | 基于令牌的跨进程子 surface 关系（替代 Wine 的 wl_subcompositor） |
| `treeland-wine-window-management-unstable-v1.xml` | `treeland_wine_window_management_unstable_v1` | `treeland_wine_window_manager_v1`, `treeland_wine_window_control_v1` | Wine 窗口定位（SetWindowPos）和 Z 序控制（HWND_TOPMOST 等） |
| `treeland-wine-window-state-unstable-v1.xml` | `treeland_wine_window_state_unstable_v1` | `treeland_wine_window_state_manager_v1`, `treeland_wine_window_state_v1` | Wine 窗口状态：最小化/还原、带焦点抢占防护的激活、注意提示（FlashWindowEx） |
