# DDE Desktop Component Protocols

For DDE desktop components. Installed via `TREELAND_PROTOCOL_DDE_XML_FILES`.

| File | Protocol | Interfaces | Purpose |
|------|----------|-----------|---------|
| `treeland-foreign-toplevel-manager-v1.xml` | `treeland_foreign_toplevel_manager_v1` | `treeland_foreign_toplevel_manager_v1`, `treeland_foreign_toplevel_handle_v1`, `treeland_dock_preview_context_v1` | Toplevel window observation, activation, state management, and dock preview |
| `treeland-input-manager-unstable-v1.xml` | `treeland_input_manager_unstable_v1` | `treeland_input_manager_v1`, `treeland_pointer_device_configuration_v1`, `treeland_mouse_settings_v1`, `treeland_touchpad_settings_v1`, `treeland_keyboard_settings_v1` | Per-device input configuration: pointer acceleration, send-events mode, keyboard toggle state |
| `treeland-keyboard-state-notify-unstable-v1.xml` | `treeland_keyboard_state_notify_unstable_v1` | `treeland_keyboard_state_notify_manager_v1`, `treeland_keyboard_state_watcher_v1` | Watch keyboard modifier (caps/num lock) state changes |
| `treeland-output-manager-v1.xml` | `treeland_output_manager_v1` | `treeland_output_manager_v1`, `treeland_output_color_control_v1` | Primary output selection, per-output color temperature and brightness control |
| `treeland-personalization-manager-v1.xml` | `treeland_personalization_manager_v1` | `treeland_personalization_manager_v1`, `treeland_personalization_cursor_context_v1`, `treeland_personalization_window_context_v1`, `treeland_personalization_font_context_v1`, `treeland_personalization_appearance_context_v1` | Cursor theme/size, per-window blend/shadow/border/titlebar, global font, global appearance (icon theme, active color, opacity, theme type, titlebar height) |
| `treeland-shortcut-manager-v2.xml` | `treeland_shortcut_manager_v2` | `treeland_shortcut_manager_v2`, `treeland_shortcut_capture_v1` | Global keyboard shortcut binding with key/touch/multi-touch gesture support |
| `treeland-virtual-output-manager-v1.xml` | `treeland_virtual_output_manager_v1` | `treeland_virtual_output_manager_v1`, `treeland_virtual_output_v1` | Virtual (mirrored) output creation and management |
| `treeland-wallpaper-manager-unstable-v1.xml` | `treeland_wallpaper_manager_unstable_v1` | `treeland_wallpaper_manager_v1`, `treeland_wallpaper_v1` | Per-output wallpaper configuration with image/video sources |
| `treeland-window-management-v1.xml` | `treeland_window_management_v1` | `treeland_window_management_v1` | Show-desktop mode control |
