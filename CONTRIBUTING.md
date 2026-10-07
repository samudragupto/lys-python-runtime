# Contributing to LYSPYTHON

Thank you for your interest in contributing to LYSPYTHON: A Lisp-Macro-Defined Python Runtime & REPL.

LYSPYTHON is an open-source programming language research project. We treat our codebase with the rigor of a formal compiler and runtime engineering laboratory. Contributions must prioritize sound theoretical foundations, clean modular abstractions, deterministic behavior, and clear documentation.

## Core Engineering Principles

Before opening a pull request or proposing an architectural change, familiarize yourself with our governing principles:

1. **Meta over Interop**: LYSPYTHON is not a basic foreign function bridge. Common Lisp is the meta-language that defines, transforms, and governs Python constructs; CPython is the execution engine.
2. **Semantics over Syntax**: Focus on what a construct means in the canonical model, not merely how it is written in surface syntax.
3. **Determinism and Traceability**: Every macro expansion step, AST transformation, and lowering phase must be deterministic, introspectable, and recordable.
4. **Clean Layer Separation**: Keep strict boundaries between reader/parser, surface AST, macro engine, canonical AST, lowering, and foreign bridge.
5. **No Emojis Policy**: Do not use emojis in commit messages, documentation, code comments, pull requests, or issue discussions. Maintain formal, technical prose.

## Repository Setup and Development Workflow

### Prerequisites
- **Common Lisp Implementation**: SBCL (Steel Bank Common Lisp) 2.2+ is recommended.
- **ASDF**: ASDF 3.3+ (standard with SBCL).
- **Python**: CPython 3.10+ (headers and shared libraries required for CFFI linking).
- **Quicklisp**: Standard Common Lisp library manager.
- **Git** and standard POSIX build tools (`make`).

### Building and Loading the System

1. Clone the repository into your local Common Lisp source registry (e.g., `~/common-lisp/` or configure ASDF):
   ```bash
   git clone https://github.com/samudragupto/lys-python-runtime.git
   ```

2. Load the system in SBCL via ASDF / Quicklisp:
   ```lisp
   (asdf:load-asd (merge-pathnames "lyspython.asd" (truename ".")))
   (ql:quickload :lys-python)
   ```

3. Run the complete test suite:
   ```bash
   make test
   ```
   Or within the REPL:
   ```lisp
   (asdf:test-system :lys-python)
   ```

## Contribution Workflow

### 1. Issue Discussion
For non-trivial enhancements, new macro primitives, or alterations to the AST specification, open an issue using the appropriate template:
- `research_proposal.yml` for conceptual language extensions or formal semantic redesigns.
- `feature_request.yml` for runtime capabilities or REPL enhancements.
- `bug_report.yml` for defects, FFI faults, or parser discrepancies.

### 2. Branching Strategy
- Base all feature branches off the latest `main` branch.
- Use descriptive branch names: `feature/macro-hygiene-tracker`, `fix/cffi-pyobject-decref`, `research/pattern-matching-macro`.

### 3. Code Conventions
- **Common Lisp**:
  - Follow standard Common Lisp indentation (2 spaces).
  - Use lowercase symbols with hyphens (`kebab-case`).
  - Name predicates with a trailing `p` (or `-p` for hyphenated names, e.g., `ast-node-p`).
  - Provide comprehensive docstrings on all exported symbols, generic functions, and structures.
  - Package exports must be declared explicitly in `src/core/packages.lisp`.
- **Python Companion Code**:
  - Follow PEP 8 guidelines.
  - Type annotations must be present on public functions.

### 4. Testing Requirements
- Every new AST node type must have corresponding unit tests verifying constructor invariants and serialization.
- Every macro definition added to `src/macros/builtin.lisp` must have tests verifying:
  - Single-step macro expansion (`macroexpand-1`).
  - Full fixed-point expansion.
  - Correct canonical AST generation.
  - Successful evaluation through the CPython lowering bridge.

### 5. Commit Standards
Write structured, conventional commit messages:
```text
feat(macros): implement fixed-point expansion depth limiter

Introduce *max-macro-expansion-depth* configuration variable and
signal expansion-depth-exceeded condition when cyclical macro
re-writing occurs.

Refs #42
```

## Pull Request Checklist

Before submitting a pull request, ensure:
- [ ] Code compiles without warnings under SBCL.
- [ ] All unit and integration tests pass (`make test`).
- [ ] Documentation has been updated in `docs/` and `ARCHITECTURE.md` if interfaces changed.
- [ ] No emojis are present in code or commit messages.
- [ ] Conventional commit messages are used.
