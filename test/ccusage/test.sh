#!/bin/bash
set -e

source dev-container-features-test-lib

check "node version" node --version
check "npm version" npm --version
check "ccusage installed" command -v ccusage

# Prepare dummy Claude data directories to satisfy ccusage path check
mkdir -p /root/.claude/projects /root/.config/claude/projects
export CLAUDE_CONFIG_DIR=/root/.claude

# Use --help (reads code path) after directories exist
check "ccusage help" ccusage --help

reportResults
