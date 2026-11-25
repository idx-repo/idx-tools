#!/usr/bin/env bash

# update-csv.sh - Update all emiten daily price CSV files.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DATA_DIR="${IDX_DATA_DIR:-$HOME/.idx-data}"
OUTPUT_DIR=""
DRY_RUN=false
VERBOSE=false
QUIET=false
LIMIT=0

show_usage() {
  cat << EOF
Usage: $(basename "$0") [OPTIONS]

Options:
  -d, --data-dir <DIR>     Path to idx-data directory (default: \$IDX_DATA_DIR or ~/.idx-data)
  -o, --output-dir <DIR>   Output directory for CSV files (default: <DATA_DIR>/Daily_Price)
  -l, --limit <NUMBER>     Limit the number of files to update (useful for batching/testing)
  -n, --dry-run            Simulate without downloading CSV data
  -v, --verbose            Show verbose debug output
  -q, --quiet              Suppress standard output messages
  -h, --help               Show this help message and exit

Examples:
  $(basename "$0")
  $(basename "$0") -o ./data -n
  $(basename "$0") --limit=10 --verbose
EOF
}

log_info() {
  if [[ "$QUIET" == false ]]; then
    echo "$@"
  fi
}

log_verbose() {
  if [[ "$VERBOSE" == true && "$QUIET" == false ]]; then
    echo "[debug] $@"
  fi
}

log_error() {
  echo "Error: $@" >&2
}

# Robust argument parsing supporting -o value, -o=value, --option value, --option=value
while [[ $# -gt 0 ]]; do
  case "$1" in
    -h|--help)
      show_usage
      exit 0
      ;;
    -n|--dry-run)
      DRY_RUN=true
      shift
      ;;
    -v|--verbose)
      VERBOSE=true
      shift
      ;;
    -q|--quiet)
      QUIET=true
      shift
      ;;
    -d|--data-dir)
      if [[ $# -lt 2 || "$2" =~ ^- ]]; then
        log_error "Option '$1' requires a directory argument."
        exit 1
      fi
      DATA_DIR="$2"
      shift 2
      ;;
    --data-dir=*)
      DATA_DIR="${1#*=}"
      shift
      ;;
    -o|--output-dir)
      if [[ $# -lt 2 || "$2" =~ ^- ]]; then
        log_error "Option '$1' requires an output directory argument."
        exit 1
      fi
      OUTPUT_DIR="$2"
      shift 2
      ;;
    --output-dir=*)
      OUTPUT_DIR="${1#*=}"
      shift
      ;;
    -l|--limit)
      if [[ $# -lt 2 || ! "$2" =~ ^[0-9]+$ ]]; then
        log_error "Option '$1' requires an integer argument."
        exit 1
      fi
      LIMIT="$2"
      shift 2
      ;;
    --limit=*)
      val="${1#*=}"
      if [[ ! "$val" =~ ^[0-9]+$ ]]; then
        log_error "Option '--limit' requires an integer argument."
        exit 1
      fi
      LIMIT="$val"
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

SOURCE_DIR="$DATA_DIR/Daily_Price"
if [[ -z "$OUTPUT_DIR" ]]; then
  OUTPUT_DIR="$SOURCE_DIR"
fi

log_verbose "Source Directory: $SOURCE_DIR"
log_verbose "Output Directory: $OUTPUT_DIR"

if [[ ! -d "$SOURCE_DIR" ]]; then
  log_error "Daily price directory not found: $SOURCE_DIR"
  if [[ ! -d "$DATA_DIR" ]]; then
    echo "Notice: Data directory '$DATA_DIR' does not exist." >&2
    echo "Please run install.sh or sync data with update-data.sh first." >&2
  fi
  exit 1
fi

mkdir -p "$OUTPUT_DIR"

# Locate idxDaily executable or script
IDX_DAILY_CMD=""
if [[ "$DRY_RUN" == false ]]; then
  if command -v idxDaily >/dev/null 2>&1; then
    IDX_DAILY_CMD="idxDaily"
  elif [[ -x "$SCRIPT_DIR/../R/idxDaily.R" ]]; then
    IDX_DAILY_CMD="$SCRIPT_DIR/../R/idxDaily.R"
  elif [[ -x "$HOME/bin/idxDaily" ]]; then
    IDX_DAILY_CMD="$HOME/bin/idxDaily"
  elif [[ -f "$SCRIPT_DIR/../R/idxDaily.R" ]] && command -v Rscript >/dev/null 2>&1; then
    IDX_DAILY_CMD="Rscript $SCRIPT_DIR/../R/idxDaily.R"
  else
    log_error "idxDaily executable not found in PATH, \$HOME/bin, or ../R/idxDaily.R."
    exit 1
  fi
  log_verbose "Using idxDaily: $IDX_DAILY_CMD"
fi

# Collect CSV files safely
shopt -s nullglob
FILES=("$SOURCE_DIR"/*.csv)
shopt -u nullglob

if [[ ${#FILES[@]} -eq 0 ]]; then
  log_info "No CSV files found in $SOURCE_DIR."
  exit 0
fi

COUNT=0
FAILURES=0

for file in "${FILES[@]}"; do
  emiten="$(basename "$file" .csv)"
  [[ -z "$emiten" ]] && continue

  out_file="$OUTPUT_DIR/${emiten}.csv"
  COUNT=$((COUNT + 1))

  if [[ "$DRY_RUN" == true ]]; then
    log_info "[dry-run] Would update $emiten -> $out_file"
  else
    log_info "Update $emiten"
    if ! $IDX_DAILY_CMD -e "$emiten" -o "$out_file"; then
      log_error "Failed to update $emiten"
      FAILURES=$((FAILURES + 1))
    fi
  fi

  if [[ "$LIMIT" -gt 0 && "$COUNT" -ge "$LIMIT" ]]; then
    log_info "Reached limit of $LIMIT files."
    break
  fi
done

if [[ "$FAILURES" -gt 0 ]]; then
  log_info "Finished with $FAILURES failure(s) out of $COUNT processed file(s)."
  exit 2
else
  log_info "Done. Processed $COUNT file(s)."
  exit 0
fi
