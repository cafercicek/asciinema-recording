#!/usr/bin/env python3
"""Embed a .cast into a self-contained HTML player (no asciinema.org upload).

Uses asciinema-player (default 3.9.0) from jsDelivr; result works offline.
Requires: asciinema CLI is NOT needed for conversion (v2 has no `convert`).
"""
from __future__ import annotations

import argparse
import json
import ssl
import urllib.request
from pathlib import Path

PLAYER_VERSION = "3.9.0"
CDN_JS = (
    f"https://cdn.jsdelivr.net/npm/asciinema-player@{PLAYER_VERSION}"
    "/dist/bundle/asciinema-player.min.js"
)
CDN_CSS = (
    f"https://cdn.jsdelivr.net/npm/asciinema-player@{PLAYER_VERSION}"
    "/dist/bundle/asciinema-player.css"
)


def fetch(url: str) -> str:
    ctx = ssl.create_default_context()
    with urllib.request.urlopen(url, context=ctx, timeout=60) as resp:
        return resp.read().decode("utf-8")


def title_from_cast(cast_text: str, fallback: str) -> str:
    first = cast_text.splitlines()[0] if cast_text else ""
    try:
        meta = json.loads(first)
        if isinstance(meta, dict) and meta.get("title"):
            return str(meta["title"])
    except json.JSONDecodeError:
        pass
    return fallback


def build_html(
    cast_text: str,
    title: str,
    js: str,
    css: str,
    *,
    about: str,
    howto: str,
    guide_html: str,
) -> str:
    import html as html_mod

    cast_json = json.dumps(cast_text)
    about_esc = html_mod.escape(about.strip())
    howto_esc = html_mod.escape(howto.strip())
    return f"""<!DOCTYPE html>
<html lang="de">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <title>{html_mod.escape(title)}</title>
  <style>{css}</style>
  <style>
    html, body {{ margin: 0; padding: 0; background: #121212; color: #eee;
      font-family: system-ui, sans-serif; }}
    main {{ max-width: 1100px; margin: 0 auto; padding: 1rem 1.25rem 2rem; }}
    h1 {{ font-size: 1.15rem; font-weight: 600; margin: 0 0 .65rem; letter-spacing: .01em; }}
    .topbar {{
      margin: 0 0 .75rem;
      padding: .75rem .9rem;
      border-left: 3px solid #5a5a5a;
      background: #1a1a1a;
      max-width: 100%;
    }}
    .topbar p {{
      margin: 0;
      line-height: 1.45;
      font-size: .88rem;
      color: #c8c8c8;
      white-space: pre-line;
    }}
    .topbar .hint {{
      margin-top: .45rem;
      font-size: .82rem;
      color: #9a9a9a;
      white-space: pre-line;
    }}
    .guide {{
      margin: 0 0 .85rem;
      padding: .75rem .9rem;
      border-left: 3px solid #3d6b4f;
      background: #161c18;
    }}
    .guide h2 {{
      margin: 0 0 .4rem;
      font-size: .92rem;
      font-weight: 600;
      color: #d2e6d8;
    }}
    .guide ol {{
      margin: .25rem 0 0;
      padding-left: 1.2rem;
      color: #c8c8c8;
      font-size: .84rem;
      line-height: 1.45;
    }}
    .guide li {{ margin: .28rem 0; }}
    .guide code {{
      font-family: ui-monospace, Consolas, monospace;
      font-size: .8rem;
      color: #e6e6e6;
      background: #222;
      padding: .05rem .3rem;
    }}
    .guide .note {{
      margin: .45rem 0 0;
      font-size: .8rem;
      color: #9a9a9a;
    }}
    #player {{ box-shadow: 0 8px 32px rgba(0,0,0,.45); }}
    /* Keep control bar BELOW terminal (player still overlays last line even with controls:true) */
    .ap-player {{
      position: relative;
      padding-bottom: 36px !important;
      box-sizing: content-box !important;
    }}
    .ap-control-bar {{
      position: absolute !important;
      left: 0;
      right: 0;
      bottom: 0 !important;
      top: auto !important;
    }}
    .meta {{ opacity: .5; font-size: .72rem; margin-top: .75rem; }}
  </style>
</head>
<body>
  <main>
    <h1>{html_mod.escape(title)}</h1>
    <div class="topbar" aria-label="About and how to use">
      <p>{about_esc}</p>
      <p class="hint">{howto_esc}</p>
    </div>
    {guide_html}
    <div id="player"></div>
    <p class="meta">Offline · asciinema-player {PLAYER_VERSION} · no upload</p>
  </main>
  <script>{js}</script>
  <script>
    const castText = {cast_json};
    const blob = new Blob([castText], {{ type: "text/plain" }});
    const url = URL.createObjectURL(blob);
    // controls: true keeps the bar BELOW the terminal (never overlays the last line).
    // Official fix since asciinema-player v3.2 / controls option in v3.4:
    // https://docs.asciinema.org/manual/player/options/#controls
    AsciinemaPlayer.create(url, document.getElementById("player"), {{
      fit: false,
      autoPlay: false,
      preload: true,
      controls: true,
      terminalFontSize: "14px"
    }});
  </script>
</body>
</html>
"""


# Asciinema player how-to (kept — not removed)
DEFAULT_HOWTO = (
    "Player: Play / Pause jederzeit. Text im Terminal markieren → Befehle kopieren.\n"
    "Mit der Fortschrittsleiste springen. Vollständig offline — kein Upload zu asciinema.org."
)

DEFAULT_ABOUT = (
    "Git Bare Repository — Demo in Git Bash (Windows): init --bare, push, clone, pull.\n"
    "Anonyme Pfade unter C:\\Temp\\git_bare_demo (kein Benutzername)."
)

# Trusted static HTML (not from user input)
DEFAULT_GUIDE_HTML = """
    <div class="guide" aria-label="Git Bash über Explorer öffnen">
      <h2>Git Bash öffnen — im Zielordner (Explorer-Adressleiste)</h2>
      <ol>
        <li>Im <strong>Explorer</strong> zu deinem <strong>Zielordner</strong> gehen
          (z.&nbsp;B. <code>C:\\Temp\\git_bare_demo</code> — dort willst du arbeiten).</li>
        <li>Oben in die <strong>Adressleiste</strong> klicken
          (oder Fokus: Alt&nbsp;+&nbsp;D) — der Ordnerpfad wird markiert.</li>
        <li>Diesen Pfad <strong>einfügen</strong> und <strong>Enter</strong>:
          <br /><code>C:\\Program Files\\Git\\git-bash.exe</code></li>
        <li>→ Git Bash startet und öffnet sich <strong>in genau diesem Ordner</strong>
          (nicht in Program Files navigieren — nur den exe-Pfad eintippen/einfügen).</li>
      </ol>
      <p class="note">Explorer selbst: Win&nbsp;+&nbsp;E. Git fehlt?
        <code>https://git-scm.com/download/win</code></p>
    </div>
"""


def main() -> int:
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("cast", type=Path, help="Input .cast file")
    p.add_argument(
        "-o",
        "--output",
        type=Path,
        default=None,
        help="Output .html (default: same name as cast)",
    )
    p.add_argument(
        "--about",
        default=DEFAULT_ABOUT,
        help="Short English blurb: purpose of the recording",
    )
    p.add_argument(
        "--howto",
        default=DEFAULT_HOWTO,
        help="How-to lines (newline-separated) for the offline player",
    )
    p.add_argument(
        "--no-guide",
        action="store_true",
        help="Omit the Explorer / Git Bash guide block above the player",
    )
    args = p.parse_args()

    cast_path = args.cast
    if not cast_path.is_file():
        raise SystemExit(f"cast not found: {cast_path}")

    out = args.output or cast_path.with_suffix(".html")
    cast_text = cast_path.read_text(encoding="utf-8")
    title = title_from_cast(cast_text, cast_path.stem.replace("-", " ").title())

    print(f"Fetching asciinema-player {PLAYER_VERSION} …")
    js = fetch(CDN_JS)
    css = fetch(CDN_CSS)
    html = build_html(
        cast_text,
        title,
        js,
        css,
        about=args.about,
        howto=args.howto,
        guide_html="" if args.no_guide else DEFAULT_GUIDE_HTML,
    )
    out.write_text(html, encoding="utf-8")
    print(f"Wrote {out} ({out.stat().st_size} bytes)")
    print(f"Player: asciinema-player {PLAYER_VERSION}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
