# kcode-install

公开安装入口：一键安装金蝶编码助手 **kcode**（npm 包 [kcode-pi](https://www.npmjs.com/package/kcode-pi)）。

源码 monorepo 为私有仓；本仓仅同步 `scripts/install-kcode.*`。

## 安装

**Windows (PowerShell)**

```powershell
irm https://raw.githubusercontent.com/wangneal/kcode-install/main/scripts/install-kcode.ps1 | iex
```

指定版本：

```powershell
irm https://raw.githubusercontent.com/wangneal/kcode-install/main/scripts/install-kcode.ps1 | iex; install-kcode.ps1 -Version 0.2.11
```

（若管道后无法带参，可先下载再执行：`irm ... -OutFile install-kcode.ps1; .\install-kcode.ps1 -Version 0.2.11`）

**macOS / Linux**

```sh
curl -fsSL https://raw.githubusercontent.com/wangneal/kcode-install/main/scripts/install-kcode.sh | sh
```

```sh
curl -fsSL https://raw.githubusercontent.com/wangneal/kcode-install/main/scripts/install-kcode.sh | sh -s -- --version 0.2.11
```

**手动**

```bash
npm install -g kcode-pi@0.2.11
```

需 [Bun](https://bun.sh) ≥ 1.3.14。

## 维护（维护者）

在 KCodeV2 主仓修改 `scripts/install-kcode.ps1` / `.sh` 后执行：

```powershell
.\scripts\sync-kcode-install-repo.ps1
```
