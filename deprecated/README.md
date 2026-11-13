Deprecated protocols. No longer implemented or their implementation reliability is not guaranteed in new versions of Treeland.

Only the files listed in `TREELAND_PROTOCOL_DEPRECATED_XML_FILES` are installed:

- `treeland-capture-unstable-v1`, `treeland-ddm-v1`, `treeland-personalization-manager-v1`,
  `treeland-dde-shell-v1`, `treeland-wallpaper-color-v1` — still implemented by Treeland.
- `treeland-output-manager-v1` — no longer implemented, kept installed only because dde-shell still
  generates client code from it; drop it once dde-shell has migrated to
  `treeland-output-manager-unstable-v2`.

The remaining files are kept here for reference only; their implementations were removed from
Treeland and they are not installed.
