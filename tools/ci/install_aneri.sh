#!/usr/bin/env bash
set -euo pipefail

source dependencies.sh

mkdir -p ~/.byond/bin
wget -nv -O ~/.byond/bin/libaneri.so "https://github.com/${ANERI_REPO}/releases/download/$ANERI_VERSION/libaneri.so"
chmod +x ~/.byond/bin/libaneri.so
ldd ~/.byond/bin/libaneri.so
