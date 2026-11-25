#!/usr/bin/env bash

# update-index.sh - Update daily CSV data for IDX indices or sectors.
# Supports IDX index files (IDX30, LQ45, IDX80, ISSI, etc.), IDX-IC sectors, or custom file lists.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DATA_DIR="${IDX_DATA_DIR:-$HOME/.idx-data}"
OUTPUT_DIR="."
DRY_RUN=false
VERBOSE=false
QUIET=false
TARGET_TYPE=""
TARGET_VALUE=""
FILE_PATH=""

show_usage() {
  cat << EOF
Usage: $(basename "$0") [OPTIONS] [INDEX_NAME]

Options:
  -i, --index <NAME>       Index name (e.g., IDX30, LQ45, IDX80, ISSI)
  -c, --idxic <CODE>       IDX-IC sector code (e.g., A, B, C...)
  -f, --file <PATH>        Custom index or sector file path
  -o, --output-dir <DIR>   Directory to save CSV files (default: .)
  -d, --data-dir <DIR>     Path to idx-data directory (default: \$IDX_DATA_DIR or ~/.idx-data)
  -n, --dry-run            Simulate without downloading CSV data
  -v, --verbose            Show verbose debug output
  -q, --quiet              Suppress standard output messages
  -h, --help               Show this help message and exit

Examples:
  $(basename "$0") IDX30
  $(basename "$0") -i LQ45 -o ./data
  $(basename "$0") --index=IDX80
  $(basename "$0") -c A
  $(basename "$0") --idxic=B
  $(basename "$0") -f /path/to/Index.csv --output-dir=./output
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

# Auto-detect target if invoked via specific script name/symlink
INVOKED_AS="$(basename "$0")"
case "$INVOKED_AS" in
  update-idx30*|idx30data-update*)
    TARGET_TYPE="index"
    TARGET_VALUE="IDX30"
    ;;
  update-lq45*|lq45data-update*)
    TARGET_TYPE="index"
    TARGET_VALUE="LQ45"
    ;;
  update-idx80*|idx80data-update*)
    TARGET_TYPE="index"
    TARGET_VALUE="IDX80"
    ;;
  update-issi*|issidata-update*)
    TARGET_TYPE="index"
    TARGET_VALUE="ISSI"
    ;;
  update-idxic*|idxic-update*)
    TARGET_TYPE="idxic"
    ;;
esac

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
    -i|--index)
      if [[ $# -lt 2 || "$2" =~ ^- ]]; then
        log_error "Option '$1' requires an index name argument."
        exit 1
      fi
      TARGET_TYPE="index"
      TARGET_VALUE="$2"
      shift 2
      ;;
    --index=*)
      TARGET_TYPE="index"
      TARGET_VALUE="${1#*=}"
      shift
      ;;
    -c|--idxic)
      if [[ $# -lt 2 || "$2" =~ ^- ]]; then
        log_error "Option '$1' requires an IDX-IC sector code argument."
        exit 1
      fi
      TARGET_TYPE="idxic"
      TARGET_VALUE="$2"
      shift 2
      ;;
    --idxic=*)
      TARGET_TYPE="idxic"
      TARGET_VALUE="${1#*=}"
      shift
      ;;
    -f|--file)
      if [[ $# -lt 2 || "$2" =~ ^- ]]; then
        log_error "Option '$1' requires a file path argument."
        exit 1
      fi
      TARGET_TYPE="file"
      FILE_PATH="$2"
      shift 2
      ;;
    --file=*)
      TARGET_TYPE="file"
      FILE_PATH="${1#*=}"
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
    -d|--data-dir)
      if [[ $# -lt 2 || "$2" =~ ^- ]]; then
        log_error "Option '$1' requires a data directory argument."
        exit 1
      fi
      DATA_DIR="$2"
      shift 2
      ;;
    --data-dir=*)
      DATA_DIR="${1#*=}"
      shift
      ;;
    idxic|IDX-IC)
      TARGET_TYPE="idxic"
      if [[ $# -gt 1 && ! "$2" =~ ^- ]]; then
        TARGET_VALUE="$2"
        shift 2
      else
        shift
      fi
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
      # Positional argument
      if [[ -z "$TARGET_TYPE" && -z "$TARGET_VALUE" ]]; then
        if [[ -f "$1" ]]; then
          TARGET_TYPE="file"
          FILE_PATH="$1"
        else
          TARGET_TYPE="index"
          TARGET_VALUE="$1"
        fi
      elif [[ "$TARGET_TYPE" == "idxic" && -z "$TARGET_VALUE" ]]; then
        TARGET_VALUE="$1"
      else
        log_error "Unexpected argument '$1'."
        exit 1
      fi
      shift
      ;;
  esac
done

# Resolve file path based on target type
if [[ "$TARGET_TYPE" == "index" ]]; then
  if [[ -z "$TARGET_VALUE" ]]; then
    log_error "Index name must be specified (e.g. IDX30, LQ45, IDX80, ISSI)."
    exit 1
  fi
  TARGET_VALUE="$(echo "$TARGET_VALUE" | tr '[:lower:]' '[:upper:]')"
  FILE_PATH="$DATA_DIR/Index/${TARGET_VALUE}.csv"
elif [[ "$TARGET_TYPE" == "idxic" ]]; then
  if [[ -z "$TARGET_VALUE" ]]; then
    log_error "IDX-IC sector code must be specified (e.g. A, B, C...)."
    exit 1
  fi
  FILE_PATH="$DATA_DIR/IDX-IC/${TARGET_VALUE}.tsv"
elif [[ "$TARGET_TYPE" == "file" ]]; then
  if [[ -z "$FILE_PATH" ]]; then
    log_error "File path must be specified."
    exit 1
  fi
else
  log_error "No target index or file specified."
  show_usage >&2
  exit 1
fi

log_verbose "Target Type: $TARGET_TYPE"
log_verbose "Target Value: $TARGET_VALUE"
log_verbose "Target File: $FILE_PATH"
log_verbose "Output Dir: $OUTPUT_DIR"
log_verbose "Data Dir: $DATA_DIR"

if [[ ! -f "$FILE_PATH" ]]; then
  log_error "Target file not found: $FILE_PATH"
  if [[ ! -d "$DATA_DIR" ]]; then
    echo "Notice: Data directory '$DATA_DIR' does not exist." >&2
    echo "Please run install.sh or sync data with update-data.sh first." >&2
  fi
  exit 1
fi

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
  log_verbose "Using idxDaily executable: $IDX_DAILY_CMD"
fi

mkdir -p "$OUTPUT_DIR"

# Extract emiten codes
# Standard Index CSV uses column 1; IDX-IC TSV has code in 2nd word of column 1
if [[ "$TARGET_TYPE" == "idxic" ]]; then
  CODES=$(tail -n +2 "$FILE_PATH" | cut -d '|' -f 1 | tr -d '"\r' | awk '{print $2}')
else
  CODES=$(tail -n +2 "$FILE_PATH" | cut -d '|' -f 1 | tr -d '"\r' | awk '{print $1}')
fi

COUNT=0
FAILURES=0

for code in $CODES; do
  [[ -z "$code" ]] && continue
  COUNT=$((COUNT + 1))
  out_file="$OUTPUT_DIR/${code}.csv"
  if [[ "$DRY_RUN" == true ]]; then
    log_info "[dry-run] Would update $code -> $out_file"
  else
    log_info "Update $code"
    if ! $IDX_DAILY_CMD -e "$code" -o "$out_file"; then
      log_error "Failed to update $code"
      FAILURES=$((FAILURES + 1))
    fi
  fi
done

if [[ "$FAILURES" -gt 0 ]]; then
  log_info "Finished with $FAILURES failure(s) out of $COUNT emiten(s)."
  exit 2
else
  log_info "Done. Processed $COUNT emiten(s) from $FILE_PATH."
  exit 0
fi
