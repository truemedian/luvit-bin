#!/bin/env sh
set -eu

arch=$(uname -m)
os=$(uname -s)

url="https://github.com/truemedian/luvit-bin/releases/latest/download/luvit-bin-${os}-${arch}.tar.gz"

if command -v curl &>/dev/null; then
    curl -fLo .luvit.tar.gz $url
elif command -v wget &>/dev/null; then
    wget -O .luvit.tar.gz $url
else
    echo "fatal: missing 'curl' or 'wget', cannot download"
    exit 1
fi

if command -v tar &>/dev/null; then
    tar -xzf .luvit.tar.gz
elif command -v gtar &>/dev/null; then
    gtar -xzf .luvit.tar.gz
elif command -v bsdtar &>/dev/null; then
    bsdtar -xzf .luvit.tar.gz
else
    echo "fatal: missing 'tar' or 'gtar' or 'bsdtar', cannot extract. leaving 'luvit.tar.gz'"

    mv .luvit.tar.gz luvit.tar.gz

    exit 1
fi

rm .luvit.tar.gz
