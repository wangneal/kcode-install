# KCode 使用说明

**kcode** 是金蝶业务项目里的 AI 编码助手（npm 包 [kcode-pi](https://www.npmjs.com/package/kcode-pi)）。它在 [oh-my-pi / omp](https://github.com/can1357/oh-my-pi) 之上二开，随包加载金蝶 **技能（skills）**、**规则（rules）** 和少量金蝶专用工具；检索、编辑、构建、LSP 等能力主要使用 omp 自带工具。

安装见 [README](../README.md)。

## 1. 环境与第一次启动

| 项 | 要求 |
|----|------|
| Bun | **≥ 1.3.14**（npm 包由 Bun 执行） |
| npm / Node | 全局安装 `kcode-pi` 时推荐 Node LTS |
| 工作目录 | **金蝶业务项目根目录**（不是 kcode 源码目录） |

```bash
kcode --help
kcode --version
cd /path/to/your/erp-project
kcode                 # 进入 omp 交互界面（TUI）
```

**首次**在某业务项目执行 `kcode` 时，若文件不存在会自动生成（**不覆盖**已有文件）：

- `AGENTS.md`、`CLAUDE.md`（包内模板）
- `OpenSpec/project.md`、`OpenSpec/roadmap.md`、`OpenSpec/AGENTS.md`（`project.md` / `roadmap.md` 按当前目录扫描）

终端会提示：**先阅读 `OpenSpec/project.md` 确认产品线**，再开始开发。

## 2. 模型与认证

若提示没有可用模型，在会话内：

```text
/login
/model
```

启动前也可设置环境变量，例如：

```powershell
$env:OPENAI_API_KEY="sk-..."
kcode
```

自定义 OpenAI 兼容网关使用 omp 用户级配置（`~/.omp/agent/`），配置后 `/model` 选择 provider。

## 3. 终端子命令（不进 TUI）

在**业务项目根目录**执行：

| 命令 | 说明 |
|------|------|
| `kcode` | 启动助手 |
| `kcode -v` / `--version` | 版本 |
| `kcode --help` | 帮助 |
| `kcode product show` | 查看 `OpenSpec/project.md`「产品画像」 |
| `kcode product set <id>` | 在「产品画像」中**添加**产品 ID |
| `kcode product remove <id>` | 从「产品画像」中移除 |
| `kcode db show` | 数据库 MCP 与凭证状态（只读） |
| `kcode db init` | 生成/更新 `.mcp.json`、`.omp/mcp-db-connect.yml` |

当前 CLI **没有** `kcode knowledge`；团队文档放在项目内，由助手在对话中 `read`，或依赖随包 **skills**。

## 4. 在会话里怎么用

用自然语言描述任务即可（苍穹/企业版插件、OpenAPI、KSQL、构建报错等）。助手按 **规则** 做交付约束，并按任务 **`read` 对应 `SKILL.md`**（如 `ok-cosmic`、`kd-enterprise-openapi`）。

多数历史 `kd_*` 工具已改为 **omp 原生 + 规则引导**（检索用 `search`/`read`，Cosmic 构建用 `bash` 跑 Maven 等）。当前随包注册的典型金蝶工具：

| 工具 | 用途 |
|------|------|
| `kd_cosmic_qa` | 金蝶云社区智能问答（需社区 `productId` 与 PAT；可用 `saveToken` 保存 token） |

元数据查询优先 **数据库 MCP**；SDK/生命周期结合技能与 `kd_cosmic_qa`。

### 产品画像

真源：**`OpenSpec/project.md`「产品画像」**。结合需求、代码库、已加载 skill 判断；不明确则先问用户，确认后 `kcode product set <id>` 或手改该节。

参考 ID（以模板为准）：

| id | 含义 |
|----|------|
| `cangqiong` | 苍穹 / Cosmic Java |
| `xinghan` | 星瀚 |
| `flagship` | 星空旗舰版 |
| `enterprise-csharp` | 企业版 C# |
| `enterprise-ironpython` | 企业版 IronPython |
| `enterprise-openapi` | 企业版 OpenAPI 等 |

每轮开始前会把画像摘要注入上下文；未确认时会提示先确认再编码。

### Git（自动）

- `git commit` 可能被拦截，要求先按 skill 做代码审查再提交。
- `git push` 成功后会提示写 `OpenSpec/handoffs/<sessionId>.md` 交接文档。

## 5. 数据库 MCP

```bash
kcode db init
kcode db show
```

凭证写在项目 **`.omp/settings.json` 的 `db` 字段**（勿把密钥提交 Git）；`kcode db init` 维护 **`.mcp.json`**。

## 6. 配置与目录

| 路径 | 用途 |
|------|------|
| `OpenSpec/project.md` | 产品画像（真源） |
| `OpenSpec/roadmap.md` | 路线图 |
| `OpenSpec/handoffs/` | 交接文档 |
| `.omp/settings.json` | 项目 omp 设置（含 `db`） |
| `.mcp.json` | MCP 声明 |
| `~/.omp/agent/` | 用户级模型与设置 |

旧文档中的 `.pi/`、`kcode knowledge`、`/kd` Loop、`kd_search` 等**可能已不适用**；以 `kcode --help` 与本文为准。

## 7. 升级

```bash
npm install -g kcode-pi@latest
kcode --version
```

或重新执行 [README](../README.md) 中的一键安装脚本。

## 8. 常见问题

| 现象 | 建议 |
|------|------|
| 找不到 `kcode` | 重开终端；检查 npm 全局 PATH |
| 无可用模型 | `/login` 或配置 API Key |
| 产品线未确认 | `kcode product show` / `set` / 编辑 `OpenSpec/project.md` |
| db MCP 未就绪 | 配置 `.omp/settings.json` 的 `db` 后 `kcode db init` |
| Windows bash 异常 | 安装 Git for Windows |

## 9. 进一步说明

本仓只有安装脚本与这份说明。主仓 `docs/` 若与本文冲突，**以已安装的 `kcode-pi` 与 `kcode --help` 为准**。