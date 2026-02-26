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

# Gemini CLI requires Node.js 20+
install_nodejs() {
    local pkg_manager="$1"
    echo "Installing Node.js using $pkg_manager..."

    case "$pkg_manager" in
        apt)
            install_packages apt "ca-certificates curl gnupg"
            curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
            apt-get install -y nodejs
            if command -v nodejs >/dev/null && ! command -v node >/dev/null; then
                ln -sf "$(command -v nodejs)" /usr/bin/node
            fi
            ;;
        apk) install_packages apk "nodejs npm" ;;
        dnf) install_packages dnf "nodejs npm" ;;
        yum)
            curl -sL https://rpm.nodesource.com/setup_20.x | bash -
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

ensure_node_major_version() {
    local min_major="$1"
    local node_major
    node_major=$(node -v 2>/dev/null | sed 's/^v//' | cut -d. -f1)

    if [ -z "$node_major" ] || [ "$node_major" -lt "$min_major" ]; then
        echo "ERROR: Node.js ${min_major}+ is required. Current: $(node -v 2>/dev/null || echo unknown)"
        return 1
    fi

    return 0
}

print_nodejs_requirement() {
    cat <<EOF

ERROR: Node.js and npm are required but could not be installed.
Note: Gemini CLI requires Node.js 20 or higher.

Please add the Node.js feature to your devcontainer.json:

  "features": {
    "ghcr.io/devcontainers/features/node:1": {},
    "ghcr.io/hasegama/devcontainer-features/gemini:1": {}
  }

EOF
    exit 1
}

main() {
    echo "Activating feature 'gemini'"
    PKG_MANAGER=$(detect_package_manager || true)

    if ! command -v node >/dev/null || ! command -v npm >/dev/null; then
        echo "Node.js or npm not found, attempting to install..."
        install_nodejs "$PKG_MANAGER" || print_nodejs_requirement
    fi

    ensure_node_major_version 20 || print_nodejs_requirement

    echo "Installing Google Gemini CLI..."
    npm install -g @google/gemini-cli@latest

    if command -v gemini >/dev/null; then
        echo "Google Gemini CLI installed successfully!"
        gemini --version 2>/dev/null || true
    else
        echo "ERROR: Google Gemini CLI installation failed!"
        exit 1
    fi
}

main
