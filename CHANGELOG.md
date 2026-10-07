# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Comprehensive architecture specification in `ARCHITECTURE.md` and `docs/design/`.
- Formal research framing, hypothesis, and methodology in `RESEARCH.md`.
- 13-phase engineering milestone progression in `ROADMAP.md`.
- ASDF system definition (`lyspython.asd`) with modular subsystems.
- Core packages definition in `src/core/packages.lisp` isolating meta, AST, macro, transform, lowering, bridge, and REPL namespaces.
- Surface Abstract Syntax Tree definitions in `src/ast/surface.lisp`.
- Canonical Abstract Syntax Tree definitions in `src/ast/canonical.lisp`.
- Macro Registry and metadata structures in `src/macros/registry.lisp`.
- Macro Expansion Engine with single-step, full recursive, and fixed-point expansion algorithms in `src/macros/engine.lisp`.
- Built-in semantic macro definitions for core Python constructs (`def`, `if`, `for`, `while`, `class`, `with`, `try`, `assign`, `call`, `return`) in `src/macros/builtin.lisp`.
- AST desugaring and normalization passes in `src/transform/desugar.lisp`.
- Semantic analyzer and scope binding resolution in `src/semantics/analyzer.lisp`.
- Lowering layer targeting executable CPython intermediate representation in `src/lowering/lower.lisp`.
- CPython foreign bridge abstraction via CFFI and Python companion harness in `src/bridge/cpython.lisp` and `src/bridge/python_bridge.py`.
- Lexical namespace and frame environment models in `src/env/namespaces.lisp`.
- Unified evaluation pipeline in `src/runtime/eval.lisp`.
- Interactive LYSPYTHON REPL with expansion inspection and AST visualization commands in `src/repl/`.
- Command line interface entry point in `src/cli/main.lisp`.
- Language Server Protocol foundational data structures and macro diagnostics in `src/lsp/foundation.lisp`.
- Sandboxed macro experiment facility in `src/extensions/sandbox.lisp`.
- Comprehensive test suite covering units, integration, and research scenarios in `tests/`.
- Concrete examples demonstrating basic syntax, macro redefinitions, and semantic redesigns in `examples/`.
- Continuous integration workflows for Common Lisp compilation, documentation consistency, architecture compliance, and security validation in `.github/workflows/`.
