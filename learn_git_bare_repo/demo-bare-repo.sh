#!/usr/bin/env bash
# Git Bare Repository — Demo (Git Bash on Windows)
# Anonym: nur C:/Temp/... — keine echte Identitaet in der Ausgabe
set -euo pipefail

# Anonyme Commit-Identitaet NUR fuer diesen Prozess (kein --global)
export GIT_AUTHOR_NAME="Demo User"
export GIT_AUTHOR_EMAIL="demo@example.com"
export GIT_COMMITTER_NAME="Demo User"
export GIT_COMMITTER_EMAIL="demo@example.com"

# Prompt wie Git Bash (MINGW), ohne echten Benutzernamen
export PS1='user@PC MINGW64 $PWD$ '
export HOME="/c/Temp/git_bare_demo_home"
mkdir -p "$HOME"

say() {
  printf '%s\n' "$1"
  sleep 0.65
}

run() {
  local cmd="$1"
  printf '\n\n'
  sleep 0.7
  # Prompt + Befehl anzeigen (wie getippt)
  printf 'user@PC MINGW64 %s$ %s\n' "$PWD" "$cmd"
  sleep 0.5
  eval "$cmd"
  printf '\n'
  sleep 0.55
}

Root="/c/Temp/git_bare_demo"
rm -rf "$Root"
mkdir -p "$Root"
cd "$Root"

say "# ============================================================"
say "#  Git Bare Repository — Demo (Git Bash)"
say "#  Ein Terminal, Ordner wechseln: bare / my_project / user_git"
say "# ============================================================"
say ""
say "# Was ist ein Bare Repo?"
say "#  - Normales Repo: Quelldateien + .git-Ordner"
say "#  - Bare Repo: nur Git-Datenbank (objects, refs, HEAD) — kein Arbeitsverzeichnis"
say "#  - Lokales Aequivalent zu GitHub/GitLab — empfängt Push, liefert Clone"
say ""

say "# ------------------------------------------------------------"
say "# 0) Git vorhanden? Version prüfen"
say "# ------------------------------------------------------------"
run "git --version"

say "# ------------------------------------------------------------"
say "# 1) Git-Identität"
say "#    (für Commits nötig — anonym, Werte werden nicht angezeigt)"
say "# ------------------------------------------------------------"
say "# git config user.name  / user.email  → anonym gesetzt (Ausgabe übersprungen)"

say "# ------------------------------------------------------------"
say "# 2) Bare Repo anlegen (frisch, leer)"
say "#    WICHTIG: --bare ist Pflicht"
say "# ------------------------------------------------------------"
run "git init --bare bare_repository"
say "# HEAD direkt auf main — vermeidet master/main-Warnung beim Clone"
run "git -C bare_repository symbolic-ref HEAD refs/heads/main"

say "# Kontrolle: Inhalt des Bare Repos (keine Projektdateien)"
run "ls bare_repository"
run "cat bare_repository/HEAD"

say "# ------------------------------------------------------------"
say "# 3) Erster Entwickler: Projekt starten und verbinden"
say "#    Das Bare Repo ist leer — jemand muss den ersten Commit pushen"
say "# ------------------------------------------------------------"
run "mkdir my_project"
run "cd my_project"
say "# Jetzt im Ordner my_project (Entwickler A)"
run "git init"
run "echo '# Hallo' > README.md"
run "git add README.md"
run "git commit -m 'Erster Commit'"
say "# Bare Repo als Remote eintragen"
run "git remote add origin /c/Temp/git_bare_demo/bare_repository"
run "git branch -M main"
run "git push -u origin main"
run "git remote -v"
run "git log --oneline"

say "# ------------------------------------------------------------"
say "# 4) Zweiten Entwickler klonen (anderer Ordner)"
say "# ------------------------------------------------------------"
run "cd .."
say "# Zurück im Demo-Root"
run "git clone /c/Temp/git_bare_demo/bare_repository user_git"
run "cd user_git"
say "# Jetzt im Ordner user_git (Entwickler B) — origin ist schon gesetzt"
run "git remote -v"
run "ls"
run "cat README.md"

say "# ------------------------------------------------------------"
say "# 5) Täglicher Ablauf: ändern → add → commit → push"
say "# ------------------------------------------------------------"
run "echo 'Zeile von Entwickler B' >> README.md"
run "git status"
run "git add README.md"
run "git commit -m 'README aktualisiert (Dev B)'"
run "git push"

say "# ------------------------------------------------------------"
say "# 6) Entwickler A holt die Änderung (Pull)"
say "# ------------------------------------------------------------"
run "cd ../my_project"
say "# Zurück in my_project (Entwickler A)"
run "git pull"
run "cat README.md"
run "git log --oneline --all --decorate"

say "# ------------------------------------------------------------"
say "# Schema:"
say "#   my_project (Dev A) --push--> bare_repository <--pull-- user_git (Dev B)"
say "# ------------------------------------------------------------"
say ""
run "cd .."
say "# Demo-Ordner:"
run "ls"
say ""
say "# Fertig. Bare Repo = zentrale Quelle; Clone/Push/Pull wie bei GitHub — nur lokal."
say "# Ende der Demo."
sleep 1
