# Installation Guide

## Prerequisites

- Docker or Podman installed
- Zsh shell (or Bash - the script is compatible)
- Git (for cloning the repository)

## Installation Steps

### 1. Clone or Download

If this is in a git repository:
```bash
cd ~/projects
git clone <repository-url> ubuntu-24.04-jdk-17-ndk-r27b
```

Or if you already have it:
```bash
cd /home/51f0x/projects/ubuntu-24.04-jdk-17-ndk-r27b
```

### 2. Build the Docker Image

```bash
cd /home/51f0x/projects/ubuntu-24.04-jdk-17-ndk-r27b
./eas-build.zsh build-image
```

This will take 10-20 minutes depending on your internet connection and hardware.

### 3. Make the Script Globally Accessible

Choose one of these options:

#### Option A: Create a Symlink (Recommended)

```bash
sudo ln -s /home/51f0x/projects/ubuntu-24.04-jdk-17-ndk-r27b/eas-build.zsh /usr/local/bin/eas-build
```

Now you can run `eas-build` from anywhere:
```bash
cd /path/to/your/mobile-app
eas-build build development
```

#### Option B: Add to PATH

Add this to your `~/.zshrc` or `~/.bashrc`:

```bash
export PATH="$PATH:/home/51f0x/projects/ubuntu-24.04-jdk-17-ndk-r27b"
```

Then reload your shell:
```bash
source ~/.zshrc  # or source ~/.bashrc
```

Now you can run the script from anywhere:
```bash
cd /path/to/your/mobile-app
eas-build.zsh build development
```

#### Option C: Create an Alias

Add this to your `~/.zshrc` or `~/.bashrc`:

```bash
alias eas-build='/home/51f0x/projects/ubuntu-24.04-jdk-17-ndk-r27b/eas-build.zsh'
```

Then reload:
```bash
source ~/.zshrc  # or source ~/.bashrc
```

#### Option D: Use Full Path (No Installation)

You can always use the full path:
```bash
cd /path/to/your/mobile-app
/home/51f0x/projects/ubuntu-24.04-jdk-17-ndk-r27b/eas-build.zsh build
```

## Verification

Verify the installation:

```bash
# Check if the script is accessible
which eas-build  # or: which eas-build.zsh

# Show help
eas-build help

# Show image info
eas-build info
```

## Testing Your Setup

Create a test Expo app and try a build:

```bash
# Create a new Expo app
npx create-expo-app my-test-app
cd my-test-app

# Configure EAS
npx eas-cli build:configure

# Run a build
eas-build build development
```

## Directory Structure

Your setup should look like this:

```
/home/51f0x/projects/ubuntu-24.04-jdk-17-ndk-r27b/
├── Dockerfile              # Docker image definition
├── eas-build.zsh          # Convenience script (executable)
├── README.md              # Main documentation
├── USAGE.md               # Usage examples
└── INSTALL.md             # This file

Your mobile app (anywhere):
/path/to/your/mobile-app/
├── app.json
├── package.json
├── eas.json
└── ... (your app code)
```

## Using the Script

### Important: Working Directory

The script works by mounting your **current directory** into the Docker container. Therefore:

1. **Always run from your mobile app directory:**
   ```bash
   cd /path/to/your/mobile-app
   eas-build build
   ```

2. **Or specify the directory explicitly:**
   ```bash
   RUNNER_WORK_DIR=/path/to/mobile-app eas-build build
   ```

### Example Workflow

```bash
# Navigate to your app
cd ~/projects/my-expo-app

# Install dependencies
eas-build install yarn

# Run development build
eas-build build development

# If something fails, debug with shell
eas-build shell
```

## Uninstallation

To remove the installation:

```bash
# Remove symlink (if created)
sudo rm /usr/local/bin/eas-build

# Remove from PATH (edit ~/.zshrc or ~/.bashrc)
# Delete the export PATH line

# Remove Docker image
docker rmi 51f0x/ubuntu-24.04-jdk-17-ndk-r27b

# Remove the directory
rm -rf /home/51f0x/projects/ubuntu-24.04-jdk-17-ndk-r27b
```

## Updating

To update to a newer version:

```bash
cd /home/51f0x/projects/ubuntu-24.04-jdk-17-ndk-r27b

# Pull latest changes (if git repo)
git pull

# Rebuild image
./eas-build.zsh build-image
```

## Troubleshooting Installation

### "Command not found"

If you get "command not found", ensure:
1. The script is executable: `chmod +x /home/51f0x/projects/ubuntu-24.04-jdk-17-ndk-r27b/eas-build.zsh`
2. The symlink/alias is created correctly
3. You've reloaded your shell after modifying PATH

### "Docker not found"

Install Docker:
```bash
# Ubuntu/Debian
sudo apt update
sudo apt install docker.io

# Start Docker
sudo systemctl start docker
sudo systemctl enable docker

# Add user to docker group
sudo usermod -aG docker $USER
# Log out and back in
```

Or install Podman:
```bash
sudo apt update
sudo apt install podman
```

### "Permission denied"

```bash
# Make script executable
chmod +x /home/51f0x/projects/ubuntu-24.04-jdk-17-ndk-r27b/eas-build.zsh

# For Docker permission issues
sudo usermod -aG docker $USER
# Log out and log back in
```

## Next Steps

Once installed, check out:
- [README.md](./README.md) - Overview and features
- [USAGE.md](./USAGE.md) - Detailed usage examples and workflows

---

**Need Help?** Open an issue or check the troubleshooting sections in USAGE.md.

