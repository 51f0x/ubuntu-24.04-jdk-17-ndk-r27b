#!/usr/bin/env zsh

# EAS Local Build Helper Script
# This script provides convenient commands for building Expo apps locally using Docker/Podman
# Version: 0.1.0

set -e

# Configuration
VERSION="0.1.0"
IMAGE_NAME="51f0x/ubuntu-24.04-jdk-17-ndk-r27b"
CONTAINER_ENGINE="${CONTAINER_ENGINE:-podman}"  # Can be overridden with CONTAINER_ENGINE=podman
WORK_DIR="${RUNNER_WORK_DIR:-$(pwd)}"
MEMORY="${RUNNER_MEMORY:-10g}"
MEMORY_SWAP="${RUNNER_MEMORY_SWAP:-16g}"  # Total of memory + swap (10g mem + 6g swap)
CPUS="${RUNNER_CPUS:-6}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Helper functions
print_info() {
    echo "${BLUE}ℹ${NC} $1"
}

print_success() {
    echo "${GREEN}✓${NC} $1"
}

print_error() {
    echo "${RED}✗${NC} $1" >&2
}

print_warning() {
    echo "${YELLOW}⚠${NC} $1"
}

# Check if container engine is available
check_container_engine() {
    if ! command -v $CONTAINER_ENGINE &> /dev/null; then
        print_error "$CONTAINER_ENGINE is not installed or not in PATH"
        print_info "Install Docker or Podman, or set CONTAINER_ENGINE environment variable"
        exit 1
    fi
}

# Check if image exists
check_image() {
    if ! $CONTAINER_ENGINE images | grep -q "$IMAGE_NAME"; then
        print_warning "Image $IMAGE_NAME not found locally"
        print_info "You may need to build it first with: $0 build-image"
        read "?Do you want to build the image now? (y/N) " answer
        if [[ "$answer" =~ ^[Yy]$ ]]; then
            build_image
        else
            exit 1
        fi
    fi
}

# Build the Docker image
build_image() {
    print_info "Building Docker image: $IMAGE_NAME"
    
    if [[ ! -f "Dockerfile" ]]; then
        print_error "Dockerfile not found in current directory"
        exit 1
    fi
    
    $CONTAINER_ENGINE build -t "$IMAGE_NAME" .
    
    if [[ $? -eq 0 ]]; then
        print_success "Image built successfully: $IMAGE_NAME"
    else
        print_error "Failed to build image"
        exit 1
    fi
}

# Run EAS build with specified profile
run_build() {
    local profile="${1:-development}"
    local command="${2:-yarn install && cd apps/mobile && eas build --platform android --local --profile $profile}"
    
    print_info "Starting EAS build with profile: $profile"
    print_info "Working directory: $WORK_DIR"
    
    $CONTAINER_ENGINE run --rm -it \
        -v "$WORK_DIR:/app" \
        -w /app \
        -e PROFILE="$profile" \
        -e EXPO_TOKEN="${EXPO_TOKEN}" \
        --memory "$MEMORY" --memory-swap "$MEMORY_SWAP" \
        --cpus "$CPUS" \
        --name eas-build \
        "$IMAGE_NAME" \
        bash -c "$command"
    
    if [[ $? -eq 0 ]]; then
        print_success "Build completed successfully"
    else
        print_error "Build failed"
        exit 1
    fi
}

# Run interactive shell
run_shell() {
    print_info "Starting interactive shell"
    print_info "Working directory: $WORK_DIR"
    
    $CONTAINER_ENGINE run --rm -it \
        -v "$WORK_DIR:/app" \
        -w /app \
        -e EXPO_TOKEN="${EXPO_TOKEN}" \
        --memory "$MEMORY" --memory-swap "$MEMORY_SWAP" \
        --cpus "$CPUS" \
        --name eas-build \
        "$IMAGE_NAME" \
        bash
}

# Run Maestro tests
run_maestro() {
    local flow_file="$1"
    
    if [[ -z "$flow_file" ]]; then
        print_error "Please specify a Maestro flow file"
        echo "Usage: $0 maestro <flow-file.yaml>"
        exit 1
    fi
    
    if [[ ! -f "$flow_file" ]]; then
        print_error "Flow file not found: $flow_file"
        exit 1
    fi
    
    print_info "Running Maestro test: $flow_file"
    
    $CONTAINER_ENGINE run --rm -it \
        -v "$WORK_DIR:/app" \
        -w /app \
        -e EXPO_TOKEN="${EXPO_TOKEN}" \
        --memory "$MEMORY" --memory-swap "$MEMORY_SWAP" \
        --cpus "$CPUS" \
        --name eas-build \
        "$IMAGE_NAME" \
        bash -c "maestro test $flow_file"
}

# Run custom command
run_custom() {
    local command="$@"
    
    if [[ -z "$command" ]]; then
        print_error "Please specify a command to run"
        exit 1
    fi
    
    print_info "Running custom command: $command"
    
    $CONTAINER_ENGINE run --rm -it \
        -v "$WORK_DIR:/app" \
        -w /app \
        -e EXPO_TOKEN="${EXPO_TOKEN}" \
        --memory "$MEMORY" --memory-swap "$MEMORY_SWAP" \
        --cpus "$CPUS" \
        --name eas-build \
        "$IMAGE_NAME" \
        bash -c "$command"
}

# Install dependencies
install_deps() {
    local package_manager="${1:-yarn}"
    
    print_info "Installing dependencies with $package_manager"
    
    case "$package_manager" in
        npm)
            run_custom "npm install"
            ;;
        yarn)
            run_custom "yarn install"
            ;;
        pnpm)
            run_custom "pnpm install"
            ;;
        bun)
            run_custom "bun install"
            ;;
        *)
            print_error "Unknown package manager: $package_manager"
            echo "Supported: npm, yarn, pnpm, bun"
            exit 1
            ;;
    esac
}

# Clean build artifacts
clean() {
    print_warning "Cleaning build artifacts and node_modules..."
    
    read "?This will delete node_modules, .expo, and build artifacts. Continue? (y/N) " answer
    if [[ "$answer" =~ ^[Yy]$ ]]; then
        run_custom "rm -rf node_modules .expo android/build android/.gradle ios/build"
        print_success "Cleaned successfully"
    else
        print_info "Cancelled"
    fi
}

# Show image info
show_info() {
    print_info "Image Information"
    echo ""
    echo "Script Version: $VERSION"
    echo "Image Name: $IMAGE_NAME"
    echo "Container Engine: $CONTAINER_ENGINE"
    echo "Work Directory: $WORK_DIR"
    echo ""
    
    if $CONTAINER_ENGINE images | grep -q "$IMAGE_NAME"; then
        print_success "Image is available locally"
        echo ""
        $CONTAINER_ENGINE images "$IMAGE_NAME"
    else
        print_warning "Image not found locally"
    fi
}

# Show help
show_help() {
    cat << EOF
${GREEN}EAS Local Build Helper${NC} ${BLUE}v$VERSION${NC}

A convenient wrapper script for building Expo apps locally using Docker/Podman.

${YELLOW}Usage:${NC}
    $0 <command> [options]

${YELLOW}Commands:${NC}
    ${BLUE}build-image${NC}              Build the Docker image
    ${BLUE}build [profile] [cmd]${NC}    Run EAS build (default: development)
                              Profiles: development, preview, production
                              Optional command overrides default EAS build
    ${BLUE}shell${NC}                    Start interactive bash shell
    ${BLUE}maestro <flow-file>${NC}      Run Maestro UI tests
    ${BLUE}install [pm]${NC}             Install dependencies (npm/yarn/pnpm/bun)
    ${BLUE}run <command>${NC}            Run custom command in container
    ${BLUE}clean${NC}                    Clean build artifacts and node_modules
    ${BLUE}info${NC}                     Show image information
    ${BLUE}help${NC}                     Show this help message

${YELLOW}Environment Variables:${NC}
    ${BLUE}CONTAINER_ENGINE${NC}         Container engine to use (docker/podman)
                              Default: podman
    ${BLUE}RUNNER_WORK_DIR${NC}          Working directory to mount
                              Default: current directory
    ${BLUE}RUNNER_MEMORY${NC}            Memory limit for container
                              Default: 10g
    ${BLUE}RUNNER_MEMORY_SWAP${NC}       Total memory + swap limit
                              Default: 16g (10g memory + 6g swap)
    ${BLUE}RUNNER_CPUS${NC}              Number of CPUs for container
                              Default: 4

${YELLOW}Examples:${NC}
    # Build the Docker image
    $0 build-image

    # Run development build
    $0 build development

    # Run production build
    $0 build production

    # Run iOS build with custom command
    $0 build development "eas build --platform ios --local --profile development"

    # Start interactive shell for debugging
    $0 shell

    # Install dependencies with yarn
    $0 install yarn

    # Run Maestro tests
    $0 maestro tests/login-flow.yaml

    # Run custom command
    $0 run "npm run test"

    # Use Podman instead of Docker
    CONTAINER_ENGINE=podman $0 build

    # Use different working directory
    RUNNER_WORK_DIR=/path/to/project $0 build

    # Use custom resource limits (6g memory + 2g swap = 8g total)
    RUNNER_MEMORY=6g RUNNER_MEMORY_SWAP=8g RUNNER_CPUS=2 $0 build

${YELLOW}Notes:${NC}
    - The script mounts your current directory (or RUNNER_WORK_DIR) into /app
    - All commands run with the same user permissions as the host
    - Build artifacts are created in your local directory

${YELLOW}For more information:${NC}
    https://docs.expo.dev/build-reference/local-builds/

EOF
}

# Main script logic
main() {
    local command="${1:-help}"
    shift || true
    
    case "$command" in
        build-image|image)
            check_container_engine
            build_image
            ;;
        build|b)
            check_container_engine
            check_image
            run_build "$@"
            ;;
        shell|sh|bash)
            check_container_engine
            check_image
            run_shell
            ;;
        maestro|test)
            check_container_engine
            check_image
            run_maestro "$@"
            ;;
        install|i)
            check_container_engine
            check_image
            install_deps "$@"
            ;;
        run|exec)
            check_container_engine
            check_image
            run_custom "$@"
            ;;
        clean|c)
            check_container_engine
            check_image
            clean
            ;;
        info|version|v)
            check_container_engine
            show_info
            ;;
        help|h|-h|--help)
            show_help
            ;;
        *)
            print_error "Unknown command: $command"
            echo ""
            show_help
            exit 1
            ;;
    esac
}

# Run main function
main "$@"

