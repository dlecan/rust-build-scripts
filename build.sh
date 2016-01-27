#!/bin/bash

set -ev

MULTI_ARCH=arm-unknown-linux-gnueabihf
RUST_VERSION=1.6.0
CARGO_VERSION=0.8.0
RUST_NAME=rust-$RUST_VERSION-$MULTI_ARCH
RUST_PACKAGE=$RUST_NAME.tar.gz

ORIG_DIR=$(pwd)
ROOT_DIR=$ORIG_DIR/tmp
mkdir -p $ROOT_DIR

INSTALL_DIR=$ROOT_DIR/$RUST_NAME
mkdir -p $INSTALL_DIR

cd $ROOT_DIR

echo "Rust $RUST_VERSION download ..."

curl -s https://static.rust-lang.org/dist/rustc-$RUST_VERSION-src.tar.gz \
  | tar -zx

cd rustc-$RUST_VERSION

./configure \
  --target=arm-unknown-linux-gnueabihf \
  --prefix=$INSTALL_DIR \
  --disable-docs

make -j4

make install

echo "Rust $RUST_VERSION build done!"

cd $ROOT_DIR

echo "Cargo $CARGO_VERSION download ..."

rm -rf cargo

git clone https://github.com/rust-lang/cargo

cd cargo

git checkout $CARGO_VERSION

git submodule update --init

python -B src/etc/install-deps.py

./configure \
  --prefix=$INSTALL_DIR \
  --local-rust-root=$INSTALL_DIR \
  --enable-optimize \
  --disable-debug

make -j4

make install

echo "Cargo $CARGO_VERSION build done!"

echo "Build final archive..."

cd $ORIG_DIR

tar -zcf $RUST_PACKAGE \
  -C $ROOT_DIR \
  $RUST_NAME

#echo "Remove work dir..."

#rm -rf $ROOT_DIR

echo "Done !"
