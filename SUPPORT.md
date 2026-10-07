# Support Guidelines

## Project Scope and Objective

LYSPYTHON is an advanced programming language research runtime exploring meta-linguistic definition of imperative languages via Common Lisp macros. Because of its research-oriented nature, support is organized around formal channels to foster engineering rigor and scientific discussion.

## Official Support Channels

### 1. GitHub Discussions
For architectural inquiries, theoretical questions regarding meta-circular evaluation, macro hygiene, semantic inversion, or ideas for new macro primitives, use GitHub Discussions:
- Category: **Ideas and Research** - for theoretical language design and semantics questions.
- Category: **Q&A** - for setup, SBCL configuration, and CPython C-API FFI troubleshooting.
- Category: **Show and Tell** - for user-defined semantic macros and experimental syntax transformations.

### 2. GitHub Issues
For reproducible defects, compiler crashes, macro expansion divergences, or memory safety bugs at the CFFI layer, file a structured GitHub Issue using our issue templates:
- **Bug Report**: For crashes, incorrect lowering, or FFI faults.
- **Feature Request**: For planned additions to AST nodes or standard macro expansions.
- **Research Proposal**: For novel formal semantic experiments or language extensions.

### 3. Documentation
Before submitting an inquiry, consult our formal technical documentation:
- [ARCHITECTURE.md](file:///c:/Users/user/Desktop/lys-python-runtime/ARCHITECTURE.md) - System architecture, execution pipeline, and lowering specification.
- [RESEARCH.md](file:///c:/Users/user/Desktop/lys-python-runtime/RESEARCH.md) - Theoretical foundations, formal problem statement, and comparative study.
- [ROADMAP.md](file:///c:/Users/user/Desktop/lys-python-runtime/ROADMAP.md) - Development phases, milestones, and release targets.
- [docs/design/](file:///c:/Users/user/Desktop/lys-python-runtime/docs/design) - Module specifications and implementation notes.

## Out of Scope

The maintainers do not provide support for:
- Proprietary CPython extension builds lacking standard header symbols.
- General questions on basic Python or basic Common Lisp syntax unrelated to LYSPYTHON.
- Production deployment in mission-critical commercial services prior to version 1.0.0.
