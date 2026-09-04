# Public Protocols

For general application developers. Installed via `TREELAND_PROTOCOL_XML_FILES`.

| File | Protocol | Interfaces | Purpose |
|------|----------|-----------|---------|
| `treeland-dde-shell-v1.xml` | `treeland_dde_shell_v1` | `treeland_dde_shell_manager_v1`, `treeland_window_overlap_checker`, `treeland_dde_shell_surface_v1`, `treeland_dde_active_v1`, `treeland_multitaskview_v1`, `treeland_window_picker_v1`, `treeland_lockscreen_v1` | DDE shell integration: surface roles, overlap detection, active events, multitask view, window picker, lockscreen |

## Breaking changes

Breaking changes are grouped by version. Under each version heading, one subsection per affected protocol explains what changed, what replaces it, and how existing consumers should adapt.

### 0.6.0

#### `treeland-capture-unstable-v1.xml`

Removed from `public/`. Replaced by upstream `ext-image-capture-source-v1` and `ext-image-copy-capture-v1`; this protocol is deprecated and the file moved to `deprecated/`. Consumers should adopt the upstream `ext-image-capture-*` protocols instead; the deprecated XML is kept installed during migration but must not be used in new code.
