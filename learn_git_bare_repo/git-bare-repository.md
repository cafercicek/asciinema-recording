# Git Bare Repository — Kurzreferenz

**Terminal für diese Anleitung:** **Git Bash** (Windows) — nicht PowerShell.

Playground-Pfad (Beispiel): `C:\Temp\git_bare_demo`  
(Demo-Video nutzt denselben anonymen Pfad.)

| Ordner | Rolle |
|--------|-------|
| `bare_repository\` | Zentrales Repo (wie Server — keine Dateien bearbeiten) |
| `my_project\` | Erster Entwickler — startet Projekt, erster Push |
| `user_git\` | Zweiter Entwickler — arbeitet per Clone |

---

## 0) Git for Windows installieren & Git Bash öffnen

### Git herunterladen

Offizieller Windows-Installer:

**https://git-scm.com/download/win**

1. Seite öffnen → Download startet (oder „Click here to download“).  
2. Installer ausführen — Standardoptionen sind in Ordnung.  
3. Fertig: **Git Bash** und `git` sind installiert.

### Schon installiert? Prüfen

Git Bash öffnen (siehe unten), dann:

```bash
git --version
# z.B. git version 2.x.x.windows.1
```

### Git Bash öffnen — Explorer-Adressleiste (empfohlen)

So startest du Git Bash **ohne** Startmenü-Suche:

1. **Windows-Explorer** öffnen  
2. Oben in die **Adressleiste** klicken (dort steht normalerweise der Ordnerpfad)  
3. Diesen Text **einfügen** und **Enter** drücken:

```text
C:\Program Files\Git\git-bash.exe
```

Es öffnet sich das Git-Bash-Fenster (`MINGW64`).

### Weitere Wege

| Weg | Schritte |
|-----|----------|
| Startmenü | Windows-Taste → `Git Bash` → Enter |
| Rechtsklick im Ordner | Explorer → Rechtsklick → **Open Git Bash here** / **Git Bash Here** (öffnet Bash **in diesem Ordner**) |
| Start-Menü-Ordner | Adressleiste: `C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Git\` → **Git Bash** doppelklicken |

**Wichtig:** Nur den Ordner `...\Programs\Git\` in die Adressleiste zu tippen öffnet **kein** Terminal — nur die Liste der Kürzel. Zum Starten brauchst du:

```text
C:\Program Files\Git\git-bash.exe
```

### Alternative: Chocolatey (optional)

Falls du Pakete lieber per `choco` installierst (Admin-PowerShell):

```powershell
choco install git -y
# Terminal neu öffnen, dann in Git Bash:
git --version
```

Chocolatey selbst fehlt noch? Siehe [Chocolatey Install](https://chocolatey.org/install) — für die meisten reicht der Link **git-scm.com/download/win**.

---

## 1) Einmalig: Git-Identität setzen

```powershell
git config --global user.name "Vorname Nachname"
git config --global user.email "email@firma.de"

# prüfen
git config --global --list
```

---

## 2) Was ist ein Bare Repo?

- **Normales Repo:** Quelldateien + `.git`-Ordner
- **Bare Repo:** nur Git-Datenbank (`objects`, `refs`, `HEAD`…) — **kein Arbeitsverzeichnis**
- Lokales Äquivalent zu GitHub/GitLab

Im Bare Repo **bearbeitest du keine Dateien** — es empfängt nur **Push** und dient als **Clone-Quelle**.

---

## 3) Bare Repo anlegen (frisch, leer)

```powershell
cd C:\Temp\git_bare_demo

# WICHTIG: --bare ist Pflicht
git init --bare bare_repository

# HEAD direkt auf main — vermeidet master/main-Warnung beim Clone
git -C bare_repository symbolic-ref HEAD refs/heads/main
```

Kontrolle:

```powershell
ls bare_repository
# HEAD, config, objects, refs — keine .c/.md Dateien
Get-Content bare_repository\HEAD
# ref: refs/heads/main
```

---

## 4) Erster Entwickler: Projekt starten und verbinden

Das Bare Repo ist **leer** — jemand muss den ersten Commit pushen.

```powershell
cd C:\Temp\git_bare_demo
mkdir my_project
cd my_project

git init
echo "# Hallo" > README.md
git add README.md
git commit -m "Erster Commit"

# Bare Repo als Remote eintragen
git remote add origin C:/Temp/git_bare_demo/bare_repository

git branch -M main
git push -u origin main
```

Kontrolle:

```powershell
git remote -v
git log --oneline
```

---

## 5) Klonen (zweiter Entwickler oder anderer Ordner)

```powershell
cd C:\Temp\git_bare_demo
git clone C:/Temp/git_bare_demo/bare_repository user_git
cd user_git
```

Nach dem Clone ist `origin` automatisch gesetzt:

```powershell
git remote -v
ls
# README.md sollte sichtbar sein (wenn Schritt 4 erledigt)
```

**Warnung:** `remote HEAD refers to nonexistent ref, unable to checkout`

Das passiert nur, wenn das Bare Repo noch **keinen Commit** hat:

```powershell
# Im Clone-Ordner: erst Dateien anlegen und pushen (Schritt 6A)
# Oder zuerst Schritt 4 (my_project push) ausführen, dann neu klonen
```

---

## 6) Clone-Ordner ist leer — was tun?

**Normal**, wenn das Bare Repo noch **keinen Commit** hat.

### Fall A — Bare Repo hat noch keinen Commit

```powershell
cd C:\Temp\git_bare_demo\user_git

# Dateien anlegen
echo "# Mein Projekt" > README.md
echo "print('hello')" > main.py

# stagen und committen
git add .
git commit -m "Erste Dateien hinzugefügt"

# erster Push ins leere Bare Repo
git branch -M main
git push -u origin main
```

Danach sieht jeder beim Klonen die Dateien.

### Fall B — Commits existieren, Ordner wirkt leer

```powershell
git branch -a
git pull origin main
ls
```

### Fall C — Neue Dateien / leeren Ordner hinzufügen

```powershell
cd C:\Temp\git_bare_demo\user_git

echo "Inhalt" > neue_datei.txt

# Git trackt keine leeren Ordner!
mkdir src
echo $null > src/.gitkeep

git status
git add neue_datei.txt src/.gitkeep
git commit -m "Neue Datei und src-Ordner"
git push
```

> **Hinweis:** Leere Ordner brauchen mindestens eine Datei (z. B. `.gitkeep`).

---

## 7) Täglicher Ablauf

```powershell
cd C:\Temp\git_bare_demo\user_git

# 1) Remote-Änderungen holen
git pull

# 2) Datei ändern / neu anlegen
echo "neue Zeile" >> README.md

# 3) stagen
git add README.md
# oder alles: git add .

# 4) committen
git commit -m "README aktualisiert"

# 5) ins Bare Repo pushen
git push
```

---

## 8) Remote-Befehle

```powershell
git remote -v                        # verbundene Adressen
git remote show origin               # Details

# Remote nachträglich (ohne Clone)
git remote add origin C:/Temp/git_bare_demo/bare_repository

# Adresse ändern
git remote set-url origin C:/Temp/git_bare_demo/bare_repository
```

---

## 9) Zweites Pane im Terminal (Herdr)

Für die Demo zwei Entwickler gleichzeitig zeigen: **Pane links = Dev A**, **Pane rechts = Dev B**.

### Herdr starten

```powershell
# Herdr-Server + Terminal öffnen
herdr
```

### Zweites Pane anlegen

**Mit Maus (einfach):**
- Rechtsklick auf Pane → **Split right** oder **Split down**

**Mit Tastatur (wie tmux):**
- `Ctrl+b`, dann `v` → Pane **rechts** (nebeneinander)
- `Ctrl+b`, dann `-` → Pane **unten** (übereinander)
- `Ctrl+b`, dann `h/j/k/l` → zwischen Panes wechseln
- `Ctrl+b`, dann `?` → alle Tastenkürzel anzeigen

### Demo-Setup: zwei Panes, zwei Ordner

```powershell
# --- Pane 1 (links): Entwickler A ---
cd C:\Temp\git_bare_demo\my_project
git status

# --- Pane 2 (rechts): Entwickler B ---
# Erst zweites Pane öffnen (Ctrl+b, v), dann:
cd C:\Temp\git_bare_demo\user_git
git status
```

So siehst du **Push in B** und **Pull in A** live nebeneinander — ohne Fenster zu wechseln.

### Scrollback / Pane-Inhalt speichern (optional)

```powershell
# Scrollback des fokussierten Panes im Editor öffnen
# Tastatur: Ctrl+b, dann e

# Oder Plugin (einmal installieren):
herdr plugin install alexjsp/herdr-scrollback-capture

# Fokussiertes Pane als HTML speichern (Desktop)
herdr plugin action invoke alexjsp.scrollback-capture.capture
```

> **Hinweis:** Herdr speichert nur das **fokussierte Pane**, nicht den ganzen Bildschirm. Für Video: OBS oder Windows Game Bar (`Win+G`).

### Alternative: Windows Terminal (ohne Herdr)

```powershell
# Neues Pane: Alt+Shift+D (horizontal) oder Alt+Shift+- (vertikal)
# Zwischen Panes: Alt+Pfeiltasten
```

---

## 10) Demo-Ablauf (5–10 Min.)

1. **Git prüfen:** `git --version` — ggf. `choco install git -y`
2. `git config --global` zeigen
3. `git init --bare bare_repository` + HEAD auf `main`
4. `my_project`: erster Commit + `remote add` + `push`
5. `git clone ... user_git` — Dateien erscheinen
6. **Herdr:** zweites Pane öffnen (`Ctrl+b`, `v`) — links `my_project`, rechts `user_git`
7. In `user_git` ändern → `add` → `commit` → `push`
8. In `my_project` `git pull` — Änderung im linken Pane zeigen

---

## 11) Ablauf (Schema)

```
my_project (Dev A)  --push-->  bare_repository  <--pull--  user_git (Dev B)
       add/commit                                 ^
                                                  +---push--- user_git
```

---

## 12) Häufige Fehler

| Fehler | Ursache | Lösung |
|--------|---------|--------|
| `git` unbekannt | Git nicht installiert | Schritt 0: `git --version`, dann `choco install git -y` |
| `remote HEAD refers to nonexistent ref` | Bare Repo noch leer (kein Commit) | Schritt 4 oder 6A: erster Commit + Push |
| Clone-Ordner leer | Kein Commit im Bare Repo | Schritt 6A: erster Commit + Push |
| `src/` fehlt in Git | Leere Ordner werden nicht getrackt | Datei oder `.gitkeep` reinlegen |
| `push rejected` | Remote ist neuer | Erst `git pull`, dann push |
| `not a git repository` | Falscher Ordner | `cd` zum richtigen Pfad |

---

## Schnellreferenz (copy & paste)

```powershell
# Git vorhanden?
git --version

# Git fehlt → installieren (Admin)
choco install git -y

# Bare Repo (frisch)
git init --bare bare_repository
git -C bare_repository symbolic-ref HEAD refs/heads/main

# erster Push
git init && git add . && git commit -m "Erster Commit"
git remote add origin C:/Temp/git_bare_demo/bare_repository
git push -u origin main

# klonen
git clone C:/Temp/git_bare_demo/bare_repository user_git

# täglich
git pull
git add .
git commit -m "Nachricht"
git push
```
