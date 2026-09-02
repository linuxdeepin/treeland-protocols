# Wine Compatibility Protocols

Protocols for the Wine Windows compatibility layer. Installed via `TREELAND_PROTOCOL_WINE_XML_FILES`.

| File | Protocol | Interfaces | Purpose |
|------|----------|-----------|---------|
| `treeland-remote-subsurface-unstable-v1.xml` | `treeland_remote_subsurface_unstable_v1` | `treeland_remote_subsurface_manager_v1`, `treeland_exported_surface_v1`, `treeland_remote_subsurface_v1` | Token-based cross-process sub-surface relationships (replaces wl_subcompositor for Wine) |
| `treeland-wine-window-management-unstable-v1.xml` | `treeland_wine_window_management_v1` | `treeland_wine_window_manager_v1`, `treeland_wine_window_control_v1` | Wine window positioning (SetWindowPos) and Z-order control (HWND_TOPMOST etc.) |
| `treeland-wine-window-state-unstable-v1.xml` | `treeland_wine_window_state_v1` | `treeland_wine_window_state_manager_v1`, `treeland_wine_window_state_v1` | Wine window state: minimize/unminimize, activation with focus-stealing prevention, attention hints (FlashWindowEx) |
