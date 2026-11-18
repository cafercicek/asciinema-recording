#!/usr/bin/env bash
# Build offline share zip: HTML + README/Anleitung (.md) + Kurz-Hinweise (.txt)
set -euo pipefail
ROOT="$(cd "$(dirname "$0")" && pwd)"
SHARE="$ROOT/share"
ZIP="$ROOT/git-bare-repository-share.zip"

mkdir -p "$SHARE"
cp -f "$ROOT/git-bare-repository.html" "$SHARE/"
cp -f "$ROOT/README.md" "$SHARE/README.md"
cp -f "$ROOT/git-bare-repository.md" "$SHARE/Anleitung.md"

cat > "$SHARE/01_Git_herunterladen.txt" << 'EOF'
Git for Windows — Download

https://git-scm.com/download/win

Installer starten. Standardoptionen reichen meist.
Danach ist Git Bash verfuegbar.
EOF

cat > "$SHARE/02_Git_Bash_oeffnen.txt" << 'EOF'
Git Bash oeffnen (Windows Explorer)

1. Windows Explorer oeffnen
2. Oben in die Adressleiste klicken
3. Diesen Pfad einfuegen und Enter:

C:\Program Files\Git\git-bash.exe

→ Git Bash-Fenster oeffnet sich (MINGW64).

Alternativen:
- Startmenue: "Git Bash" suchen
- Rechtsklick im Ordner: "Open Git Bash here" / "Git Bash Here"
EOF

cat > "$SHARE/03_Video_oeffnen.txt" << 'EOF'
Demo ansehen (offline)

Doppelklick auf:

  git-bare-repository.html

Oeffnet sich im Browser — kein Internet noetig.

Weitere Hilfe: README.md und Anleitung.md
EOF

cat > "$SHARE/LESEN.txt" << 'EOF'
Git Bare Repository — Offline-Paket

Inhalt:
  git-bare-repository.html  → Demo-Video (Browser, doppelklicken)
  README.md                 → Kurze Uebersicht
  Anleitung.md              → Schritt-fuer-Schritt
  01_Git_herunterladen.txt  → Download-Link
  02_Git_Bash_oeffnen.txt   → Git Bash starten
  03_Video_oeffnen.txt      → HTML oeffnen

Empfohlen:
  1) 01_Git_herunterladen.txt
  2) 02_Git_Bash_oeffnen.txt
  3) 03_Video_oeffnen.txt
EOF

rm -f "$ZIP"
( cd "$SHARE" && zip -9 -r "$ZIP" . )
echo "Wrote $ZIP ($(wc -c < "$ZIP") bytes)"
unzip -l "$ZIP"
