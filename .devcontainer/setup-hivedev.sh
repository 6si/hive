#!/bin/bash
# Ensure SDKMAN is loaded
export SDKMAN_DIR="/usr/local/sdkman"
[[ -s "${SDKMAN_DIR}/bin/sdkman-init.sh" ]] && source "${SDKMAN_DIR}/bin/sdkman-init.sh"

# Install the necessary JDKs for Hive 3 and 4
sdk install java 8.0.402-amzn
sdk install java 11.0.22-amzn
sdk install java 17.0.10-amzn

# Set default to 11 (good middle ground for Hive 4)
sdk default java 11.0.22-amzn

# Pre-fetch some Hive dependencies to save time
mvn dependency:go-offline -DskipTests || true