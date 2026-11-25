#!/usr/bin/env bash

# test_update_index.sh - Unit & integration tests for update-index.sh and index wrappers.

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$REPO_ROOT/tests/test_helpers.sh"

TMP_DIR="$(mktemp -d /tmp/idx_test_index_XXXXXX)"
trap 'rm -rf "$TMP_DIR"' EXIT

FIXTURE_DATA="$TMP_DIR/idx-data"
FIXTURE_OUT="$TMP_DIR/output"

mkdir -p "$FIXTURE_DATA/Index" "$FIXTURE_DATA/IDX-IC" "$FIXTURE_OUT"

cat << 'EOF' > "$FIXTURE_DATA/Index/IDX30.csv"
"Kode"|"Nama Perusahaan"
"AALI"|"Astra Agro Lestari Tbk."
"ADRO"|"Adaro Energy Indonesia Tbk."
"BBCA"|"Bank Central Asia Tbk."
EOF

cat << 'EOF' > "$FIXTURE_DATA/Index/LQ45.csv"
"Kode"|"Nama Perusahaan"
"ASII"|"Astra International Tbk."
"BBRI"|"Bank Rakyat Indonesia (Persero) Tbk."
EOF

cat << 'EOF' > "$FIXTURE_DATA/IDX-IC/A.tsv"
"No" "Kode"|"Nama Perusahaan"
"1" "AALI"|"Astra Agro Lestari Tbk."
"2" "ADRO"|"Adaro Energy Indonesia Tbk."
EOF

cat << 'EOF' > "$TMP_DIR/custom_tickers.txt"
"Kode"
"TLKM"
"UNVR"
EOF

echo "=== Suite: update-index.sh & Wrappers ==="

test_case "Help flag (-h / --help)"
out="$("$REPO_ROOT/Bash/update-index.sh" -h)"
status=$?
assert_exit_code 0 "$status" "update-index.sh -h should exit 0"
assert_contains "$out" "Usage: update-index.sh [OPTIONS] [INDEX_NAME]"

test_case "Missing index name argument (-i without value)"
out="$("$REPO_ROOT/Bash/update-index.sh" -i 2>&1 || true)"
status=$?
assert_exit_code 0 "$status"
assert_contains "$out" "Option '-i' requires an index name argument."

test_case "Missing option value with next flag (-i -o)"
out="$("$REPO_ROOT/Bash/update-index.sh" -i -o ./data 2>&1 || true)"
assert_contains "$out" "Option '-i' requires an index name argument."

test_case "Unknown flag (--invalid-flag)"
out="$("$REPO_ROOT/Bash/update-index.sh" --invalid-flag 2>&1 || true)"
assert_contains "$out" "Unknown option '--invalid-flag'."

test_case "Non-existent index file"
out="$("$REPO_ROOT/Bash/update-index.sh" -i NONEXISTENT -d "$FIXTURE_DATA" 2>&1 || true)"
assert_contains "$out" "Target file not found"

test_case "Standard index via positional argument in dry-run"
out="$("$REPO_ROOT/Bash/update-index.sh" IDX30 -d "$FIXTURE_DATA" -n)"
status=$?
assert_exit_code 0 "$status"
assert_contains "$out" "[dry-run] Would update AALI -> ./AALI.csv"
assert_contains "$out" "[dry-run] Would update ADRO -> ./ADRO.csv"
assert_contains "$out" "[dry-run] Would update BBCA -> ./BBCA.csv"
assert_contains "$out" "Processed 3 emiten(s)"

test_case "Standard index via --index=LQ45 syntax with custom -o"
out="$("$REPO_ROOT/Bash/update-index.sh" --index=LQ45 -d "$FIXTURE_DATA" -o "$FIXTURE_OUT" -n)"
status=$?
assert_exit_code 0 "$status"
assert_contains "$out" "[dry-run] Would update ASII -> $FIXTURE_OUT/ASII.csv"
assert_contains "$out" "[dry-run] Would update BBRI -> $FIXTURE_OUT/BBRI.csv"
assert_contains "$out" "Processed 2 emiten(s)"

test_case "IDX-IC sector update (-c A)"
out="$("$REPO_ROOT/Bash/update-index.sh" -c A -d "$FIXTURE_DATA" -n)"
status=$?
assert_exit_code 0 "$status"
assert_contains "$out" "[dry-run] Would update AALI -> ./AALI.csv"
assert_contains "$out" "[dry-run] Would update ADRO -> ./ADRO.csv"

test_case "Custom file list (-f)"
out="$("$REPO_ROOT/Bash/update-index.sh" -f "$TMP_DIR/custom_tickers.txt" -n)"
status=$?
assert_exit_code 0 "$status"
assert_contains "$out" "[dry-run] Would update TLKM -> ./TLKM.csv"
assert_contains "$out" "[dry-run] Would update UNVR -> ./UNVR.csv"

test_case "Quiet mode (-q)"
out="$("$REPO_ROOT/Bash/update-index.sh" IDX30 -d "$FIXTURE_DATA" -n -q)"
status=$?
assert_exit_code 0 "$status"
if [[ -z "$out" ]]; then
  TESTS_PASSED=$((TESTS_PASSED + 1))
else
  echo -e "    ${RED}FAIL:${NC} Quiet mode should have empty output, got: $out"
  TESTS_FAILED=$((TESTS_FAILED + 1))
fi

test_case "Verbose mode (-v)"
out="$("$REPO_ROOT/Bash/update-index.sh" IDX30 -d "$FIXTURE_DATA" -n -v)"
assert_contains "$out" "[debug] Target Type: index"
assert_contains "$out" "[debug] Target Value: IDX30"

test_case "Wrapper: update-idx30.sh"
out="$("$REPO_ROOT/Bash/update-idx30.sh" -d "$FIXTURE_DATA" -n)"
assert_contains "$out" "[dry-run] Would update AALI -> ./AALI.csv"

test_case "Wrapper: update-lq45.sh"
out="$("$REPO_ROOT/Bash/update-lq45.sh" -d "$FIXTURE_DATA" -n)"
assert_contains "$out" "[dry-run] Would update ASII -> ./ASII.csv"

test_case "Wrapper: update-idxic.sh A"
out="$("$REPO_ROOT/Bash/update-idxic.sh" A -d "$FIXTURE_DATA" -n)"
assert_contains "$out" "[dry-run] Would update AALI -> ./AALI.csv"

report_suite_results "update-index.sh & Wrappers"
exit $?
