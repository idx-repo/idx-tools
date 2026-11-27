#!/usr/bin/env bash

# test_installer.sh - Test install.sh and remove.sh symlink creation and removal.

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$REPO_ROOT/tests/test_helpers.sh"

TMP_HOME="$(mktemp -d /tmp/idx_test_home_XXXXXX)"
trap 'rm -rf "$TMP_HOME"' EXIT

echo "=== Suite: Installer & Uninstaller ==="

test_case "Install creates required symlinks in \$HOME/bin"
(
  export HOME="$TMP_HOME"
  cd "$REPO_ROOT"
  # Mock idx-deps and idxdata-update to avoid network or dependency calls during test
  mkdir -p "$TMP_HOME/bin"
  echo '#!/bin/sh' > "$TMP_HOME/bin/idx-deps" && chmod +x "$TMP_HOME/bin/idx-deps"
  echo '#!/bin/sh' > "$TMP_HOME/bin/idxdata-update" && chmod +x "$TMP_HOME/bin/idxdata-update"
  export PATH="$TMP_HOME/bin:$PATH"

  # Run install.sh (skipping git clone if ~/.idx-data exists)
  mkdir -p "$TMP_HOME/.idx-data"
  sh "$REPO_ROOT/install.sh" >/dev/null 2>&1
)

assert_file_exists "$TMP_HOME/bin/idxDaily" "idxDaily symlink"
assert_file_exists "$TMP_HOME/bin/idx-deps" "idx-deps symlink"
assert_file_exists "$TMP_HOME/bin/plotDaily" "plotDaily symlink"
assert_file_exists "$TMP_HOME/bin/idxdata-update" "idxdata-update symlink"
assert_file_exists "$TMP_HOME/bin/csvdata-update" "csvdata-update symlink"
assert_file_exists "$TMP_HOME/bin/idxindex-update" "idxindex-update symlink"
assert_file_exists "$TMP_HOME/bin/idx30data-update" "idx30data-update symlink"
assert_file_exists "$TMP_HOME/bin/lq45data-update" "lq45data-update symlink"
assert_file_exists "$TMP_HOME/bin/idx80data-update" "idx80data-update symlink"
assert_file_exists "$TMP_HOME/bin/issidata-update" "issidata-update symlink"
assert_file_exists "$TMP_HOME/bin/idxic-update" "idxic-update symlink"

test_case "Remove cleans up symlinks from \$HOME/bin"
(
  export HOME="$TMP_HOME"
  sh "$REPO_ROOT/remove.sh" >/dev/null 2>&1
)

assert_file_not_exists "$TMP_HOME/bin/idxDaily" "idxDaily removed"
assert_file_not_exists "$TMP_HOME/bin/idx-deps" "idx-deps removed"
assert_file_not_exists "$TMP_HOME/bin/plotDaily" "plotDaily removed"
assert_file_not_exists "$TMP_HOME/bin/idxdata-update" "idxdata-update removed"
assert_file_not_exists "$TMP_HOME/bin/csvdata-update" "csvdata-update removed"
assert_file_not_exists "$TMP_HOME/bin/idxindex-update" "idxindex-update removed"
assert_file_not_exists "$TMP_HOME/bin/idx30data-update" "idx30data-update removed"
assert_file_not_exists "$TMP_HOME/bin/lq45data-update" "lq45data-update removed"
assert_file_not_exists "$TMP_HOME/bin/idx80data-update" "idx80data-update removed"
assert_file_not_exists "$TMP_HOME/bin/issidata-update" "issidata-update removed"
assert_file_not_exists "$TMP_HOME/bin/idxic-update" "idxic-update removed"
assert_file_not_exists "$TMP_HOME/.idx-data" "data folder removed"

report_suite_results "Installer & Uninstaller"
exit $?
