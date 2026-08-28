#!/bin/sh
set -eu

# Cursor CLI native installer.
# The official installer (curl https://cursor.com/install | bash) always
# fetches whatever version is baked into that script and does not accept a
# version argument. This feature downloads the versioned tarball directly so
# the CLI version is pinned and reproducible.
# Reference: https://cursor.com/docs/cli/installation
# Artifact:  https://downloads.cursor.com/lab/<version>/<os>/<arch>/agent-cli-package.tar.gz
#
# Version specifier (this is the Cursor CLI version, NOT the version
# of this feature itself — do not confuse the two):
# Latest as of 2026-08-28, taken from https://cursor.com/install
CURSOR_CLI_VERSION="2026.08.25-3e8eec8"

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
# The CLI writes to $HOME/.local/share/cursor-agent and $HOME/.local/bin.
# Installing into the target user's home (then chown) keeps ownership correct
# and matches the official installer layout.
TARGET_USER="${_REMOTE_USER:-root}"

# Resolve TARGET_HOME from /etc/passwd at install time rather than trusting
# `_REMOTE_USER_HOME`. When the target user is created by an earlier feature
# (e.g. `common-utils` creating `vscode`), the devcontainer CLI may have
# evaluated `_REMOTE_USER_HOME` before that user existed and set it to
# `/root`.
TARGET_HOME=$(getent passwd "${TARGET_USER}" 2>/dev/null | cut -d: -f6 || true)
if [ -z "${TARGET_HOME}" ]; then
    TARGET_HOME="${_REMOTE_USER_HOME:-/root}"
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

resolve_os() {
    kernel=$(uname -s)
    case "$kernel" in
        Linux)  echo "linux"  ;;
        Darwin) echo "darwin" ;;
        *)
            echo "ERROR: Unsupported operating system: ${kernel}" >&2
            return 1
            ;;
    esac
}

resolve_arch() {
    arch=$(uname -m)
    case "$arch" in
        x86_64|amd64)  echo "x64"   ;;
        aarch64|arm64) echo "arm64" ;;
        *)
            echo "ERROR: Unsupported architecture: ${arch}" >&2
            return 1
            ;;
    esac
}

chown_tree_to_target() {
    if [ "${TARGET_USER}" = "root" ]; then
        return 0
    fi
    target_gid=$(getent passwd "${TARGET_USER}" 2>/dev/null | cut -d: -f4 || true)
    if [ -z "${target_gid}" ]; then
        echo "ERROR: Could not resolve GID for user ${TARGET_USER}."
        return 1
    fi
    # GNU/BSD chown require options before owner:group.
    chown "${TARGET_USER}:${target_gid}" \
        "${TARGET_HOME}/.local" \
        "${TARGET_HOME}/.local/bin" \
        "${TARGET_HOME}/.local/share"
    chown -R "${TARGET_USER}:${target_gid}" \
        "${TARGET_HOME}/.local/share/cursor-agent"
    chown -h "${TARGET_USER}:${target_gid}" \
        "${TARGET_HOME}/.local/bin/agent" \
        "${TARGET_HOME}/.local/bin/cursor-agent"
}

main() {
    echo "Activating feature 'cursor-cli'"
    echo "Target user: ${TARGET_USER} (home: ${TARGET_HOME})"
    echo "Cursor CLI version: ${CURSOR_CLI_VERSION}"

    if ! command -v curl >/dev/null; then
        PKG_MANAGER=$(detect_package_manager || true)
        install_curl "$PKG_MANAGER" || {
            echo "ERROR: curl is required but could not be installed."
            exit 1
        }
    fi

    OS=$(resolve_os) || exit 1
    ARCH=$(resolve_arch) || exit 1
    DOWNLOAD_URL="https://downloads.cursor.com/lab/${CURSOR_CLI_VERSION}/${OS}/${ARCH}/agent-cli-package.tar.gz"
    echo "Downloading Cursor CLI from ${DOWNLOAD_URL}"

    VERSIONS_DIR="${TARGET_HOME}/.local/share/cursor-agent/versions"
    FINAL_DIR="${VERSIONS_DIR}/${CURSOR_CLI_VERSION}"
    TEMP_DIR="${VERSIONS_DIR}/.tmp-${CURSOR_CLI_VERSION}"

    mkdir -p "${TEMP_DIR}"
    curl -fsSL "${DOWNLOAD_URL}" | tar --strip-components=1 -xzf - -C "${TEMP_DIR}"
    rm -rf "${FINAL_DIR}"
    mv "${TEMP_DIR}" "${FINAL_DIR}"

    CURSOR_BIN="${FINAL_DIR}/cursor-agent"
    if [ ! -x "${CURSOR_BIN}" ]; then
        echo "ERROR: Expected binary at ${CURSOR_BIN} but it was not found."
        exit 1
    fi

    mkdir -p "${TARGET_HOME}/.local/bin"
    rm -f "${TARGET_HOME}/.local/bin/agent" "${TARGET_HOME}/.local/bin/cursor-agent"
    ln -s "${CURSOR_BIN}" "${TARGET_HOME}/.local/bin/agent"
    ln -s "${CURSOR_BIN}" "${TARGET_HOME}/.local/bin/cursor-agent"

    # ~/.local/bin is typically not on PATH in a fresh container. Symlink into
    # /usr/local/bin so both `agent` (primary) and `cursor-agent` (legacy) are
    # discoverable regardless of shell configuration.
    ln -sf "${CURSOR_BIN}" /usr/local/bin/agent
    ln -sf "${CURSOR_BIN}" /usr/local/bin/cursor-agent

    chown_tree_to_target

    if [ "${TARGET_USER}" = "root" ]; then
        agent --version
    else
        su - "${TARGET_USER}" -c "agent --version"
    fi
    echo "Cursor CLI installed successfully!"
}

main
