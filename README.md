# hasegama/devcontainer-features

> This devcontainer-features repository has been customized by hasegama for personal development use. The primary motivation for creating this custom collection was to pin specific versions of ClaudeCode installations.

## Features Included

- `claude-code`: Installs the Claude Code CLI (pinned version) and VS Code extension.
- `ccusage`: Installs the ccusage CLI for analyzing Claude Code token usage (`npm install -g ccusage`).
- `codex`: Installs the OpenAI Codex CLI (`npm install -g @openai/codex`).

## Example devcontainer.json snippet

```jsonc
{
	"image": "mcr.microsoft.com/devcontainers/base:ubuntu",
	"features": {
		"ghcr.io/devcontainers/features/node:1": {},
		"ghcr.io/hasegama/devcontainer-features/claude-code:latest": {},
		"ghcr.io/hasegama/devcontainer-features/ccusage:latest": {},
		"ghcr.io/hasegama/devcontainer-features/codex:latest": {}
	}
}
```
