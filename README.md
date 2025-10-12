# EAS-Like Local Android Build Image

A Docker image for building Android applications locally with EAS (Expo Application Services), eliminating the need for cloud build minutes. This image includes all necessary tools for React Native and Expo Android development.

This image is adapted to ubuntu-24.04-jdk-17-ndk-r27b of [Expo Reference](https://docs.expo.dev/build-reference/infrastructure/).

> **🚀 New here?** Check out the [QUICKSTART.md](./QUICKSTART.md) guide for a step-by-step walkthrough!

## 🚀 What's Inside

This Docker image is packed with everything you need for Android development:

### Core Tools
- **Ubuntu 24.04 Noble** (GCE image: ubuntu-2404-noble-amd64-v20250805)
- **Java 17** (OpenJDK)
- **Android NDK** 27.1.12297006 (r27b)
- **Android SDK** with command-line tools, platform-tools, and build-tools

### JavaScript Runtime & Package Managers
- **Node.js** 20.19.4
- **npm** 10.9.3
- **Yarn** 1.22.22
- **pnpm** 10.14.0
- **Bun** 1.2.20
- **node-gyp** 11.3.0

### Mobile Development Tools
- **EAS CLI** (Expo Application Services)
- **Maestro** 2.0.2 (Mobile UI testing framework)
- **Git** (latest stable version)

## 🚀 Quick Start with Convenience Script

For the easiest experience, use the included `eas-build.zsh` script.

### Setup

**Option A: Add to PATH (Recommended)**

```bash
# Add to your ~/.zshrc or ~/.bashrc
export PATH="$PATH:/home/51f0xprojects/ubuntu-24.04-jdk-17-ndk-r27b"

# Or create a symlink
sudo ln -s /home/51f0xprojects/ubuntu-24.04-jdk-17-ndk-r27b/eas-build.zsh /usr/local/bin/eas-build
```

**Option B: Run from Mobile App Directory**

Navigate to your mobile app and reference the script with full path:

```bash
cd /path/to/your/mobile-app
/home/51f0xprojects/ubuntu-24.04-jdk-17-ndk-r27b/eas-build.zsh build
```

### Usage

**IMPORTANT:** The script must be run from your mobile app directory, or you must specify `RUNNER_WORK_DIR`.

```bash
# Navigate to your mobile app first
cd /path/to/your/mobile-app

# Then run builds
eas-build.zsh build-image      # First time only
eas-build.zsh build development
eas-build.zsh build production
eas-build.zsh shell
eas-build.zsh install yarn
eas-build.zsh help
```

Or specify the app directory explicitly:

```bash
RUNNER_WORK_DIR=/path/to/mobile-app eas-build.zsh build
```

The script supports both Docker and Podman:
```bash
CONTAINER_ENGINE=podman eas-build.zsh build
```

## 📦 Building the Image

### Using the Convenience Script

```bash
./eas-build.zsh build-image
```

### Manual Build

To build this Docker image manually:

```bash
docker build -t 51f0x/ubuntu-24.04-jdk-17-ndk-r27b .
```

Or with a custom tag:

```bash
docker build -t 51f0x/ubuntu-24.04-jdk-17-ndk-r27b:latest .
```

### Using Podman

If you prefer Podman over Docker:

```bash
podman build -t ubuntu-24.04-jdk-17-ndk-r27b .
```

## 🏃 Running the Container

### Using the Convenience Script (Recommended)

**NOTE:** Run these commands from your mobile app directory:

```bash
cd /path/to/your/mobile-app

# Default development build
eas-build.zsh build

# Specific profile
eas-build.zsh build production

# Interactive shell
eas-build.zsh shell
```

### Manual Docker Commands

#### Quick Start with Default Profile

```bash
docker run --rm -v $(pwd):/app -w /app ubuntu-24.04-jdk-17-ndk-r27b
```

This will run EAS build with the default `development` profile.

#### Custom Build Profile

Specify a different build profile using the `PROFILE` environment variable:

```bash
docker run --rm -v $(pwd):/app -w /app -e PROFILE=production ubuntu-24.04-jdk-17-ndk-r27b
```

#### Interactive Mode

For debugging or manual operations, run the container interactively:

```bash
docker run --rm -it -v $(pwd):/app -w /app ubuntu-24.04-jdk-17-ndk-r27b bash
```

#### Podman Alternative

```bash
podman run --rm -v $(pwd):/app -w /app ubuntu-24.04-jdk-17-ndk-r27b
```

## 💡 Use Cases

### Local EAS Builds

Build your Expo Android app locally without consuming cloud build minutes:

```bash
# Using convenience script
./eas-build.zsh build preview

# Or manually
docker run --rm \
  -v $(pwd):/app \
  -w /app \
  -e PROFILE=preview \
  ubuntu-24.04-jdk-17-ndk-r27b
```

### Running Maestro Tests

Access Maestro CLI for automated UI testing:

```bash
# Using convenience script
./eas-build.zsh maestro tests/login-flow.yaml

# Or manually
docker run --rm -it \
  -v $(pwd):/app \
  -w /app \
  ubuntu-24.04-jdk-17-ndk-r27b \
  bash -c "maestro test your-flow.yaml"
```

### Custom Build Scripts

Execute your own build scripts:

```bash
# Using convenience script
./eas-build.zsh run "npm install && npm run build:android"

# Or manually
docker run --rm \
  -v $(pwd):/app \
  -w /app \
  ubuntu-24.04-jdk-17-ndk-r27b \
  bash -c "npm install && npm run build:android"
```

### Installing Dependencies

Quickly install dependencies with your preferred package manager:

```bash
./eas-build.zsh install npm    # or yarn, pnpm, bun
```

### Cleaning Build Artifacts

Clean up build artifacts and node_modules:

```bash
./eas-build.zsh clean
```

## 🛠️ Convenience Script Features

The `eas-build.zsh` script provides several convenient features:

### Available Commands

| Command | Description | Example |
|---------|-------------|---------|
| `build-image` | Build the Docker image | `./eas-build.zsh build-image` |
| `build [profile]` | Run EAS build with specified profile | `./eas-build.zsh build production` |
| `shell` | Start interactive bash shell | `./eas-build.zsh shell` |
| `maestro <file>` | Run Maestro UI tests | `./eas-build.zsh maestro test.yaml` |
| `install [pm]` | Install dependencies | `./eas-build.zsh install yarn` |
| `run <command>` | Execute custom command | `./eas-build.zsh run "npm test"` |
| `clean` | Clean build artifacts | `./eas-build.zsh clean` |
| `info` | Show image information | `./eas-build.zsh info` |
| `help` | Display help message | `./eas-build.zsh help` |

### Script Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `CONTAINER_ENGINE` | `podman` | Container engine to use (docker/podman) |
| `RUNNER_WORK_DIR` | Current directory | Working directory to mount |
| `RUNNER_MEMORY` | 10g | Memory limit for container |
| `RUNNER_MEMORY_SWAP` | 16g | Total memory + swap limit (10g memory + 6g swap) |
| `RUNNER_CPUS` | 4 | Number of CPUs for container |

### Features

- ✅ **Color-coded output** for better readability
- ✅ **Automatic image checking** - prompts to build if image not found
- ✅ **Support for both Docker and Podman**
- ✅ **Interactive prompts** for destructive operations
- ✅ **Error handling** with meaningful messages
- ✅ **Flexible working directory** mounting

## 🎯 Environment Variables

### Container Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `PROFILE` | `development` | EAS build profile to use |
| `JAVA_HOME` | `/usr/lib/jvm/java-17-openjdk-amd64` | Java installation path |
| `ANDROID_HOME` | `/opt/android-sdk` | Android SDK location |
| `NDK_HOME` | `/opt/android-ndk-r27b` | Android NDK location |
| `BUN_INSTALL` | `/usr/local` | Bun installation directory |

## 🎨 The Vibe

This image is all about **developer freedom** and **cost efficiency**. No more waiting for cloud build queues or worrying about build minute limits. Build your Android apps on your own hardware, with full control over the environment and dependencies.

Perfect for:
- 🏢 Teams with strict data privacy requirements
- 💰 Developers looking to reduce cloud build costs
- 🚀 CI/CD pipelines that need fast, reproducible builds
- 🧪 Testing and experimentation without burning through credits
- 🔧 Developers who prefer local development workflows

## ⚠️ Disclaimer

This Docker image is provided **as-is** without any warranties or guarantees. While it includes up-to-date tools and dependencies, please note:

- **Not officially affiliated** with Expo or the EAS team
- Build times depend on your hardware capabilities
- Some EAS features may require cloud services (e.g., distribution, submissions)
- Android SDK licenses must be accepted (handled automatically in the image)
- Large builds may consume significant disk space and memory
- This image is designed for Android builds only (iOS builds require macOS/Xcode)

### Security Considerations

- This image downloads and installs software from various sources
- Review the Dockerfile before building if security is a concern
- Keep the image updated to receive security patches
- Avoid running untrusted code in the container

## 🤝 Contributing

Feel free to submit issues, fork the repository, and send pull requests! Contributions are welcome.

## 📄 License

This project is open source and available for use, modification, and distribution.

## 📖 Documentation

- **[QUICKSTART.md](./QUICKSTART.md)** - ⚡ Fast getting started guide (start here!)
- **[INSTALL.md](./INSTALL.md)** - Installation and setup instructions
- **[USAGE.md](./USAGE.md)** - Detailed usage examples, workflows, and troubleshooting

## 🙏 Acknowledgments

Inspired by [eas-like-local-builder](https://github.com/erayalakese/eas-like-local-builder) and the broader React Native/Expo community.

---

**Happy Building! 🛠️**

