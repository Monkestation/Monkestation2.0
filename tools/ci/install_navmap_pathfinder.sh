#!/usr/bin/env bash
set -euo pipefail

source dependencies.sh

mkdir -p ~/.byond/bin
wget -nv -O ~/.byond/bin/libnavmap_pathfinder.so "https://github.com/${NAVMAP_PATHFINDER_REPO}/releases/download/v${NAVMAP_PATHFINDER_VERSION}/libnavmap_pathfinder.so"
chmod +x ~/.byond/bin/libnavmap_pathfinder.so
ldd ~/.byond/bin/libnavmap_pathfinder.so
