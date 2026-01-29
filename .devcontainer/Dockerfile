FROM ubuntu:22.04

ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=1000

ENV DEBIAN_FRONTEND=noninteractive
ENV MAVEN3_HOME=/opt/maven3
ENV MAVEN4_HOME=/opt/maven4

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates curl wget git unzip tar gnupg2 software-properties-common apt-transport-https && \
    rm -rf /var/lib/apt/lists/*;

# Install OpenJDK 11 and 17 from default repos
RUN apt-get update && apt-get install -y --no-install-recommends openjdk-11-jdk openjdk-17-jdk && rm -rf /var/lib/apt/lists/*;

# Install Temurin (Adoptium) JDK 8 for Java 8 compatibility used by Hive 3.x
RUN wget -qO - https://packages.adoptium.net/artifactory/api/gpg/key/public | gpg --dearmor -o /usr/share/keyrings/adoptium.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/adoptium.gpg] https://packages.adoptium.net/artifactory/deb jammy main" > /etc/apt/sources.list.d/adoptium.list && \
    apt-get update && apt-get install -y --no-install-recommends temurin-8-jdk && \
    rm -rf /var/lib/apt/lists/*;

# Install Maven 3.8.8
RUN wget -qO /tmp/maven3.tar.gz https://archive.apache.org/dist/maven/maven-3/3.8.8/binaries/apache-maven-3.8.8-bin.tar.gz \
 && tar -xzf /tmp/maven3.tar.gz -C /opt \
 && ln -s /opt/apache-maven-3.8.8 ${MAVEN3_HOME} \
 && rm /tmp/maven3.tar.gz

# Install Maven 4.0.0
RUN wget -qO /tmp/maven4.tar.gz https://archive.apache.org/dist/maven/maven-4/4.0.0/binaries/apache-maven-4.0.0-bin.tar.gz \
 && tar -xzf /tmp/maven4.tar.gz -C /opt \
 && ln -s /opt/apache-maven-4.0.0 ${MAVEN4_HOME} \
 && rm /tmp/maven4.tar.gz

# Configure alternatives for mvn (maven4 has higher priority by default)
RUN update-alternatives --install /usr/bin/mvn mvn ${MAVEN3_HOME}/bin/mvn 100 \
 && update-alternatives --install /usr/bin/mvn mvn ${MAVEN4_HOME}/bin/mvn 200

# Configure java alternatives
RUN update-alternatives --install /usr/bin/java java /usr/lib/jvm/java-11-openjdk-amd64/bin/java 100 \
 && update-alternatives --install /usr/bin/java java /usr/lib/jvm/java-17-openjdk-amd64/bin/java 200 \
 && update-alternatives --install /usr/bin/java java /usr/lib/jvm/temurin-8-jdk-amd64/bin/java 300 || true

# Helper scripts to switch
RUN printf '#!/bin/sh\nupdate-alternatives --set mvn ${MAVEN3_HOME}/bin/mvn\n' > /usr/local/bin/use-maven3 && \
    printf '#!/bin/sh\nupdate-alternatives --set mvn ${MAVEN4_HOME}/bin/mvn\n' > /usr/local/bin/use-maven4 && \
    printf '#!/bin/sh\nupdate-alternatives --set java /usr/lib/jvm/java-11-openjdk-amd64/bin/java\n' > /usr/local/bin/use-java11 && \
    printf '#!/bin/sh\nupdate-alternatives --set java /usr/lib/jvm/java-17-openjdk-amd64/bin/java\n' > /usr/local/bin/use-java17 && \
    printf '#!/bin/sh\nupdate-alternatives --set java /usr/lib/jvm/temurin-8-jdk-amd64/bin/java\n' > /usr/local/bin/use-java8 && \
    chmod +x /usr/local/bin/use-* && sync

# Create non-root user (vscode)
RUN groupadd --gid ${USER_GID} ${USERNAME} || true && \
    useradd -s /bin/bash --uid ${USER_UID} --gid ${USER_GID} -m ${USERNAME} || true

ENV JAVA_HOME=/usr/lib/jvm/temurin-8-jdk-amd64
ENV MAVEN_HOME=${MAVEN4_HOME}
ENV PATH=${JAVA_HOME}/bin:${MAVEN_HOME}/bin:${PATH}

WORKDIR /workspace

USER ${USERNAME}
