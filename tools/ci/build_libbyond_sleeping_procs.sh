#!/usr/bin/env bash
set -euo pipefail

mkdir -p ~/.byond/bin
g++ -nostdlib -m32 -shared -fPIC -fno-stack-protector -o ~/.byond/bin/libbyond_sleeping_procs.so tools/libbyond_sleeping_procs/lib.cpp
chmod +x ~/.byond/bin/libbyond_sleeping_procs.so
