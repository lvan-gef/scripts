#! /usr/bin/env bash

DIRECTORY="$HOME/build_dir/neovim"
NVIMCONFIG="$HOME/.config/nvim"
CPUCOUNT=1;

if [[ "$OSTYPE" == "darwin"* ]]; then
    CPUCOUNT="$(sysctl hw.ncpu | awk '{print $2}')";
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    CPUCOUNT="$(nproc --all)";
fi;

version="stable"
if [ "$#" -eq 1 ]; then
    version=$1;
fi;

echo "Used version: $version"

if [[ "$OSTYPE" == "linux"* ]]; then
    sudo apt install cmake gettext lua5.1 liblua5.1-0-dev ninja-build curl build-essential
elif [[ "$OSTYPE" == "darwin"* ]]; then
    if ! brew --version; then
        xcode-select --install
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        brew install ninja cmake gettext curl
    fi;
fi;

if [ ! -d "$DIRECTORY" ]; then
    echo "git clone neovim";
    git clone https://github.com/neovim/neovim.git $DIRECTORY
fi;

if [ ! -d "$DIRECTORY" ]; then
    echo "Failed to git clone neovim";
    exit 1;
fi;

cd "$DIRECTORY";
git fetch --all

git checkout $version

make clean
make -j$CPUCOUNT CMAKE_BUILD_TYPE=RelWithDebInfo;

sudo make -j$CPUCOUNT install

if [ ! -d "$NVIMCONFIG" ]; then
    git clone git@github.com:lvan-gef/nvim.git $NVIMCONFIG
fi;

if [ ! -d "$NVIMCONFIG" ]; then
    echo "Failed to git clone my config"
    exit 2;
fi;

cd $NVIMCONFIG
if [[ "$OSTYPE" == "darwin"* ]]; then
    git switch mac
    git pull
else
    git switch current
    git pull
fi;
