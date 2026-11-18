# asciinema-recordings

Private collection of asciinema terminal recordings.

**No upload required.** Share the `.cast` or the self-contained `.html` privately.

## Versions

| Piece | Version | Notes |
|-------|---------|--------|
| asciinema CLI | 2.4.x | `rec` / `play` / `cat` / `upload` — **no** `convert` |
| asciinema-player (in HTML) | **3.9.0** | Bundled offline by `cast_to_html.py` |

## Recordings

| Folder | Description |
|--------|-------------|
| [`learn_git_bare_repo/`](learn_git_bare_repo/) | Git bare repository demo (**Git Bash / Windows**), `.cast` + offline `.html` + share ZIP — [Git download](https://git-scm.com/download/win), open via `C:\Program Files\Git\git-bash.exe` |

## Just recipes

```bash
just              # list recipes
just play         # terminal replay
just play 2       # 2× speed
just html         # rebuild offline HTML
just open-html    # open HTML in browser
just versions     # print tool versions
```

### Play a cast (WSL / Linux)

```bash
asciinema play learn_git_bare_repo/git-bare-repository.cast
```

Faster: `asciinema play -s 2 learn_git_bare_repo/git-bare-repository.cast`

### Private share (browser)

Open or send `learn_git_bare_repo/git-bare-repository.html` — single file, works offline.
