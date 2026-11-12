# Treeland Protocols

Wayland protocol extensions for treeland.

## Experimental status

All Treeland Wayland protocol extensions defined in this repository are
**experimental**. They may change at any time, including in
backward-incompatible ways, and no compatibility guarantees of any kind
are provided. Consumers must track the upstream protocol definition and
must not rely on current interface names, requests, events, or semantics
remaining stable.

## Breaking changes

Breaking changes are grouped by version. Under each version heading, one subsection
per affected protocol explains what changed and how existing consumers should adapt.

### 0.10.0

#### `internal/` directory removed

The four internal protocols (`treeland-app-id-resolver-unstable-v2`,
`treeland-prelaunch-splash-unstable-v2`, `treeland-screensaver-unstable-v2`,
`treeland-wallpaper-shell-unstable-v1`) are only consumed by binaries inside the
[treeland](https://github.com/linuxdeepin/treeland) repository. Their XML moved to
`src/protocols/` in that repository and is no longer installed by this package.
Consumers outside treeland must not depend on these protocols; use
`treeland-protocols` 0.9.0 or older if the XML files are still needed for
generating client code, and track treeland for their current definitions.

## Dependencies

Check `debian/control` for build-time dependencies, or use `cmake` to check the missing required dependencies.

## Building

Regular CMake building steps applies, in short:

```shell
$ mkdir build && cd build
$ cmake ..
$ cmake --build .
```

## Getting Involved

- [Code contribution via GitHub](https://github.com/linuxdeepin/dde-launchpad/)
- [Submit bug or suggestions to GitHub Issues or GitHub Discussions](https://github.com/linuxdeepin/developer-center/issues/new/choose)
- [Translate this project into your language on Hosted Weblate](https://hosted.weblate.org/projects/deepin/dde-launchpad/)

## License

**treeland-protocols** is licensed under MIT.
