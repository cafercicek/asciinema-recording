# learn_git_bare_repo

Asciinema recording: **Git bare repository** explained and demonstrated in **Git Bash (Windows)**.

Zielgruppe: Windows-Nutzer (Explorer / Git Bash). Befehle sind bewusst einfach (`ls`, `cd`, `cat`, `echo`) — kein PowerShell.

## Windows: Git installieren & Git Bash öffnen

### Git for Windows herunterladen

Offizieller Download:

**https://git-scm.com/download/win**

Installer starten (Defaults reichen meist). Danach ist **Git Bash** verfügbar.

### Git Bash öffnen (empfohlen: Explorer-Adressleiste)

1. **Windows Explorer** öffnen  
2. In die **Adressleiste** klicken (Pfad-Zeile oben)  
3. Diesen Pfad einfügen und **Enter**:

```text
C:\Program Files\Git\git-bash.exe
```

→ Git Bash-Fenster öffnet sich.

**Alternativen**

| Weg | Was tun |
|-----|---------|
| Startmenü | `Git Bash` suchen und starten |
| Explorer Rechtsklick | Im Ordner rechtsklick → **Open Git Bash here** / **Git Bash Here** |
| Start-Menü-Ordner | `C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Git\` öffnen → **Git Bash** doppelklicken |

> Nur den Ordner `...\Programs\Git\` in die Adressleiste tippen öffnet **kein** Terminal — nur die Kürzelliste. Zum Starten braucht es `git-bash.exe` (oder den **Git Bash**-Link).

Mehr Schritt-für-Schritt: [`git-bare-repository.md`](git-bare-repository.md) (Abschnitt 0).

## Files

| File | Role |
|------|------|
| `git-bare-repository.cast` | Terminal recording (play with asciinema) |
| `git-bare-repository.html` | Self-contained offline player (asciinema-player **3.9.0**) |
| `cast_to_html.py` | Rebuild `.html` from `.cast` (no upload) |
| `build_cast.py` | Pace demo output → `.cast` (typing + pauses) |
| `demo-bare-repo.sh` | Demo script for **Git Bash** (anonymous paths under `C:\Temp\...`) |
| `demo-bare-repo.ps1` | Older PowerShell variant (reference only) |
| `git-bare-repository.md` | Kurzreferenz / step-by-step notes |
| `README.md` | This file |

## Play

```bash
asciinema play git-bare-repository.cast
# or from repo root:
just play
```

## Private HTML share

```bash
just html        # rebuild
just open-html   # open in browser
```

Or open `git-bare-repository.html` (self-contained offline player).

## Offline-Paket (ZIP) — lokal weitergeben

Alles in einer Datei (HTML + Markdown + kurze `.txt`-Hinweise):

```bash
just zip
# → learn_git_bare_repo/git-bare-repository-share.zip
```

ZIP-Inhalt:

| Datei | Zweck |
|-------|--------|
| `git-bare-repository.html` | Demo (Browser, doppelklicken) |
| `README.md` | Kurze Übersicht |
| `Anleitung.md` | Schritt-für-Schritt |
| `01_Git_herunterladen.txt` | Download-Link |
| `02_Git_Bash_oeffnen.txt` | `C:\Program Files\Git\git-bash.exe` |
| `03_Video_oeffnen.txt` | HTML öffnen |
| `LESEN.txt` | Start hier |

**GitHub Actions:** bei jedem Push auf `main` wird dasselbe ZIP als Artifact `git-bare-repository-share` hochgeladen (Actions → Run → Artifacts). Optional auch auf GitHub Pages, falls Pages aktiviert ist.

## Demo flow (in the cast)

1. What is a bare repo?
2. `git init --bare` + HEAD → `main`
3. First developer: `my_project` → commit → push
4. Clone as `user_git`
5. Dev B: change → commit → push
6. Dev A: `git pull`

All paths in the recording use `C:/Temp/git_bare_demo` (Git Bash: `/c/Temp/git_bare_demo`). No personal username/email shown. Prompt is anonymous `user@PC MINGW64`.

## Re-record (WSL)

```bash
# 1) run script via Windows Git Bash
"/mnt/c/Program Files/Git/bin/bash.exe" -lc '/c/Temp/demo-bare-repo.sh' \
  > /mnt/c/Temp/demo-out-bash.txt 2>&1

# 2) build paced cast + HTML
python3 learn_git_bare_repo/build_cast.py
just html
```
