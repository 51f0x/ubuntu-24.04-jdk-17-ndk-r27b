# Quick Start Guide

## 🎯 TL;DR

```bash
# 1. Build image (once)
cd /home/51f0x/projects/ubuntu-24.04-jdk-17-ndk-r27b
./eas-build.zsh build-image

# 2. Install script globally (optional but recommended)
sudo ln -s /home/51f0x/projects/ubuntu-24.04-jdk-17-ndk-r27b/eas-build.zsh /usr/local/bin/eas-build

# 3. Go to your mobile app and build
cd /path/to/your/mobile-app
eas-build build development
```

## ⚠️ Critical Concept

**The script MUST be run from your mobile app directory!**

```
┌─────────────────────────────────────┐
│  Where the script lives:            │
│  /home/51f0x/projects/               │
│    ubuntu-24.04-jdk-17-ndk-r27b/    │
│      ├── eas-build.zsh ← Script     │
│      └── Dockerfile                 │
└─────────────────────────────────────┘
                  ⬇️
        (symlink or PATH)
                  ⬇️
┌─────────────────────────────────────┐
│  Where you RUN it:                  │
│  /path/to/your/mobile-app/          │
│    ├── package.json                 │
│    ├── app.json                     │
│    ├── eas.json                     │
│    └── src/                         │
│                                     │
│  $ eas-build build ← Run here!      │
└─────────────────────────────────────┘
```

## 🚀 Step-by-Step

### First Time Setup

1. **Build the Docker image** (takes 10-20 minutes)
   ```bash
   cd /home/51f0x/projects/ubuntu-24.04-jdk-17-ndk-r27b
   ./eas-build.zsh build-image
   ```

2. **Make script accessible** (choose one)
   ```bash
   # Option A: Symlink (easiest)
   sudo ln -s /home/51f0x/projects/ubuntu-24.04-jdk-17-ndk-r27b/eas-build.zsh /usr/local/bin/eas-build
   
   # Option B: Add to PATH (add to ~/.zshrc)
   export PATH="$PATH:/home/51f0x/projects/ubuntu-24.04-jdk-17-ndk-r27b"
   
   # Option C: Create alias (add to ~/.zshrc)
   alias eas-build='/home/51f0x/projects/ubuntu-24.04-jdk-17-ndk-r27b/eas-build.zsh'
   ```

3. **Verify installation**
   ```bash
   eas-build help
   ```

### Every Time You Build

1. **Navigate to your mobile app**
   ```bash
   cd /path/to/your/mobile-app
   ```
   
   👉 This step is **MANDATORY**! The script needs to see your `package.json`, `app.json`, etc.

2. **Run build commands**
   ```bash
   eas-build build development    # Development build
   eas-build build preview         # Preview build
   eas-build build production      # Production build
   ```

## 📋 Common Commands

All commands assume you're in your mobile app directory:

```bash
cd /path/to/your/mobile-app  # ← Always start here!

# Install dependencies
eas-build install yarn        # or npm, pnpm, bun

# Run builds
eas-build build development   # Dev build
eas-build build production    # Prod build

# Debug
eas-build shell              # Open interactive shell

# Clean
eas-build clean              # Remove build artifacts

# Custom commands
eas-build run "npm test"     # Run any command

# Maestro tests
eas-build maestro test.yaml  # UI testing
```

## 🔧 Common Patterns

### Pattern 1: Standard Workflow
```bash
cd ~/projects/my-expo-app
eas-build install yarn
eas-build build development
```

### Pattern 2: Using Full Path (if not installed)
```bash
cd ~/projects/my-expo-app
/home/51f0x/projects/ubuntu-24.04-jdk-17-ndk-r27b/eas-build.zsh build development
```

### Pattern 3: Specifying Directory Explicitly
```bash
EAS_WORK_DIR=~/projects/my-expo-app eas-build build development
```

### Pattern 4: Multiple Apps
```bash
cd ~/projects/app1
eas-build build production

cd ~/projects/app2
eas-build build production
```

## ❌ Common Mistakes

### ❌ Running from script directory
```bash
cd /home/51f0x/projects/ubuntu-24.04-jdk-17-ndk-r27b
./eas-build.zsh build development  # ← WRONG! No mobile app here
```

### ❌ Running from wrong directory
```bash
cd ~
eas-build build development  # ← WRONG! No package.json here
```

### ✅ Correct way
```bash
cd /path/to/your/mobile-app  # ← Go to app first
eas-build build development  # ← Then build
```

## 🐳 What's Happening Behind the Scenes

When you run:
```bash
cd /path/to/your/mobile-app
eas-build build development
```

The script:
1. Detects your current directory: `/path/to/your/mobile-app`
2. Runs Docker with volume mount: `-v /path/to/your/mobile-app:/app`
3. Inside container, works in `/app` which points to your mobile app
4. Finds your `package.json`, `app.json`, runs `eas build`
5. Outputs build artifacts to your local directory

## 🆘 Troubleshooting

| Problem | Solution |
|---------|----------|
| "Command not found" | Install the script (step 2 above) or use full path |
| "package.json not found" | You're in wrong directory! `cd` to your mobile app |
| "Image not found" | Run `eas-build build-image` first |
| "Permission denied" | `chmod +x` the script or add user to docker group |
| "No space left" | Clean Docker: `docker system prune -a` |

## 📚 Learn More

- [README.md](./README.md) - Full documentation
- [INSTALL.md](./INSTALL.md) - Detailed installation guide
- [USAGE.md](./USAGE.md) - Advanced usage and workflows

## 💡 Pro Tip

Add this function to your `~/.zshrc` for even easier usage:

```bash
# EAS Local Build shortcut
eas() {
    if [[ ! -f "package.json" ]]; then
        echo "❌ Not in a mobile app directory (no package.json found)"
        return 1
    fi
    eas-build "$@"
}
```

Then just run:
```bash
cd ~/projects/my-app
eas build development  # Even shorter!
```

---

**Questions?** Check [USAGE.md](./USAGE.md) for detailed examples.

