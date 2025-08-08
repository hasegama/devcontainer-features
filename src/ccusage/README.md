
# ccusage CLI (ccusage)

Installs the ccusage CLI globally (npm install -g ccusage)

## Example Usage

```json
"features": {
    "ghcr.io/hasegama/devcontainer-features/ccusage:1": {}
}
```

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|


# Using ccusage in devcontainers

## Requirements

This feature requires Node.js and npm in the container. You can either:

1. Use a base image that already includes Node.js, or
2. Add the official Node.js feature to `devcontainer.json`, or
3. Let this feature attempt to install Node.js automatically (best-effort on Debian/Ubuntu, Alpine, Fedora, RHEL, CentOS)

Note: When auto-installing, a recent LTS line (Node.js 18.x) is used.

## Recommended configuration

Explicitly adding the Node feature is the most predictable:

```json
"features": {
    "ghcr.io/devcontainers/features/node:1": {},
    "ghcr.io/hasegama/devcontainer-features/ccusage:1": {}
}
```

## Using with existing Node.js

If your base image already has Node.js (or you manage it with nvm/asdf), you can just include ccusage:

```json
"features": {
    "ghcr.io/hasegama/devcontainer-features/ccusage:1": {}
}
```

## What this installs

Runs:

```bash
npm install -g ccusage
```

## Quick usage

```bash
ccusage          # Daily report (default)
ccusage daily --json
ccusage monthly
```

## Data source

ccusage reads Claude Code JSONL usage files (typically under `~/.claude/projects/`). Mount/bind that path into the devcontainer if you need host data.


---

_Note: This file was auto-generated from the [devcontainer-feature.json](https://github.com/hasegama/devcontainer-features/blob/main/src/ccusage/devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
