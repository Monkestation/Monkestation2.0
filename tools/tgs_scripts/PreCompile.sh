#!/bin/bash

./InstallDeps.sh

set -e
set -x

#load dep exports
#need to switch to game dir for Dockerfile weirdness
original_dir=$PWD
cd "$1"
. dependencies.sh
cd "$original_dir"


# update rust-g
if [ ! -d "rust-g" ]; then
	echo "Cloning rust-g..."
	git clone "https://github.com/${RUST_G_REPO}"
	cd rust-g
	~/.cargo/bin/rustup target add i686-unknown-linux-gnu
else
	echo "Fetching rust-g..."
	cd rust-g
	git fetch
	~/.cargo/bin/rustup target add i686-unknown-linux-gnu
fi

echo "Deploying rust-g..."
git checkout "$RUST_G_VERSION"
env PKG_CONFIG_ALLOW_CROSS=1 ~/.cargo/bin/cargo build --ignore-rust-version --release --target=i686-unknown-linux-gnu --features uuid
mv target/i686-unknown-linux-gnu/release/librust_g.so "$1/librust_g.so"
cd ..

# update aneri
if [ ! -d "aneri" ]; then
	echo "Cloning aneri..."
	git clone "https://github.com/${ANERI_REPO}"
	cd aneri
else
	echo "Fetching aneri..."
	cd aneri
	git fetch
fi
# aneri needs a newer rust than the one InstallDeps.sh put here on first setup
~/.cargo/bin/rustup update stable
~/.cargo/bin/rustup target add i686-unknown-linux-gnu

echo "Deploying aneri..."
git checkout "$ANERI_VERSION"
env PKG_CONFIG_ALLOW_CROSS=1 ~/.cargo/bin/cargo build --release --target=i686-unknown-linux-gnu --package aneri --no-default-features --features all --locked
mv target/i686-unknown-linux-gnu/release/libaneri.so "$1/libaneri.so"
cd ..

#
cd "$original_dir"
# update dreamluau
if [ ! -d "dreamluau" ]; then
	echo "Cloning dreamluau..."
	git clone https://github.com/tgstation/dreamluau
	cd dreamluau
	~/.cargo/bin/rustup target add i686-unknown-linux-gnu
else
	echo "Fetching dreamlaua..."
	cd dreamluau
	git fetch
	~/.cargo/bin/rustup target add i686-unknown-linux-gnu
fi

echo "Deploying Dreamlaua..."
git checkout "$DREAMLUAU_VERSION"
env PKG_CONFIG_ALLOW_CROSS=1 ~/.cargo/bin/cargo build --ignore-rust-version --release --target=i686-unknown-linux-gnu
mv target/i686-unknown-linux-gnu/release/libdreamluau.so "$1/libdreamluau.so"
cd ..

echo "Deploying navmap-pathfinder..."
curl -fsSL -o "$1/libnavmap_pathfinder.so" "https://github.com/${NAVMAP_PATHFINDER_REPO}/releases/download/v${NAVMAP_PATHFINDER_VERSION}/libnavmap_pathfinder.so"

# compile tgui
echo "Compiling tgui..."
cd "$1"
env TG_BOOTSTRAP_CACHE="$original_dir" CBT_BUILD_MODE="TGS" tools/bootstrap/javascript.sh tools/build/build.ts
