# Graph Report - lys-python-runtime  (2026-10-02)

## Corpus Check
- 61 files · ~23,311 words
- Verdict: corpus is large enough that graph structure adds value.
- Unclassified: 18 file(s) not represented in the graph (top: .mermaid 8, (none) 6, .lys 3)

## Summary
- 576 nodes · 590 edges · 58 communities (37 shown, 21 thin omitted)
- Extraction: 99% EXTRACTED · 1% INFERRED · 0% AMBIGUOUS · INFERRED: 3 edges (avg confidence: 0.88)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `90ca1b99`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).

## Community Hubs (Navigation)
- surface.lisp
- canonical.lisp
- python_bridge.py
- cpython.lisp
- registry.lisp
- logging.lisp
- core/packages.lisp
- engine.lisp
- config.lisp
- history.lisp
- tokens.lisp
- foundation.lisp
- run_tests.lisp
- kernel.lisp
- analyzer.lisp
- errors.lisp
- lower.lisp
- start-repl
- eval.lisp
- test_macro_engine.lisp
- sandbox.lisp
- inspector.lisp
- test_pipeline.lisp
- test_ast.lisp
- 03_pure_functional_python.lisp
- main
- if (macro)
- def (macro)
- def-with-contract (macro)
- load-builtin-macros
- parse-surface-sexpr
- desugar-ast
- lys.tests
- test-dynamic-semantic-inversion
- test-ast-desugaring-pass
- build_binary.sh
- run_repl.sh
- run_tests.sh
- LYSPYTHON Development Roadmap
- LYSPYTHON
- LYSPYTHON: System Architecture and Engineering Specification
- RESEARCH SPECIFICATION: META-LANGUAGE DRIVEN IMPERATIVE RUNTIMES
- Contribution Workflow
- 2. Invariant Contracts Across Interfaces
- 3. Editor Configuration Guides
- Project Governance
- Official Support Channels
- The LYSPYTHON Macro System Specification
- Implementation Notes for Engineers and Runtime Developers
- PULL_REQUEST_TEMPLATE.md
- Tree-sitter Integration Architecture
- Theoretical Foundations of Heterogeneous Meta-Macro Systems
- Changelog
- Semantic Inversion: Inverting the Meta-Language Hierarchy
- LYSPYTHON Examples and Research Demonstrations
- rules/graphify.md
- workflows/graphify.md

## God Nodes (most connected - your core abstractions)
1. `LYSPYTHON` - 30 edges
2. `LYSPYTHON Development Roadmap` - 14 edges
3. `LYSPYTHON: System Architecture and Engineering Specification` - 10 edges
4. `RESEARCH SPECIFICATION: META-LANGUAGE DRIVEN IMPERATIVE RUNTIMES` - 10 edges
5. `Contributor Covenant Code of Conduct` - 7 edges
6. `macroexpand-fixpoint()` - 6 edges
7. `tokenize-surface-string()` - 6 edges
8. `print_ascii_tree()` - 6 edges
9. `Contribution Workflow` - 6 edges
10. `canonical-macro-symbol()` - 5 edges

## Surprising Connections (you probably didn't know these)
- `2. Branching Strategy` --references--> `main()`  [INFERRED]
  CONTRIBUTING.md → tools/ast_visualizer.py

## Import Cycles
- None detected.

## Communities (58 total, 21 thin omitted)

### Community 0 - "surface.lisp"
Cohesion: 0.04
Nodes (22): ast-assign, ast-attribute, ast-aug-assign, ast-binary-op, ast-block, ast-call, ast-children(), ast-class (+14 more)

### Community 1 - "canonical.lisp"
Cohesion: 0.06
Nodes (15): ast-canonical-node, c-assign, c-binary-op, c-block, c-call, c-def, c-identifier, c-if (+7 more)

### Community 2 - "python_bridge.py"
Cohesion: 0.09
Nodes (9): 2. Branching Strategy, execute_lowered_code(), __lys_get_next__(), __lys_has_next__(), LysPythonBridge, main(), parse_sexpr(), read_tokens() (+1 more)

### Community 3 - "cpython.lisp"
Cohesion: 0.10
Nodes (11): cpython-bridge-initialized-p(), cpython-eval-result, cpython-status(), eval-in-cpython(), initialize-cpython-bridge(), %extract-json-string(), %parse-bridge-response(), pyobject-handle (+3 more)

### Community 4 - "registry.lisp"
Cohesion: 0.12
Nodes (10): canonical-macro-symbol(), clear-macros(), define-python-macro (macro), list-macros(), lookup-macro(), macro-definition, %destructure-ast-node(), register-macro() (+2 more)

### Community 5 - "logging.lisp"
Cohesion: 0.13
Nodes (11): format-ast-node(), log-error(), log-info(), log-trace(), log-warn(), make-unique-identifier(), %format-indent(), print-ast-tree() (+3 more)

### Community 6 - "core/packages.lisp"
Cohesion: 0.20
Nodes (17): lys.ast.canonical, lys.ast.surface, lys.bridge, lys.cli, lys.config, lys.core, lys.env, lys.extensions (+9 more)

### Community 7 - "engine.lisp"
Cohesion: 0.18
Nodes (8): get-node-operator(), macroexpand-1(), macroexpand-all(), macroexpand-fixpoint(), %node-structural-digest(), *expansion-trace*, *step-counter*, trace-step

### Community 8 - "config.lisp"
Cohesion: 0.15
Nodes (10): runtime-mode-p(), set-runtime-mode(), *cpython-shared-library-path*, *max-macro-expansion-depth*, *runtime-mode*, *trace-expansions-p*, *tree-sitter-library-path*, *valid-runtime-modes* (+2 more)

### Community 9 - "history.lisp"
Cohesion: 0.14
Nodes (8): clear-history(), history-entry, list-history(), record-history-entry(), save-history-to-file(), *history-counter*, *history-file*, *repl-history*

### Community 10 - "tokens.lisp"
Cohesion: 0.21
Nodes (6): digit-char-p*(), identifier-part-p(), identifier-start-p(), token, tokenize-surface-string(), whitespace-char-p()

### Community 11 - "foundation.lisp"
Cohesion: 0.18
Nodes (6): compute-macro-diagnostics(), expand-macro-action(), handle-request(), lsp-document, *open-documents*, start-server()

### Community 12 - "run_tests.lisp"
Cohesion: 0.26
Nodes (7): run-all-tests(), run-integration-tests(), run-research-tests(), run-test-case (macro), run-unit-tests(), *test-failures*, *test-passes*

### Community 13 - "kernel.lisp"
Cohesion: 0.24
Nodes (6): initialize-kernel(), kernel-status(), reset-kernel-state(), shutdown-kernel(), *kernel-initialized-p*, *kernel-start-time*

### Community 14 - "analyzer.lisp"
Cohesion: 0.20
Nodes (5): analyze-semantics(), check-hygiene(), make-default-semantic-context(), resolve-scopes(), semantic-context

### Community 15 - "errors.lisp"
Cohesion: 0.22
Nodes (8): cpython-bridge-error, expansion-cycle-detected, expansion-depth-exceeded, lowering-error, lys-condition, lys-error, macro-expansion-error, syntax-error

### Community 16 - "lower.lisp"
Cohesion: 0.32
Nodes (4): lower-canonical-ast(), lowered-ir, %indent-spaces(), %lower-to-python-string()

### Community 17 - "start-repl"
Cohesion: 0.43
Nodes (4): %print-banner(), %print-help(), %repl-evaluate(), start-repl()

### Community 18 - "eval.lisp"
Cohesion: 0.33
Nodes (3): eval-surface-ast(), eval-surface-code(), pipeline-result

### Community 19 - "test_macro_engine.lisp"
Cohesion: 0.29
Nodes (3): test-macro-cycle-detection(), test-macro-expansion-and-trace(), test-macro-registration-and-lookup()

### Community 39 - "LYSPYTHON Development Roadmap"
Cohesion: 0.06
Nodes (27): Attribution, Contributor Covenant Code of Conduct, Enforcement, Enforcement Responsibilities, Our Pledge, Our Standards, Scope, LYSPYTHON Development Roadmap (+19 more)

### Community 40 - "LYSPYTHON"
Cohesion: 0.06
Nodes (32): 10. Key Features, 11. LYSPYTHON REPL, 12. Macro Expansion Inspector, 13. Technology Stack, 14. Repository Structure, 15. Design Principles, 16. Use Cases, 17. Getting Started (+24 more)

### Community 41 - "LYSPYTHON: System Architecture and Engineering Specification"
Cohesion: 0.10
Nodes (21): 1. Architectural Goals, 2. High-Level System Overview, 3.1 Subsystem Decomposition, 3. Layered Architecture and Subsystem Responsibilities, 4.1 Surface AST (`src/ast/surface.lisp`), 4.2 Canonical AST (`src/ast/canonical.lisp`), 4. Surface AST vs. Canonical AST, 5.1 Macro Registry Design (`src/macros/registry.lisp`) (+13 more)

### Community 42 - "RESEARCH SPECIFICATION: META-LANGUAGE DRIVEN IMPERATIVE RUNTIMES"
Cohesion: 0.15
Nodes (13): 1. Abstract, 2. Problem Statement, 3. Research Questions, 4. Conceptual Framework: Meta-Language vs. Object-Language, 5. Novelty Statement, 6. Comparative Study, 7.1 Macro Systems and Language-Oriented Programming, 7.2 Abstract Syntax Tree Transformation Pipelines (+5 more)

### Community 43 - "Contribution Workflow"
Cohesion: 0.17
Nodes (11): 1. Issue Discussion, 3. Code Conventions, 4. Testing Requirements, 5. Commit Standards, Building and Loading the System, Contributing to LYSPYTHON, Contribution Workflow, Core Engineering Principles (+3 more)

### Community 44 - "2. Invariant Contracts Across Interfaces"
Cohesion: 0.25
Nodes (7): 1. Scope and Boundary Definition, 2. Invariant Contracts Across Interfaces, Architectural Specification: Subsystem Decomposition and Contracts, Contract 1: Reader -> Surface AST, Contract 2: Surface AST -> Macro Engine, Contract 3: Macro Output -> Desugaring -> Canonical AST, Contract 4: Canonical AST -> Lowering -> CPython Bridge

### Community 45 - "3. Editor Configuration Guides"
Cohesion: 0.25
Nodes (7): 1. Overview, 2. Core Capabilities, 3. Editor Configuration Guides, Emacs (eglot), Language Server Protocol (LSP) Architecture & Editor Integration, Neovim (nvim-lspconfig), Visual Studio Code

### Community 46 - "Project Governance"
Cohesion: 0.25
Nodes (7): Contributors, Decision Making Process, Maintainers / Core Architects, Principles of Project Governance, Project Governance, Research Reviewers, Roles and Responsibilities

### Community 47 - "Official Support Channels"
Cohesion: 0.25
Nodes (7): 1. GitHub Discussions, 2. GitHub Issues, 3. Documentation, Official Support Channels, Out of Scope, Project Scope and Objective, Support Guidelines

### Community 48 - "The LYSPYTHON Macro System Specification"
Cohesion: 0.29
Nodes (6): 1. Conceptual Overview, 2. The `define-python-macro` Abstraction, 3. Macro Categories, 4. Expansion Stages, Parameters and Semantics, The LYSPYTHON Macro System Specification

### Community 49 - "Implementation Notes for Engineers and Runtime Developers"
Cohesion: 0.33
Nodes (5): 1. Memory Management Across the SBCL / CPython Boundary, 2. Hygiene and Variable Capture in Heterogeneous Macros, 3. Fixed-Point Cycle Detection Mechanics, Implementation Notes for Engineers and Runtime Developers, Rules for Handling `PyObject*` in Common Lisp

### Community 50 - "PULL_REQUEST_TEMPLATE.md"
Cohesion: 0.33
Nodes (5): Code Quality Checklist, Subsystem Impacted, Summary of Changes, Theoretical or Semantic Rationale, Verification and Testing

### Community 51 - "Tree-sitter Integration Architecture"
Cohesion: 0.40
Nodes (4): 1. Role of Tree-sitter in LYSPYTHON, 2. Ingestion Pipeline, 3. Fallback Reader, Tree-sitter Integration Architecture

### Community 52 - "Theoretical Foundations of Heterogeneous Meta-Macro Systems"
Cohesion: 0.40
Nodes (4): 1. Introduction, 2. Mathematical Formalization of Macro Transformation, 3. Termination and Fixed-Point Semantics, Theoretical Foundations of Heterogeneous Meta-Macro Systems

### Community 53 - "Changelog"
Cohesion: 0.50
Nodes (3): Added, Changelog, [Unreleased]

### Community 54 - "Semantic Inversion: Inverting the Meta-Language Hierarchy"
Cohesion: 0.50
Nodes (3): 1. The Conventional FFI Paradigm, 2. The Inversion Model, Semantic Inversion: Inverting the Meta-Language Hierarchy

### Community 55 - "LYSPYTHON Examples and Research Demonstrations"
Cohesion: 0.50
Nodes (3): Directory Structure, LYSPYTHON Examples and Research Demonstrations, Running an Example

## Knowledge Gaps
- **165 isolated node(s):** `*bound-immutable-identifiers*`, `build_binary.sh script`, `run_repl.sh script`, `run_tests.sh script`, `*bridge-initialized*` (+160 more)
  These have ≤1 connection - possible missing edges or undocumented components. (Counts symbols only; 334 node(s) total have ≤1 connection when file, concept and rationale nodes are included.)
- **21 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `LYSPYTHON` connect `LYSPYTHON` to `LYSPYTHON Development Roadmap`?**
  _High betweenness centrality (0.023) - this node is a cross-community bridge._
- **Why does `Contribution Workflow` connect `Contribution Workflow` to `python_bridge.py`?**
  _High betweenness centrality (0.023) - this node is a cross-community bridge._
- **What connects `*bound-immutable-identifiers*`, `build_binary.sh script`, `run_repl.sh script` to the rest of the system?**
  _165 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `surface.lisp` be split into smaller, more focused modules?**
  _Cohesion score 0.044444444444444446 - nodes in this community are weakly interconnected._
- **Should `canonical.lisp` be split into smaller, more focused modules?**
  _Cohesion score 0.06451612903225806 - nodes in this community are weakly interconnected._
- **Should `python_bridge.py` be split into smaller, more focused modules?**
  _Cohesion score 0.08735632183908046 - nodes in this community are weakly interconnected._
- **Should `cpython.lisp` be split into smaller, more focused modules?**
  _Cohesion score 0.10476190476190476 - nodes in this community are weakly interconnected._