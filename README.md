# kcode-install

公开安装入口：一键安装金蝶编码助手 **kcode**（npm 包 [kcode-pi](https://www.npmjs.com/package/kcode-pi)）。

主开发 monorepo 可为私有仓；本仓托管一键安装脚本与公开 **使用说明**（[`docs/USAGE.md`](docs/USAGE.md)，由 KCodeV2 同步）。

## 使用前准备

| 依赖 | 说明 |
|------|------|
| [Bun](https://bun.sh) | **≥ 1.3.14**（一键脚本会在缺失时自动安装 Bun） |
| npm / Node.js | 推荐安装 [Node.js LTS](https://nodejs.org)；无 npm 时脚本会尝试 `bun install -g kcode-pi` |
| Git（仅源码安装） | Windows 源码模式 `-Source` / `--source` 需要 git |

## 一键安装（推荐）

**Windows（PowerShell）**

```powershell
irm https://raw.githubusercontent.com/wangneal/kcode-install/main/scripts/install-kcode.ps1 | iex
```

**macOS / Linux**

```sh
curl -fsSL https://raw.githubusercontent.com/wangneal/kcode-install/main/scripts/install-kcode.sh | sh
```

脚本会：检测/安装 Bun → 全局安装 `kcode-pi` →（Windows）在可用时配置 `~/.omp/agent/settings.json` 的 `shellPath`（Git Bash）。

## 指定版本

先下载脚本再带参数执行，避免管道无法传参：

**Windows**

```powershell
irm https://raw.githubusercontent.com/wangneal/kcode-install/main/scripts/install-kcode.ps1 -OutFile install-kcode.ps1
.\install-kcode.ps1 -Version 0.2.14
```

**macOS / Linux**

```sh
curl -fsSL https://raw.githubusercontent.com/wangneal/kcode-install/main/scripts/install-kcode.sh -o install-kcode.sh
sh install-kcode.sh --version 0.2.14
```

## 手动安装

```bash
# 需已安装 Bun ≥ 1.3.14 与 npm
npm install -g kcode-pi
# 或固定版本：
# npm install -g kcode-pi@0.2.14
```

## 安装后验证

```bash
kcode --version
```

在项目根目录启动交互会话：

```bash
cd /path/to/your/project
kcode
```

首次使用按提示配置模型与认证（与 oh-my-pi / omp 体系一致）。

**安装后的日常用法**（命令、`/login`、产品画像、skills、数据库 MCP、Git 审查/交接）：见 **[docs/USAGE.md](docs/USAGE.md)**（与当前 `kcode-pi` CLI 对齐，非主仓旧版 Loop 文档）。

## 从源码安装（维护者 / 可访问主仓时）

**Windows：** `.\install-kcode.ps1 -Source`（可选 `-Ref main`）

**Unix：** `sh install-kcode.sh --source`（可选 `--ref main`）

会 clone `wangneal/kcode-pi`，在 monorepo 内 `bun install` 后 `bun install -g packages/kd-core`。

## 升级与卸载

```bash
# 升级（与一键安装相同，会覆盖全局包）
npm install -g kcode-pi@latest

# 卸载
npm uninstall -g kcode-pi
```

## 常见问题

- **`kcode` 找不到命令**：关闭并重新打开终端，确认 npm 全局 bin 在 `PATH`（Windows 常见路径 `%AppData%\npm`）。
- **Bun 版本过低**：按 https://bun.sh/docs/installation 升级后重跑安装脚本。
- **`npm install -g` 失败**：检查网络与 npm 登录；企业环境可配置 registry 镜像后再安装。
- **Windows 下 bash 工具不可用**：安装 [Git for Windows](https://git-scm.com/download/win) 后重跑 `install-kcode.ps1`，或手动在 `~/.omp/agent/settings.json` 设置 `shellPath`。

## 维护者（KCodeV2 主仓）

修改 `scripts/install-kcode.ps1` / `install-kcode.sh` 后，在 KCodeV2 根目录执行：

```powershell
.\scripts\sync-kcode-install-repo.ps1
```

可选：`-InstallRepoDir <path>` 指定本地 `kcode-install` 目录；`-NoPush` 只提交不推送。

更多发版说明见主仓 `docs/KCODE_NPM_PUBLISH.md`（不随本仓同步）。