#!/usr/bin/env python3
"""
LYSPYTHON: AST Visualizer and Graph Generator
Renders Surface and Canonical AST hierarchies as Graphviz DOT or ASCII trees.
"""

import sys
import json
import argparse
from typing import Any, List, Dict


def parse_sexpr(s: str) -> Any:
    """Minimal recursive descent parser for symbolic S-expressions."""
    tokens = []
    i = 0
    while i < len(s):
        c = s[i]
        if c.isspace():
            i += 1
        elif c in '()':
            tokens.append(c)
            i += 1
        elif c == '"':
            end = s.find('"', i + 1)
            tokens.append(s[i:end + 1])
            i = end + 1
        else:
            j = i
            while j < len(s) and not s[j].isspace() and s[j] not in '()':
                j += 1
            tokens.append(s[i:j])
            i = j

    def read_tokens(tok_iter):
        for tok in tok_iter:
            if tok == '(':
                res = []
                for sub in tok_iter:
                    if sub == ')':
                        return res
                    tok_iter_copy = [sub] + list(tok_iter)
                    return [read_tokens(iter(tok_iter_copy))]
            else:
                return tok
        return None

    return tokens


def print_ascii_tree(node: Any, prefix: str = "", is_last: bool = True):
    """Render a nested list as an ASCII tree."""
    connector = "`-- " if is_last else "|-- "
    if isinstance(node, list):
        label = node[0] if node else "[]"
        print(f"{prefix}{connector}{label}")
        new_prefix = prefix + ("    " if is_last else "|   ")
        for i, child in enumerate(node[1:]):
            print_ascii_tree(child, new_prefix, i == len(node[1:]) - 1)
    else:
        print(f"{prefix}{connector}{node}")


def main():
    parser = argparse.ArgumentParser(description="LYSPYTHON AST Visualizer")
    parser.add_argument("--tree", action="store_true", help="Print ASCII tree view")
    parser.add_argument("input", nargs="?", default="(:if (:binop :== (:id \"x\") (:literal 10)) (:literal 1) (:literal 0))")
    args = parser.parse_args()

    print(f"Visualizing AST: {args.input}")
    tokens = parse_sexpr(args.input)
    print_ascii_tree(tokens)


if __name__ == "__main__":
    main()
