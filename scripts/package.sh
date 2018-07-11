#!/usr/bin/env bash
set -eu
set -o pipefail

# Creates rockspec and source rock for a new LUAcheck release given version number.
# Should be executed from root LUAcheck directory.
# Resulting rockspec and rock will be in `package/`.

version="$1"

rm -rf package
mkdir package
cd package


echo
echo "=== Creating rockspec for LUAcheck $version ==="
echo

LUArocks new-version ../LUAcheck-dev-1.rockspec --tag="$version"

echo
echo "=== Copying LUAcheck files ==="
echo

mkdir LUAcheck
cp -r ../src LUAcheck
mkdir LUAcheck/bin
cp ../bin/LUAcheck.LUA LUAcheck/bin
cp -r ../doc LUAcheck
cp ../README.md ../CHANGELOG.md ../LICENSE LUAcheck

echo
echo "=== Packing source rock for LUAcheck $version ==="
echo

zip -r LUAcheck-"$version"-1.src.rock LUAcheck LUAcheck-"$version"-1.rockspec

cd ..
