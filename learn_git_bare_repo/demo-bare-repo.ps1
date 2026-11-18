#Requires -Version 7
$ErrorActionPreference = "Stop"
$Host.UI.RawUI.WindowTitle = "Git Bare Repository Demo"

# Anonyme Commit-Identitaet NUR fuer diesen Prozess (kein --global, keine echte Mail)
$env:GIT_AUTHOR_NAME     = "Demo User"
$env:GIT_AUTHOR_EMAIL    = "demo@example.com"
$env:GIT_COMMITTER_NAME  = "Demo User"
$env:GIT_COMMITTER_EMAIL = "demo@example.com"

function Say([string]$msg) {
    Write-Host $msg -ForegroundColor Cyan
    Start-Sleep -Milliseconds 650
}

function Run([string]$cmd) {
    # Blank lines: keep narration and commands visually separated
    Write-Host ""
    Write-Host ""
    Start-Sleep -Milliseconds 700
    Write-Host "PS $($PWD.Path)> $cmd" -ForegroundColor Yellow
    Start-Sleep -Milliseconds 500
    Invoke-Expression $cmd
    Write-Host ""
    Start-Sleep -Milliseconds 550
}

$Root = "C:\Temp\git_bare_demo"
if (Test-Path $Root) { Remove-Item -Recurse -Force $Root }
New-Item -ItemType Directory -Path $Root | Out-Null
Set-Location $Root

Say "# ============================================================"
Say "#  Git Bare Repository — Demo (PowerShell)"
Say "#  Ein Terminal, Ordner wechseln: bare / my_project / user_git"
Say "# ============================================================"
Say ""
Say "# Was ist ein Bare Repo?"
Say "#  - Normales Repo: Quelldateien + .git-Ordner"
Say "#  - Bare Repo: nur Git-Datenbank (objects, refs, HEAD) — kein Arbeitsverzeichnis"
Say "#  - Lokales Aequivalent zu GitHub/GitLab — empfängt Push, liefert Clone"
Say ""

Say "# ------------------------------------------------------------"
Say "# 0) Git vorhanden? Version prüfen"
Say "# ------------------------------------------------------------"
Run "git --version"

Say "# ------------------------------------------------------------"
Say "# 1) Git-Identität"
Say "#    (für Commits nötig — anonym, Werte werden nicht angezeigt)"
Say "# ------------------------------------------------------------"
Say "# git config user.name  / user.email  → anonym gesetzt (Ausgabe übersprungen)"

Say "# ------------------------------------------------------------"
Say "# 2) Bare Repo anlegen (frisch, leer)"
Say "#    WICHTIG: --bare ist Pflicht"
Say "# ------------------------------------------------------------"
Run "git init --bare bare_repository"
Say "# HEAD direkt auf main — vermeidet master/main-Warnung beim Clone"
Run "git -C bare_repository symbolic-ref HEAD refs/heads/main"

Say "# Kontrolle: Inhalt des Bare Repos (keine Projektdateien)"
Run "Get-ChildItem bare_repository | Select-Object -ExpandProperty Name"
Run "Get-Content bare_repository\HEAD"

Say "# ------------------------------------------------------------"
Say "# 3) Erster Entwickler: Projekt starten und verbinden"
Say "#    Das Bare Repo ist leer — jemand muss den ersten Commit pushen"
Say "# ------------------------------------------------------------"
Run "New-Item -ItemType Directory -Path my_project | Out-Null"
Run "Set-Location my_project"
Say "# Jetzt im Ordner my_project (Entwickler A)"
Run "git init"
Run "Set-Content -Path README.md -Value '# Hallo'"
Run "git add README.md"
Run "git commit -m 'Erster Commit'"
Say "# Bare Repo als Remote eintragen"
Run "git remote add origin C:/Temp/git_bare_demo/bare_repository"
Run "git branch -M main"
Run "git push -u origin main"
Run "git remote -v"
Run "git log --oneline"

Say "# ------------------------------------------------------------"
Say "# 4) Zweiten Entwickler klonen (anderer Ordner)"
Say "# ------------------------------------------------------------"
Run "Set-Location .."
Say "# Zurück im Demo-Root"
Run "git clone C:/Temp/git_bare_demo/bare_repository user_git"
Run "Set-Location user_git"
Say "# Jetzt im Ordner user_git (Entwickler B) — origin ist schon gesetzt"
Run "git remote -v"
Run "Get-ChildItem | Select-Object -ExpandProperty Name"
Run "Get-Content README.md"

Say "# ------------------------------------------------------------"
Say "# 5) Täglicher Ablauf: ändern → add → commit → push"
Say "# ------------------------------------------------------------"
Run "Add-Content -Path README.md -Value '`nZeile von Entwickler B'"
Run "git status"
Run "git add README.md"
Run "git commit -m 'README aktualisiert (Dev B)'"
Run "git push"

Say "# ------------------------------------------------------------"
Say "# 6) Entwickler A holt die Änderung (Pull)"
Say "# ------------------------------------------------------------"
Run "Set-Location ..\my_project"
Say "# Zurück in my_project (Entwickler A)"
Run "git pull"
Run "Get-Content README.md"
Run "git log --oneline --all --decorate"

Say "# ------------------------------------------------------------"
Say "# Schema:"
Say "#   my_project (Dev A) --push--> bare_repository <--pull-- user_git (Dev B)"
Say "# ------------------------------------------------------------"
Say ""
Run "Set-Location .."
Say "# Demo-Ordner:"
Run "Get-ChildItem | Select-Object -ExpandProperty Name"
Say ""
Say "# Fertig. Bare Repo = zentrale Quelle; Clone/Push/Pull wie bei GitHub — nur lokal."
Say "# Ende der Demo."
Start-Sleep -Seconds 1
