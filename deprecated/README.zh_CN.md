已弃用的协议。不再实现，或在 Treeland 新版本中不保证实现可靠性。

只有列入 `TREELAND_PROTOCOL_DEPRECATED_XML_FILES` 的文件会被安装：

- `treeland-capture-unstable-v1`、`treeland-ddm-v1`、`treeland-personalization-manager-v1`、
  `treeland-dde-shell-v1`、`treeland-wallpaper-color-v1` —— Treeland 仍有实现。
- `treeland-output-manager-v1` —— 实现已删除，仅因 dde-shell 仍从它生成客户端代码而保留安装；
  待 dde-shell 迁移到 `treeland-output-manager-unstable-v2` 后即可剔除。

其余文件仅留作参考——Treeland 中的实现已被删除，因此不再安装。
