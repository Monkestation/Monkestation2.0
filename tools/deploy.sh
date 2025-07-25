#!/bin/bash

#Run this in the repo root after compiling
#First arg is path to where you want to deploy
#creates a work tree free of everything except what's necessary to run the game

#second arg is working directory if necessary
if [[ $# -eq 2 ]] ; then
  cd $2
fi

mkdir -p \
    $1/_maps \
    $1/data/cassette_storage \
    $1/code/datums/greyscale/json_configs \
    $1/data/spritesheets \
    $1/icons \
    $1/sound/runtime \
    $1/strings \
    $1/tgui/public \
    $1/tgui/packages/tgfont/dist \
    $1/goon/icons \
    $1/monkestation/icons \
    $1/monkestation/code

if [ -d ".git" ]; then
  mkdir -p $1/.git/logs
  cp -r .git/logs/* $1/.git/logs/
fi

cp tgstation.dmb tgstation.rsc $1/
cp -r _maps/* $1/_maps/
cp -r data/cassette_storage/* $1/data/cassette_storage/
cp -r code/datums/greyscale/json_configs/* $1/code/datums/greyscale/json_configs/
cp -r icons/* $1/icons/
cp -r sound/runtime/* $1/sound/runtime/
cp -r strings/* $1/strings/
cp -r tgui/public/* $1/tgui/public/
cp -r tgui/packages/tgfont/dist/* $1/tgui/packages/tgfont/dist/
cp -r goon/icons/* $1/goon/icons/
cp -r monkestation/icons/* $1/monkestation/icons/
cp -r monkestation/code/* $1/monkestation/code/

#remove .dm files from _maps

#this regrettably doesn't work with windows find
#find $1/_maps -name "*.dm" -type f -delete

#dlls on windows
if [ "$(uname -o)" = "Msys" ]; then
  cp ./*.dll $1/
fi
