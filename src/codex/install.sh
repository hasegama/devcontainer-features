#!/bin/sh
set -eu

if [ "$(id -u)" -ne 0 ]; then
    echo "Script must be run as root. Use sudo, su, or add \"USER root\" to your Dockerfile before running this script."
    exit 1
fi

detect_package_manager() {
    for pm in apt-get apk dnf yum; do
        if command -v $pm >/dev/null; then
            case $pm in
                apt-get) echo "apt" ;;
                *) echo "$pm" ;;
            esac
            return 0
        fi
    done
    echo "unknown"
    return 1
}

install_packages() {
    local pkg_manager="$1"
    shift
    local packages="$@"
    case "$pkg_manager" in
        apt) apt-get update && apt-get install -y $packages ;;
        apk) apk add --no-cache $packages ;;
        dnf|yum) $pkg_manager install -y $packages ;;
        *) echo "WARNING: Unsupported package manager. Cannot install: $packages"; return 1 ;;
    esac
}

install_nodejs() {
    local pkg_manager="$1"
    echo "Installing Node.js using $pkg_manager..."

    case "$pkg_manager" in
        apt)
            install_packages apt "ca-certificates curl gnupg"
            curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
            apt-get install -y nodejs
            if command -v nodejs >/dev/null && ! command -v node >/dev/null; then
                ln -sf "$(command -v nodejs)" /usr/bin/node
            fi
            ;;
        apk) install_packages apk "nodejs npm" ;;
        dnf) install_packages dnf "nodejs npm" ;;
        yum)
            curl -sL https://rpm.nodesource.com/setup_18.x | bash -
            yum install -y nodejs
            ;;
        *)
            echo "ERROR: Unsupported package manager for Node.js"
            return 1
            ;;
    esac

    if command -v node >/dev/null && command -v npm >/dev/null; then
        echo "Successfully installed Node.js and npm"
        return 0
    fi
    echo "Failed to install Node.js and npm"
    return 1
}

print_nodejs_requirement() {
    cat <<EOF

ERROR: Node.js and npm are required but could not be installed.
Please add the Node.js feature to your devcontainer.json:

  "features": {
    "ghcr.io/devcontainers/features/node:1": {},
    "ghcr.io/hasegama/devcontainer-features/codex:1": {}
  }

EOF
    exit 1
}

resolve_platform_suffix() {
    # Codex はプラットフォーム固有の実行バイナリを optionalDependencies
    # として配布している（例: @openai/codex-linux-arm64）。
    # npm のグローバルインストールでは optional な依存が取りこぼされる
    # 既知事例があるため、OS/CPU を判定してサフィックスを返す。
    local kernel arch os cpu
    kernel=$(uname -s)
    arch=$(uname -m)

    case "$kernel" in
        Linux)  os="linux"  ;;
        Darwin) os="darwin" ;;
        *)
            echo "WARNING: Unsupported OS: $kernel" >&2
            return 1
            ;;
    esac

    case "$arch" in
        x86_64|amd64)   cpu="x64"   ;;
        aarch64|arm64)  cpu="arm64" ;;
        *)
            echo "WARNING: Unsupported architecture: $arch" >&2
            return 1
            ;;
    esac

    echo "${os}-${cpu}"
}

main() {
    echo "Activating feature 'codex'"
    PKG_MANAGER=$(detect_package_manager || true)

    if ! command -v node >/dev/null || ! command -v npm >/dev/null; then
        echo "Node.js or npm not found, attempting to install..."
        install_nodejs "$PKG_MANAGER" || print_nodejs_requirement
    fi

    VERSION="${VERSION:-latest}"
    echo "Installing OpenAI Codex CLI (version: ${VERSION})..."

    # バージョンが "latest" の場合、実際のバージョン番号を解決する。
    # プラットフォーム依存パッケージの指定に具体的なバージョン番号が必要なため。
    RESOLVED_VERSION="$VERSION"
    if [ "$VERSION" = "latest" ]; then
        RESOLVED_VERSION=$(npm view "@openai/codex@latest" version 2>/dev/null) || {
            echo "ERROR: Failed to resolve latest version of @openai/codex"
            exit 1
        }
        echo "Resolved latest version: ${RESOLVED_VERSION}"
    fi

    # プラットフォーム依存パッケージのサフィックスを特定
    PLATFORM_SUFFIX=$(resolve_platform_suffix || true)

    if [ -n "$PLATFORM_SUFFIX" ]; then
        # 本体とプラットフォーム依存パッケージを明示的にインストール。
        # Codex の optionalDependencies はエイリアス形式で宣言されている:
        #   "@openai/codex-linux-arm64": "npm:@openai/codex@0.144.1-linux-arm64"
        # グローバルインストールでの取りこぼしを防ぐため、エイリアスを
        # そのまま再現して両方を明示指定する。
        PLATFORM_ALIAS="@openai/codex-${PLATFORM_SUFFIX}@npm:@openai/codex@${RESOLVED_VERSION}-${PLATFORM_SUFFIX}"
        echo "Platform package: @openai/codex-${PLATFORM_SUFFIX} (${RESOLVED_VERSION}-${PLATFORM_SUFFIX})"
        npm install -g "@openai/codex@${RESOLVED_VERSION}" "$PLATFORM_ALIAS"
    else
        # プラットフォーム判定できない場合は本体のみ（従来動作）
        echo "WARNING: Could not determine platform package. Installing codex only."
        npm install -g "@openai/codex@${RESOLVED_VERSION}"
    fi

    # 実際にバイナリが起動できることを検証する。
    # command -v だけではシムリンクの存在確認にすぎず、
    # プラットフォーム依存バイナリが欠落していても成功してしまう。
    echo "Verifying codex binary..."
    if codex --version; then
        echo "OpenAI Codex CLI installed successfully!"
    else
        echo "ERROR: codex --version failed. The platform-specific binary may be missing."
        exit 1
    fi
}

main
