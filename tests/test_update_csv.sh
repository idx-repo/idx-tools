#!/usr/bin/env bash

# test_update_csv.sh - Unit & integration tests for update-csv.sh.

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$REPO_ROOT/tests/test_helpers.sh"

TMP_DIR="$(mktemp -d /tmp/idx_test_csv_XXXXXX)"
trap 'rm -rf "$TMP_DIR"' EXIT

FIXTURE_DATA="$TMP_DIR/idx-data"
mkdir -p "$FIXTURE_DATA/Daily_Price"

touch "$FIXTURE_DATA/Daily_Price/AALI.csv"
touch "$FIXTURE_DATA/Daily_Price/BBCA.csv"
touch "$FIXTURE_DATA/Daily_Price/TLKM.csv"

echo "=== Suite: update-csv.sh ==="

test_case "Help flag (-h / --help)"
out="$("$REPO_ROOT/Bash/update-csv.sh" -h)"
status=$?
assert_exit_code 0 "$status"
assert_contains "$out" "Usage: update-csv.sh [OPTIONS]"

test_case "Missing data directory error"
out="$("$REPO_ROOT/Bash/update-csv.sh" -d /tmp/nonexistent_dir_idx 2>&1 || true)"
assert_contains "$out" "Daily price directory not found"

test_case "Dry-run update-csv.sh across all files"
out="$("$REPO_ROOT/Bash/update-csv.sh" -d "$FIXTURE_DATA" -n)"
status=$?
assert_exit_code 0 "$status"
assert_contains "$out" "[dry-run] Would update AALI"
assert_contains "$out" "[dry-run] Would update BBCA"
assert_contains "$out" "[dry-run] Would update TLKM"
assert_contains "$out" "Processed 3 file(s)."

test_case "Limit option (--limit=2)"
out="$("$REPO_ROOT/Bash/update-csv.sh" -d "$FIXTURE_DATA" --limit=2 -n)"
status=$?
assert_exit_code 0 "$status"
assert_contains "$out" "Reached limit of 2 files."
assert_contains "$out" "Processed 2 file(s)."

test_case "Invalid limit option (--limit=abc)"
out="$("$REPO_ROOT/Bash/update-csv.sh" --limit=abc 2>&1 || true)"
assert_contains "$out" "Option '--limit' requires an integer argument."

test_case "Empty directory handling"
EMPTY_DATA="$TMP_DIR/empty-data"
mkdir -p "$EMPTY_DATA/Daily_Price"
out="$("$REPO_ROOT/Bash/update-csv.sh" -d "$EMPTY_DATA" -n)"
status=$?
assert_exit_code 0 "$status"
assert_contains "$out" "No CSV files found"

test_case "Lag option validation (--lag=abc should fail)"
out="$("$REPO_ROOT/Bash/update-csv.sh" --lag=abc 2>&1 || true)"
assert_contains "$out" "requires a numeric seconds argument"

test_case "Lag option with dry-run verbose logging (--lag=0.5 -v -n)"
out="$("$REPO_ROOT/Bash/update-csv.sh" -d "$FIXTURE_DATA" --lag=0.5 -v -n)"
assert_contains "$out" "[dry-run] Would sleep for 0.5s (lag)"

report_suite_results "update-csv.sh"
exit $?
