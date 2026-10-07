#!/usr/bin/env bash
# LYSPYTHON: Launch Interactive Research REPL

set -euo pipefail

SBCL_BIN="${SBCL_BIN:-sbcl}"

echo "Starting LYSPYTHON Interactive REPL..."

"${SBCL_BIN}" --noinform \
              --eval '(require :asdf)' \
              --eval '(asdf:load-asd (merge-pathnames "lyspython.asd" (truename ".")))' \
              --eval '(asdf:load-system :lys-python)' \
              --eval '(lys.repl:start-repl)' \
              --quit
