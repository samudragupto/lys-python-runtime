# LYSPYTHON Development Roadmap

This document outlines the progressive, phased execution plan for LYSPYTHON: A Lisp-Macro-Defined Python Runtime & REPL. The roadmap spans foundational language workbench architecture through empirical compiler research and editor tooling.

---

## Phase 0: Research, Ideation & System Design
- **Objective**: Establish the theoretical and mathematical foundations of meta-language driven imperative execution. Formalize the boundary between Common Lisp (meta-language) and Python (object-language).
- **Tasks**:
  - Author formal problem definition, research questions, and literature review comparing macro-expansion systems against dual-language FFI bridges.
  - Define the formal semantics of the transformation pipeline: Surface AST -> Macro Expansion -> Canonical AST -> Lowered Form -> CPython C-API.
  - Establish hygiene criteria and variable capture prevention mechanisms for multi-language macro systems.
- **Deliverables**:
  - `RESEARCH.md` complete with theoretical background and comparative analyses.
  - `ARCHITECTURE.md` specifying data flow, system boundaries, and module contracts.
- **Status**: Completed.

---

## Phase 1: Foundation & Repository Engineering
- **Objective**: Construct the enterprise-grade repository skeleton, ASDF system definition, package isolation, configuration hierarchy, and continuous integration workflows.
- **Tasks**:
  - Define `lyspython.asd` with modular sub-components and strict dependency topology.
  - Structure package namespaces in `src/core/packages.lisp` isolating meta, AST, macro, lowering, bridge, and REPL facilities.
  - Implement runtime configuration, logging, diagnostic condition hierarchies, and global kernel state.
  - Establish GitHub Actions workflows for ASDF loading, markdown validation, architecture enforcement, and security auditing.
- **Deliverables**:
  - Complete root repository files (`Makefile`, `LICENSE`, `CONTRIBUTING.md`, `SECURITY.md`, `CITATION.cff`).
  - Automated CI matrix in `.github/workflows/`.
  - Kernel bootstrap sequence in `src/core/kernel.lisp`.
- **Status**: Completed.

---

## Phase 2: Python Surface Modeling & AST Design
- **Objective**: Formulate the Surface Abstract Syntax Tree (Surface AST) capable of capturing all surface syntactical forms of Python code without loss of semantic intent.
- **Tasks**:
  - Model expressions: literals, identifiers, binary operations, unary operations, calls, attribute lookups, subscripts, slices, comprehensions, and lambda abstractions.
  - Model statements: function definitions (`def`), class definitions (`class`), conditionals (`if`/`elif`/`else`), loops (`for`/`while`), context managers (`with`), exception handlers (`try`/`except`/`finally`), assignments, and control transfers (`return`/`break`/`continue`/`raise`).
  - Implement surface AST constructors, serialization, equality predicates, and visitor protocols.
- **Deliverables**:
  - `src/ast/surface.lisp` defining structured surface nodes.
  - Unit tests verifying AST node creation and immutability.
- **Status**: Completed.

---

## Phase 3: Lisp Macro Registry & Definition Layer
- **Objective**: Engineer the central Lisp Macro Registry and the `define-python-macro` abstraction that allows Common Lisp code to register syntactic and semantic rewrites for Python forms.
- **Tasks**:
  - Implement the `macro-registry` data structure supporting name resolution, priority ordering, versioning, documentation, and metadata tags.
  - Create the `define-python-macro` domain-specific macro definition interface supporting pattern destructuring and quasiquotation over AST nodes.
  - Support lexical vs. global macro environments.
- **Deliverables**:
  - `src/macros/registry.lisp` containing the thread-safe registry.
  - Macro registration and unregistration interfaces with inspection capabilities.
- **Status**: Completed.

---

## Phase 4: Macro Expansion Engine
- **Objective**: Implement the core macro expansion engine capable of single-step expansion, recursive expansion, and fixed-point expansion with cycle detection.
- **Tasks**:
  - Implement `macroexpand-1` to expand the outermost macro application of a surface AST node.
  - Implement `macroexpand-all` to recursively traverse and expand AST subtrees.
  - Implement `macroexpand-fixpoint` to repeatedly expand an AST until a stable, irreducible canonical form is achieved.
  - Build the `expansion-trace` recording mechanism that logs every intermediate transformation step for debugging and inspection.
- **Deliverables**:
  - `src/macros/engine.lisp` with expansion algorithms and recursion limit guards.
  - Comprehensive unit tests verifying termination and cycle detection.
- **Status**: Completed.

---

## Phase 5: Canonical AST, Desugaring & Semantics
- **Objective**: Establish the normalized, canonical AST representation into which all surface forms must lower, and implement semantic validation and scope analysis.
- **Tasks**:
  - Formulate `src/ast/canonical.lisp` defining the minimal, un-sugared core AST.
  - Implement desugaring passes: lowering `for` into iterator retrieval and `while` loops, lowering `with` into `try`/`finally` blocks, and flattening complex assignments.
  - Build `src/semantics/analyzer.lisp` for lexical scope analysis, variable capture detection, and binding verification.
- **Deliverables**:
  - `src/transform/desugar.lisp` implementing canonical desugaring rewrites.
  - `src/semantics/analyzer.lisp` performing static semantic verification.
- **Status**: Completed.

---

## Phase 6: Lowering & CPython Bridge
- **Objective**: Bridge Common Lisp's canonical AST representation with the real CPython runtime via CFFI and Python C-API structures.
- **Tasks**:
  - Construct `src/lowering/lower.lisp` to lower canonical AST structures into CPython AST / executable bytecode forms.
  - Implement `src/bridge/cpython.lisp` binding to `libpython` via CFFI, providing initialization (`Py_InitializeEx`), object allocation, evaluation, and reference counting (`Py_INCREF`/`Py_DECREF`).
  - Provide a fallback bridge harness in `src/bridge/python_bridge.py` for headless environments and verification.
- **Deliverables**:
  - Seamless evaluation of lowered representations within live CPython processes.
  - Deterministic foreign memory management and error conversion.
- **Status**: Completed.

---

## Phase 7: LYSPYTHON REPL & Expansion Inspector
- **Objective**: Build an interactive, researcher-oriented REPL featuring live macro registration, step-by-step expansion visualization, and multi-mode tracing.
- **Tasks**:
  - Implement `src/repl/core.lisp` with prompt loop, command dispatch, and multiline ingestion.
  - Implement `src/repl/inspector.lisp` providing visual diffs of Surface AST -> Expanded AST -> Canonical AST.
  - Support execution modes: `:normal`, `:macro-trace`, `:ast-trace`, `:verbose`, and `:research`.
  - Maintain session history and namespace persistence in `src/repl/history.lisp`.
- **Deliverables**:
  - Functional interactive REPL executable via CLI or Common Lisp image.
- **Status**: Completed.

---

## Phase 8: Tree-sitter Integration
- **Objective**: Integrate Tree-sitter for robust, resilient, editor-grade surface parsing of Python source code.
- **Tasks**:
  - Define the Tree-sitter C-API bindings and CST-to-Surface-AST translation layer in `src/reader/parser.lisp`.
  - Support incremental re-parsing for editor keystroke latency benchmarks.
  - Provide fallback s-expression surface reader for environments without native tree-sitter binaries.
- **Deliverables**:
  - Resilient surface parser producing validated surface AST instances.
  - Documentation in `docs/notes/TREE-SITTER-INTEGRATION.md`.
- **Status**: Active / In Progress.

---

## Phase 9: LSP Foundations
- **Objective**: Design and build the foundational data model for the LYSPYTHON Language Server Protocol (LSP) to provide macro-aware editor tooling.
- **Tasks**:
  - Implement JSON-RPC message framing and LSP state machine in `src/lsp/foundation.lisp`.
  - Provide "Expand Macro Under Cursor" code actions and macro definition origin jump-to-definition.
  - Emit macro-expansion-aware semantic diagnostics and inline hints.
- **Deliverables**:
  - `src/lsp/foundation.lisp` complete with protocol types and handlers.
  - Integration guide for Neovim, VS Code, Zed, and Emacs in `docs/notes/LSP-FOUNDATIONS.md`.
- **Status**: Active / In Progress.

---

## Phase 10: Built-in Python Semantic Macros
- **Objective**: Implement the standard library of semantic macros that define the baseline semantics of Python in terms of Common Lisp rewrites.
- **Tasks**:
  - Write macro definitions for: `def` (function definition with metadata and docstring extraction), `if` (conditional branching), `for` (iterative sequencing), `while` (loop invariant execution), `class` (metaclass and namespace assembly), `with` (context manager protocol), `try` (exception dispatching).
  - Implement macro hygiene guards to prevent accidental symbol shadowing.
- **Deliverables**:
  - `src/macros/builtin.lisp` containing baseline semantic definitions.
  - Verification that standard Python idioms execute identically to baseline CPython when un-altered.
- **Status**: Completed.

---

## Phase 11: Tooling, Docs, CI/CD & Hardening
- **Objective**: Ensure comprehensive test coverage, stress testing, documentation integrity, and clean cross-platform builds.
- **Tasks**:
  - Expand unit and integration test matrices in `tests/`.
  - Validate memory leak absence across long-running REPL sessions.
  - Generate comprehensive technical diagrams in `docs/diagrams/`.
- **Deliverables**:
  - 100% green test passes across unit, integration, and research suites.
  - Verified documentation links and architectural diagrams.
- **Status**: Active / In Progress.

---

## Phase 12: Research Validation, Examples & Long-Term Vision
- **Objective**: Conduct empirical case studies validating the research thesis: demonstrating language redefinition via Common Lisp macros without altering CPython source code.
- **Tasks**:
  - Case Study 1: Transparent function memoization and contract verification via redefined `def`.
  - Case Study 2: Re-engineered control flow (reversible loops, transactional `if` statements).
  - Case Study 3: Pure functional subset of Python enforcing immutability through macro-time validation.
  - Publish research whitepaper and reproducible benchmarking scripts.
- **Deliverables**:
  - `examples/macro-experiments/` and `examples/semantic-redesigns/` fully populated.
  - Research validation report and evaluation artifact.
- **Status**: Active / In Progress.
