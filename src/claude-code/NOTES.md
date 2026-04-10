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

## User context and PATH

devcontainer Feature scripts always run as root (per the spec). However,
the native installer places the CLI binary at `$HOME/.local/bin/claude`,
which would land in `/root/.local/bin` if we ran it as root — inaccessible
to the end user, and not on PATH anyway.

To solve this, `install.sh`:

1. Reads `_REMOTE_USER` / `_REMOTE_USER_HOME`, which the devcontainer CLI
   automatically injects based on `devcontainer.json`'s `remoteUser` /
   `containerUser` settings.
2. Runs the native installer via `su - <user>` so the binary lands under
   that user's home with correct ownership.
3. Symlinks the binary to `/usr/local/bin/claude` so it is discoverable on
   PATH regardless of shell configuration. The actual data directory
   (`$HOME/.local/share/claude`) stays under the end user's home.

Reference: https://containers.dev/implementors/features/

## Version pinning

The Claude Code CLI version is managed by the `CLAUDE_CODE_VERSION` variable
inside `install.sh`.

**The feature's own `version` field in `devcontainer-feature.json` mirrors
the Claude Code CLI version it installs.** This makes it immediately obvious
which CLI version a given feature release is pinned to, and keeps the two
numbers in lockstep.

When bumping the CLI version, update **both** of the following to the same
value:

1. `CLAUDE_CODE_VERSION` in `install.sh`
2. `version` in `devcontainer-feature.json`

Then trigger the `Release dev container features & Generate Documentation`
workflow (`workflow_dispatch`) on `main` to publish the new version to
`ghcr.io/hasegama/devcontainer-features/claude-code`. The publish step is a
no-op if `version` is unchanged, so bumping it is required to roll out any
install-logic fix as well.
