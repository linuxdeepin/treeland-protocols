# Treeland 协议

Treeland 的 Wayland 协议扩展。

## 实验性状态

本仓库中定义的所有 Treeland Wayland 协议扩展均为**实验性**。它们可能随时更改，包括以不向后兼容的方式更改，且不提供任何形式的兼容性保证。使用者必须跟踪上游协议定义，不得依赖当前接口名称、请求、事件或语义保持稳定。

## 依赖

查看 `debian/control` 获取构建依赖，或使用 `cmake` 检查缺失的依赖。

## 构建

使用常规的 CMake 构建步骤，简述如下：

```shell
$ mkdir build && cd build
$ cmake ..
$ cmake --build .
```

## 参与贡献

- [通过 GitHub 贡献代码](https://github.com/linuxdeepin/dde-launchpad/)
- [在 GitHub Issues 或 GitHub Discussions 提交 Bug 或建议](https://github.com/linuxdeepin/developer-center/issues/new/choose)
- [在 Hosted Weblate 上翻译本项目](https://hosted.weblate.org/projects/deepin/dde-launchpad/)

## 许可证

**treeland-protocols** 采用 MIT 许可证。
