#!/bin/bash

set -e

source dev-container-features-test-lib

check "gemini installed" command -v gemini
check "gemini help" gemini --help

reportResults
