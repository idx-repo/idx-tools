#!/usr/bin/env bash

# test_helpers.sh - Helper functions and assertion utilities for idx-tools test suite.

TESTS_PASSED=0
TESTS_FAILED=0
CURRENT_TEST_NAME=""

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

test_case() {
  CURRENT_TEST_NAME="$1"
  echo -e "  ${BLUE}•${NC} Running: $CURRENT_TEST_NAME"
}

assert_exit_code() {
  local expected="$1"
  local actual="$2"
  local msg="${3:-"Exit code mismatch"}"

  if [[ "$expected" -eq "$actual" ]]; then
    TESTS_PASSED=$((TESTS_PASSED + 1))
  else
    echo -e "    ${RED}FAIL:${NC} $msg (expected: $expected, got: $actual)"
    TESTS_FAILED=$((TESTS_FAILED + 1))
  fi
}

assert_contains() {
  local haystack="$1"
  local needle="$2"
  local msg="${3:-"Expected string not found in output"}"

  if echo "$haystack" | grep -F -q -- "$needle"; then
    TESTS_PASSED=$((TESTS_PASSED + 1))
  else
    echo -e "    ${RED}FAIL:${NC} $msg"
    echo -e "      Expected to find: '$needle'"
    echo -e "      In: '$haystack'"
    TESTS_FAILED=$((TESTS_FAILED + 1))
  fi
}

assert_file_exists() {
  local file="$1"
  local msg="${2:-"Expected file does not exist"}"

  if [[ -e "$file" || -L "$file" ]]; then
    TESTS_PASSED=$((TESTS_PASSED + 1))
  else
    echo -e "    ${RED}FAIL:${NC} $msg: $file"
    TESTS_FAILED=$((TESTS_FAILED + 1))
  fi
}

assert_file_not_exists() {
  local file="$1"
  local msg="${2:-"File should not exist"}"

  if [[ ! -e "$file" && ! -L "$file" ]]; then
    TESTS_PASSED=$((TESTS_PASSED + 1))
  else
    echo -e "    ${RED}FAIL:${NC} $msg: $file"
    TESTS_FAILED=$((TESTS_FAILED + 1))
  fi
}

report_suite_results() {
  local suite_name="$1"
  echo ""
  if [[ "$TESTS_FAILED" -eq 0 ]]; then
    echo -e "${GREEN}✓ ${suite_name} passed (${TESTS_PASSED} assertions)${NC}"
    return 0
  else
    echo -e "${RED}✗ ${suite_name} failed (${TESTS_FAILED} failure(s), ${TESTS_PASSED} passed)${NC}"
    return 1
  fi
}
