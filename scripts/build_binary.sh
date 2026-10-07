#!/usr/bin/env bash
# LYSPYTHON: Standalone Executable Image Builder

set -euo pipefail

SBCL_BIN="${SBCL_BIN:-sbcl}"
OUTPUT_BIN="${OUTPUT_BIN:-bin/lyspython}"

mkdir -p bin

echo "Compiling standalone LYSPYTHON binary: ${OUTPUT_BIN}..."

"${SBCL_BIN}" --non-interactive \
              --eval '(require :asdf)' \
              --eval '(asdf:load-asd (merge-pathnames "lyspython.asd" (truename ".")))' \
              --eval '(asdf:load-system :lys-python)' \
              --eval "(sb-ext:save-lisp-and-die \"${OUTPUT_BIN}\" :toplevel #'lys.cli:main :executable t)"

echo "Binary build complete: ${OUTPUT_BIN}"
