# Usage Guide

Quick reference guide for using the EAS Local Build Image.

## ⚠️ Important: Working Directory

**The script MUST be run from your mobile app directory**, or you must set `RUNNER_WORK_DIR` to point to your app.

The script mounts your current directory into the Docker container, so it needs access to your `package.json`, `app.json`, `eas.json`, and source code.

## 🚀 Getting Started

### 1. Build the Docker Image (One-Time Setup)

First, build the Docker image from the script directory:

```bash
cd /home/51f0x/projects/ubuntu-24.04-jdk-17-ndk-r27b
./eas-build.zsh build-image
```

This will take several minutes as it downloads and installs all dependencies.

### 2. Install the Script (Recommended)

Make the script accessible from anywhere:

```bash
# Option A: Create symlink
sudo ln -s /home/51f0x/projects/ubuntu-24.04-jdk-17-ndk-r27b/eas-build.zsh /usr/local/bin/eas-build

# Option B: Add to PATH in ~/.zshrc
export PATH="$PATH:/home/51f0x/projects/ubuntu-24.04-jdk-17-ndk-r27b"
```

See [INSTALL.md](./INSTALL.md) for detailed installation instructions.

### 3. Navigate to Your Expo Project

```bash
cd /path/to/your/expo-project
```

**This is crucial!** Your current directory will be mounted into the container.

### 4. Run Your First Build

```bash
# If you installed it globally
eas-build build development

# Or use full path
/home/51f0x/projects/ubuntu-24.04-jdk-17-ndk-r27b/eas-build.zsh build development
```

## 📋 Common Workflows

**Remember:** All commands below assume you're in your mobile app directory!

```bash
cd /path/to/your/mobile-app  # Always start here!
```

### Development Workflow

```bash
# Navigate to your app
cd /path/to/your/mobile-app

# Install dependencies
eas-build install yarn

# Run development build
eas-build build development

# If build fails, open shell for debugging
eas-build shell
```

### Production Release Workflow

```bash
# Navigate to your app
cd /path/to/your/mobile-app

# Clean previous build artifacts
eas-build clean

# Install fresh dependencies
eas-build install npm

# Run production build
eas-build build production
```

### Testing Workflow

```bash
# Navigate to your app
cd /path/to/your/mobile-app

# Install dependencies
eas-build install

# Run your tests
eas-build run "npm test"

# Run Maestro UI tests
eas-build maestro flows/login-test.yaml
```

### CI/CD Integration

In your CI/CD pipeline, the working directory is usually automatically set to your project root:

```bash
# In your CI/CD pipeline (e.g., .gitlab-ci.yml, .github/workflows/build.yml)
export CONTAINER_ENGINE=docker  # or podman

# Build image once (cache it if possible)
/path/to/eas-build.zsh build-image

# Run builds - CI is already in the project directory
/path/to/eas-build.zsh build production
```

Or explicitly set the working directory:

```bash
# If your CI uses a different structure
export RUNNER_WORK_DIR=$CI_PROJECT_DIR  # GitLab
export RUNNER_WORK_DIR=$GITHUB_WORKSPACE  # GitHub Actions

/path/to/eas-build.zsh build production
```

## 🔧 Debugging

### Open Interactive Shell

When something goes wrong, drop into an interactive shell:

```bash
./eas-build.zsh shell
```

Inside the container, you can:

```bash
# Check Node.js version
node --version

# Check npm version
npm --version

# Check Java version
java -version

# Check Android SDK
sdkmanager --list

# Check NDK
ls -la $NDK_HOME

# Manually run EAS
eas build --platform android --local --profile development
```

### View Container Logs

If using Docker:

```bash
docker logs <container-id>
```

### Check Image Info

```bash
./eas-build.zsh info
```

## 🎯 Build Profiles

### Development Profile

- Fast build
- Debug mode enabled
- Development server connected
- Larger APK size

```bash
./eas-build.zsh build development
```

### Preview Profile

- Optimized build
- Suitable for testing
- Can be distributed to testers
- Medium APK size

```bash
./eas-build.zsh build preview
```

### Production Profile

- Fully optimized
- Minified and obfuscated
- Ready for Play Store
- Smallest APK size
- Requires signing keys

```bash
./eas-build.zsh build production
```

## 🔐 Signing Your App

For production builds, you need to configure signing. Create `credentials.json` in your project:

```json
{
  "android": {
    "keystore": {
      "keystorePath": "./android/keystores/release.keystore",
      "keystorePassword": "your-password",
      "keyAlias": "your-alias",
      "keyPassword": "your-key-password"
    }
  }
}
```

Then reference it in your `eas.json`:

```json
{
  "build": {
    "production": {
      "android": {
        "buildType": "apk",
        "credentialsSource": "local"
      }
    }
  }
}
```

## 📦 Managing Dependencies

### Installing Dependencies

```bash
# npm
./eas-build.zsh install npm

# Yarn
./eas-build.zsh install yarn

# pnpm
./eas-build.zsh install pnpm

# Bun
./eas-build.zsh install bun
```

### Updating Dependencies

```bash
./eas-build.zsh run "npm update"
./eas-build.zsh run "yarn upgrade"
./eas-build.zsh run "pnpm update"
./eas-build.zsh run "bun update"
```

### Cleaning Build Cache

```bash
# Clean all build artifacts
./eas-build.zsh clean

# Clean npm cache
./eas-build.zsh run "npm cache clean --force"

# Clean Gradle cache (Android)
./eas-build.zsh run "cd android && ./gradlew clean"
```

## 🐳 Using Podman Instead of Docker

If you prefer Podman:

```bash
export CONTAINER_ENGINE=podman

# All commands work the same way
./eas-build.zsh build-image
./eas-build.zsh build development
```

Or use it inline:

```bash
CONTAINER_ENGINE=podman ./eas-build.zsh build
```

## 💻 Using Different Working Directory

By default, the script mounts your **current directory** into the container at `/app`. This is where Docker/Podman looks for your app code.

### Default Behavior (Recommended)

```bash
# Navigate to your app first
cd /path/to/your/mobile-app

# Then run commands - current directory is automatically mounted
eas-build build
```

### Override with RUNNER_WORK_DIR

If you can't navigate to the directory, specify it explicitly:

```bash
# Set for your session
export RUNNER_WORK_DIR=/path/to/mobile-app
eas-build build

# Or inline for a single command
RUNNER_WORK_DIR=/path/to/mobile-app eas-build build
```

### Example: Multiple Projects

```bash
# Build project 1
cd ~/projects/app1
eas-build build production

# Build project 2
cd ~/projects/app2
eas-build build production

# Or without changing directories
RUNNER_WORK_DIR=~/projects/app1 eas-build build production
RUNNER_WORK_DIR=~/projects/app2 eas-build build production
```

## 🔄 Updating the Image

When new versions are released, rebuild the image:

```bash
# Pull latest Dockerfile changes
git pull

# Rebuild image
./eas-build.zsh build-image
```

## 🚨 Troubleshooting

### "Image not found"

Build the image first:

```bash
./eas-build.zsh build-image
```

### "Container engine not found"

Install Docker or Podman:

```bash
# Ubuntu/Debian
sudo apt install docker.io

# Or Podman
sudo apt install podman
```

### "Permission denied"

Make script executable:

```bash
chmod +x eas-build.zsh
```

For Docker, add user to docker group:

```bash
sudo usermod -aG docker $USER
# Log out and back in
```

### "Out of disk space"

Clean up old containers and images:

```bash
# Docker
docker system prune -a

# Podman
podman system prune -a
```

### "Build failed with Gradle error"

Try cleaning Gradle cache:

```bash
./eas-build.zsh run "cd android && ./gradlew clean"
./eas-build.zsh run "rm -rf android/.gradle"
```

### "Node modules conflicts"

Clean and reinstall:

```bash
./eas-build.zsh clean
./eas-build.zsh install yarn
```

## 📚 Additional Resources

- [Expo EAS Build Documentation](https://docs.expo.dev/build/introduction/)
- [Expo Build Reference](https://docs.expo.dev/build-reference/infrastructure/)
- [EAS Build Configuration](https://docs.expo.dev/build/eas-json/)
- [Docker Documentation](https://docs.docker.com/)
- [Podman Documentation](https://docs.podman.io/)

## 💡 Pro Tips

1. **Cache the image**: In CI/CD, cache the built Docker image to speed up builds
2. **Use .dockerignore**: Exclude unnecessary files from being copied
3. **Mount volumes**: Mount only necessary directories to reduce container size
4. **Parallel builds**: Run multiple builds in parallel for different profiles
5. **Resource limits**: Set CPU/memory limits for predictable builds

```bash
# Example with resource limits (the script handles this automatically)
# Default: 10g memory, 16g total swap (10g + 6g), 4 CPUs
# Override with: RUNNER_MEMORY=8g RUNNER_MEMORY_SWAP=10g RUNNER_CPUS=2 eas-build build
```

---

**Happy Building! 🎉**

