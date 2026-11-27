#!/usr/bin/env bash

# run_tests.sh - Master test runner for idx-tools.

set -uo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

GREEN='\033[0;32m'
RED='\033[0;31m'
BOLD='\033[1m'
NC='\033[0m'

chmod +x "$REPO_ROOT"/tests/*.sh "$REPO_ROOT"/Bash/*.sh "$REPO_ROOT"/*.sh

echo -e "${BOLD}====================================================${NC}"
echo -e "${BOLD}         Running idx-tools Test Suite               ${NC}"
echo -e "${BOLD}====================================================${NC}"
echo ""

SUITES=(
  "test_syntax.sh"
  "test_update_index.sh"
  "test_update_csv.sh"
  "test_update_data.sh"
  "test_installer.sh"
)

TOTAL_FAILED=0
TOTAL_SUITES=${#SUITES[@]}
PASSED_SUITES=0

for suite in "${SUITES[@]}"; do
  suite_path="$REPO_ROOT/tests/$suite"
  if [[ -f "$suite_path" ]]; then
    if bash "$suite_path"; then
      PASSED_SUITES=$((PASSED_SUITES + 1))
    else
      TOTAL_FAILED=$((TOTAL_FAILED + 1))
    fi
    echo ""
  else
    echo -e "${RED}Test suite missing: $suite${NC}"
    TOTAL_FAILED=$((TOTAL_FAILED + 1))
  fi
done

echo -e "${BOLD}====================================================${NC}"
if [[ "$TOTAL_FAILED" -eq 0 ]]; then
  echo -e "${GREEN}${BOLD}ALL TEST SUITES PASSED ($PASSED_SUITES/$TOTAL_SUITES)${NC}"
  echo -e "${BOLD}====================================================${NC}"
  exit 0
else
  echo -e "${RED}${BOLD}SOME TEST SUITES FAILED ($TOTAL_FAILED failed, $PASSED_SUITES passed)${NC}"
  echo -e "${BOLD}====================================================${NC}"
  exit 1
fi
