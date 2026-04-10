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

main() {
    echo "Activating feature 'claude-code'"

    # curl is required. It is included in most base images, but verify just in case.
    if ! command -v curl >/dev/null; then
        echo "ERROR: curl is required but not found."
        echo "Please ensure curl is installed in your base image."
        exit 1
    fi

    echo "Installing Claude Code CLI v${CLAUDE_CODE_VERSION} via native installer..."
    curl -fsSL https://claude.ai/install.sh | bash -s "${CLAUDE_CODE_VERSION}"

    if command -v claude >/dev/null; then
        echo "Claude Code CLI installed successfully!"
        claude --version
    else
        echo "ERROR: Claude Code CLI installation failed!"
        exit 1
    fi
}

main
