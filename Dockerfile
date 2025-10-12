# syntax=docker/dockerfile:1.7
FROM ubuntu:24.04-slim

SHELL ["/bin/bash", "-o", "pipefail", "-c"]
ENV DEBIAN_FRONTEND=noninteractive

# -------- Version pins (edit in one place) --------
ARG JAVA_MAJOR=17
ARG NODE_VERSION=v20.19.4
ARG NPM_VERSION=10.9.3
ARG BUN_VERSION=1.2.20
ARG ANDROID_NDK=r27b               # 27.1.12297006
ARG SDKTOOLS_ZIP=commandlinetools-linux-11076708_latest.zip  # newer tools id
ARG MAESTRO_VERSION=2.0.2

# Optional checksums (fill with official shas)
ARG NODE_SHA256="d200798332b7a56d355888ce58e6a639fac7939a4833e5bc8780c66888e1ce4d"
ARG BUN_SHA256="4e9edc4cba0c7c1623a288be01e53bbde11a4d073f2cf339cab026627858b548"
ARG NDK_SHA256="33e16af1a6bbabe12cad54b2117085c07eab7e4fa67cdd831805f0e94fd826c1"
ARG SDKTOOLS_SHA256="2d2d50857e4eb553af5a6dc3ad507a17adf43d115264b1afc116f95c92e5e258"
ARG MAESTRO_SHA256="6ba03b6f09f7df7d40fdc2eb02f8022d89cad04b39e0eee11b794ef9757b2a2c"

# -------- Base packages in ONE layer (with cache) --------
RUN --mount=type=cache,target=/var/cache/apt \
    --mount=type=cache,target=/var/lib/apt \
    apt-get update && \
    apt-get install -y --no-install-recommends \
      sudo \
      ca-certificates \
      wget curl unzip xz-utils \
      build-essential \
      git \
      openjdk-${JAVA_MAJOR}-jdk \
      python3 python3-pip \
      zsh bash \
    && rm -rf /var/lib/apt/lists/*

# -------- Environment --------
ENV LANG=C.UTF-8 LC_ALL=C.UTF-8
ENV JAVA_HOME=/usr/lib/jvm/java-${JAVA_MAJOR}-openjdk-amd64
ENV ANDROID_HOME=/opt/android-sdk
ENV NDK_HOME=/opt/android-ndk-${ANDROID_NDK}
ENV PATH="$PATH:$JAVA_HOME/bin:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools:$NDK_HOME/toolchains/llvm/prebuilt/linux-x86_64/bin"

# -------- Create non-root user (uid/gid can be overridden) --------
ARG USERNAME=builder
ARG UID=1000
ARG GID=1000
RUN groupadd -g $GID $USERNAME && \
    useradd -m -u $UID -g $GID -s /bin/bash $USERNAME && \
    echo "$USERNAME ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
USER $USERNAME
WORKDIR /home/$USERNAME

# -------- Install Node (tarball) + npm pin --------
# Uses cache for tarball; verifies if you provide NODE_SHA256
RUN set -eux; \
    cd /tmp; \
    wget -q https://nodejs.org/dist/${NODE_VERSION}/node-${NODE_VERSION}-linux-x64.tar.xz; \
    if [ -n "${NODE_SHA256}" ]; then echo "${NODE_SHA256}  node-${NODE_VERSION}-linux-x64.tar.xz" | sha256sum -c -; fi; \
    sudo tar -xJf node-${NODE_VERSION}-linux-x64.tar.xz -C /usr/local --strip-components=1; \
    rm node-${NODE_VERSION}-linux-x64.tar.xz; \
    npm --version; \
    npm i -g npm@${NPM_VERSION}; \
    corepack enable; corepack prepare yarn@stable --activate; corepack prepare pnpm@latest --activate

# -------- Install Bun (archive, no curl|bash) --------
RUN set -eux; \
    cd /tmp; \
    wget -q https://github.com/oven-sh/bun/releases/download/bun-v${BUN_VERSION}/bun-linux-x64.zip; \
    if [ -n "${BUN_SHA256}" ]; then echo "${BUN_SHA256}  bun-linux-x64.zip" | sha256sum -c -; fi; \
    unzip -q bun-linux-x64.zip -d bun-tmp; \
    sudo mv bun-tmp/bun-linux-x64/bun /usr/local/bin/bun; \
    rm -rf bun-tmp bun-linux-x64.zip; \
    bun --version

# -------- Android NDK --------
RUN set -eux; \
    cd /tmp; \
    wget -q https://dl.google.com/android/repository/android-ndk-${ANDROID_NDK}-linux.zip -O ndk.zip; \
    if [ -n "${NDK_SHA256}" ]; then echo "${NDK_SHA256}  ndk.zip" | sha256sum -c -; fi; \
    sudo unzip -q ndk.zip -d /opt; \
    sudo chown -R builder:builder /opt/android-ndk-${ANDROID_NDK}; \
    rm -f ndk.zip

# -------- Android SDK cmdline-tools --------
RUN set -eux; \
    sudo mkdir -p ${ANDROID_HOME}/cmdline-tools; \
    cd /tmp; \
    wget -q https://dl.google.com/android/repository/${SDKTOOLS_ZIP} -O sdktools.zip; \
    if [ -n "${SDKTOOLS_SHA256}" ]; then echo "${SDKTOOLS_SHA256}  sdktools.zip" | sha256sum -c -; fi; \
    sudo unzip -q sdktools.zip -d ${ANDROID_HOME}/cmdline-tools; \
    sudo mv ${ANDROID_HOME}/cmdline-tools/cmdline-tools ${ANDROID_HOME}/cmdline-tools/latest; \
    sudo chown -R builder:builder ${ANDROID_HOME}; \
    rm -f sdktools.zip

# Accept licenses + base components (split for caching)
RUN yes | sdkmanager --licenses
RUN sdkmanager "platform-tools"
RUN sdkmanager "platforms;android-33" "build-tools;33.0.0"
RUN sdkmanager "platforms;android-35" "build-tools;35.0.0"
RUN sdkmanager "platforms;android-36" "build-tools;36.0.0"

# -------- Maestro CLI --------
RUN set -eux; \
    cd /tmp; \
    wget -q https://github.com/mobile-dev-inc/maestro/releases/download/cli-${MAESTRO_VERSION}/maestro.zip; \
    if [ -n "${MAESTRO_SHA256}" ]; then echo "${MAESTRO_SHA256}  maestro.zip" | sha256sum -c -; fi; \
    sudo unzip -q maestro.zip -d /opt; \
    sudo chmod +x /opt/maestro/bin/maestro; \
    sudo chown -R builder:builder /opt/maestro; \
    rm -f maestro.zip
ENV PATH="${PATH}:/opt/maestro/bin"

# -------- Default command (profile overridable) --------
CMD ["bash", "-lc", "eas build --platform android --local --profile ${PROFILE:-development}"]
