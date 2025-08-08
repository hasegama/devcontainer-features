#!/bin/bash
set -e

source dev-container-features-test-lib

check "node version" node --version
check "npm version" npm --version
check "ccusage installed" command -v ccusage

# Prepare dummy Claude data directories (use $HOME to work under non-root images)
CLAUDE_MOCK_DIR="${HOME}/.claude"
mkdir -p "${CLAUDE_MOCK_DIR}/projects"
export CLAUDE_CONFIG_DIR="${CLAUDE_MOCK_DIR}"

# Use --help (reads code path) after directories exist
check "ccusage help" ccusage --help

reportResults
