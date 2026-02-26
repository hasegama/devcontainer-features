#!/bin/bash

set -e

if ! command -v gemini >/dev/null 2>&1; then
    echo "gemini command not found"
    exit 1
fi

if ! gemini --help >/dev/null 2>&1; then
    echo "gemini help failed"
    exit 1
fi

echo "gemini installation test passed!"
exit 0
