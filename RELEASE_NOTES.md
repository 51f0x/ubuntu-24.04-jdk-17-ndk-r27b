# Release Notes

## v0.1.0 - Initial Release (2025-10-12)

### 🎉 Overview

First stable release of the **EAS Local Android Build Image** - a Docker-based environment for building Android applications locally with EAS (Expo Application Services). This eliminates the need for cloud build minutes and provides full control over your build environment.

### ✨ What's Included

This release provides a complete Android development environment based on Ubuntu 24.04 with all necessary tools pre-configured.

#### Core Development Tools
- **Ubuntu 24.04 Noble** (GCE image: ubuntu-2404-noble-amd64-v20250805)
- **Java 17** (OpenJDK) - `openjdk-17-jdk`
- **Android NDK** 27.1.12297006 (r27b)
- **Android SDK** with command-line tools 7583922
  - Platform Tools
  - Platforms: Android 33, 35, 36
  - Build Tools: 33.0.0, 35.0.0, 36.0.0
- **Git** (latest stable from official PPA)

#### JavaScript Runtime & Package Managers
- **Node.js** 20.19.4
- **npm** 10.9.3
- **Yarn** 1.22.22
- **pnpm** 10.14.0
- **Bun** 1.2.20
- **node-gyp** 11.3.0

#### Mobile Development & Testing
- **EAS CLI** (latest)
- **Maestro** 2.0.2 - Mobile UI testing framework

### 🚀 Key Features

#### Convenience Script (`eas-build.zsh`)
A powerful wrapper script that simplifies Docker/Podman operations:

**Available Commands:**
- `build-image` - Build the Docker image
- `build [profile]` - Run EAS build (development/preview/production)
- `shell` - Interactive bash shell for debugging
- `maestro <file>` - Run Maestro UI tests
- `install [pm]` - Install dependencies (npm/yarn/pnpm/bun)
- `run <command>` - Execute custom commands
- `clean` - Clean build artifacts
- `info` - Show image information
- `help` - Display help message

**Features:**
- ✅ Color-coded output for better readability
- ✅ Automatic image checking with build prompts
- ✅ Support for both Docker and Podman
- ✅ Interactive prompts for destructive operations
- ✅ Configurable resource limits (memory, CPU)
- ✅ Flexible working directory mounting

#### Resource Configuration
Default resource limits (configurable via environment variables):
- **Memory:** 10GB
- **Memory + Swap:** 16GB (10GB + 6GB swap)
- **CPUs:** 6 cores

### 📦 Installation

#### Quick Start

```bash
# 1. Build the image (one-time setup)
cd /path/to/ubuntu-24.04-jdk-17-ndk-r27b
./eas-build.zsh build-image

# 2. Make script globally accessible (optional)
sudo ln -s $(pwd)/eas-build.zsh /usr/local/bin/eas-build

# 3. Use from your mobile app directory
cd /path/to/your/mobile-app
eas-build build development
```

### 📖 Documentation

This release includes comprehensive documentation:

- **[README.md](./README.md)** - Overview and features
- **[QUICKSTART.md](./QUICKSTART.md)** - Fast getting started guide (⚡ start here!)
- **[INSTALL.md](./INSTALL.md)** - Detailed installation and setup
- **[USAGE.md](./USAGE.md)** - Usage examples, workflows, and troubleshooting

### 💡 Use Cases

Perfect for:
- 🏢 Teams with strict data privacy requirements
- 💰 Developers looking to reduce cloud build costs
- 🚀 CI/CD pipelines requiring fast, reproducible builds
- 🧪 Testing and experimentation without consuming cloud credits
- 🔧 Developers who prefer local development workflows

### ⚠️ Known Limitations

- **Android only** - iOS builds require macOS/Xcode
- **Large disk usage** - Initial image build requires ~5-8GB
- **Build times** - Depend on host hardware capabilities
- **Cloud features** - Some EAS features (distribution, store submissions) still require cloud services

### 🔐 Security Notes

- Android SDK licenses are automatically accepted during image build
- All tools are downloaded from official sources
- Review the Dockerfile before building if security is a concern
- Keep the image updated for security patches

### 🎯 Compatibility

**Container Engines:**
- Docker (all recent versions)
- Podman (all recent versions)

**Host Operating Systems:**
- Linux (Ubuntu, Debian, Fedora, etc.)
- macOS (with Docker Desktop or Podman)
- Windows (with Docker Desktop or WSL2 + Podman)

**Shells:**
- Zsh (primary)
- Bash (compatible)

### 🙏 Acknowledgments

Inspired by [eas-like-local-builder](https://github.com/erayalakese/eas-like-local-builder) and adapted from [Expo Build Infrastructure Reference](https://docs.expo.dev/build-reference/infrastructure/).

### 📝 Breaking Changes

None - this is the initial release.

### 🐛 Bug Fixes

None - this is the initial release.

### 🔄 Migration Guide

None - this is the initial release.

### 📦 Assets

**Docker Image Size:** ~5-8GB (compressed)

**Required Files:**
- `Dockerfile` - Image definition
- `eas-build.zsh` - Convenience script
- Documentation files (README, QUICKSTART, INSTALL, USAGE)
- `.gitignore` - Git exclusions

### 🚦 Getting Help

- Check the [USAGE.md](./USAGE.md) troubleshooting section
- Review [Expo EAS Build Documentation](https://docs.expo.dev/build/introduction/)
- Open an issue in the repository

### 📅 What's Next?

Planned for future releases:
- Additional Android SDK versions
- More JavaScript runtime versions
- Performance optimizations
- Enhanced CI/CD integration examples
- Additional testing tools

---

**Download and start building locally! 🛠️**

