#!/usr/bin/env bash

# test_update_data.sh - Unit tests for update-data.sh.

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$REPO_ROOT/tests/test_helpers.sh"

TMP_DIR="$(mktemp -d /tmp/idx_test_data_XXXXXX)"
trap 'rm -rf "$TMP_DIR"' EXIT

echo "=== Suite: update-data.sh ==="

test_case "Help flag (-h / --help)"
out="$("$REPO_ROOT/Bash/update-data.sh" -h)"
status=$?
assert_exit_code 0 "$status"
assert_contains "$out" "Usage: update-data.sh [OPTIONS]"

test_case "Non-existent data directory error"
out="$("$REPO_ROOT/Bash/update-data.sh" -d "$TMP_DIR/nonexistent" 2>&1 || true)"
assert_contains "$out" "Data directory not found"

test_case "Directory is not a git repository error"
mkdir -p "$TMP_DIR/not_git"
out="$("$REPO_ROOT/Bash/update-data.sh" -d "$TMP_DIR/not_git" 2>&1 || true)"
assert_contains "$out" "is not a valid git repository"

report_suite_results "update-data.sh"
exit $?
