#!/bin/sh
set -e

# kcode (kcode-pi) Installer — 对齐 oh-my-pi install.sh（无独立二进制，需 Bun）
# Usage: curl -fsSL https://raw.githubusercontent.com/wangneal/kcode-install/main/scripts/install-kcode.sh | sh
#
#   --source          clone repo + bun install -g packages/kd-core
#   --ref <ref>       branch/tag (default: migrate-omp)
#   --version <ver>   npm pin e.g. 0.2.4

REPO="wangneal/kcode-pi"
NPM_PACKAGE="kcode-pi"
MIN_BUN_VERSION="1.3.14"
REF="migrate-omp"
VERSION=""
MODE=""

while [ $# -gt 0 ]; do
    case "$1" in
        --source) MODE="source"; shift ;;
        --ref)
            shift
            [ -n "$1" ] || { echo "Missing --ref"; exit 1; }
            REF="$1"; shift ;;
        --ref=*) REF="${1#*=}"; shift ;;
        --version)
            shift
            [ -n "$1" ] || { echo "Missing --version"; exit 1; }
            VERSION="$1"; shift ;;
        --version=*) VERSION="${1#*=}"; shift ;;
        *) echo "Unknown: $1"; exit 1 ;;
    esac
done

has_bun() { command -v bun >/dev/null 2>&1; }
has_git() { command -v git >/dev/null 2>&1; }
has_npm() { command -v npm >/dev/null 2>&1; }

version_ge() {
    current="$1"; minimum="$2"
    cm="${current%%.*}"; cr="${current#*.}"; cn="${cr%%.*}"; cp="${cr#*.}"; cp="${cp%%-*}"; cp="${cp%%.*}"
    mm="${minimum%%.*}"; mr="${minimum#*.}"; mn="${mr%%.*}"; mp="${mr#*.}"; mp="${mp%%.*}"
    [ "$cm" -gt "$mm" ] && return 0
    [ "$cm" -lt "$mm" ] && return 1
    [ "$cn" -gt "$mn" ] && return 0
    [ "$cn" -lt "$mn" ] && return 1
    [ "$cp" -ge "$mp" ]
}

require_bun_version() {
    v=$(bun --version 2>/dev/null || true)
    [ -n "$v" ] || { echo "bun version unreadable"; exit 1; }
    vc=${v%%-*}
    version_ge "$vc" "$MIN_BUN_VERSION" || {
        echo "Bun ${MIN_BUN_VERSION}+ required (current: $vc)"
        exit 1
    }
}

install_bun() {
    echo "Installing bun..."
    if command -v bash >/dev/null 2>&1; then
        curl -fsSL https://bun.sh/install | bash
    else
        curl -fsSL https://bun.sh/install | sh
    fi
    export BUN_INSTALL="${BUN_INSTALL:-$HOME/.bun}"
    export PATH="$BUN_INSTALL/bin:$PATH"
    require_bun_version
}

ensure_bun() {
    if ! has_bun; then install_bun; fi
    require_bun_version
}

install_via_npm() {
    ensure_bun
    if ! has_npm; then
        echo "npm not found; trying: bun install -g $NPM_PACKAGE"
        if [ -n "$VERSION" ]; then
            bun install -g "${NPM_PACKAGE}@${VERSION}" || exit 1
        else
            bun install -g "$NPM_PACKAGE" || exit 1
        fi
    else
        if [ -n "$VERSION" ]; then
            npm install -g "${NPM_PACKAGE}@${VERSION}" || exit 1
        else
            npm install -g "$NPM_PACKAGE" || exit 1
        fi
    fi
    echo "Installed kcode via npm/bun global"
}

install_via_source() {
    ensure_bun
    has_git || { echo "git required for --source"; exit 1; }
    TMP_DIR="$(mktemp -d)"
    trap 'rm -rf "$TMP_DIR"' EXIT
    if git clone --depth 1 --branch "$REF" "https://github.com/${REPO}.git" "$TMP_DIR" >/dev/null 2>&1; then
        :
    else
        git clone "https://github.com/${REPO}.git" "$TMP_DIR"
        (cd "$TMP_DIR" && git checkout "$REF")
    fi
    [ -d "$TMP_DIR/packages/kd-core" ] || { echo "missing packages/kd-core"; exit 1; }
    (cd "$TMP_DIR" && bun install) || exit 1
    bun install -g "$TMP_DIR/packages/kd-core" || exit 1
    echo "Installed kcode from source ($REF)"
}

case "$MODE" in
    source) install_via_source ;;
    *) install_via_npm ;;
esac

echo "Run: kcode --version && kcode"
