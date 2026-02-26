#!/bin/bash

set -e

source dev-container-features-test-lib

check "node version" node --version
check "npm version" npm --version
check "gemini installed" command -v gemini
check "gemini help" gemini --help

reportResults
