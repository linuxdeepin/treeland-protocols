# DDE Desktop Component Protocols

For DDE desktop components. Installed via `TREELAND_PROTOCOL_DDE_XML_FILES`.

| File | Protocol | Interfaces | Purpose |
|------|----------|-----------|---------|
| `treeland-foreign-toplevel-manager-unstable-v2.xml` | `treeland_foreign_toplevel_manager_unstable_v2` | `treeland_foreign_toplevel_manager_v2`, `treeland_foreign_toplevel_handle_v2`, `treeland_dock_preview_context_v2` | Redesigned toplevel observation and dock preview; fixes naming, member ordering, destroy placement, and description quality relative to v1 |
| `treeland-input-manager-unstable-v1.xml` | `treeland_input_manager_unstable_v1` | `treeland_input_manager_v1`, `treeland_pointer_device_configuration_v1`, `treeland_mouse_settings_v1`, `treeland_touchpad_settings_v1`, `treeland_keyboard_settings_v1` | Per-device input configuration: pointer acceleration, send-events mode, keyboard toggle state, and XKB keymap settings |
| `treeland-keyboard-state-notify-unstable-v1.xml` | `treeland_keyboard_state_notify_unstable_v1` | `treeland_keyboard_state_notify_manager_v1`, `treeland_keyboard_state_watcher_v1` | Watch keyboard modifier (caps/num lock) state changes |
| `treeland-output-manager-unstable-v2.xml` | `treeland_output_manager_unstable_v2` | `treeland_output_manager_v2`, `treeland_output_picture_control_v2` | Primary output designation, per-output color temperature and brightness control; outputs addressed by uuid |
| `treeland-shortcut-manager-unstable-v3.xml` | `treeland_shortcut_manager_unstable_v3` | `treeland_shortcut_manager_v3`, `treeland_shortcut_capture_v3` | Global keyboard shortcut binding with key/touch/multi-touch gesture support and one-shot shortcut capture |
| `treeland-compositor-action-unstable-v1.xml` | `treeland_compositor_action_unstable_v1` | `treeland_compositor_action_v1` | One-shot privileged triggering of window-independent compositor actions: workspace switching, show-desktop, multitask overview, screen zoom, FPS overlay, lockscreen, shutdown menu, user switch; window-level and task-switch actions are intentionally excluded and remain only as shortcuts in `treeland_shortcut_manager_v3` |
| `treeland-appearance-manager-unstable-v1.xml` | `treeland_appearance_manager_unstable_v1` | `treeland_appearance_manager_v1` | Privileged user-level appearance configuration: cursor theme/size, global font, icon theme, accent color, window opacity, color scheme, titlebar height, global corner radius |
| `treeland-output-group-manager-unstable-v1.xml` | `treeland_output_group_manager_unstable_v1` | `treeland_output_group_manager_v1`, `treeland_output_group_v1` | Output mirroring (copy mode) groups: designate a source output mirrored to one or more mirror outputs, addressed by uuid, with registry-pattern enumeration |
| `treeland-wallpaper-manager-unstable-v1.xml` | `treeland_wallpaper_manager_unstable_v1` | `treeland_wallpaper_manager_v1`, `treeland_wallpaper_v1` | Per-output wallpaper configuration with image/video sources |
| `treeland-layer-shell-extension-unstable-v1.xml` | `treeland_layer_shell_extension_unstable_v1` | `treeland_layer_shell_extension_manager_v1`, `treeland_layer_shell_extension_object_v1` | Compositor-driven interactive resize for layer-shell surfaces (dock / side bar / status bar): begin_resize with seat+serial, per-resize size limits, and rejection reasons |
| `treeland-xwindow-control-unstable-v1.xml` | `treeland_xwindow_control_unstable_v1` | `treeland_xwindow_control_v1` | XWayland window placement: move an XWayland window (by X11 window ID) to a position relative to another surface, with wl_callback result feedback |
| `treeland-active-notify-unstable-v1.xml` | `treeland_active_notify_unstable_v1` | `treeland_active_notify_manager_v1`, `treeland_active_notify_v1` | Seat activity notification: observe pointer button/wheel enter/leave activity and drag/drop lifecycle events scoped to a seat |
| `treeland-region-watch-unstable-v1.xml` | `treeland_region_watch_unstable_v1` | `treeland_region_watch_manager_v1`, `treeland_region_watch_v1` | Edge-anchored region overlap watch: register an edge-anchored region on an output and observe enter/leave overlap events with xdg-shell toplevels |
| `treeland-dde-shell-unstable-v2.xml` | `treeland_dde_shell_unstable_v2` | `treeland_dde_shell_manager_v2`, `treeland_dde_shell_surface_v2` | DDE shell surface role: turn a wl_surface into a shell surface rendered at the workspace overlay level (above normal toplevels, below layer-shell surfaces) or at the normal window layer, suggest an initial position relative to an output or the cursor, and declare switcher/dock-preview/multitask-view listing preferences via a skip bitfield |

## Breaking changes

Breaking changes are grouped by version. Under each version heading, one subsection per affected protocol explains what changed, what replaces it, and how existing consumers should adapt.

### 0.8.0

#### `treeland-virtual-output-manager-v1.xml`

Superseded by `treeland-output-group-manager-unstable-v1.xml`; the old v1 file moved to `deprecated/` unchanged. The protocol was redesigned around uuid-based output identity, compositor-assigned group names, persisted configuration, and a registry-pattern enumeration model. Wire-level differences:

1. Protocol and interfaces renamed: `treeland_virtual_output_manager_v1` → `treeland_output_group_manager_unstable_v1`, with interfaces `treeland_virtual_output_manager_v1` → `treeland_output_group_manager_v1` and `treeland_virtual_output_v1` → `treeland_output_group_v1`; interface versions reset to 1.
2. Groups are addressed by compositor-assigned names instead of client-supplied ones: `create_group` takes only the initial `source` uuid (empty for no source) and the compositor reports the name it picked through the new `name` event, emitted before any other event on the object; a new `get_group` request obtains a group object by that name. The `name` argument of `create_virtual_output` and the `invalid_group_name`/`name_exists` manager errors are removed.
3. Output identity switched from name strings to uuids: the `name`/`outputs` arguments of `create_virtual_output`, the `names` array of `virtual_output_list`, and the `outputs` array of the `outputs` event are gone. Outputs are referenced by uuid strings on `set_source`, `add_output`, and `remove_output`, and on the `state` event (empty source when the group has no available source). The old `outputs[0] = source, outputs[1..] = mirrors` positional convention is replaced by an explicit source plus an ordered mirror list.
4. Mirror uuids come from `treeland-output-uuid-head-unstable-v1`, not `treeland-output-uuid-unstable-v1`: while copy mode is engaged the compositor exposes a `wl_output` only for the source output, so mirror outputs cannot be identified through `wl_output`-based protocols.
5. Enumeration replaced by a registry push model: `get_virtual_output_list` and the `virtual_output_list` snapshot event are removed; `get_virtual_output` is replaced by `get_group`. On binding the manager the compositor emits one `group_added` event carrying the name of each existing group, followed by a single `groups_done` event, and `group_added` again whenever any client creates a group, while `group_removed` (carrying the group name) is emitted when a group is dissolved. `group_added` carries only the group name, not a `new_id` object; clients obtain a group object with `get_group`. This removes the list-then-lookup TOCTOU window.
6. Incremental mirror events are replaced by a single full-state event: `output_added`/`output_removed` are gone, and a single `state` event carries the effective source uuid plus a count and the concatenated fixed-length uuids of the mirrors in list order on creation and after every change. A new `done` event on each group object marks the end of the initial state batch (`name`, `state`, `done`).
7. Changes are queued and committed: `set_source`, `add_output`, and `remove_output` no longer take effect immediately; they queue changes that a new `commit` request applies in queue order. A failed change is skipped with an `operation_failed` event and the remaining changes are still applied. The `state` event is emitted once per commit that changes the effective state. Queued changes do not reserve outputs: an output queued in another group is not treated as in use until that group commits, so when two groups queue the same output the first to commit wins and the other is reported with `output_in_use`.
8. Configuration is persisted and separated from effective state: the compositor stores each group's name, configured source, and configured mirror list across restarts and restores them on startup, so groups reappear as `group_added` on bind and auto-resume when their outputs return. The single `state` event reports effective runtime state only — an unplugged or disabled output stays configured but disappears from it. When the configured source becomes unavailable the compositor auto-promotes the first available mirror (the earliest in the configured mirror list order) to the effective source; whether the promotion is temporary (the configured source reclaims the role when it returns) or permanent (the selected output becomes the new configured source) is a compositor implementation detail. To pin an auto-promoted mirror as the permanent source a client calls `set_source` with its uuid and then commits; the change succeeds idempotently when that output is the current effective source.
9. Failures are all non-fatal on the manager: the per-group `error` event and the codes `invalid_group_name` (0), `invalid_screen_number` (1), and `invalid_output` (2) are removed, and the manager has no fatal `error` enum. Business failures — `invalid_output`, `duplicate_output`, `output_in_use`, `not_in_group`, `invalid_name` — are reported through the new `operation_failed` event (code + uuid), so no failure terminates the connection. A failed `create_group` source still creates the group with an empty source; an invalid `get_group` name still creates the object, but it is an invalid group object that receives no `name` or `state` event and rejects every request except `destroy`. Only `already_dissolved` — sending any request other than `destroy` on a dissolved group — remains a fatal protocol error.
10. Object lifecycle redefined: `destroy` only releases that client's handle and neither dissolves the group nor emits `group_removed`; a separate `dissolve` request tears the group down, discarding any queued changes, emitting `removed` on every bound group object and `group_removed` on the manager. Initial state is pushed on every group object as one batch: `name`, then `state`, then `done`; a failed `create_group` source inserts an `operation_failed` before `done`, and an invalid `get_group` object receives only `operation_failed` then `done`.

Consumers should rebind the global as `treeland_output_group_manager_v1`, address groups by the compositor-assigned name from the `name` event (or `get_group`), obtain mirror uuids from `treeland-output-uuid-head-unstable-v1`, queue changes with `set_source`/`add_output`/`remove_output` and apply them with `commit`, read the effective source and mirror list from the `state` event (and wait for `done` before acting on initial state), and dissolve groups with `dissolve` rather than by destroying a group object; the old v1 XML is kept installed during migration but must not be used in new code.

### 0.7.0

#### `treeland-appearance-manager-unstable-v1.xml`

The `set_accent_color` request dropped its `a` (alpha) argument. The accent color is now an opaque RGB triple `r, g, b` (each `uint` in `[0, 255]`); the alpha channel is no longer carried on the wire. Consumers must stop sending the trailing `a` argument and must not interpret accent color opacity from this request; opacity is outside the scope of the accent color setting.

#### `treeland-show-desktop-unstable-v1.xml`

Deprecated and moved to `deprecated/`; superseded by the `show_desktop` action of the `treeland_compositor_action_v1` global of `treeland-compositor-action-unstable-v1.xml` (in `dde/`). Wire-level differences:

1. The replacement is a one-shot fire-and-forget trigger: the `show_desktop` action toggles show-desktop mode and the compositor sends no confirmation, whereas `set_show_desktop_state` requested an explicit transition to `show` or `normal` and the `show_desktop_state` event confirmed every state change.
2. State observation has no direct replacement: the new protocol carries no events, so clients that tracked the mode via `show_desktop_state` (including the initial state sent on bind) lose that feedback and must treat triggering as best-effort.
3. The replacement global is privileged: only the DDE clients allowed by the compositor may bind `treeland_compositor_action_v1`, whereas `treeland_show_desktop_v1` was bound by regular shell clients.

Consumers should rebind the global as `treeland_compositor_action_v1` and trigger the `show_desktop` action; the old XML is kept installed during migration but must not be used in new code.

#### `treeland-dde-shell-v1.xml`

The DDE-shell protocol interfaces consumed by DDE components are split into dedicated `dde/` protocols. Each replacement is an independent privileged global; consumers should bind the new globals and stop using the deprecated dde-shell interfaces.

- `treeland_dde_active_v1` (and its `get_treeland_dde_active` manager request) is non-functional and superseded by `treeland-active-notify-unstable-v1.xml` (`treeland_active_notify_manager_v1` / `treeland_active_notify_v1`): `get_active_notify` creates a per-seat notifier whose `activity_changed` event carries a `reason` enum and an `activity_state` enum (renamed from `active_in`/`active_out`; mouse tracks the left-button state, wheel is a per-event pulse), plus a `drag_changed` event carrying a `drag_state` enum (started/dropped/cancelled).
- `treeland_window_overlap_checker` (and its `get_window_overlap_checker` manager request) is non-functional and superseded by `treeland-region-watch-unstable-v1.xml` (`treeland_region_watch_manager_v1` / `treeland_region_watch_v1`): the watcher interface gains the `_v1` suffix, the region request is renamed from `update` to `set_region` with an explicit `anchor` enum and `invalid_anchor`/`invalid_size` errors, and `output_removed` covers output lifetime.
- `treeland_multitaskview_v1` and `treeland_lockscreen_v1` (with their creating requests) are superseded by the corresponding actions (`toggle_multitask_view`/`open_multitask_view`/`close_multitask_view` and `lockscreen`/`shutdown_menu`/`show_user_switch`) of `treeland-compositor-action-unstable-v1.xml` (`treeland_compositor_action_v1`).
- `treeland_dde_shell_surface_v1` (and its `get_shell_surface` manager request) is superseded by `treeland-dde-shell-unstable-v2.xml` (`treeland_dde_shell_manager_v2` / `treeland_dde_shell_surface_v2`), in `dde/`; the surface role is carried over with a `role` enum that adds `normal` (0) while keeping `overlay` (1), and a merged `set_skip_flags` bitfield.

#### `treeland-output-manager-v1.xml`

Superseded by `treeland-output-manager-unstable-v2.xml`; the old v1 file moved to `deprecated/` unchanged. The v2 protocol renames both interfaces, normalizes member ordering, and addresses outputs by opaque uuid strings from the new `treeland-output-uuid-unstable-v1` protocol instead of output names or `wl_output` objects. Wire-level differences:

1. Interfaces renamed: `treeland_output_manager_v1` → `treeland_output_manager_v2` and `treeland_output_color_control_v1` → `treeland_output_picture_control_v2`; interface versions reset to 1.
2. `destroy` moved to the first request on both interfaces, shifting the opcodes of all other requests by one.
3. `set_primary_output` takes a `string uuid` instead of an output name or `wl_output` object; an empty uuid or a uuid with no connected enabled output is rejected via the non-fatal `primary_output_failed` event (reason `invalid_output`), leaving the designation unchanged.
4. The `primary_output` event carries a `string uuid` (empty when no primary output is designated) instead of an output name or `wl_output` object, is emitted once on bind, and confirms every `set_primary_output` request.
5. `get_picture_control` takes a `string uuid`; the object is created even for an empty or currently unknown uuid (no fatal protocol error is raised), and its commits fail with `commit_result.invalid_output` until the uuid identifies a live enabled output.
6. The `result` event argument changed from a plain `uint` flag (1 = success, 0 = failure) to the `commit_result` enum (`success = 0`, `failed = 1`, `unsupported = 2`, `invalid_output = 3`), so the wire values are inverted.

Consumers should rebind the global as `treeland_output_manager_v2`, obtain output uuids from `treeland_output_uuid_manager_v1.get_uuid`, pass uuid strings instead of output names or `wl_output` objects, and interpret `result` values via the `commit_result` enum.

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
5. Documentation was refined (no wire change): destroying the manager object is documented to implicitly release the exclusive control acquired via `acquire`, and the `capture_next_shortcut` request and the capture interface semantics were rewritten to match the compositor implementation (trigger timing, seat/focus validation, the `busy`/`aborted` failure conditions, and the valid-shortcut rules).

Consumers should rebind the global as `treeland_shortcut_manager_v3`, send `acquire` before any bind or unbind request, and create capture objects via `capture_next_shortcut`; the old v2 XML is kept installed during migration but must not be used in new code.
