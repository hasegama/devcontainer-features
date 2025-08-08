#!/bin/bash
set -e

if ! command -v ccusage &> /dev/null; then
  echo "ccusage command not found"
  exit 1
fi

# Basic invocation (help)
mkdir -p /root/.claude/projects /root/.config/claude/projects
export CLAUDE_CONFIG_DIR=/root/.claude

if ! ccusage --help >/dev/null 2>&1; then
  echo "ccusage help failed"
  exit 1
fi

echo "ccusage installation test passed!"
