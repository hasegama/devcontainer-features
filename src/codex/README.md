
# OpenAI Codex CLI (codex)

Installs the OpenAI Codex CLI globally

## Example Usage

```json
"features": {
    "ghcr.io/hasegama/devcontainer-features/codex:1": {}
}
```

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|


# Using OpenAI Codex in devcontainers

## Requirements

Requires Node.js and npm to be present. You can:

1. Use an image that already ships with Node.js
2. Add the official Node feature
3. Rely on this feature's best-effort Node.js install (Debian/Ubuntu, Alpine, Fedora, RHEL, CentOS)

Node.js 18.x LTS is installed when auto-install is needed.

## Recommended configuration

```json
"features": {
    "ghcr.io/devcontainers/features/node:1": {},
    "ghcr.io/hasegama/devcontainer-features/codex:1": {}
}
```

## Using with existing Node.js

```json
"features": {
    "ghcr.io/hasegama/devcontainer-features/codex:1": {}
}
```

## What this installs

```bash
npm install -g @openai/codex
```

## Quick usage

```bash
codex --help
codex --version
```

## Notes

If you manage Node.js with tools like nvm/asdf inside the container, ensure the global npm prefix is on PATH when the feature runs (the standard global prefix is already covered for system installs).


---

_Note: This file was auto-generated from the [devcontainer-feature.json](https://github.com/hasegama/devcontainer-features/blob/main/src/codex/devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
