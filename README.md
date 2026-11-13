# Treeland Protocols

Wayland protocol extensions for treeland.

## Stability

All Treeland Wayland protocol extensions defined in this repository are
not fully stable. Backward-incompatible changes should be avoided but are
not guaranteed; any backward-incompatible change must bump the version
number in the protocol and interface names and reset the interface
version.

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
