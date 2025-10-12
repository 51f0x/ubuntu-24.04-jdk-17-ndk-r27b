FROM ubuntu:noble-20250805

# Set environment variables for Java
ENV JAVA_HOME /usr/lib/jvm/java-17-openjdk-amd64
ENV PATH $PATH:$JAVA_HOME/bin

# Install essential packages and Java 17
RUN apt-get update && apt-get install -y \
    wget \
    curl \
    unzip \
    build-essential \
    openjdk-17-jdk \
    software-properties-common \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Add the official Git PPA
RUN add-apt-repository ppa:git-core/ppa
# Update package list and install the latest stable Git version
RUN apt-get update && apt-get install -y git

# Install Node.js 20.19.4
RUN wget https://nodejs.org/dist/v20.19.4/node-v20.19.4-linux-x64.tar.xz \
    && tar -xJf node-v20.19.4-linux-x64.tar.xz -C /usr/local --strip-components=1 \
    && rm node-v20.19.4-linux-x64.tar.xz

# Update npm to 10.9.3 and install Yarn, pnpm, node-gyp, and eas-cli
RUN npm install -g npm@10.9.3 \
    && npm install -g yarn@1.22.22 pnpm@10.14.0 node-gyp@11.3.0 eas-cli

# Install Bun 1.2.20 using wget
ENV BUN_INSTALL /usr/local
RUN wget -qO- https://bun.sh/install | bash -s "bun-v1.2.20"

# Install Android NDK 27.1.12297006
RUN wget https://dl.google.com/android/repository/android-ndk-r27b-linux.zip \
    && unzip android-ndk-r27b-linux.zip -d /opt \
    && rm android-ndk-r27b-linux.zip

ENV NDK_HOME /opt/android-ndk-r27b

# Install Android SDK command-line tools
RUN wget https://dl.google.com/android/repository/commandlinetools-linux-7583922_latest.zip \
    && mkdir -p /opt/android-sdk/cmdline-tools \
    && unzip commandlinetools-linux-7583922_latest.zip -d /opt/android-sdk/cmdline-tools \
    && mv /opt/android-sdk/cmdline-tools/cmdline-tools /opt/android-sdk/cmdline-tools/latest \
    && rm commandlinetools-linux-7583922_latest.zip

# Set environment variables for Android SDK
ENV ANDROID_HOME /opt/android-sdk
ENV PATH $PATH:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools

# Install required Android SDK components
RUN yes | sdkmanager --licenses \
    && sdkmanager "platform-tools" "platforms;android-33" "build-tools;33.0.0"

# Install Maestro 2.0.2
RUN wget https://github.com/mobile-dev-inc/maestro/releases/download/cli-2.0.2/maestro.zip \
    && unzip maestro.zip -d /opt \
    && rm maestro.zip

ENV PATH $PATH:/opt/maestro/bin

# Hardcode the EAS build command with a default profile
CMD ["bash", "-c", "eas build --platform android --local --profile ${PROFILE:-development}"]