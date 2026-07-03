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

### 首次 `kcode init`（**必须显式触发**）

**kcode 不会**再自动生成项目脚手架。在业务项目根目录**必须先**运行一次：

```bash
# 苍穹/星瀚/旗舰版（COSMIC Java）
kcode init --cosmic

# 企业版 C# / IronPython
kcode init --enterprise
```

`kcode init` 会**仅生成不存在的文件**：

- `.trellis/workflow.md`、`.trellis/spec/`、`.trellis/tasks/`、`.trellis/config.yaml`（Trellis 工作流目录）
- `.pi/settings.json`、`.pi/extensions/`、`.pi/skills/`、`.pi/agents/`（Pi 平台配置）
- `AGENTS.md`、`CLAUDE.md`（项目入口）
- `.trellis/spec/project/index.md`「产品画像」节

之后直接 `kcode` 即可启动会话。

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
| `kcode` | 启动助手（已 init 则直接进会话；未 init 时提示运行 `kcode init`） |
| `kcode init --cosmic` | 初始化苍穹/星瀚/旗舰版项目 |
| `kcode init --enterprise` | 初始化企业版 C# / Python 项目 |
| `kcode --version` / `-v` | 显示版本号 |
| `kcode --help` / `-h` | 显示帮助信息 |

**已删除**的旧子命令（0.2.20 之前版本用过）：`kcode product show / set / remove`、`kcode db show / init`。当前 CLI 没有任何 `kcode product *` 或 `kcode db *` 子命令——产品线在 `kcode init` 时选择，数据库 MCP 由 `kingdee-mcp` 扩展在会话启动时自动配置。

## 4. 在会话里怎么用

用自然语言描述任务即可（苍穹/企业版插件、OpenAPI、KSQL、构建报错等）。助手按 **规则** 做交付约束，并按任务 **`read` 对应 `SKILL.md`**（如 `ok-cosmic`、`kd-enterprise-openapi`）。

多数历史 `kd_*` 工具已改为 **omp 原生 + 规则引导**（检索用 `search`/`read`，Cosmic 构建用 `bash` 跑 Maven 等）。当前随包注册的典型金蝶工具：

| 工具 | 用途 |
|------|------|
| `kd_cosmic_qa` | 金蝶云社区智能问答（需社区 `productId` 与 PAT；可用 `saveToken` 保存 token） |

元数据查询优先 **数据库 MCP**；SDK/生命周期结合技能与 `kd_cosmic_qa`。

### 产品画像

真源：**`.trellis/spec/project/index.md`「产品画像」**（兼容旧 `OpenSpec/project.md`）。结合需求、代码库、已加载 skill 判断；不明确则先问用户，确认后：

- 重跑 `kcode init --cosmic` / `kcode init --enterprise` 改写
- 或直接编辑 `.trellis/spec/project/index.md` 的「产品画像」节

参考 ID（以 `kcode init` 选择为准）：

| id | 含义 |
|----|------|
| `cangqiong` | 苍穹 / Cosmic Java |
| `enterprise` | 企业版（C# / IronPython） |

每轮开始前会把画像摘要注入上下文；未确认时会提示先确认再编码。

### Git

`kcode 0.2.20` **不再**自动拦截 `git commit` / `git push`（早期版本的 kingdee-git-workflow 扩展已删除）。开发者直接用 git 即可。

## 5. 数据库 MCP

凭证写在项目 **`.omp/settings.json` 的 `db` 字段**（勿把密钥提交 Git）；`kingdee-mcp` 扩展在会话启动时**自动**按此配置生成 `.mcp.json`。

`kd-core` 模板自带默认 `kingdee-mcp` 配置（Postgres / SQL Server / Oracle 等）。如需调整数据库类型或凭证：

1. 编辑项目根 `.omp/settings.json` 的 `db` 字段
2. 重启 `kcode` 会话

## 6. 配置与目录

| 路径 | 用途 |
|------|------|
| `.trellis/workflow.md` | Trellis 工作流定义 |
| `.trellis/spec/` | 编码规范与领域 spec |
| `.trellis/spec/project/index.md` | 产品画像（真源） |
| `.trellis/tasks/` | 任务管理（PRDs、context） |
| `.pi/` | Pi 平台配置（skills、agents、extensions） |
| `AGENTS.md` | AI 协作入口（kcode 启动时读取） |
| `CLAUDE.md` | 会话级 AI 协作规则 |
| `.omp/settings.json` | 项目 omp 设置（含 `db`） |
| `.mcp.json` | MCP 声明（由 kingdee-mcp 自动生成） |
| `~/.omp/agent/` | 用户级模型与设置 |

旧版本中的 `OpenSpec/AGENTS.md` / `OpenSpec/project.md` / `OpenSpec/handoffs/`、`.pi/` 早期用法、`kcode knowledge`、`/kd` Loop、`kd_search`、`kd commit` 等**已不适用**；以 `kcode --help` 与本文为准。

## 7. 升级

```bash
npm install -g kcode-pi@latest
kcode --version
```

或重新执行 [README](../README.md) 中的一键安装脚本。

## 8. 常见问题

| 现象 | 建议 |
|------|------|
| 找不到 `kcode` | 重开终端；检查 npm 全局 PATH（Windows 常见 `%AppData%\npm`） |
| 无可用模型 | 会话内 `/login` 或配置 API Key |
| 项目未初始化 | 运行 `kcode init --cosmic` 或 `kcode init --enterprise` |
| 不知道当前产品线 | `read .trellis/spec/project/index.md`（兼容旧 `OpenSpec/project.md`） |
| 数据库 MCP 未就绪 | 编辑 `.omp/settings.json` 的 `db` 字段后重启 `kcode` |
| Windows bash 异常 | 安装 [Git for Windows](https://git-scm.com/download/win) |
| Bun 版本过低 | 按 https://bun.sh/docs/installation 升级后重跑安装脚本 |

## 9. 进一步说明

本仓只有安装脚本与这份说明。主仓 `docs/` 若与本文冲突，**以已安装的 `kcode-pi` 与 `kcode --help` 为准**。
