# asciinema-recordings — local play & private HTML share (no upload required)
# asciinema CLI: 2.4.x (no `convert`) · HTML uses asciinema-player 3.9.0

cast := "learn_git_bare_repo/git-bare-repository.cast"
html := "learn_git_bare_repo/git-bare-repository.html"
converter := "learn_git_bare_repo/cast_to_html.py"

default:
    @just --list

# Play the cast in the terminal (needs asciinema)
play speed="1":
    asciinema play -s {{speed}} {{cast}}

# Dump cast as plain text
cat:
    asciinema cat {{cast}}

# Rebuild self-contained offline HTML (needs network once for player assets)
html:
    python3 {{converter}} {{cast}} -o {{html}}

# Open HTML in the default browser (WSL → Windows explorer if needed)
open-html:
    #!/usr/bin/env bash
    set -euo pipefail
    if command -v wslpath >/dev/null && command -v explorer.exe >/dev/null; then
      explorer.exe "$(wslpath -w {{html}})"
    elif command -v xdg-open >/dev/null; then
      xdg-open {{html}}
    else
      echo "Open manually: {{html}}"
    fi

# Offline share zip (HTML + README/Anleitung.md + Kurz-txt)
zip:
    bash learn_git_bare_repo/build_share_zip.sh

# Show tool versions used for this workflow
versions:
    @echo "asciinema CLI: $(asciinema --version 2>/dev/null || echo 'not installed')"
    @echo "HTML player:   asciinema-player 3.9.0 (bundled in .html via cast_to_html.py)"
    @python3 -c "import ast; p='{{converter}}'; print('converter pin:', [l.split('=')[1].strip().strip('\"') for l in open(p) if l.startswith('PLAYER_VERSION')][0])"
