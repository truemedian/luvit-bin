#!/bin/bash
set -eu

FAKE=false
COMPRESS=false

while [ $# -gt 0 ]; do
    case "$1" in
        -q|--fake)
            FAKE=true
            shift;;
        -c|--compress)
            COMPRESS=true
            shift;;
        *)
            echo "unknown argument: $1"
            exit 1;;
    esac
done

_date_version=$(date +%Y%m%d)

LUVIT_REPO=${LUVIT_REPO:-luvit.git}
LUVI_REPO=${LUVI_REPO:-luvi.git}
LIT_REPO=${LIT_REPO:-lit.git}
VERSION=${VERSION:-$_date_version}
ARTIFACTS=${ARTIFACTS:-.}
SYSTEM=$(uname -s)
ARCH=$(uname -m)

LUVIT_REPO=$(realpath $LUVIT_REPO)
LUVI_REPO=$(realpath $LUVI_REPO)
LIT_REPO=$(realpath $LIT_REPO)
ARTIFACTS=$(realpath $ARTIFACTS)

if [ ! -d $LUVIT_REPO ] || [ ! -d $LUVI_REPO ] || [ ! -d $LIT_REPO ]; then
    echo "error: repositories not checked out"
    exit 1
fi

# Fetch tags to properly version binaries
echo "Fetching Tags..."

git --git-dir="$LUVIT_REPO/.git" fetch --tags
git --git-dir="$LUVI_REPO/.git" fetch --tags
git --git-dir="$LIT_REPO/.git" fetch --tags

LUVIT_VERSION=$(git --git-dir="$LUVIT_REPO/.git" describe | sed -Ee 's/\-.+//' -e 's/v//')
LUVI_VERSION=$(git --git-dir="$LUVI_REPO/.git" describe | sed -Ee 's/\-.+//' -e 's/v//')
LIT_VERSION=$(git --git-dir="$LIT_REPO/.git" describe | sed -Ee 's/\-.+//' -e 's/v//')

echo "Installation Configuration"
echo "  SYSTEM: $SYSTEM"
echo "  ARCH: $ARCH"
echo ""
echo "  ARTIFACTS: $ARTIFACTS"
echo "  VERSION: $VERSION"
echo ""
echo "  LUVIT_REPO: $LUVIT_REPO"
echo "  LUVI_REPO: $LUVI_REPO"
echo "  LIT_REPO: $LIT_REPO"
echo ""
echo "  LUVIT_VERSION: $LUVIT_VERSION"
echo "  LUVI_VERSION: $LUVI_VERSION"
echo "  LIT_VERSION: $LIT_VERSION"

if [ "$FAKE" = "true" ]; then
    exit 0
else
    echo ""
fi

echo "Configuring Installation Directory: $ARTIFACTS"

mkdir -p $ARTIFACTS

echo "Building Luvi $LUVI_VERSION"

cd $LUVI_REPO

make clean
make reset
make regular-asm
make
make test

echo "Installing Luvi to $ARTIFACTS"

cp ./build/luvi $ARTIFACTS/luvi

echo "Building Lit $LIT_VERSION"

cd $LIT_REPO

"$ARTIFACTS/luvi" "." -- make "." "$ARTIFACTS/lit" "$ARTIFACTS/luvi"

echo "Building Luvit $LUVIT_VERSION"

cd $LUVIT_REPO

"$ARTIFACTS/lit" make "." "$ARTIFACTS/luvit" "$ARTIFACTS/luvi"

echo "Builds Complete"

if [ "$COMPRESS" = "true" ]; then
    cd $ARTIFACTS

    _tarball="luvit-$VERSION-$SYSTEM-$ARCH.tar.gz"

    tar czf "$_tarball" luvit luvi lit

    if [ -e $GITHUB_ENV ]; then
        echo "TARBALL=$_tarball" >> $GITHUB_ENV
    fi
fi