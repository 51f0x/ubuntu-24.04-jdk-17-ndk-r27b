#!/usr/bin/env zsh
set -euo pipefail

IMAGE_NAME="${IMAGE_NAME:-51f0x/ubuntu-24.04-jdk-17-ndk-r27b}"
CONTAINER_ENGINE="${CONTAINER_ENGINE:-podman}"   # or docker
WORK_DIR="${RUNNER_WORK_DIR:-$(pwd)}"
MEMORY="${RUNNER_MEMORY:-10g}"
MEMORY_SWAP="${RUNNER_MEMORY_SWAP:-16g}"
CPUS="${RUNNER_CPUS:-6}"
PLATFORM_OPT="${RUNNER_PLATFORM:+--platform ${RUNNER_PLATFORM}}"   # e.g. linux/amd64 or linux/arm64
ENV_FILE_OPT="${ENV_FILE:+--env-file ${ENV_FILE}}"

UIDGID="$(id -u):$(id -g)"
GRADLE_VOL="${GRADLE_VOL:-gradle-cache}"
ANDROID_VOL="${ANDROID_VOL:-android-sdk}"
NDK_VOL="${NDK_VOL:-android-ndk}"
NPM_VOL="${NPM_VOL:-npm-cache}"
BUN_VOL="${BUN_VOL:-bun-cache}"

info() { print -P "%F{blue}ℹ%f $*"; }
ok()   { print -P "%F{green}✓%f $*"; }
err()  { print -P "%F{red}✗%f $*" >&2; }

print_env_vars() {
  print -P "%F{cyan}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━%f"
  print -P "%F{cyan}Environment Variables%f"
  print -P "%F{cyan}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━%f"
  print -P "%F{yellow}Container Settings:%f"
  print -P "  IMAGE_NAME           = %F{white}$IMAGE_NAME%f"
  print -P "  CONTAINER_ENGINE     = %F{white}$CONTAINER_ENGINE%f"
  print -P "  RUNNER_PLATFORM      = %F{white}${RUNNER_PLATFORM:-(not set)}%f"
  print -P ""
  print -P "%F{yellow}Resource Limits:%f"
  print -P "  RUNNER_MEMORY        = %F{white}$MEMORY%f"
  print -P "  RUNNER_MEMORY_SWAP   = %F{white}$MEMORY_SWAP%f"
  print -P "  RUNNER_CPUS          = %F{white}$CPUS%f"
  print -P ""
  print -P "%F{yellow}Directories & Volumes:%f"
  print -P "  RUNNER_WORK_DIR      = %F{white}$WORK_DIR%f"
  print -P "  GRADLE_VOL           = %F{white}$GRADLE_VOL%f"
  print -P "  ANDROID_VOL          = %F{white}$ANDROID_VOL%f"
  print -P "  NDK_VOL              = %F{white}$NDK_VOL%f"
  print -P "  NPM_VOL              = %F{white}$NPM_VOL%f"
  print -P "  BUN_VOL              = %F{white}$BUN_VOL%f"
  print -P ""
  print -P "%F{yellow}Other Settings:%f"
  print -P "  USER:GROUP (auto)    = %F{white}$UIDGID%f"
  print -P "  ENV_FILE             = %F{white}${ENV_FILE:-(not set)}%f"
  if [[ -n "${EXPO_TOKEN:-}" ]]; then
    print -P "  EXPO_TOKEN           = %F{green}(set)%f"
  else
    print -P "  EXPO_TOKEN           = %F{red}(not set)%f"
  fi
  print -P "%F{cyan}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━%f"
  print ""
}

check_ce() {
  command -v "$CONTAINER_ENGINE" >/dev/null || { err "$CONTAINER_ENGINE not found"; exit 1; }
}

build_image() {
  check_ce
  info "Building image: $IMAGE_NAME"
  $CONTAINER_ENGINE build -t "$IMAGE_NAME" .
  ok "Image built: $IMAGE_NAME"
}

_run_base() {
  local extra=("$@")
  # For Podman: use :U to chown volumes to container user
  # For Docker: :U not supported, rely on matching UIDs
  local vol_opt=""
  if [[ "$CONTAINER_ENGINE" == "podman" ]]; then
    vol_opt=":U"
  fi
  $CONTAINER_ENGINE run --rm -it --replace \
    $PLATFORM_OPT $ENV_FILE_OPT \
    -v "$WORK_DIR:/app${vol_opt}" -w /app \
    -v "$GRADLE_VOL:/home/builder/.gradle" \
    -v "$ANDROID_VOL:/opt/android-sdk" \
    -v "$NDK_VOL:/opt/android-ndk-r27b" \
    -v "$NPM_VOL:/home/builder/.npm" \
    -v "$BUN_VOL:/home/builder/.bun" \
    -e EXPO_TOKEN="${EXPO_TOKEN:-}" \
    --user "$UIDGID" \
    --memory "$MEMORY" --memory-swap "$MEMORY_SWAP" --cpus "$CPUS" \
    --name eas-build "$IMAGE_NAME" "${extra[@]}"
}

build() {
  local profile="${1:-development}"
  local command="${2:-yarn install && cd apps/mobile && eas build --platform android --local --profile $profile}"
  if [[ "$profile" == "production" && -z "${EXPO_TOKEN:-}" ]]; then
    err "EXPO_TOKEN is required for production profiles"; exit 1
  fi
  info "EAS build (profile: $profile)"
  _run_base bash -lc "$command"
  ok "Build finished"
}

shell() { info "Shell"; _run_base bash; }

maestro() {
  local flow="${1:-}"
  [[ -f "$flow" ]] || { err "Flow not found: $flow"; exit 1; }
  _run_base bash -lc "maestro test '$flow'"
}

install() {
  local pm="${1:-yarn}"
  case "$pm" in
    npm|yarn|pnpm|bun) _run_base bash -lc "$pm install" ;;
    *) err "Unknown PM: $pm" ; exit 1 ;;
  esac
}

run_cmd() { [[ $# -gt 0 ]] || { err "Command required"; exit 1; }; _run_base bash -lc "$*"; }

clean() {
  info "Cleaning local artifacts…"
  rm -rf node_modules .expo android/build android/.gradle ios/build || true
  ok "Cleaned"
}

info_cmd() {
  info "Image: $IMAGE_NAME"
  info "Engine: $CONTAINER_ENGINE"
  info "Workdir: $WORK_DIR"
  $CONTAINER_ENGINE images "$IMAGE_NAME" || true
}

# Print environment variables on start (except for help command)
[[ "${1:-help}" != "help" && "${1:-help}" != "h" && "${1:-help}" != "--help" && "${1:-help}" != "-h" ]] && print_env_vars

case "${1:-help}" in
  build-image|image) build_image ;;
  build|b) shift; build "$@" ;;
  shell|sh|bash) shell ;;
  maestro|test) shift; maestro "$@" ;;
  install|i) shift; install "$@" ;;
  run|exec) shift; run_cmd "$@" ;;
  clean|c) clean ;;
  info|version|v) info_cmd ;;
  help|h|--help|-h)
    cat <<'EOF'
Usage: runner.zsh <command>
  build-image           Build the image
  build [profile] [cmd] Run EAS build (default profile: development)
  shell                 Interactive shell
  maestro <flow.yaml>   Run Maestro tests
  install [npm|yarn|pnpm|bun]
  run <command>         Run custom command inside container
  clean                 Remove local build artifacts
  info                  Show image info

Env:
  RUNNER_PLATFORM=linux/amd64|linux/arm64
  ENV_FILE=.env
  RUNNER_MEMORY=10g (memory limit)
  RUNNER_MEMORY_SWAP=16g (total memory + swap)
  RUNNER_CPUS=4 (CPU cores)
  GRADLE_VOL, ANDROID_VOL, NDK_VOL, NPM_VOL, BUN_VOL to override cache volumes
EOF
  ;;
  *) err "Unknown command: $1"; exit 1 ;;
esac
