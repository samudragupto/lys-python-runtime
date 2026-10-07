# Project Governance

## Principles of Project Governance

LYSPYTHON operates under an open-source research stewardship model designed to maintain architectural integrity, theoretical rigor, and high engineering quality. The project prioritizes academic clarity, verifiable design principles, and reproducible compiler engineering over rapid, unvetted feature accumulation.

## Roles and Responsibilities

### Maintainers / Core Architects
Core architects hold commit rights to the primary repository and oversee architectural decisions. Responsibilities include:
- Guiding the theoretical and engineering direction of the runtime.
- Reviewing and approving modifications to the AST specification, macro expansion engine, and CFFI bridge.
- Ensuring compliance with research milestones defined in `ROADMAP.md`.
- Managing releases, version tagging, and security advisories.

### Contributors
Contributors are developers, researchers, and students who author pull requests, propose formal macro abstractions, improve test suites, or enhance documentation. Contributors are expected to uphold the technical standards documented in `CONTRIBUTING.md`.

### Research Reviewers
Research reviewers provide peer evaluation for research proposals submitted via the `research_proposal.yml` template, ensuring theoretical soundness and alignment with programming language literature.

## Decision Making Process

1. **Consensus-Driven Technical Review**: Technical decisions regarding module layout, AST representation, and lowering mechanisms are discussed publicly in Pull Requests or Architectural Issues.
2. **RFC Requirement for Core Changes**: Any change modifying:
   - The contract of `define-python-macro`,
   - The Canonical AST structure (`src/ast/canonical.lisp`),
   - Or the CPython foreign memory lifetime protocol,
   requires an Architectural RFC submitted to `docs/design/` prior to implementation.
3. **Architectural Veto**: In cases of fundamental divergence, the Core Architects retain final authority to preserve the project's foundational premise: Common Lisp as the defining meta-language of Python semantics.
