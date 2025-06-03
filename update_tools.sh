#! /usr/bin/env bash

DIR="$HOME/build_dir"

# add checking if commands where succesfull
cd "$DIR/fd" || exit
git pull --rebase
cargo build --release
cargo test
cargo install --path .

cd "$DIR/ripgrep" || exit
git pull --rebase
cargo build --release --features 'pcre2'

cd "$DIR/fzf" || exit
git pull --rebase
./install
