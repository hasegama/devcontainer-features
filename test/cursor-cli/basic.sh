#!/bin/bash

set -e

if ! command -v agent >/dev/null 2>&1; then
    echo "agent command not found"
    exit 1
fi

if ! command -v cursor-agent >/dev/null 2>&1; then
    echo "cursor-agent command not found"
    exit 1
fi

if ! agent --version >/dev/null 2>&1; then
    echo "agent version check failed"
    exit 1
fi

echo "Cursor CLI installation test passed!"
exit 0
