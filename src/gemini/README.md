
# Google Gemini CLI (gemini)

Installs the Google Gemini CLI globally

## Example Usage

```json
"features": {
    "ghcr.io/hasegama/devcontainer-features/gemini:1": {}
}
```

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|


# Using Google Gemini CLI in devcontainers

## Requirements

Requires Node.js and npm to be present. Gemini CLI requires **Node.js 20 or higher**. You can:

1. Use an image that already ships with Node.js 20+
2. Add the official Node feature (use a version that provides Node 20+)
3. Rely on this feature's best-effort Node.js install (Debian/Ubuntu, Alpine, Fedora, RHEL, CentOS)

Node.js 20.x LTS is installed when auto-install is needed (where the package manager supports it).

## Recommended configuration

```json
"features": {
    "ghcr.io/devcontainers/features/node:1": {},
    "ghcr.io/hasegama/devcontainer-features/gemini:1": {}
}
```

## Using with existing Node.js

```json
"features": {
    "ghcr.io/hasegama/devcontainer-features/gemini:1": {}
}
```

## What this installs

```bash
npm install -g @google/gemini-cli
```

## Quick usage

```bash
gemini --help
gemini --version
```

## Notes

If you manage Node.js with tools like nvm/asdf inside the container, ensure the global npm prefix is on PATH when the feature runs (the standard global prefix is already covered for system installs). Ensure Node.js version is 20 or higher for Gemini CLI.


---

_Note: This file was auto-generated from the [devcontainer-feature.json](https://github.com/hasegama/devcontainer-features/blob/main/src/gemini/devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
