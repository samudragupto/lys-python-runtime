# The LYSPYTHON Macro System Specification

## 1. Conceptual Overview

The macro system is the defining core of LYSPYTHON. It allows Common Lisp programmers to define transformation rules that apply to Python syntactic constructs.

Macros operate strictly on the **semantic tree structure** of Python, never on raw character strings or unparsed tokens.

## 2. The `define-python-macro` Abstraction

The fundamental construct for defining a macro is `define-python-macro`:

```lisp
(define-python-macro name (lambda-list)
  "Optional documentation string."
  body...)
```

### Parameters and Semantics
- `name`: A symbol matching the surface construct operator (e.g., `def`, `if`, `for`, `while`, `class`, `with`, `try`, `assign`, `call`, `return`).
- `lambda-list`: Arguments corresponding to the AST node's slots.
- `body`: Common Lisp expressions that return a transformed AST node or AST s-expression.

## 3. Macro Categories

LYSPYTHON distinguishes between three classes of macros:

1. **Syntactic Macros (Desugaring)**:
   Rewrite convenient surface syntax into more primitive forms.
   *Example*: Desugaring `for x in iterable: body` into an iterator assignment and a `while` loop.

2. **Semantic Macros (Meaning Redefinition)**:
   Alter the operational semantics of a construct without altering its outward shape.
   *Example*: Redefining `def` to automatically inject pre/post condition validation or execution profiling.

3. **Instrumenting / Governance Macros**:
   Wrap execution blocks with telemetry, access control checks, or transactional isolation boundaries.

## 4. Expansion Stages

1. **Step-by-Step (`macroexpand-1`)**: Applies the single outermost registered transformation.
2. **Recursive Traversal (`macroexpand-all`)**: Applies transformations recursively down all child branches of the AST.
3. **Fixed-Point Convergence (`macroexpand-fixpoint`)**: Repeatedly expands the tree until no further transformations apply, or until a cycle is detected.
