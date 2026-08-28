
# Cursor CLI (cursor-cli)

Installs the Cursor CLI globally (native installer)

## Example Usage

```json
"features": {
    "ghcr.io/hasegama/devcontainer-features/cursor-cli:1": {}
}
```

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|


# Using Cursor CLI in devcontainers

## Installation method

This feature downloads a **pinned** Cursor CLI tarball from
`https://downloads.cursor.com/lab/<version>/<os>/<arch>/agent-cli-package.tar.gz`.

The official installer (`curl https://cursor.com/install -fsS | bash`) always
installs whatever version is currently baked into that script and does not
accept a version argument, so we fetch the artifact directly.

Reference: https://cursor.com/docs/cli/installation

## Requirements

- `curl` must be available in the container (included in most base images).
- **Node.js is NOT required** — this is a native binary.
- glibc-based images only. Cursor CLI does not work on Alpine
  (musl). See: https://forum.cursor.com/t/cursor-agent-does-not-work-with-non-glibc-based-distributions-such-as-alpine-linux/141571

## User context and PATH

devcontainer Feature scripts always run as root (per the spec). The CLI
layout matches the official installer:

- binary: `$HOME/.local/share/cursor-agent/versions/<version>/cursor-agent`
- user symlinks: `$HOME/.local/bin/agent` and `$HOME/.local/bin/cursor-agent`

`install.sh`:

1. Reads `_REMOTE_USER` / `_REMOTE_USER_HOME`, which the devcontainer CLI
   automatically injects based on `devcontainer.json`'s `remoteUser` /
   `containerUser` settings.
2. Installs into that user's home and corrects ownership.
3. Symlinks the binary to `/usr/local/bin/agent` and
   `/usr/local/bin/cursor-agent` so it is discoverable on PATH regardless of
   shell configuration.

Reference: https://containers.dev/implementors/features/

## Version pinning

The Cursor CLI version is managed by the `CURSOR_CLI_VERSION` variable
inside `install.sh`.

**The feature's own `version` field in `devcontainer-feature.json` is the
feature's semver (`1.0.0`, `1.0.1`, …), not the CLI version.** Cursor CLI
versions look like `2026.08.25-3e8eec8`, which is not valid semver, so the
two numbers cannot stay in lockstep the way `claude-code` does.

When bumping the CLI version, update:

1. `CURSOR_CLI_VERSION` in `install.sh` (the CLI version string)
2. `version` in `devcontainer-feature.json` (bump the feature semver so a
   new GHCR tag is published)

Then trigger the `Release dev container features & Generate Documentation`
workflow (`workflow_dispatch`) on `main` to publish the new version to
`ghcr.io/hasegama/devcontainer-features/cursor-cli`. The publish step is a
no-op if `version` is unchanged, so bumping it is required to roll out any
install-logic fix as well.

## Quick usage

```bash
agent --version
agent --help
```

The primary command is `agent`. `cursor-agent` is a legacy alias installed
alongside it.


---

_Note: This file was auto-generated from the [devcontainer-feature.json](https://github.com/hasegama/devcontainer-features/blob/main/src/cursor-cli/devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
