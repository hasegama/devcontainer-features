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

# Install Node.js when missing. Prefer NodeSource on apt; fallback to distro packages.
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
    "ghcr.io/hasegama/devcontainer-features/claude-code:1": {}
  }

EOF
    exit 1
}

main() {
    echo "Activating feature 'claude-code'"
    PKG_MANAGER=$(detect_package_manager || true)

    if ! command -v node >/dev/null || ! command -v npm >/dev/null; then
        echo "Node.js or npm not found, attempting to install..."
        install_nodejs "$PKG_MANAGER" || print_nodejs_requirement
    fi

    echo "Installing Claude Code CLI..."
    npm install -g @anthropic-ai/claude-code@1.0.55

    if command -v claude >/dev/null; then
        echo "Claude Code CLI installed successfully!"
        claude --version
    else
        echo "ERROR: Claude Code CLI installation failed!"
        exit 1
    fi
}

main
