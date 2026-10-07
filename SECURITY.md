# Security Policy

## Supported Versions

The following table indicates the current support status for security updates across releases of LYSPYTHON.

| Version      | Supported          | Status                               |
| ------------ | ------------------ | ------------------------------------ |
| 0.1.x-alpha  | Yes                | Active research and development tree |
| < 0.1.0      | No                 | Pre-release prototypes               |

## Vulnerability Reporting and Responsible Disclosure

The LYSPYTHON project takes the security of language runtimes and foreign function interface (FFI) boundaries seriously. Because LYSPYTHON bridges Common Lisp memory management (such as SBCL garbage collection) with CPython's reference-counted runtime (`PyObject*`), potential vulnerabilities may arise in memory safety, pointer invalidation, macro hygiene circumvention, or sandboxed execution escapes.

If you discover a security vulnerability within LYSPYTHON, please do not disclose it publicly in issues, discussions, or social media.

### Reporting Procedure

1. Submit a detailed report by email to the repository maintainers at: `security@lyspython.org` (or directly via GitHub Private Vulnerability Reporting).
2. Include the following details:
   - Specific component or module (e.g., `src/bridge/cpython.lisp`, `src/macros/engine.lisp`, `src/lowering/lower.lisp`).
   - Detailed description of the vulnerability, including memory hazards, foreign execution exploits, or macro denial-of-service conditions.
   - Minimal reproducible proof of concept (either Common Lisp code or Python surface script).
   - Expected behavior versus observed security impact.
   - Any remediation suggestions or draft patches.

### Response Timelines

- Initial acknowledgment: Within 48 hours of receipt.
- Triage assessment and confirmation: Within 7 business days.
- Patch delivery and advisory publication: Within 30 days, coordinated with the reporting researcher.

## Security Architecture Principles

LYSPYTHON adheres to the following internal security guidelines:

1. **Foreign Pointer Lifetime Isolation**: Every CPython reference (`PyObject*`) allocated via CFFI must have deterministic decref semantics or be managed by a registered finalizer to prevent memory corruption and resource leakage.
2. **Macro Sandbox Boundaries**: Macro expansions operate purely on AST data structures. User-defined macros must not manipulate host process internals or invoke unvetted system calls during AST transformation passes.
3. **Canonical AST Validation**: Before passing an AST to the CPython lowerer, the canonical semantic analyzer validates node invariants to prevent malformed AST injection into the CPython execution engine.
