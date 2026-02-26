#!/bin/bash

set -e

source dev-container-features-test-lib

check "claude cli installed" command -v claude
check "claude version" claude --version

reportResults