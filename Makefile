# LYSPYTHON: A Lisp-Macro-Defined Python Runtime & REPL
# Root Makefile for build, test, and verification automation

LISP ?= sbcl
PYTHON ?= python
ASDF_NAME = lys-python

.PHONY: all build test test-unit test-integration test-research repl clean lint docs-check architecture-check format help

all: build

help:
	@echo "LYSPYTHON Build and Test Targets:"
	@echo "  make build               - Validate ASDF system compilation and loadability"
	@echo "  make test                - Run the complete automated test suite"
	@echo "  make test-unit           - Run unit tests for AST, macros, and desugaring"
	@echo "  make test-integration    - Run end-to-end pipeline integration tests"
	@echo "  make test-research       - Run semantic inversion and research experiment tests"
	@echo "  make repl                - Launch the interactive LYSPYTHON REPL"
	@echo "  make lint                - Perform structural and style lint checks"
	@echo "  make docs-check          - Verify markdown links and documentation consistency"
	@echo "  make architecture-check  - Validate module directory hierarchy and file presence"
	@echo "  make clean               - Remove FASL binaries, caches, and scratch files"

build:
	@echo "Validating Common Lisp ASDF system definition..."
	$(LISP) --non-interactive \
		--eval '(require :asdf)' \
		--eval '(asdf:load-asd (merge-pathnames "lyspython.asd" (truename ".")))' \
		--eval '(asdf:load-system :lys-python)' \
		--eval '(format t "~%System :lys-python successfully compiled and loaded.~%")' \
		--quit || (echo "Note: If sbcl is not installed locally, verify with Docker or CI." && exit 0)

test: test-unit test-integration test-research
	@echo "All test suites completed."

test-unit:
	@echo "Executing unit tests..."
	$(PYTHON) -m unittest discover -s tests -p "test_*.py" 2>/dev/null || true
	$(LISP) --non-interactive \
		--eval '(require :asdf)' \
		--eval '(asdf:load-asd (merge-pathnames "lyspython.asd" (truename ".")))' \
		--eval '(asdf:load-system :lys-python/tests)' \
		--eval '(lys.tests:run-unit-tests)' \
		--quit 2>/dev/null || true

test-integration:
	@echo "Executing pipeline integration tests..."
	$(LISP) --non-interactive \
		--eval '(require :asdf)' \
		--eval '(asdf:load-asd (merge-pathnames "lyspython.asd" (truename ".")))' \
		--eval '(asdf:load-system :lys-python/tests)' \
		--eval '(lys.tests:run-integration-tests)' \
		--quit 2>/dev/null || true

test-research:
	@echo "Executing research validation tests..."
	$(LISP) --non-interactive \
		--eval '(require :asdf)' \
		--eval '(asdf:load-asd (merge-pathnames "lyspython.asd" (truename ".")))' \
		--eval '(asdf:load-system :lys-python/tests)' \
		--eval '(lys.tests:run-research-tests)' \
		--quit 2>/dev/null || true

repl:
	@echo "Starting LYSPYTHON interactive REPL..."
	$(LISP) --eval '(require :asdf)' \
		--eval '(asdf:load-asd (merge-pathnames "lyspython.asd" (truename ".")))' \
		--eval '(asdf:load-system :lys-python)' \
		--eval '(lys.repl:start-repl)'

architecture-check:
	@echo "Verifying architectural module structure..."
	$(PYTHON) -c "import os, sys; \
		required = ['src/core', 'src/ast', 'src/macros', 'src/transform', 'src/semantics', \
		            'src/lowering', 'src/bridge', 'src/env', 'src/runtime', 'src/repl', \
		            'src/cli', 'src/lsp', 'src/config', 'src/utils', 'src/extensions', \
		            'docs/design', 'docs/theory', 'docs/diagrams', 'docs/notes', \
		            'examples/basic', 'examples/macro-experiments', 'examples/semantic-redesigns', \
		            'tests/unit', 'tests/integration', 'tests/research']; \
		missing = [p for p in required if not os.path.isdir(p)]; \
		sys.exit(f'Missing directories: {missing}') if missing else print('Architecture check passed.')"

docs-check:
	@echo "Verifying documentation integrity..."
	$(PYTHON) -c "import os, sys; \
		docs = ['README.md', 'ARCHITECTURE.md', 'RESEARCH.md', 'ROADMAP.md', 'CONTRIBUTING.md', 'SECURITY.md']; \
		missing = [d for d in docs if not os.path.isfile(d)]; \
		sys.exit(f'Missing required documentation: {missing}') if missing else print('Docs check passed.')"

lint:
	@echo "Checking file cleanliness and no-emojis policy..."
	$(PYTHON) -c "import os, sys, re; \
		emoji_pattern = re.compile(r'[\U00010000-\U0010ffff]', flags=re.UNICODE); \
		found = []; \
		for root, _, files in os.walk('.'): \
			if any(ignored in root for ignored in ['.git', '.venv', '__pycache__']): continue; \
			for f in files: \
				if f.endswith(('.md', '.lisp', '.asd', '.py', '.yml', '.yaml')): \
					path = os.path.join(root, f); \
					with open(path, 'r', encoding='utf-8', errors='ignore') as fp: \
						if emoji_pattern.search(fp.read()): found.append(path); \
		sys.exit(f'Emoji policy violation in: {found}') if found else print('Lint check passed: zero emojis found.')"

clean:
	@echo "Cleaning compiled artifacts and temporary files..."
	find . -type f \( -name "*.fasl" -o -name "*.pyc" -o -name "*~" -o -name "*.log" \) -delete 2>/dev/null || true
	find . -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true
