# Implementation Notes for Engineers and Runtime Developers

## 1. Memory Management Across the SBCL / CPython Boundary

One of the central technical challenges in LYSPYTHON is coordinating two disparate memory management paradigms:
- **Common Lisp (SBCL)**: Generational copying garbage collection.
- **CPython**: Reference counting with cyclic generational cycle detection (`PyObject*`).

### Rules for Handling `PyObject*` in Common Lisp
1. **Never leak foreign pointers**: Any foreign pointer obtained via `PyObject_CallObject`, `PyDict_New`, or `PyRun_String` must be tracked via an encapsulating `python-handle` struct or registered with a garbage collector finalizer (`trivial-garbage:finalize` or SBCL finalizers).
2. **Borrowed vs New References**:
   - `PyDict_GetItemString` returns a *borrowed* reference. Do not call `Py_DECREF` on it.
   - `PyObject_GetAttrString`, `PyLong_FromLong`, etc., return *new* references. You must ensure `Py_DECREF` is called when finished.
3. **Condition Handling**: If a Lisp condition is signaled during evaluation, an `unwind-protect` block must clean up any pending foreign pointers to prevent resource leaks in long-running REPL sessions.

## 2. Hygiene and Variable Capture in Heterogeneous Macros

In homogeneous Lisp macro systems, hygiene is maintained via `gensym` or syntax-rules renaming. In LYSPYTHON, macros transform Python AST nodes.
- When generating intermediate variables during desugaring (e.g., iterator storage in `for` loops), allocate fresh symbols using `(make-unique-identifier "iter_")`.
- The semantic analyzer ensures these synthesized symbols do not collide with user variables defined in the lexical scope.

## 3. Fixed-Point Cycle Detection Mechanics

The macro expansion loop tracks a structural hash of each AST node:
```lisp
(defun node-structural-digest (node)
  (sxhash (serialize-ast-node node)))
```
If `(member digest visited-digests)` evaluates to true before the node is irreducible, the engine terminates expansion and signals an `expansion-cycle-detected` diagnostic condition.
