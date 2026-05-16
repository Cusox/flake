{ pkgs, ... }:

{
  home.file.".config/nvim" = {
    source = ../../config/nvim;
    recursive = true;
  };

  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;
    defaultEditor = true;
    withPython3 = false;
    withRuby = false;

    extraPackages = with pkgs; [
      # Tool
      fd
      fzf
      ripgrep

      # Tree-sitter CLI
      tree-sitter

      # LSP
      bash-language-server
      clang-tools
      copilot-language-server
      docker-compose-language-service
      docker-language-server
      gopls
      harper
      vscode-json-languageserver
      lua-language-server
      neocmakelsp
      nixd
      ty

      # Formatter
      shfmt
      gersemi
      nixfmt
      ruff
      stylua
      yamlfmt

      # DAP
      vscode-extensions.vadimcn.vscode-lldb

      # Linter
      shellcheck
    ];

    plugins = with pkgs.vimPlugins; [
      (nvim-treesitter.withPlugins (p: [
        p.bash
        p.c
        p.cmake
        p.cpp
        p.css
        p.diff
        p.dockerfile
        p.git_config
        p.gitcommit
        p.gitignore
        p.go
        p.gomod
        p.gotmpl
        p.html
        p.java
        p.javascript
        p.json
        p.latex
        p.lua
        p.make
        p.markdown
        p.markdown_inline
        p.ninja
        p.nix
        p.query
        p.regex
        p.rust
        p.scss
        p.toml
        p.tsx
        p.typescript
        p.vimdoc
        p.xml
        p.yaml
      ]))
    ];
  };
}
