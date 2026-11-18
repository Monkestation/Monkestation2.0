#!/bin/sh

#Project dependencies file
#Final authority on what's required to fully build the project

# byond version
export BYOND_MAJOR=516
export BYOND_MINOR=1687

#rust_g repo
export RUST_G_REPO="Monkestation/rust-g"

#rust_g git tag
export RUST_G_VERSION=7.0.0

# node version
export NODE_VERSION_LTS=24.12.0

# bun version
export BUN_VERSION=1.3.6

# SpacemanDMM git tag
export SPACEMAN_DMM_VERSION=suite-1.12

# Python version for mapmerge and other tools
export PYTHON_VERSION=3.10.0

#dreamluau repo
export DREAMLUAU_REPO="tgstation/dreamluau"

#dreamluau git tag
export DREAMLUAU_VERSION=0.1.3

#navmap-pathfinder repo
export NAVMAP_PATHFINDER_REPO="CabinetOnFire/navmap-pathfinder"

#navmap-pathfinder release, must match NAVMAP_PATHFINDER_VERSION in code/__DEFINES/navmap_pathfinder.dm
export NAVMAP_PATHFINDER_VERSION=1.0.14
