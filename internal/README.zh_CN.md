# 内部协议

Treeland 合成器内部协议 — 不面向通用应用开发者。通过 `TREELAND_PROTOCOL_INTERNAL_XML_FILES` 安装。

| 文件 | 协议 | 接口 | 用途 |
|------|----------|-----------|---------|
| `treeland-app-id-resolver-unstable-v2.xml` | `treeland_app_id_resolver_unstable_v2` | `treeland_app_id_resolver_manager_v2`, `treeland_app_id_resolver_v2` | 将进程（pidfd）解析为沙箱应用的应用 ID |
| `treeland-prelaunch-splash-unstable-v2.xml` | `treeland_prelaunch_splash_unstable_v2` | `treeland_prelaunch_splash_manager_v2`, `treeland_prelaunch_splash_v2` | 应用预启动闪屏控制 |
| `treeland-screensaver-unstable-v2.xml` | `treeland_screensaver_unstable_v2` | `treeland_screensaver_v2` | 屏保激活与配置 |
| `treeland-wallpaper-shell-unstable-v1.xml` | `treeland_wallpaper_shell_unstable_v1` | `treeland_wallpaper_notifier_v1`, `treeland_wallpaper_shell_v1`, `treeland_wallpaper_surface_v1` | 壁纸来源通知和逐表面壁纸绑定 |

## 破坏性变更

破坏性变更按版本分组。每个版本标题下，每个受影响协议有一个子节说明变更内容、替代方案以及现有消费者如何适配。

### 0.6.0

#### `treeland-ddm-v1.xml`

从 `internal/` 移除。DDM 现在通过 Qt Remote Objects 与 Treeland 通信，不再需要此 Wayland 协议。文件已移至 `deprecated/`。消费者应将 DDM↔Treeland IPC 切换到 Qt Remote Objects 通道，并停止绑定 `treeland_ddm_v1`；旧 XML 在迁移期间仍会安装，但不得用于新代码。

#### `treeland-app-id-resolver-v1.xml`

被 `treeland-app-id-resolver-unstable-v2.xml` 取代；旧 v1 文件移至 `deprecated/`。管理器和解析器接口重命名为 `treeland_app_id_resolver_manager_v2` / `treeland_app_id_resolver_v2`（接口版本重置为 1）。消费者应重新绑定全局对象为 `treeland_app_id_resolver_manager_v2`，将 `get_resolver` 目标接口替换为 `_v2`，并适配澄清后的请求/响应契约；旧 v1 XML 在迁移期间仍会安装，但绑定的是已弃用的接口名。

#### `treeland-screensaver-v1.xml`

被 `treeland-screensaver-unstable-v2.xml` 取代；旧 v1 文件移至 `deprecated/`。接口重命名为 `treeland_screensaver_v2`（接口版本重置为 1），`destroy` 请求现在属于基础接口而非 `since="2"` 的新增。消费者应重新绑定为 `treeland_screensaver_v2` 并无条件调用 `destroy`；旧 v1 XML 在迁移期间仍会安装。
