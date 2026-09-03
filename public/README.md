# Public Protocols

For general application developers. Installed via `TREELAND_PROTOCOL_XML_FILES`.

| File | Protocol | Interfaces | Purpose |
|------|----------|-----------|---------|
| `treeland-dde-shell-v1.xml` | `treeland_dde_shell_v1` | `treeland_dde_shell_manager_v1`, `treeland_window_overlap_checker`, `treeland_dde_shell_surface_v1`, `treeland_dde_active_v1`, `treeland_multitaskview_v1`, `treeland_window_picker_v1`, `treeland_lockscreen_v1` | DDE shell integration: surface roles, overlap detection, active events, multitask view, window picker, lockscreen |
| `treeland-appearance-unstable-v1.xml` | `treeland_appearance_unstable_v1` | `treeland_appearance_v1` | Query and observe user-level appearance settings: cursor theme/size, fonts, icon theme, accent color, window opacity, color scheme, titlebar height, corner radius |
| `treeland-decoration-unstable-v1.xml` | `treeland_decoration_unstable_v1` | `treeland_decoration_manager_v1`, `treeland_decoration_context_v1` | Per-window server-side decoration (SSD) customization by applications: corner radius, shadow, border, titlebar visibility; requires xdg-decoration SSD |
## Breaking changes

Breaking changes are grouped by version. Under each version heading, one subsection per affected protocol explains what changed, what replaces it, and how existing consumers should adapt.

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
