"""
LYSPYTHON: A Lisp-Macro-Defined Python Runtime & REPL
Subsystem: CPython Companion Bridge and Execution Harness
"""

import sys
import io
import json
import traceback
import ast
from typing import Any, Dict, Optional, Tuple


# Runtime helpers for desugared macros
def __lys_has_next__(iterator: Any) -> bool:
    """Helper runtime primitive for macro-desugared while loops."""
    if not hasattr(iterator, "__lys_peek__"):
        try:
            val = next(iterator)
            iterator.__lys_peek__ = val
            iterator.__lys_has_item__ = True
            return True
        except StopIteration:
            iterator.__lys_has_item__ = False
            return False
    return getattr(iterator, "__lys_has_item__", False)


def __lys_get_next__(iterator: Any) -> Any:
    """Consume the peeked item or advance iterator."""
    if hasattr(iterator, "__lys_peek__") and iterator.__lys_has_item__:
        val = iterator.__lys_peek__
        del iterator.__lys_peek__
        iterator.__lys_has_item__ = False
        return val
    return next(iterator)


class LysPythonBridge:
    """Encapsulates persistent namespace execution and diagnostics."""

    def __init__(self):
        self.globals: Dict[str, Any] = {
            "__name__": "__lys_main__",
            "__builtins__": __builtins__,
            "__lys_has_next__": __lys_has_next__,
            "__lys_get_next__": __lys_get_next__,
        }
        self.locals: Dict[str, Any] = self.globals

    def execute_snippet(self, source_code: str) -> Dict[str, Any]:
        """Execute a lowered Python code string, capturing stdout and evaluation values."""
        stdout_capture = io.StringIO()
        stderr_capture = io.StringIO()
        old_stdout = sys.stdout
        old_stderr = sys.stderr

        sys.stdout = stdout_capture
        sys.stderr = stderr_capture

        success = True
        eval_result: Any = None
        error_type: Optional[str] = None
        error_msg: Optional[str] = None
        tb_str: Optional[str] = None

        try:
            # Parse into AST to capture expression values even in multi-statement blocks
            parsed = ast.parse(source_code)
            if parsed.body and isinstance(parsed.body[-1], ast.Expr):
                last_expr = parsed.body.pop()
                if parsed.body:
                    exec(compile(parsed, "<lyspython>", "exec"), self.globals, self.locals)
                code_obj = compile(ast.Expression(last_expr.value), "<lyspython>", "eval")
                eval_result = eval(code_obj, self.globals, self.locals)
            else:
                exec(compile(parsed, "<lyspython>", "exec"), self.globals, self.locals)
                eval_result = None
        except Exception as exc:
            success = False
            error_type = type(exc).__name__
            error_msg = str(exc)
            tb_str = traceback.format_exc()
        finally:
            sys.stdout = old_stdout
            sys.stderr = old_stderr

        stdout_val = stdout_capture.getvalue()
        stderr_val = stderr_capture.getvalue()

        return {
            "success": success,
            "result_repr": repr(eval_result) if eval_result is not None else "None",
            "stdout": stdout_val,
            "stderr": stderr_val,
            "error_type": error_type,
            "error_message": error_msg,
            "traceback": tb_str,
        }


# Global bridge singleton
_BRIDGE_INSTANCE = LysPythonBridge()


def execute_lowered_code(source_code: str) -> str:
    """Entry point callable from CFFI or subprocess, returning JSON."""
    result = _BRIDGE_INSTANCE.execute_snippet(source_code)
    return json.dumps(result)


if __name__ == "__main__":
    # If invoked directly via CLI/stdin for subprocess fallback mode
    if len(sys.argv) > 1 and sys.argv[1] == "--eval":
        payload = sys.argv[2] if len(sys.argv) > 2 else sys.stdin.read()
        print(execute_lowered_code(payload))
    else:
        # Interactive pipe mode
        for line in sys.stdin:
            if not line:
                break
            print(execute_lowered_code(line.strip()))
