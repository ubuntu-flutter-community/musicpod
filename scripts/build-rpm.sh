#!/usr/bin/env bash
set -e

# script to build RPM package
VERSION=$(grep '^version:' pubspec.yaml | cut -d' ' -f2 | tr -d "'\"")
PACKAGE_NAME="musicpod"
RPM_VERSION="${VERSION}"

echo "Building RPM package for ${PACKAGE_NAME} version ${VERSION}"

if ! command -v rpmbuild &> /dev/null; then
    echo "Error: rpmbuild not found. Please install rpm-build:"
    echo "  sudo dnf install rpm-build rpmdevtools"
    echo "  or"
    echo "  sudo yum install rpm-build rpmdevtools"
    exit 1
fi

if ! command -v flutter &> /dev/null; then
    echo "Error: Flutter not found in PATH"
    exit 1
fi

RPMBUILD_DIR="${HOME}/rpmbuild"
mkdir -p ${RPMBUILD_DIR}/{BUILD,BUILDROOT,RPMS,SOURCES,SPECS,SRPMS}

echo "Creating source tarball..."
TARBALL_NAME="${PACKAGE_NAME}-${VERSION}"
TARBALL="${RPMBUILD_DIR}/SOURCES/${TARBALL_NAME}.tar.gz"

TEMP_DIR=$(mktemp -d)
trap "rm -rf ${TEMP_DIR}" EXIT

rsync -a --exclude='.git' \
      --exclude='build' \
      --exclude='*.deb' \
      --exclude='*.rpm' \
      --exclude='.dart_tool' \
      --exclude='.flutter-plugins' \
      --exclude='.flutter-plugins-dependencies' \
      . ${TEMP_DIR}/${TARBALL_NAME}/

tar -czf ${TARBALL} -C ${TEMP_DIR} ${TARBALL_NAME}
cp rpm/musicpod.spec ${RPMBUILD_DIR}/SPECS/

sed -i "s/^Version:.*/Version:        ${VERSION}/" ${RPMBUILD_DIR}/SPECS/musicpod.spec

echo "Building RPM package..."
rpmbuild -ba ${RPMBUILD_DIR}/SPECS/musicpod.spec

echo ""
echo "Build complete! Package files are in:"
echo "  ${RPMBUILD_DIR}/RPMS/"
ls -lh ${RPMBUILD_DIR}/RPMS/*/${PACKAGE_NAME}-*.rpm 2>/dev/null || echo "No .rpm file found"

