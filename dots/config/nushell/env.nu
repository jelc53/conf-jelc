load-env {
  # Specifies how environment variables are:
  # - converted from a string to a value on Nushell startup (from_string)
  # - converted from a value back to a string when running external commands (to_string)
  # Note: The conversions happen *after* config.nu is loaded
  "ENV_CONVERSIONS": {
    "PATH": {
      from_string: { |s| $s | split row (char esep) | path expand }
      to_string: { |v| $v | str join (char esep) }
    }
    "Path": {
      from_string: { |s| $s | split row (char esep) | path expand }
      to_string: { |v| $v | str join (char esep) }
    }
  },
  "GITHUB_USER": "jelc53",
  "HF_DATASETS_CACHE": "/data/hf",
  "NU_LIB_DIRS": [($nu.config-path | path dirname | path join 'scripts')],
  "NU_PLUGIN_DIRS": [($nu.config-path | path dirname | path join 'plugins')],
  # Coq setup start
  "OPAM_SWITCH_PREFIX": "~/.opam/4.07.1+flambda",
  "CAML_LD_LIBRARY_PATH": "~/.opam/4.07.1+flambda/lib/stublibs:~/.opam/4.07.1+flambda/lib/ocaml/stublibs:~/.opam/4.07.1+flambda/lib/ocaml",
  "OCAML_TOPLEVEL_PATH": "~/.opam/4.07.1+flambda/lib/toplevel",
  "MANPATH": ":~/.opam/4.07.1+flambda/man",
  # Coq setup stop (remove opam from path too)
  "PATH": [
    "/opt/texlive/2023/bin/x86_64-linux",
    "/opt/cisco/anyconnect/bin",
    "/opt/zotero",
    "~/.opam/4.07.1+flambda/bin",
    "~/.pyenv/shims",
    "~/.pyenv/bin",
    "~/.poetry/bin",
    "~/.local/bin",
    "~/.cargo/bin",
    "~/.cabal/bin",
    "~/.elan/bin",
    "~/.nvm/versions/node/v18.17.1/bin",
    "~/.local/share/gem/ruby/3.1.0/bin",
    "/opt/homebrew/bin",	
    "/usr/lib/ruby/gems/3.1.0/bin",
    "/usr/local/cuda/bin",
    "/usr/local/bin",
    "/usr/local/sbin",
    "/usr/bin",
    "/bin",
    "/sbin",
  ],
  "FZF_DEFAULT_OPTS": "--ansi --layout=reverse --height='50%' --border --color fg:7,bg:0,hl:1,fg+:232,bg+:1,hl+:255 --color info:7,prompt:2,spinner:1,pointer:232,marker:1",
  "PROMPT_COMMAND_RIGHT": "",
  "PROMPT_INDICATOR": "",
  "PROMPT_INDICATOR_VI_INSERT": "",
  "PROMPT_INDICATOR_VI_NORMAL": "",
  "PROMPT_MULTILINE_INDICATOR": "::: ",
  "SXHKD_SHELL": "/bin/bash",
  "TERM": "alacritty",
}
