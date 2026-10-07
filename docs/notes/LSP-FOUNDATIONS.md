# Language Server Protocol (LSP) Architecture & Editor Integration

## 1. Overview

LYSPYTHON is designed for first-class editor integration via the Language Server Protocol (LSP). Unlike standard Python language servers (Pyright, Ruff, Jedi), the LYSPYTHON Language Server is **macro-aware**.

## 2. Core Capabilities

1. **Macro Diagnostics**:
   Signals errors that occur during Common Lisp macro expansion with accurate source mapping pointing to the original Python surface tokens.
2. **Code Action: Expand Macro Under Cursor**:
   Allows developers in editors like Neovim, VS Code, or Emacs to select any statement (e.g., `def` or `if`) and invoke "Expand Macro", displaying the stepwise expansion inline.
3. **Hover Documentation**:
   Hovering over a keyword or operator displays the Common Lisp macro definition, priority, and documentation registered in `*global-macro-registry*`.

## 3. Editor Configuration Guides

### Neovim (nvim-lspconfig)
```lua
local lspconfig = require('lspconfig')
local configs = require('lspconfig.configs')

if not configs.lyspython then
  configs.lyspython = {
    default_config = {
      cmd = { "sbcl", "--load", "lyspython.asd", "--eval", "(ql:quickload :lys-python)", "--eval", "(lys.lsp:start-server)" },
      filetypes = { "python", "lys" },
      root_dir = lspconfig.util.root_pattern("lyspython.asd", "pyproject.toml", ".git"),
      settings = {},
    },
  }
end
lspconfig.lyspython.setup{}
```

### Visual Studio Code
Configure `settings.json`:
```json
{
  "lyspython.server.path": "sbcl",
  "lyspython.server.arguments": [
    "--load", "lyspython.asd",
    "--eval", "(ql:quickload :lys-python)",
    "--eval", "(lys.lsp:start-server)"
  ]
}
```

### Emacs (eglot)
```elisp
(with-eval-after-load 'eglot
  (add-to-list 'eglot-server-programs
               '(lys-mode . ("sbcl" "--load" "lyspython.asd"
                                    "--eval" "(ql:quickload :lys-python)"
                                    "--eval" "(lys.lsp:start-server)"))))
```
