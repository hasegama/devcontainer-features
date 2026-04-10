
# Claude Code CLI (claude-code)

Installs the Claude Code CLI globally (native installer)

## Example Usage

```json
"features": {
    "ghcr.io/hasegama/devcontainer-features/claude-code:1": {}
}
```

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|


## Customizations

### VS Code Extensions

- `anthropic.claude-code`

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

Note that `devcontainer-feature.json`'s `version` field is the version of this
feature itself, which is independent from the Claude Code CLI version. Do not
confuse the two.

When bumping the CLI version, edit only `install.sh`. Bump the feature's own
version according to this feature repository's release policy.


---

_Note: This file was auto-generated from the [devcontainer-feature.json](https://github.com/hasegama/devcontainer-features/blob/main/src/claude-code/devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
