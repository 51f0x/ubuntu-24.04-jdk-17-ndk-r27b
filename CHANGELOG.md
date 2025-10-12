# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.0] - 2025-10-12

### Added
- Initial release of EAS Local Android Build Docker image
- Ubuntu 24.04 Noble base image (ubuntu-2404-noble-amd64-v20250805)
- Java 17 (OpenJDK) development environment
- Android NDK 27.1.12297006 (r27b)
- Android SDK with command-line tools 7583922
- Android platforms: 33, 35, 36
- Android build-tools: 33.0.0, 35.0.0, 36.0.0
- Node.js 20.19.4 with npm 10.9.3
- JavaScript package managers: Yarn 1.22.22, pnpm 10.14.0, Bun 1.2.20
- node-gyp 11.3.0 for native module compilation
- EAS CLI for Expo Application Services
- Maestro 2.0.2 for mobile UI testing
- Git (latest stable from official PPA)
- Convenience script `eas-build.zsh` with comprehensive commands
- Support for Docker and Podman container engines
- Configurable resource limits (memory, CPU, swap)
- Comprehensive documentation suite:
  - README.md - Project overview
  - QUICKSTART.md - Quick start guide
  - INSTALL.md - Installation instructions
  - USAGE.md - Usage examples and troubleshooting
- Build profiles support: development, preview, production
- Interactive shell mode for debugging
- Custom command execution support
- Dependency installation with multiple package managers
- Build artifact cleaning functionality
- Image information display
- Color-coded CLI output
- Automatic image checking with build prompts
- Environment variable configuration support
- .gitignore for common build artifacts

### Changed
- N/A (initial release)

### Deprecated
- N/A (initial release)

### Removed
- N/A (initial release)

### Fixed
- N/A (initial release)

### Security
- Android SDK licenses automatically accepted
- All tools downloaded from official sources only

[0.1.0]: https://github.com/yourusername/ubuntu-24.04-jdk-17-ndk-r27b/releases/tag/v0.1.0

