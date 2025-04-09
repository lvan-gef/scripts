#! /usr/bin/env sh

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

if [ ! -d "$DIRECTORY" ]; then
	echo "git clone neovim";
	git clone https://github.com/neovim/neovim.git $DIRECTORY
fi;

if [ ! -d "$DIRECTORY" ]; then
	echo "Failed to git clone neovim";
	exit 1;
fi;

cd "$DIRECTORY";

# checkout to version
git checkout $version

# make neovim
make -j$CPUCOUNT CMAKE_BUILD_TYPE=RelWithDebInfo;

# install neovim
sudo make -j$CPUCOUNT install

# get neovim config from my github
if [ ! -d "$NVIMCONFIG" ]; then
	git clone git@github.com:lvan-gef/nvim.git $NVIMCONFIG
fi;

if [ ! -d "$NVIMCONFIG" ]; then
    echo "Failed to git clone my config"
	exit 2;
fi;

if [[ "$OSTYPE" == "darwin"* ]]; then
    cd $NVIMCONFIG
    git checkout mac
fi;
