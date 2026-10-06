#!/usr/bin/env bash
# Runs the rendering harness (test/screens_test.dart) and prints only
# failures, culprit widget locations and the final summary.
out=$(MSYS_NO_PATHCONV=1 flutter test test/screens_test.dart "$@" 2>&1)
echo "$out" \
  | grep -vE "^#[0-9]+ |<asynchronous suspension>" \
  | grep -E -A3 "\[E\]$|overflowed by|relevant error-causing widget|thrown during|multiple heroes|Exception:" \
  | grep -vE "WIDGET INSPECTOR|^--$|Test failed|test description|The overflowing|^\s*$" \
  | sed 's#file:///D:/Project/allinonetangail/##' | awk '!seen[$0]++' | head -${LINES_MAX:-80}
echo "$out" | grep -E "All tests passed|Some tests failed" | tail -1
echo "$out" | grep -oE "^[0-9:]+ \+[0-9]+( -[0-9]+)?" | tail -1
