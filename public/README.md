# Public Protocols

For general application developers. Installed via `TREELAND_PROTOCOL_XML_FILES`.

| File | Protocol | Interfaces | Purpose |
|------|----------|-----------|---------| 
| `treeland-window-animation-v1.xml` | `treeland_window_animation_v1` | `treeland_window_animation_manager_v1`, `treeland_window_animation_rect_v1` | Window open/close animation relative to a rectangle, with optional source image |
| `treeland-dde-shell-v1.xml` | `treeland_dde_shell_v1` | `treeland_dde_shell_manager_v1`, `treeland_window_overlap_checker`, `treeland_dde_shell_surface_v1`, `treeland_dde_active_v1`, `treeland_multitaskview_v1`, `treeland_window_picker_v1`, `treeland_lockscreen_v1` | DDE shell integration: surface roles, overlap detection, active events, multitask view, window picker, lockscreen |

## Breaking changes

| Version | Date    | Protocol                           | Change                                                                                                                          |
|---------|---------|------------------------------------|--------------------------------------------------------------------------------------------------------------------------------|
| 0.6.0   | 2026/08 | `treeland-capture-unstable-v1.xml` | Removed from public. Replaced by upstream `ext-image-capture-source-v1` and `ext-image-copy-capture-v1`; this protocol is deprecated. |
