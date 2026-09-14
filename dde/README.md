# DDE Desktop Component Protocols

For DDE desktop components. Installed via `TREELAND_PROTOCOL_DDE_XML_FILES`.

| File | Protocol | Interfaces | Purpose |
|------|----------|-----------|---------|
| `treeland-foreign-toplevel-manager-unstable-v2.xml` | `treeland_foreign_toplevel_manager_unstable_v2` | `treeland_foreign_toplevel_manager_v2`, `treeland_foreign_toplevel_handle_v2`, `treeland_dock_preview_context_v2` | Redesigned toplevel observation and dock preview; fixes naming, member ordering, destroy placement, and description quality relative to v1 |
| `treeland-input-manager-unstable-v1.xml` | `treeland_input_manager_unstable_v1` | `treeland_input_manager_v1`, `treeland_pointer_device_configuration_v1`, `treeland_mouse_settings_v1`, `treeland_touchpad_settings_v1`, `treeland_keyboard_settings_v1` | Per-device input configuration: pointer acceleration, send-events mode, keyboard toggle state |
| `treeland-keyboard-state-notify-unstable-v1.xml` | `treeland_keyboard_state_notify_unstable_v1` | `treeland_keyboard_state_notify_manager_v1`, `treeland_keyboard_state_watcher_v1` | Watch keyboard modifier (caps/num lock) state changes |
| `treeland-output-manager-unstable-v2.xml` | `treeland_output_manager_unstable_v2` | `treeland_output_manager_v2`, `treeland_output_picture_control_v2` | Primary output designation, per-output color temperature and brightness control; outputs addressed by uuid |
| `treeland-shortcut-manager-unstable-v3.xml` | `treeland_shortcut_manager_unstable_v3` | `treeland_shortcut_manager_v3`, `treeland_shortcut_capture_v3` | Global keyboard shortcut binding with key/touch/multi-touch gesture support and one-shot shortcut capture |
| `treeland-appearance-manager-unstable-v1.xml` | `treeland_appearance_manager_unstable_v1` | `treeland_appearance_manager_v1` | Privileged user-level appearance configuration: cursor theme/size, global font, icon theme, accent color, window opacity, color scheme, titlebar height, global corner radius |
| `treeland-output-uuid-unstable-v1.xml` | `treeland_output_uuid_unstable_v1` | `treeland_output_uuid_manager_v1`, `treeland_output_uuid_v1` (frozen) | Stable opaque uuid identity for `wl_output` objects; the uuid is shared with the head variant and consumed by other output protocols |
| `treeland-output-uuid-head-unstable-v1.xml` | `treeland_output_uuid_head_unstable_v1` | `treeland_output_uuid_head_manager_v1` | Companion to `treeland-output-uuid-unstable-v1`: obtain the same `treeland_output_uuid_v1` object from a `zwlr_output_head_v1` (wlr-output-management), including disabled outputs with no live `wl_output` |
| `treeland-output-mirror-manager-unstable-v1.xml` | `treeland_output_mirror_manager_unstable_v1` | `treeland_output_mirror_manager_v1`, `treeland_output_mirror_group_v1` | Output mirroring (copy mode) groups: designate a source output mirrored to one or more mirror outputs, addressed by uuid, with registry-pattern enumeration |
| `treeland-wallpaper-manager-unstable-v1.xml` | `treeland_wallpaper_manager_unstable_v1` | `treeland_wallpaper_manager_v1`, `treeland_wallpaper_v1` | Per-output wallpaper configuration with image/video sources |
| `treeland-show-desktop-unstable-v1.xml` | `treeland_show_desktop_unstable_v1` | `treeland_show_desktop_v1` | Show-desktop mode control: request mode transitions and observe compositor-driven state changes |
| `treeland-layer-shell-extension-unstable-v1.xml` | `treeland_layer_shell_extension_unstable_v1` | `treeland_layer_shell_extension_manager_v1`, `treeland_layer_shell_extension_object_v1` | Compositor-driven interactive resize for layer-shell surfaces (dock / side bar / status bar): begin_resize with seat+serial, per-resize size limits, and rejection reasons |

## Breaking changes

Breaking changes are grouped by version. Under each version heading, one subsection per affected protocol explains what changed, what replaces it, and how existing consumers should adapt.

### 0.7.0

#### `treeland-output-manager-v1.xml`

Superseded by `treeland-output-manager-unstable-v2.xml`; the old v1 file moved to `deprecated/` unchanged. The v2 protocol renames both interfaces, normalizes member ordering, and addresses outputs by opaque uuid strings from the new `treeland-output-uuid-unstable-v1` protocol instead of output names or `wl_output` objects. Wire-level differences:

1. Interfaces renamed: `treeland_output_manager_v1` → `treeland_output_manager_v2` and `treeland_output_color_control_v1` → `treeland_output_picture_control_v2`; interface versions reset to 1.
2. `destroy` moved to the first request on both interfaces, shifting the opcodes of all other requests by one.
3. `set_primary_output` takes a `string uuid` instead of an output name or `wl_output` object; an empty uuid is a fatal `error.invalid_uuid`, and a uuid with no connected enabled output is rejected via the `primary_output_failed` event (reason `invalid_output`).
4. The `primary_output` event carries a `string uuid` (empty when no primary output is designated) instead of an output name or `wl_output` object, is emitted once on bind, and confirms every `set_primary_output` request.
5. `get_picture_control` takes a `string uuid`; an empty uuid, or a uuid with no recognized connected output, is a fatal `error.invalid_uuid` (the object is not created, so the initial-state contract holds).
6. The `result` event argument changed from a plain `uint` flag (1 = success, 0 = failure) to the `commit_result` enum (`success = 0`, `failed = 1`, `unsupported = 2`, `invalid_output = 3`), so the wire values are inverted.

Consumers should rebind the global as `treeland_output_manager_v2`, obtain output uuids from `treeland_output_uuid_manager_v1.get_uuid`, pass uuid strings instead of output names or `wl_output` objects, and interpret `result` values via the `commit_result` enum.

#### `treeland-virtual-output-manager-v1.xml`

Superseded by `treeland-output-mirror-manager-unstable-v1.xml`; the old v1 file moved to `deprecated/` unchanged. The protocol was redesigned around uuid-based output identity instead of output-name strings, with explicit source/mirror separation, a registry-pattern enumeration model, and fully specified object lifecycles. Wire-level differences:

1. Protocol and interfaces renamed: `treeland_virtual_output_manager_v1` → `treeland_output_mirror_manager_unstable_v1`, with interfaces `treeland_virtual_output_manager_v1` → `treeland_output_mirror_manager_v1` and `treeland_virtual_output_v1` → `treeland_output_mirror_group_v1`; interface versions reset to 1.
2. Output identity switched from name strings to uuids: the `name`/`outputs` `string`/`array` arguments of `create_virtual_output`, the `names` `array` argument of the `virtual_output_list` event, and the `outputs` `array` argument of the `outputs` event are all removed. The new `create_group` request takes a group `name` `string` and an initial `source` uuid `string` (empty for no source), so a group is created with its source already set and observers never see an empty-source group; mirrors are added with `add_output` and the source changed with `set_source`. Outputs are referenced by uuid strings on the group's `set_source`, `add_output`, and `remove_output` requests and on its `source`, `output_added`, and `output_removed` events. The old `outputs[0] = source, outputs[1..] = mirrors` positional convention is replaced by an explicit `set_source` request and an ordered `add_output`/`remove_output` mirror list, with the `source` event reporting the current source uuid (empty when the group has no source). A non-empty source that does not identify a connected enabled output is rejected with the new fatal manager error `invalid_source`.
3. Enumeration replaced by a registry push model: the `get_virtual_output_list` request and the `virtual_output_list` snapshot event are removed. On binding the manager the compositor emits one `group_added` event (carrying a fresh group object) per existing group, and again whenever a group is created; `group_removed` is emitted when a group is dissolved. This removes the list-then-lookup TOCTOU window.
4. The `get_virtual_output` request is removed; clients obtain handles to existing groups from the bind-time `group_added` dump or from later `group_added` events, so the unknown-name fatal-error path no longer exists.
5. The per-group `error` event is removed. Failures are split by severity: manager errors `invalid_name` (empty, non-UTF-8, or NUL-containing name) and `name_exists` (duplicate) are fatal protocol errors; group business failures — `invalid_output`, `duplicate_output`, `output_in_use`, `not_in_group` — are non-fatal and reported via the new `operation_failed` event (code + uuid), so transient output state like an unplug between `get_uuid` and the request does not terminate the connection. Only `already_dissolved` (any request other than `destroy` on a dissolved group) remains a fatal group protocol error. The old codes `invalid_group_name` (0), `invalid_screen_number` (1), and `invalid_output` (2) no longer exist.
6. Object lifecycle redefined: destroying a group object (`destroy`) now only releases that client's handle and does not dissolve the group or affect other clients; a separate `dissolve` request tears down the group, emitting `removed` to all bound group objects and `group_removed` on the manager. The old behavior, where any client destroying its `treeland_virtual_output_v1` object (including one obtained via `get_virtual_output`) dissolved the group, is removed. Initial state is now pushed: a `source` event (empty uuid when no source) followed by one `output_added` per mirror is emitted immediately on every group object's creation, so clients no longer start with unknown state.
7. Source-successor behavior on hardware removal is retained and made explicit: when the source output is unplugged or disabled and mirrors remain, the first remaining mirror becomes the new source (the compositor emits `output_removed` then `source` for it); client-driven `remove_output` of the source instead clears it (emits `source` with an empty uuid) and does not auto-select a successor.

Consumers should rebind the global as `treeland_output_mirror_manager_v1`, obtain `treeland_output_mirror_group_v1` objects from the `group_added` event (or as the return value of `create_group`), reference outputs by uuid via `set_source`/`add_output`/`remove_output`, and dissolve groups with `dissolve` rather than by destroying a group object; the old v1 XML is kept installed during migration but must not be used in new code.

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
6. **Numeric representation normalized (wire-incompatible)**:
   - `window_opacity`: the old `uint` value with no defined range is now a `fixed` value in `[0.0, 1.0]` (1.0 fully opaque, 0.0 fully transparent). Both the `set_window_opacity` request argument and the `window_opacity` event argument changed type and scale; consumers must switch from integer percentage handling to fixed-point.
   - `active_color`: the old single `string` argument (a color description) is now four `uint` components `r, g, b, a` in `[0, 255]`, on both the `set_accent_color` request and the `accent_color` event.

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

#### `treeland-foreign-toplevel-manager-v1.xml`

Superseded by `treeland-foreign-toplevel-manager-unstable-v2.xml`; the old v1 file moved to `deprecated/`. The protocol was redesigned with corrected naming, member ordering, and improved descriptions. Compared to the old `treeland_foreign_toplevel_manager_v1` interface:

1. Naming corrected: `unstable` added to the file and protocol name; the three interfaces were bumped to `_v2`.
2. A `destroy` destructor request is now the first request on all three interfaces (newly added on the manager, moved to first on the other two).
3. Enums were moved before requests.
4. Events were moved after requests.
5. The `finished` event was changed from a destructor event to a plain event, and the `stop` request no longer forbids all further requests. The compositor no longer destroys the manager object automatically; the client must send `destroy` explicitly, ideally after `stop` and `finished`.
6. The `set_rectangle` request was renamed to `set_icon_geometry`, and the `invalid_rectangle` error entry was renamed to `invalid_geometry`.
7. The dock preview `show` request's `surfaces` argument was renamed to `identifiers` to reflect that it carries uint32 toplevel identifiers, not wl_surface objects.
8. A manager `error` enum was added with `invalid_surface`, raised when the `relative_surface` passed to `get_dock_preview_context` is not a valid wl_surface owned by the calling client.
9. The description was corrected and expanded.

Consumers should rebind the global as `treeland_foreign_toplevel_manager_v2`, obtain `treeland_foreign_toplevel_handle_v2` objects from the `toplevel` event, and use `treeland_dock_preview_context_v2` for previews; the old v1 XML is kept installed during migration but must not be used in new code.
#### `treeland-shortcut-manager-v2.xml`

Superseded by `treeland-shortcut-manager-unstable-v3.xml`; the old v2 file moved to `deprecated/` unchanged. The protocol was renamed to follow the unstable naming convention, and the interfaces were renamed to match the new major version. Compared to the old `treeland_shortcut_manager_v2` interface:

1. The protocol was renamed to `treeland_shortcut_manager_unstable_v3`; the interfaces were renamed to `treeland_shortcut_manager_v3` and `treeland_shortcut_capture_v3`.
2. The manager interface version was reset from 3 to 1 and all `since` attributes were removed (they marked members added across v2 interface versions 2 and 3: `capture_next_shortcut`, the `invalid_surface` error, and the `tile_left`/`tile_right` actions).
3. The `action` enum was restructured and renumbered: `quit` and `taskswitch_enter` were removed (`quit` is no longer exposed as a shortcut; the task switcher is entered implicitly by the `taskswitch_next`/`taskswitch_prev` actions); the direct-switch set was expanded from `workspace_1`..`workspace_6` to `workspace_1`..`workspace_12`; and 14 new actions were added — `minimize`, `resize_window`, `move_window_to_prev_workspace`, `move_window_to_next_workspace`, `zoom_in`/`zoom_out`/`zoom_reset`, and the tiling snap family `tile_top`/`tile_bottom`/`tile_top_left`/`tile_top_right`/`tile_bottom_left`/`tile_bottom_right`. Entries were regrouped into logical families (notify, workspace switching, window state, window operations, cross-workspace move, show-desktop/multitask, task switching, tiling, screen zoom, system), so every action value changed; `notify` is now 0 and `shutdown_menu` is now 45. Some newly added actions may not yet be implemented by every compositor build; binding such an action is accepted but has no effect until implemented.
4. The commit mechanism was removed: `bind_key`, `bind_swipe_gesture`, and `bind_hold_gesture` take effect immediately, a rejected bind is reported per binding via the new `bind_failure` event, and the `commit` request, the `commit_success` and `commit_failure` events, and the `error.invalid_commit` entry no longer exist. The `error.invalid_surface` entry was renumbered from 4 to 3. Unlike the old model, one failing binding no longer rolls back the other bindings of the same batch.
5. Documentation was refined (no wire change): destroying the manager object is now documented to implicitly release the exclusive control acquired via `acquire`, and the `capture_next_shortcut` request and the capture interface semantics were rewritten to match the compositor implementation (trigger timing, seat/focus validation, the `busy`/`aborted` failure conditions, and the valid-shortcut rules).

Consumers should rebind the global as `treeland_shortcut_manager_v3`, send `acquire` before any bind or unbind request, and create capture objects via `capture_next_shortcut`; the old v2 XML is kept installed during migration but must not be used in new code.
