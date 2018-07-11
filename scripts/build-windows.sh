#!/usr/bin/env bash
set -eu
set -o pipefail

# Builds LUAcheck.exe (64bit) using MinGW and LUAstatic.
# Should be executed from root LUAcheck directory.
# Resulting binary will be in `build/LUAcheck.exe`.

rm -rf build
mkdir build
cd build

echo
echo "=== Downloading LUA 5.3.4 ==="
echo
curl https://www.LUA.org/ftp/LUA-5.3.4.tar.gz | tar xz

echo
echo "=== Downloading LUAFileSystem 1.6.3-2 ==="
echo
LUArocks unpack LUAfilesystem 1.6.3-2

echo
echo "=== Downloading Lanes 3.10.1-1 ==="
echo
LUArocks unpack lanes 3.10.1-1

echo
echo "=== Building LUA 5.3.4 ==="
echo
cd LUA-5.3.4
make mingw CC=x86_64-w64-mingw32-gcc AR="x86_64-w64-mingw32-ar rcu"
cp src/libLUA.a ..
cd ..

echo
echo "=== Building LUAFileSystem 1.6.3-2 ==="
echo
cd LUAfilesystem-1.6.3-2/LUAfilesystem
x86_64-w64-mingw32-gcc -c -O2 src/lfs.c -I../../LUA-5.3.4/src -o src/lfs.o
x86_64-w64-mingw32-ar rcs src/lfs.a src/lfs.o
cp src/lfs.a ../..
cd ../..


echo
echo "=== Building Lanes 3.10.1-1 ==="
echo
cd lanes-3.10.1-1/lanes
x86_64-w64-mingw32-gcc -c -O2 src/compat.c -I../../LUA-5.3.4/src -o src/compat.o
x86_64-w64-mingw32-gcc -c -O2 src/deep.c -I../../LUA-5.3.4/src -o src/deep.o
x86_64-w64-mingw32-gcc -c -O2 src/lanes.c -I../../LUA-5.3.4/src -o src/lanes.o
x86_64-w64-mingw32-gcc -c -O2 src/keeper.c -I../../LUA-5.3.4/src -o src/keeper.o
x86_64-w64-mingw32-gcc -c -O2 src/tools.c -I../../LUA-5.3.4/src -o src/tools.o
x86_64-w64-mingw32-gcc -c -O2 src/threading.c -I../../LUA-5.3.4/src -o src/threading.o
x86_64-w64-mingw32-ar rcs src/lanes.a src/compat.o src/deep.o src/lanes.o src/keeper.o src/tools.o src/threading.o
cp src/lanes.a ../..
cp src/lanes.LUA ../..
cd ../..

echo
echo "=== Copying LUAcheck sources ==="
echo
cp -r ../src/LUAcheck .
mkdir -p bin
cp ../bin/LUAcheck.LUA bin

echo
echo "=== Building LUAcheck.exe ==="
echo
CC="x86_64-w64-mingw32-gcc" LUAstatic bin/LUAcheck.LUA LUAcheck/*.LUA lanes.LUA libLUA.a lfs.a lanes.a -ILUA-5.3.4/src
strip LUAcheck.exe

cd ..
