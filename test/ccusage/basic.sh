#!/bin/bash
set -e

if ! command -v ccusage &> /dev/null; then
  echo "ccusage command not found"
  exit 1
fi

# Basic invocation (help)
CLAUDE_MOCK_DIR="${HOME}/.claude"
mkdir -p "${CLAUDE_MOCK_DIR}/projects"
export CLAUDE_CONFIG_DIR="${CLAUDE_MOCK_DIR}"

if ! ccusage --help >/dev/null 2>&1; then
  echo "ccusage help failed"
  exit 1
fi

echo "ccusage installation test passed!"
