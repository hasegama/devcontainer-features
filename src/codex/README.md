# OpenAI Codex Dev Container Feature

Installs the `@openai/codex` CLI globally via `npm install -g @openai/codex`.

## Example Usage

```jsonc
{
  "image": "mcr.microsoft.com/devcontainers/base:ubuntu",
  "features": {
    "ghcr.io/devcontainers/features/node:1": {},
    "ghcr.io/hasegama/devcontainer-features/codex:1": {}
  }
}
```

After rebuild:

```bash
codex --help
```

## Notes
 
- Will attempt to install Node.js 18 LTS if Node.js is not already present (same logic as other features here).
