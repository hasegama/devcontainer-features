#!/bin/bash
set -e

source dev-container-features-test-lib

check "node version" node --version
check "npm version" npm --version
check "ccusage installed" command -v ccusage
check "ccusage help" ccusage --help

reportResults
