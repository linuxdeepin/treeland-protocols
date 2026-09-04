# 公共协议

面向通用应用开发者。通过 `TREELAND_PROTOCOL_XML_FILES` 安装。

| 文件 | 协议 | 接口 | 用途 |
|------|----------|-----------|---------|
| `treeland-dde-shell-v1.xml` | `treeland_dde_shell_v1` | `treeland_dde_shell_manager_v1`, `treeland_window_overlap_checker`, `treeland_dde_shell_surface_v1`, `treeland_dde_active_v1`, `treeland_multitaskview_v1`, `treeland_window_picker_v1`, `treeland_lockscreen_v1` | DDE Shell 集成：surface 角色、重叠检测、活跃事件、多任务视图、窗口选取、锁屏 |

## 破坏性变更

破坏性变更按版本分组。每个版本标题下，每个受影响协议有一个子节说明变更内容、替代方案以及现有消费者如何适配。

### 0.6.0

#### `treeland-capture-unstable-v1.xml`

从 `public/` 移除。被上游 `ext-image-capture-source-v1` 和 `ext-image-copy-capture-v1` 取代；此协议已弃用，文件移至 `deprecated/`。消费者应改用上游 `ext-image-capture-*` 协议；旧 XML 在迁移期间仍会安装，但不得用于新代码。
