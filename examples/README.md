# LYSPYTHON Examples and Research Demonstrations

This directory contains executable scripts, macro experiments, and semantic redesigns demonstrating the capabilities of LYSPYTHON.

## Directory Structure

```text
examples/
|-- basic/
|   |-- 01_hello_world.lys       # Basic surface syntax evaluation
|   `-- 02_control_flow.lys      # Desugared for-loops and conditionals
|-- macro-experiments/
|   |-- 01_redefined_if.lisp     # Overriding Python 'if' with telemetry logging
|   `-- 02_pattern_match.lys     # Structural pattern matching macro
`-- semantic-redesigns/
    |-- 01_instrumented_def.lisp # Redefining 'def' to inject automatic timing & profiling
    |-- 02_contract_checking.lisp# Pre/post-condition invariant contracts on functions
    `-- 03_pure_functional_python.lisp # Enforcing immutability at macro-expansion time
```

## Running an Example

To execute an example in LYSPYTHON:
```bash
# In the REPL:
(lys.runtime:eval-surface-code (uiop:read-file-string "examples/basic/01_hello_world.lys"))

# Or using the command-line interface:
lyspython --file examples/basic/01_hello_world.lys
```
