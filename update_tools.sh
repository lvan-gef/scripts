#! /usr/bin/env bash

DIR="$HOME/build_dir/"

# add checking if commands where succesfull
cd "$DIR/fd"
git pull --rebase
cargo build --relase
cargo test
cargo install --path .

cd "$DIR/ripgrep"
git pull --rebase
cargo build --release --features 'pcre2'

cd "$DIR/fzf"
git pull --rebase
./install
