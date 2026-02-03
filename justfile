# Hive Development Build and Management Tasks

set shell := ["bash", "-c"]

# Default recipe - show help
default:
    @just --list

# ============================================================================
# Java Version Management
# ============================================================================

# Switch to Java 8
java8:
    #!/bin/bash
    export SDKMAN_DIR="/usr/local/sdkman"
    [[ -s "${SDKMAN_DIR}/bin/sdkman-init.sh" ]] && source "${SDKMAN_DIR}/bin/sdkman-init.sh"
    sdk default java 8.0.402-amzn
    java -version

# Switch to Java 11 (default for Hive 4)
java11:
    #!/bin/bash
    export SDKMAN_DIR="/usr/local/sdkman"
    [[ -s "${SDKMAN_DIR}/bin/sdkman-init.sh" ]] && source "${SDKMAN_DIR}/bin/sdkman-init.sh"
    sdk default java 11.0.22-amzn
    java -version

# Switch to Java 17
java17:
    #!/bin/bash
    export SDKMAN_DIR="/usr/local/sdkman"
    [[ -s "${SDKMAN_DIR}/bin/sdkman-init.sh" ]] && source "${SDKMAN_DIR}/bin/sdkman-init.sh"
    sdk default java 17.0.10-amzn
    java -version

# List installed Java versions
java-list:
    #!/bin/bash
    export SDKMAN_DIR="/usr/local/sdkman"
    [[ -s "${SDKMAN_DIR}/bin/sdkman-init.sh" ]] && source "${SDKMAN_DIR}/bin/sdkman-init.sh"
    sdk list java | head -30

# ============================================================================
# Maven Version Management
# ============================================================================

# Switch to Maven 3.6.x
maven36:
    #!/bin/bash
    export SDKMAN_DIR="/usr/local/sdkman"
    [[ -s "${SDKMAN_DIR}/bin/sdkman-init.sh" ]] && source "${SDKMAN_DIR}/bin/sdkman-init.sh"
    sdk default maven 3.6.3
    mvn --version

# Switch to Maven 3.8.x
maven38:
    #!/bin/bash
    export SDKMAN_DIR="/usr/local/sdkman"
    [[ -s "${SDKMAN_DIR}/bin/sdkman-init.sh" ]] && source "${SDKMAN_DIR}/bin/sdkman-init.sh"
    sdk default maven 3.8.8
    mvn --version

# Switch to Maven 3.9.x
maven39:
    #!/bin/bash
    export SDKMAN_DIR="/usr/local/sdkman"
    [[ -s "${SDKMAN_DIR}/bin/sdkman-init.sh" ]] && source "${SDKMAN_DIR}/bin/sdkman-init.sh"
    sdk default maven 3.9.6
    mvn --version

# List installed Maven versions
maven-list:
    #!/bin/bash
    export SDKMAN_DIR="/usr/local/sdkman"
    [[ -s "${SDKMAN_DIR}/bin/sdkman-init.sh" ]] && source "${SDKMAN_DIR}/bin/sdkman-init.sh"
    sdk list maven | head -30

# ============================================================================
# Build Tasks
# ============================================================================

# Clean the entire project
clean:
    mvn clean

# Build entire project with distribution package
build-without-tests:
    echo "=== building without tests ==="
    #mvn clean install -Pdist -Dtar -DskipTests=true -Dmaven.javadoc.skip=true

# Build with tests (slower, comprehensive)
build-with-tests:
    echo "=== building with tests ==="
    # mvn clean install -Pdist -Dtar -Dmaven.javadoc.skip=true

build-dist: build-with-tests
    #!/bin/bash
    file_name="apache-hive-3.1.3-bin.tar.gz"
    tar_generation_dir="hive_build_dist"
    ts="$(date -u +%Y%m%dT%H%M%SZ)"
    gdp_tar_name="apache-hive-3.1.3-bin-gdp-${ts}.tar.gz"
    echo "=== building tar ${gdp_tar_name} ==="
    if [ ! -f ./packaging/target/${file_name} ]; then \
      echo "ERROR: ./packaging/target/${file_name} is still missing after build"; \
      exit 2; \
    fi
    echo "=== Re-creating gdp tar ==="
    rm -rf ./${tar_generation_dir}
    mkdir ./${tar_generation_dir}
    cp ./packaging/target/apache-hive-3.1.3-bin.tar.gz ./${tar_generation_dir}/
    cd ./${tar_generation_dir}
    tar -zxvf apache-hive-3.1.3-bin.tar.gz
    rm apache-hive-3.1.3-bin.tar.gz
    echo "=== creating gdp tar ==="
    tar --numeric-owner --owner=1000 --group=1000 --mode=0754 -czf "${gdp_tar_name}" apache-hive-3.1.3-bin
    cd ../
    mv ./${tar_generation_dir}/${gdp_tar_name} ./
    rm -rf ./${tar_generation_dir}
    echo "=== gdp tar created ==="


aws-login:
    #!/bin/bash
    if aws sts get-caller-identity --profile=default-engineering &> /dev/null; then
      echo "Already logged in"
    else
      aws sso login --profile=default-engineering
    fi

upload-tar bucket_name='6si-customers-adhoc' prefix='big_data/resources/': aws-login
    #!/bin/bash
    if [ -z "{{bucket_name}}" ]; then
      echo "ERROR: bucket_name is required";
      echo "Usage: just upload-tar <bucket_name> [prefix]";
      exit 2;
    fi
    file="$(ls -1t apache-hive-3.1.3-bin-gdp-*.tar.gz 2>/dev/null | head -1)"
    if [ -z "${file}" ]; then
      echo "ERROR: No GDP tar found in current directory (expected apache-hive-3.1.3-bin-gdp-*.tar.gz)";
      exit 2;
    fi
    p="{{prefix}}"
    if [ -n "${p}" ] && [ "${p: -1}" != "/" ]; then
      p="${p}/"
    fi
    dest="s3://{{bucket_name}}/${p}$(basename "${file}")"
    echo "Uploading ${file} -> ${dest}"
    aws s3 cp "${file}" "${dest}"  --profile=default-engineering


# ============================================================================
# Module-specific Build Tasks
# ============================================================================

# Build core module
build-core:
    cd core && mvn clean install -DskipTests=true

# Build QL module
build-ql:
    cd ql && mvn clean install -DskipTests=true -Dmaven.javadoc.skip=true

# Build metastore module
build-metastore:
    cd metastore && mvn clean install -DskipTests=true

# Build LLAP module
build-llap:
    cd llap-server && mvn clean install -DskipTests=true -Dmaven.javadoc.skip=true

# Build CLI module
build-cli:
    cd cli && mvn clean install -DskipTests=true

# Build service module
build-service:
    cd service && mvn clean install -DskipTests=true

# Build HBase handler module
build-hbase-handler:
    cd hbase-handler && mvn clean install -DskipTests=true

# Build Druid handler module
build-druid-handler:
    cd druid-handler && mvn clean install -DskipTests=true

# ============================================================================
# Development Tasks
# ============================================================================

# Fetch dependencies only (no build)
fetch-deps:
    mvn dependency:go-offline -DskipTests

# Generate project documentation
generate-docs:
    mvn site:site

# Run checkstyle validation
checkstyle:
    mvn checkstyle:check

# Run findbugs analysis
findbugs:
    mvn findbugs:check

# Validate project structure
validate:
    mvn validate


# ============================================================================
# Utility Tasks
# ============================================================================

# Show current Java version
show-java:
    java -version

# Show current Maven version
show-maven:
    mvn --version

# Show SDKMAN environment
show-sdkman:
    #!/bin/bash
    echo "SDKMAN_DIR: ${SDKMAN_DIR:-not set}"
    echo "JAVA_HOME: ${JAVA_HOME:-not set}"
    echo "M2_HOME: ${M2_HOME:-not set}"
    echo ""
    echo "Current Java:"
    java -version
    echo ""
    echo "Current Maven:"
    mvn --version

# Clear local Maven cache (use with caution)
clear-m2-cache:
    rm -rf ~/.m2/repository/*
    echo "Maven cache cleared"

# Display build information
info:
    #!/bin/bash
    echo "=== Hive Build Environment ==="
    echo ""
    echo "Java Version:"
    java -version 2>&1 | head -1
    echo ""
    echo "Maven Version:"
    mvn --version 2>&1 | head -1
    echo ""
    echo "Workspace: /workspaces/hive"
    echo ""
    echo "Available commands:"
    echo "  Java:       java8, java11, java17, java-list"
    echo "  Maven:      maven36, maven38, maven39, maven-list"
    echo "  Build:      build, build-fast, build-dist, build-with-tests"
    echo "  Modules:    build-core, build-ql, build-metastore, build-llap, etc"
    echo "  Tools:      checkstyle, findbugs, validate"
    echo "  IDE:        eclipse, idea"
    echo ""

# Show this help
help: info
    @just --list
