# ccusage Dev Container Feature

Installs the [ccusage](https://github.com/ryoppippi/ccusage) CLI globally via `npm install -g ccusage`.

## Example Usage

```jsonc
{
  "image": "mcr.microsoft.com/devcontainers/base:ubuntu",
  "features": {
    "ghcr.io/devcontainers/features/node:1": {},
    "ghcr.io/hasegama/devcontainer-features/ccusage:1": {}
  }
}
```

Once the container rebuilds:

```bash
ccusage --help
ccusage daily --json
```

## Notes

- This feature expects Node.js (it will attempt to install Node 18 LTS if not present, mirroring the `claude-code` feature's logic).
- If you already include the official Node feature, it will just install the CLI.
