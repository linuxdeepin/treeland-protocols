# Internal Protocols

Treeland compositor internals — not for general application developers. Installed via `TREELAND_PROTOCOL_INTERNAL_XML_FILES`.

| File | Protocol | Interfaces | Purpose |
|------|----------|-----------|---------|
| `treeland-app-id-resolver-unstable-v2.xml` | `treeland_app_id_resolver_unstable_v2` | `treeland_app_id_resolver_manager_v2`, `treeland_app_id_resolver_v2` | Resolve process (pidfd) to application ID for sandboxed apps |
| `treeland-prelaunch-splash-unstable-v2.xml` | `treeland_prelaunch_splash_unstable_v2` | `treeland_prelaunch_splash_manager_v2`, `treeland_prelaunch_splash_v2` | Application pre-launch splash screen control |
| `treeland-screensaver-unstable-v2.xml` | `treeland_screensaver_unstable_v2` | `treeland_screensaver_v2` | Screensaver activation and configuration |
| `treeland-wallpaper-shell-unstable-v1.xml` | `treeland_wallpaper_shell_unstable_v1` | `treeland_wallpaper_notifier_v1`, `treeland_wallpaper_shell_v1`, `treeland_wallpaper_surface_v1` | Wallpaper source notification and per-surface wallpaper binding |

## Breaking changes

Breaking changes are grouped by version. Under each version heading, one subsection per affected protocol explains what changed, what replaces it, and how existing consumers should adapt.

### 0.6.0

#### `treeland-ddm-v1.xml`

Removed from `internal/`. DDM now communicates with Treeland via Qt Remote Objects, so this Wayland protocol is no longer needed and the file moved to `deprecated/`. Consumers should switch DDM↔Treeland IPC to the Qt Remote Objects channel and drop any binding to `treeland_ddm_v1`; the deprecated XML is still installed for one cycle but must not be used in new code.

#### `treeland-app-id-resolver-v1.xml`

Superseded by `treeland-app-id-resolver-unstable-v2.xml`; the old v1 file moved to `deprecated/`. The manager and resolver interfaces were renamed to `treeland_app_id_resolver_manager_v2` / `treeland_app_id_resolver_v2` (interface version reset to 1). Consumers should rebind the global as `treeland_app_id_resolver_manager_v2`, replace `get_resolver` target interface with `_v2`, and adjust to the clarified request/response contract; the old v1 XML is kept installed during migration but binds the deprecated interface name.

#### `treeland-screensaver-v1.xml`

Superseded by `treeland-screensaver-unstable-v2.xml`; the old v1 file moved to `deprecated/`. The interface was renamed to `treeland_screensaver_v2` (interface version reset to 1), and the `destroy` request is now part of the base interface rather than a `since="2"` addition. Consumers should rebind the global as `treeland_screensaver_v2` and call `destroy` unconditionally; the old v1 XML is kept installed during migration.
