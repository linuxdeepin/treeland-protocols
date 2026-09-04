# DDE Desktop Component Protocols

For DDE desktop components. Installed via `TREELAND_PROTOCOL_DDE_XML_FILES`.

| File | Protocol | Interfaces | Purpose |
|------|----------|-----------|---------|
| `treeland-foreign-toplevel-manager-v1.xml` | `treeland_foreign_toplevel_manager_v1` | `treeland_foreign_toplevel_manager_v1`, `treeland_foreign_toplevel_handle_v1`, `treeland_dock_preview_context_v1` | Toplevel window observation, activation, state management, and dock preview |
| `treeland-input-manager-unstable-v1.xml` | `treeland_input_manager_unstable_v1` | `treeland_input_manager_v1`, `treeland_pointer_device_configuration_v1`, `treeland_mouse_settings_v1`, `treeland_touchpad_settings_v1`, `treeland_keyboard_settings_v1` | Per-device input configuration: pointer acceleration, send-events mode, keyboard toggle state |
| `treeland-keyboard-state-notify-unstable-v1.xml` | `treeland_keyboard_state_notify_unstable_v1` | `treeland_keyboard_state_notify_manager_v1`, `treeland_keyboard_state_watcher_v1` | Watch keyboard modifier (caps/num lock) state changes |
| `treeland-output-manager-v1.xml` | `treeland_output_manager_v1` | `treeland_output_manager_v1`, `treeland_output_color_control_v1` | Primary output selection, per-output color temperature and brightness control |
| `treeland-shortcut-manager-v2.xml` | `treeland_shortcut_manager_v2` | `treeland_shortcut_manager_v2`, `treeland_shortcut_capture_v1` | Global keyboard shortcut binding with key/touch/multi-touch gesture support |
| `treeland-appearance-manager-unstable-v1.xml` | `treeland_appearance_manager_unstable_v1` | `treeland_appearance_manager_v1` | Privileged user-level appearance configuration: cursor theme/size, global font, icon theme, accent color, window opacity, color scheme, titlebar height, global corner radius |
| `treeland-virtual-output-manager-v1.xml` | `treeland_virtual_output_manager_v1` | `treeland_virtual_output_manager_v1`, `treeland_virtual_output_v1` | Virtual (mirrored) output creation and management |
| `treeland-wallpaper-manager-unstable-v1.xml` | `treeland_wallpaper_manager_unstable_v1` | `treeland_wallpaper_manager_v1`, `treeland_wallpaper_v1` | Per-output wallpaper configuration with image/video sources |
| `treeland-show-desktop-unstable-v1.xml` | `treeland_show_desktop_unstable_v1` | `treeland_show_desktop_v1` | Show-desktop mode control: request mode transitions and observe compositor-driven state changes |

## Breaking changes

Breaking changes are grouped by version. Under each version heading, one subsection per affected protocol explains what changed, what replaces it, and how existing consumers should adapt.

### 0.6.0

#### `treeland-personalization-manager-v1.xml`

Superseded by `treeland-decoration-unstable-v1.xml` and `treeland-appearance-unstable-v1.xml` (in `public/`), and `treeland-appearance-manager-unstable-v1.xml` (in `dde/`); per-window background blur is handled by the upstream `ext-background-effect-v1` protocol. The old v1 file moved to `deprecated/` unchanged.

Key changes:
1. **Protocol split and role separation**:
   - Server-side decoration (SSD) customization (window corner radius, shadow, border, and server-side titlebar) is split into `treeland-decoration-unstable-v1.xml` (in `public/`). It requires xdg-decoration server-side decorations first and enables a "half-CSD, half-SSD" configuration (keep compositor border/corners/shadow while hiding its titlebar).
   - Per-window background blur is replaced by the upstream `ext-background-effect-v1` protocol (staging in wayland-protocols), which is decoration-mode independent and advertises its blur capability via the `capabilities` event. The `wallpaper` blend mode of the old protocol is deprecated without replacement; consumers must not rely on it.
   - Read-only user-level appearance querying and observation (cursor theme/size, fonts, icon theme, accent color, window opacity, color scheme, titlebar height, corner radius) is split into `treeland-appearance-unstable-v1.xml` (in `public/`) for all regular applications.
   - Privileged user-level appearance configuration (modifying cursor, fonts, and visual theming) is split into `treeland-appearance-manager-unstable-v1.xml` (in `dde/`) for desktop control center and system settings components.
2. **Push-model state synchronization**:
   - Removed redundant synchronous `get_*` query requests. The compositor pushes current values immediately upon context creation and broadcasts changes to all bound contexts.
3. **Cursor settings simplification**:
   - Removed `commit` request and `verfity` event. `set_theme` and `set_size` now take effect immediately, matching font and appearance context semantics.
4. **Color scheme enum renamed and refined**:
   - Renamed `theme_type` to `color_scheme` and removed `auto`, standardizing the enum to `light` (0) and `dark` (1); dynamic auto-switching policy is handled client-side.
5. **Standardized lifecycle and structure**:
   - Added explicit `type="destructor"` to `destroy` requests and moved them to the first request on each interface;
   - Placed all `enum` definitions before requests and all `event` definitions after requests.

#### `treeland-window-management-v1.xml`

Superseded by `treeland-show-desktop-unstable-v1.xml`; the old v1 file moved to `deprecated/`. The protocol was renamed to reflect its actual scope (show-desktop mode only). Compared to the old `treeland_window_management_v1` interface:

1. The interface was renamed to `treeland_show_desktop_v1`.
2. The `destroy` request was moved to the first request position.
3. The `show_desktop` event was renamed to `show_desktop_state`.
4. The `desktop_state` enum was renamed to `state`.
5. The `preview_show` enum entry was removed because it was never implemented and is no longer needed.
6. The `set_desktop` request was renamed to `set_show_desktop_state`.
7. The description was corrected and expanded.

Consumers should rebind the global as `treeland_show_desktop_v1`, send `set_show_desktop_state` to request a transition, and listen for `show_desktop_state` to observe compositor-driven changes; the old v1 XML is kept installed during migration but must not be used in new code.
