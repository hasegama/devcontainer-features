#!/bin/bash

set -e

if ! command -v codex >/dev/null 2>&1; then
    echo "codex command not found"
    exit 1
fi

if ! codex --help >/dev/null 2>&1; then
    echo "codex help failed"
    exit 1
fi

echo "codex installation test passed!"
exit 0