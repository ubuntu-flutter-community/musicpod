#!/usr/bin/env bash
set -e

# script to build DEB package
VERSION=$(grep '^version:' pubspec.yaml | cut -d' ' -f2 | tr -d "'\"")
PACKAGE_NAME="musicpod"
DEB_VERSION="${VERSION}-1"

echo "Building DEB package for ${PACKAGE_NAME} version ${VERSION}"

if ! command -v dpkg-buildpackage &> /dev/null; then
    echo "Error: dpkg-buildpackage not found. Please install devscripts and debhelper:"
    echo "  sudo apt-get install devscripts debhelper"
    exit 1
fi

if ! command -v flutter &> /dev/null; then
    echo "Error: Flutter not found in PATH"
    exit 1
fi

echo "Cleaning previous builds..."
rm -rf debian/musicpod
rm -f ../${PACKAGE_NAME}_*.deb ../${PACKAGE_NAME}_*.dsc ../${PACKAGE_NAME}_*.tar.gz ../${PACKAGE_NAME}_*.changes

if [ -f debian/changelog ]; then
    sed -i "s/^musicpod ([^)]*/musicpod (${DEB_VERSION}/" debian/changelog
    sed -i "s/^ -- .*/ -- $(git config user.name) <$(git config user.email)>  $(date -R)/" debian/changelog
fi

echo "Building DEB package..."
dpkg-buildpackage -b -us -uc

echo ""
echo "Build complete! Package files are in the parent directory:"
ls -lh ../${PACKAGE_NAME}_*.deb 2>/dev/null || echo "No .deb file found"

