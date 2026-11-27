#!/usr/bin/env bash

# update-data.sh - Sync the idx-repo/idx-data git repository.

set -euo pipefail

DATA_DIR="${IDX_DATA_DIR:-$HOME/.idx-data}"
REMOTE="origin"
BRANCH=""
QUIET=false

show_usage() {
  cat << EOF
Usage: $(basename "$0") [OPTIONS]

Options:
  -d, --dir <DIR>        Path to idx-data directory (default: \$IDX_DATA_DIR or ~/.idx-data)
  -r, --remote <REMOTE>  Git remote name (default: origin)
  -b, --branch <BRANCH>  Git branch to pull (default: currently checked out branch)
  -q, --quiet            Suppress standard output
  -h, --help             Show this help message and exit

Examples:
  $(basename "$0")
  $(basename "$0") -d /custom/idx-data
  $(basename "$0") --branch=master
EOF
}

log_info() {
  if [[ "$QUIET" == false ]]; then
    echo "$@"
  fi
}

log_error() {
  echo "Error: $@" >&2
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    -h|--help)
      show_usage
      exit 0
      ;;
    -q|--quiet)
      QUIET=true
      shift
      ;;
    -d|--dir)
      if [[ $# -lt 2 || "$2" =~ ^- ]]; then
        log_error "Option '$1' requires a directory argument."
        exit 1
      fi
      DATA_DIR="$2"
      shift 2
      ;;
    --dir=*)
      DATA_DIR="${1#*=}"
      shift
      ;;
    -r|--remote)
      if [[ $# -lt 2 || "$2" =~ ^- ]]; then
        log_error "Option '$1' requires a remote argument."
        exit 1
      fi
      REMOTE="$2"
      shift 2
      ;;
    --remote=*)
      REMOTE="${1#*=}"
      shift
      ;;
    -b|--branch)
      if [[ $# -lt 2 || "$2" =~ ^- ]]; then
        log_error "Option '$1' requires a branch argument."
        exit 1
      fi
      BRANCH="$2"
      shift 2
      ;;
    --branch=*)
      BRANCH="${1#*=}"
      shift
      ;;
    --)
      shift
      break
      ;;
    -*)
      log_error "Unknown option '$1'."
      show_usage >&2
      exit 1
      ;;
    *)
      log_error "Unexpected argument '$1'."
      show_usage >&2
      exit 1
      ;;
  esac
done

if [[ ! -d "$DATA_DIR" ]]; then
  log_error "Data directory not found: $DATA_DIR"
  echo "To clone it for the first time, run: git clone --depth=1 https://github.com/idx-repo/idx-data.git \"$DATA_DIR\"" >&2
  exit 1
fi

if ! git -C "$DATA_DIR" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  log_error "Directory '$DATA_DIR' is not a valid git repository."
  exit 1
fi

log_info "Updating idx-data at $DATA_DIR..."

PULL_ARGS=()
if [[ "$QUIET" == true ]]; then
  PULL_ARGS+=("-q")
fi
if [[ -n "$BRANCH" ]]; then
  PULL_ARGS+=("$REMOTE" "$BRANCH")
fi

git -C "$DATA_DIR" pull "${PULL_ARGS[@]}"

log_info "idx-data successfully updated."
