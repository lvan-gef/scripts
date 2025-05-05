#!/usr/bin/env bash

cppdir="$HOME/build_dir/cppcheck"

if [ ! -d "$cppdir" ]; then
    >&2 echo "dir: $cppdir does not exists"
    exit 1
fi

cd "$cppdir"
echo "Workdir: $PWD"
git pull

cppbuild="$cppdir/build"
if [ ! -d  "$cppbuild" ]; then
    echo "Create dir: $cppbuild"
    mkdir "$cppbuild"
    if [ $? -ne 0 ]; then
        >&2 echo "mkdir failed"
        exit 2
    fi;
fi

cd "$cppbuild"
echo "Workdir: $PWD"

cmake -DHAVE_RULES=ON -DCMAKE_BUILD_TYPE=RelWithDebInfo ..
if [ $? -ne 0 ]; then
    >&2 echo "cmake config failed"
    exit 3
fi;

cmake --build . --config RelWithDebInfo
if [ $? -ne 0 ]; then
    >&2 echo "cmake build failed"
    exit 4
fi;
