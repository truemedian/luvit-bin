#!/bin/bash
set -eu

[ -d luvi.git ] || exit 1

_hdrs="$PWD/headers"

cd luvi.git

[ -d build ] || exit 1

mkdir -p $_hdrs

# Luajit
mkdir -p $_hdrs/luajit
cp deps/luv/deps/luajit/src/*.h $_hdrs/luajit
cp build/deps/luv/lj_*.h $_hdrs/luajit

# PCRE
mkdir -p $_hdrs/pcre
cp deps/pcre/*.h $_hdrs/pcre
cp build/deps/pcre/*.h $_hdrs/pcre

# LPeg
mkdir -p $_hdrs/lpeg
cp deps/lpeg/*.h $_hdrs/lpeg

# Zlib
mkdir -p $_hdrs/zlib
cp deps/zlib/*.h $_hdrs/zlib

# Miniz
mkdir -p $_hdrs/miniz
cp deps/miniz.h $_hdrs/miniz

# Libuv
mkdir -p $_hdrs/uv
cp deps/luv/deps/libuv/include/*.h $_hdrs/uv

# Openssl
mkdir -p $_hdrs/openssl
cp build/openssl/src/openssl/include/openssl/*.h $_hdrs/openssl

cd $_hdrs

tar czf headers.tar.gz *
