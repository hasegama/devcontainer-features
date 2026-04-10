# Using Claude Code in devcontainers

## Installation method

This feature uses the official native installer
(`curl -fsSL https://claude.ai/install.sh | bash`).
npm installation was deprecated by Anthropic in Feb 2026, so we migrated away
from it.

Reference: https://code.claude.com/docs/en/setup

## Requirements

- `curl` must be available in the container (included in most base images).
- **Node.js is NOT required** — the native installer has no runtime dependencies.

## Version pinning

The Claude Code CLI version is managed by the `CLAUDE_CODE_VERSION` variable
inside `install.sh`.

Note that `devcontainer-feature.json`'s `version` field is the version of this
feature itself, which is independent from the Claude Code CLI version. Do not
confuse the two.

When bumping the CLI version, edit only `install.sh`. Bump the feature's own
version according to this feature repository's release policy.
