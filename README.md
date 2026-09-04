# Treeland Protocols

Wayland protocol extensions for treeland.

## Experimental status

All Treeland Wayland protocol extensions defined in this repository are
**experimental**. They may change at any time, including in
backward-incompatible ways, and no compatibility guarantees of any kind
are provided. Consumers must track the upstream protocol definition and
must not rely on current interface names, requests, events, or semantics
remaining stable.

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
