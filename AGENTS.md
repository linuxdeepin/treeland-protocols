# Treeland Protocols — Agent Reference

## Repository structure

```
├── CMakeLists.txt              # build & install definition
├── AGENTS.md                   # this file
├── public/                     # protocols for general application developers
├── dde/                        # DDE component protocols
├── internal/                   # Treeland-internal, not for general app developers
├── wine/                       # Wine compatibility layer protocols
└── deprecated/                 # replaced by newer versions, installed by default
```

## Protocol classification

| Directory     | Audience                              | CMakeLists variable                      |
|--------------|---------------------------------------|----------------------------------------|
| `public/`    | General application developers        | `TREELAND_PROTOCOL_XML_FILES`          |
| `dde/`       | DDE desktop components                | `TREELAND_PROTOCOL_DDE_XML_FILES`     |
| `internal/`  | Treeland compositor internals only    | `TREELAND_PROTOCOL_INTERNAL_XML_FILES`|
| `wine/`      | Wine compatibility layer              | `TREELAND_PROTOCOL_WINE_XML_FILES`     |
| `deprecated/`| Superseded, installed by default     | `TREELAND_PROTOCOL_DEPRECATED_XML_FILES`|

New protocol files must be added to the corresponding variable in `CMakeLists.txt`.

## Naming conventions

### File naming

```
<category>/treeland-<topic>-unstable-v1.xml
```

- `unstable-vN` is the default suffix for new protocols.
- Some protocols that were never published as unstable omit the suffix (e.g. `treeland-dde-shell-v1.xml`).

### Protocol and interface naming

```
file:              treeland-<topic>-unstable-v1.xml
protocol name:     treeland_<topic>_unstable_v1
interface names:   treeland_<foo>_v1        (no _unstable in interface names)
```

**Key convention**: interface names usually end with `_v1` but do **not** include `_unstable`, even in unstable files. This mirrors the upstream Wayland convention (e.g. `wl_surface` is defined in `wayland.xml`, not in a file named after the interface).

### Version bumping

- Backward-compatible: keep the same file, raise interface `version`, add `since="N"` on new members.
- Backward-incompatible: create a new file with next major version suffix, keep the old file.

### SPDX copyright

Use the repo's standard block. Match the year range of neighboring files in the same protocol family:

```xml
<copyright><![CDATA[
SPDX-FileCopyrightText: 2024 - 2026 UnionTech Software Technology Co., Ltd.
SPDX-License-Identifier: MIT
]]></copyright>
```

## Per-directory protocol listings

Each subdirectory (except `deprecated/`) contains a `README.md` with a table of protocols and their interfaces.

## Deprecating a protocol

When a protocol is superseded or no longer needed, follow these steps:

1. **Move the file**
   ```
   git mv <dir>/<protocol>.xml deprecated/<protocol>.xml
   ```

2. **Update `CMakeLists.txt`**
   - Remove the entry from its current variable (e.g. `TREELAND_PROTOCOL_XML_FILES`).
   - Add it to `TREELAND_PROTOCOL_DEPRECATED_XML_FILES`.

3. **Update the source directory `README.md`**
   - Remove the protocol row from the protocol table.
   - Append a row to the **Breaking changes** table (create the section if it does not exist yet):

     | Version | Date | Protocol | Change |
     |---------|------|----------|--------|
     | x.y.z | YYYY/MM | `` `<protocol>.xml` `` | One-sentence explanation and replacement. |

4. **Commit** with a message in the form:
   ```
   deprecate: move <protocol> to deprecated/

   <Reason and replacement in one or two sentences.>
   ```

The `deprecated/` directory has no README protocol table. Deprecated files are still installed by default (`TREELAND_PROTOCOLS_INSTALL_DEPRECATED` is `ON`).
