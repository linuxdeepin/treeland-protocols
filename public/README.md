# Public Protocols

For general application developers. Installed via `TREELAND_PROTOCOL_XML_FILES`.

| File | Protocol | Interfaces | Purpose |
|------|----------|-----------|---------|
| `treeland-window-transition-unstable-v1.xml` | `treeland_window_transition_unstable_v1` | `treeland_window_transition_manager_v1`, `treeland_window_transition_rect_v1` | Window open/close transition relative to a rectangle, with optional source image |
| `treeland-dde-shell-v1.xml` | `treeland_dde_shell_v1` | `treeland_dde_shell_manager_v1`, `treeland_window_overlap_checker` (deprecated), `treeland_dde_shell_surface_v1`, `treeland_dde_active_v1` (deprecated), `treeland_multitaskview_v1`, `treeland_window_picker_v1`, `treeland_lockscreen_v1` | DDE shell integration: surface roles, overlap detection, active events, multitask view, window picker, lockscreen; the `treeland_dde_active_v1` and `treeland_window_overlap_checker` interfaces and the `set_xwindow_position_relative` request are deprecated and non-functional, superseded by `dde/treeland-active-notify-unstable-v1.xml`, `dde/treeland-window-overlap-checker-unstable-v1.xml`, and `dde/treeland-xwindow-control-unstable-v1.xml` |
| `treeland-appearance-unstable-v1.xml` | `treeland_appearance_unstable_v1` | `treeland_appearance_v1` | Query and observe user-level appearance settings: cursor theme/size, fonts, icon theme, accent color, window opacity, color scheme, titlebar height, corner radius |
| `treeland-decoration-unstable-v1.xml` | `treeland_decoration_unstable_v1` | `treeland_decoration_manager_v1`, `treeland_decoration_context_v1` | Per-window server-side decoration (SSD) customization by applications: corner radius, shadow, border, titlebar visibility; requires xdg-decoration SSD |
## Breaking changes

Breaking changes are grouped by version. Under each version heading, one subsection per affected protocol explains what changed, what replaces it, and how existing consumers should adapt.

### 0.7.0

#### `treeland-dde-shell-v1.xml`

The manager request `set_xwindow_position_relative` and the `treeland_dde_active_v1` and `treeland_window_overlap_checker` interfaces (with their creating manager requests `get_treeland_dde_active` and `get_window_overlap_checker`) are now documented as deprecated and non-functional: they have no effect and no events are ever emitted. The file itself stays in place for now; the whole `treeland-dde-shell` protocol is slated for removal in a future release.

They are superseded by three new independent protocols in `dde/`:
- `treeland-xwindow-control-unstable-v1.xml` (`treeland_xwindow_control_v1`): XWayland window placement — the `set_xwindow_position_relative` request with `wl_callback` result feedback, unchanged wire semantics.
- `treeland-active-notify-unstable-v1.xml` (`treeland_active_notify_manager_v1`, `treeland_active_notify_v1`): seat activity notification — the `get_active_notify` request creates a per-seat notifier whose `activity_enter`/`activity_leave` events carry a `reason` enum (renamed from `active_in`/`active_out`), plus `start_drag`/`drop` events.
- `treeland-window-overlap-checker-unstable-v1.xml` (`treeland_window_overlap_checker_manager_v1`, `treeland_window_overlap_checker_v1`): window overlap monitoring — edge-anchored region registration (`set_region`) with `enter`/`leave` state events and explicit error reporting; the checker interface is renamed from `treeland_window_overlap_checker`, gaining the `_v1` suffix, and the region-setting request is renamed from `update` to `set_region`.

Consumers should bind the new globals instead of using the deprecated manager requests and interfaces; the deprecated requests and interfaces must not be used in new code.

### 0.6.0

#### `treeland-personalization-manager-v1.xml`

Split from `dde/treeland-personalization-manager-v1.xml`. The protocol is split by audience into three role-scoped protocols:
- `treeland-decoration-unstable-v1.xml` (in `public/`): per-window server-side decoration (SSD) customization (corner radius, shadow, border, titlebar visibility); requires xdg-decoration server-side decorations first, enabling a "half-CSD, half-SSD" configuration.
- `treeland-appearance-unstable-v1.xml` (in `public/`): read-only user-level appearance querying and observation for all regular applications.
- `treeland-appearance-manager-unstable-v1.xml` (in `dde/`): privileged user-level appearance configuration for the desktop control center and system settings components.

Per-window background blur should use the upstream `ext-background-effect-v1` protocol (staging in wayland-protocols) instead; it advertises its blur capability via the `capabilities` event. The `wallpaper` blend mode of the old protocol is deprecated without replacement; consumers must not rely on it.

The old v1 file is moved to `deprecated/` unchanged. Consumers should adopt the role-scoped replacement protocols and the upstream `ext-background-effect-v1`; the old XML is kept installed during migration but must not be used in new code.

#### `treeland-capture-unstable-v1.xml`

Removed from `public/`. Replaced by upstream `ext-image-capture-source-v1` and `ext-image-copy-capture-v1`; this protocol is deprecated and the file moved to `deprecated/`. Consumers should adopt the upstream `ext-image-capture-*` protocols instead; the deprecated XML is kept installed during migration but must not be used in new code.
