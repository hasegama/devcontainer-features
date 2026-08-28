#!/bin/bash

set -e

source dev-container-features-test-lib

check "agent cli installed" command -v agent
check "cursor-agent alias installed" command -v cursor-agent
check "agent version" agent --version

reportResults
