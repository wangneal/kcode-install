# kcode (kcode-pi) Installer for Windows — 对齐 oh-my-pi install.ps1（无独立二进制，需 Bun）
# Usage: irm https://raw.githubusercontent.com/wangneal/kcode-install/main/scripts/install-kcode.ps1 | iex
#
#   irm .../install-kcode.ps1 -OutFile install-kcode.ps1; .\install-kcode.ps1 -Version 0.2.11
#   .\install-kcode.ps1 -Source   # 需能 clone 主仓（通常仅维护者）

param(
    [switch]$Source,
    [string]$Ref = "migrate-omp",
    [string]$Version = ""
)

$ErrorActionPreference = "Stop"

$Repo = "wangneal/kcode-pi"
$NpmPackage = "kcode-pi"
$MinimumBunVersion = "1.3.14"

function Test-BunInstalled {
    try { $null = Get-Command bun -ErrorAction Stop; return $true } catch { return $false }
}

function Get-BunVersion {
    try {
        $versionText = (bun --version 2>$null)
        if (-not $versionText) { return $null }
        return [version]($versionText.Trim().Split("-")[0])
    } catch { return $null }
}

function Assert-BunVersion {
    param([string]$MinimumVersion)
    $current = Get-BunVersion
    if (-not $current -or $current -lt [version]$MinimumVersion) {
        $t = if ($current) { $current.ToString() } else { "unknown" }
        throw "Bun $MinimumVersion+ required (current: $t). https://bun.sh/docs/installation"
    }
}

function Test-GitInstalled {
    try { $null = Get-Command git -ErrorAction Stop; return $true } catch { return $false }
}

function Find-BashShell {
    $gitBash = "C:\Program Files\Git\bin\bash.exe"
    if (Test-Path $gitBash) { return $gitBash }
    try { return (Get-Command bash.exe -ErrorAction Stop).Source } catch { return $null }
}

function Configure-BashShell {
    try {
        $settingsDir = Join-Path $env:USERPROFILE ".omp\agent"
        $settingsFile = Join-Path $settingsDir "settings.json"
        if (Test-Path $settingsFile) {
            try {
                $existing = Get-Content $settingsFile -Raw | ConvertFrom-Json
                if ($existing.shellPath) {
                    Write-Host "Bash shell already configured: $($existing.shellPath)" -ForegroundColor Cyan
                    return
                }
            } catch { }
        }
        $bashPath = Find-BashShell
        if ($bashPath) {
            if (-not (Test-Path $settingsDir)) { New-Item -ItemType Directory -Force -Path $settingsDir | Out-Null }
            $settings = @{}
            if (Test-Path $settingsFile) {
                try { $settings = Get-Content $settingsFile -Raw | ConvertFrom-Json -AsHashtable } catch { $settings = @{} }
            }
            $settings["shellPath"] = $bashPath
            $settings | ConvertTo-Json -Depth 10 | Set-Content $settingsFile -Encoding UTF8
            Write-Host "Configured shellPath: $bashPath" -ForegroundColor Green
        } else {
            Write-Host "No bash found — install Git for Windows for agent bash tools: https://git-scm.com/download/win" -ForegroundColor Yellow
        }
    } catch {
        Write-Host "Could not configure bash shell: $_" -ForegroundColor Yellow
    }
}

function Install-Bun {
    Write-Host "Installing Bun..."
    irm bun.sh/install.ps1 | iex
    $env:Path = [Environment]::GetEnvironmentVariable("Path", "User") + ";" + [Environment]::GetEnvironmentVariable("Path", "Machine")
    Assert-BunVersion $MinimumBunVersion
}

function Ensure-Bun {
    if (-not (Test-BunInstalled)) { Install-Bun }
    Assert-BunVersion $MinimumBunVersion
}

function Install-ViaNpm {
    Ensure-Bun
    if (-not (Get-Command npm -ErrorAction SilentlyContinue)) {
        throw "npm not found. Install Node.js (https://nodejs.org) or use Bun-only: bun install -g $NpmPackage"
    }
    $spec = if ($Version) { "$NpmPackage@$Version" } else { $NpmPackage }
    Write-Host "npm install -g $spec ..."
    npm install -g $spec
    if ($LASTEXITCODE -ne 0) { throw "npm install -g failed" }
    Write-Host "Installed kcode via npm" -ForegroundColor Green
}

function Install-ViaSource {
    Ensure-Bun
    if (-not (Test-GitInstalled)) { throw "git required for -Source" }
    $tmpRoot = Join-Path $env:TEMP ("kcode-install-" + [Guid]::NewGuid().ToString("N"))
    New-Item -ItemType Directory -Force -Path $tmpRoot | Out-Null
    try {
        $repoUrl = "https://github.com/$Repo.git"
        $cloned = $false
        try {
            git clone --depth 1 --branch $Ref $repoUrl $tmpRoot 2>$null | Out-Null
            if ($LASTEXITCODE -eq 0) { $cloned = $true }
        } catch { }
        if (-not $cloned) {
            git clone $repoUrl $tmpRoot | Out-Null
            Push-Location $tmpRoot
            try { git checkout $Ref | Out-Null } finally { Pop-Location }
        }
        $pkgPath = Join-Path $tmpRoot "packages\kd-core"
        if (-not (Test-Path $pkgPath)) { throw "Missing $pkgPath" }
        Push-Location $tmpRoot
        try {
            Write-Host "bun install (monorepo)..."
            bun install
            if ($LASTEXITCODE -ne 0) { throw "bun install failed" }
        } finally { Pop-Location }
        Write-Host "bun install -g $pkgPath ..."
        bun install -g $pkgPath
        if ($LASTEXITCODE -ne 0) { throw "bun install -g kd-core failed" }
        Write-Host "Installed kcode from source ($Ref)" -ForegroundColor Green
    } finally {
        Remove-Item -Recurse -Force $tmpRoot -ErrorAction SilentlyContinue
    }
}

if ($Source) {
    Install-ViaSource
} else {
    Install-ViaNpm
}
Configure-BashShell
Write-Host "Run 'kcode --version' then 'kcode' in your project root."
