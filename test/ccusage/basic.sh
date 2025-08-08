#!/bin/bash
set -e

if ! command -v ccusage &> /dev/null; then
  echo "ccusage command not found"
  exit 1
fi

# Basic invocation (help)
if ! ccusage --help >/dev/null 2>&1; then
  echo "ccusage help failed"
  exit 1
fi

echo "ccusage installation test passed!"
