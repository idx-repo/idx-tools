#!/usr/bin/env bash

# test_syntax.sh - Validate syntax of all Bash and R scripts in the repository.

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$REPO_ROOT/tests/test_helpers.sh"

echo "=== Suite: Syntax & Lint Checks ==="

test_case "Bash scripts syntax validation (bash -n)"
for script in "$REPO_ROOT"/Bash/*.sh "$REPO_ROOT"/*.sh; do
  [[ -f "$script" ]] || continue
  rel_path="${script#$REPO_ROOT/}"
  if bash -n "$script" 2>/dev/null; then
    TESTS_PASSED=$((TESTS_PASSED + 1))
  else
    echo -e "    ${RED}FAIL:${NC} Syntax error in $rel_path"
    TESTS_FAILED=$((TESTS_FAILED + 1))
  fi
done

test_case "R scripts syntax validation (Rscript parse)"
for r_script in "$REPO_ROOT"/R/*.R; do
  [[ -f "$r_script" ]] || continue
  rel_path="${r_script#$REPO_ROOT/}"
  if Rscript -e "invisible(parse(file='$r_script'))" >/dev/null 2>&1; then
    TESTS_PASSED=$((TESTS_PASSED + 1))
  else
    echo -e "    ${RED}FAIL:${NC} Syntax error in $rel_path"
    TESTS_FAILED=$((TESTS_FAILED + 1))
  fi
done

report_suite_results "Syntax Checks"
exit $?
