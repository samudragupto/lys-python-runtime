#!/usr/bin/env bash
# LYSPYTHON: Automated Test Suite Runner

set -euo pipefail

SBCL_BIN="${SBCL_BIN:-sbcl}"

echo "Executing LYSPYTHON test suites..."

"${SBCL_BIN}" --non-interactive \
              --eval '(require :asdf)' \
              --eval '(asdf:load-asd (merge-pathnames "lyspython.asd" (truename ".")))' \
              --eval '(asdf:load-system :lys-python/tests)' \
              --eval '(let ((ok (lys.tests:run-all-tests))) (uiop:quit (if ok 0 1)))'
