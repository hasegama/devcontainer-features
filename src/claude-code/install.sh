#!/bin/sh
set -eu

# Claude Code CLI native installer.
# npm installation was deprecated by Anthropic in Feb 2026, so we use the
# official native installer instead.
# Reference: https://code.claude.com/docs/en/setup
#
# Version specifier (this is the Claude Code CLI version, NOT the version
# of this feature itself — do not confuse the two):
#   - "X.Y.Z": pin to a specific version
#   - "stable": stable channel (~1 week delayed, skips releases with major regressions)
#   - "latest": latest release
CLAUDE_CODE_VERSION="2.1.87"

if [ "$(id -u)" -ne 0 ]; then
    echo "Script must be run as root. Use sudo, su, or add \"USER root\" to your Dockerfile before running this script."
    exit 1
fi

# Determine the target user. The devcontainer CLI automatically injects
# these environment variables based on devcontainer.json's `remoteUser` /
# `containerUser` settings:
#   - _REMOTE_USER:      the effective remote user (falls back to containerUser)
#   - _REMOTE_USER_HOME: that user's home directory
# Reference: https://containers.dev/implementors/features/
#
# The native installer writes to $HOME/.local/bin/claude. If we ran it as
# root, the binary would land in /root/.local/bin (inaccessible to the end
# user) and PATH would not pick it up anyway. Installing as the target user
# places the binary under their own home with correct ownership.
TARGET_USER="${_REMOTE_USER:-root}"
TARGET_HOME="${_REMOTE_USER_HOME:-/root}"

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

install_curl() {
    pkg_manager="$1"
    echo "curl not found. Installing via ${pkg_manager}..."
    case "$pkg_manager" in
        apt) apt-get update && apt-get install -y ca-certificates curl ;;
        apk) apk add --no-cache ca-certificates curl ;;
        dnf|yum) $pkg_manager install -y ca-certificates curl ;;
        *)
            echo "ERROR: Unsupported package manager. Cannot install curl."
            return 1
            ;;
    esac
}

main() {
    echo "Activating feature 'claude-code'"
    echo "Target user: ${TARGET_USER} (home: ${TARGET_HOME})"

    # curl is required. It is included in most base images, but fall back
    # to the distro package manager if missing (e.g. bare ubuntu:focal).
    if ! command -v curl >/dev/null; then
        PKG_MANAGER=$(detect_package_manager || true)
        install_curl "$PKG_MANAGER" || {
            echo "ERROR: curl is required but could not be installed."
            exit 1
        }
    fi

    echo "Installing Claude Code CLI v${CLAUDE_CODE_VERSION} via native installer..."
    if [ "${TARGET_USER}" = "root" ]; then
        curl -fsSL https://claude.ai/install.sh | bash -s "${CLAUDE_CODE_VERSION}"
    else
        # Run the installer as the target user so the binary lands in their
        # own ~/.local/bin with correct ownership. `su -` resets HOME so the
        # installer resolves $HOME to the target user's home directory.
        su - "${TARGET_USER}" -c "curl -fsSL https://claude.ai/install.sh | bash -s ${CLAUDE_CODE_VERSION}"
    fi

    # The native installer places the binary at $HOME/.local/bin/claude, but
    # ~/.local/bin is typically not on PATH in a fresh container. Symlink the
    # binary into /usr/local/bin so it is discoverable regardless of shell
    # configuration, while the actual data directory stays under the user's
    # home (owned by the target user).
    CLAUDE_BIN="${TARGET_HOME}/.local/bin/claude"
    if [ ! -x "${CLAUDE_BIN}" ]; then
        echo "ERROR: Expected binary at ${CLAUDE_BIN} but it was not found."
        exit 1
    fi
    ln -sf "${CLAUDE_BIN}" /usr/local/bin/claude

    # Verify by running the binary as the target user so $HOME resolves
    # correctly (the native installer's runtime may read files under
    # $HOME/.local/share/claude).
    if [ "${TARGET_USER}" = "root" ]; then
        claude --version
    else
        su - "${TARGET_USER}" -c "claude --version"
    fi
    echo "Claude Code CLI installed successfully!"
}

main
