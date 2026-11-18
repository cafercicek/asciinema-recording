#!/usr/bin/env python3
"""Build paced asciinema v2 cast from Git Bash demo output.

Source: /mnt/c/Temp/demo-out-bash.txt
Prompt form: user@PC MINGW64 /c/Temp/...$ command
"""
import json
import os
import re
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
SRC = "/mnt/c/Temp/demo-out-bash.txt"
DST = os.path.join(HERE, "git-bare-repository.cast")

with open(SRC, "rb") as f:
    text = f.read().decode("utf-8", errors="replace")

text = re.sub(r"\x1b\[[0-9;]*[A-Za-z]", "", text)
text = text.replace("\r\n", "\n").replace("\r", "\n")

leaks = []
for bad in [
    "Demo User",
    "demo@example",
    "C:\\Users\\",
    "C:/Users/",
    "/home/",
]:
    if bad.lower() in text.lower():
        leaks.append(bad)
if leaks:
    print("LEAKS:", leaks, file=sys.stderr)
    sys.exit(1)

lines = text.split("\n")
while lines and lines[-1] == "":
    lines.pop()

header = {
    "version": 2,
    "width": 100,
    "height": 30,
    "title": "Git Bare Repository — Git Bash Demo (Windows)",
    "env": {"TERM": "xterm-256color", "SHELL": "bash"},
}

events = []
t = 0.0


def emit(s: str, delay: float = 0.0):
    global t
    t += delay
    events.append([round(t, 6), "o", s])


def pause(seconds: float):
    global t
    t += seconds


def emit_line(line: str, delay_before: float = 0.2):
    emit(line + "\r\n", delay_before)


# Git Bash / MINGW64 prompt: "user@PC MINGW64 /c/Temp/...$ command"
bash_re = re.compile(r"^(user@PC MINGW64 .+?\$ )(.*)$")

i = 0
prev_kind = None  # "comment" | "output" | "command" | "blank" | None

while i < len(lines):
    line = lines[i]
    s = line.strip()

    if s == "":
        emit_line("", 0.2)
        prev_kind = "blank"
        i += 1
        continue

    if s.startswith("#"):
        # Extra breathing room after command output (easier to read)
        if prev_kind in ("output", "command"):
            emit_line("", 0.4)
            emit_line("", 0.3)
            pause(0.9)
        emit_line(line, 0.85 if prev_kind != "comment" else 0.65)
        prev_kind = "comment"
        i += 1
        continue

    m = bash_re.match(line)
    if m:
        prompt, cmd = m.group(1), m.group(2)
        if prev_kind != "blank":
            emit_line("", 0.35)
            emit_line("", 0.4)
        else:
            emit_line("", 0.3)
        pause(0.85)

        emit(prompt, 0.3)
        pause(0.4)
        for ch in cmd:
            d = 0.055 if ch.isalnum() else 0.08
            emit(ch, d)
        pause(0.5)
        emit("\r\n", 0.05)
        prev_kind = "command"
        i += 1
        continue

    if prev_kind == "command":
        pause(0.3)
    emit_line(line, 0.2)
    prev_kind = "output"
    i += 1

emit_line("", 0.4)
pause(1.2)

with open(DST, "w", encoding="utf-8") as f:
    f.write(json.dumps(header, ensure_ascii=False) + "\n")
    for ev in events:
        f.write(json.dumps(ev, ensure_ascii=False) + "\n")

print(f"lines={len(lines)}")
print(f"events={len(events)}")
print(f"duration_s={round(t, 1)}")
print(f"bytes={os.path.getsize(DST)}")
print(f"dst={DST}")
