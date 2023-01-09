#!/bin/bash
set -eu

_build="$PWD/build"

__clone() {
    mkdir -p ${_build}

    git clone https://github.com/luvit/luvit luvit.git --depth 1 --recurse-submodules --shallow-submodules
    git clone https://github.com/luvit/luvi luvi.git --depth 1 --recurse-submodules --shallow-submodules
    git clone https://github.com/luvit/lit lit.git --depth 1 --recurse-submodules --shallow-submodules

}

__luvi() {
    cd luvi.git

    git fetch --tags --prune --progress --no-recurse-submodules --depth=1 origin master

    latest_tagged=$(git rev-list --tags --max-count=1)
    luvi_version=$(git describe --tags "$latest_tagged")
    if [ "${latest_tagged}" != "$(git rev-parse HEAD)" ]; then
        luvi_version="${luvi_version}-dev+$(git rev-parse --short HEAD)"
    fi

    echo $luvi_version >VERSION

    make regular-asm
    make
    make test

    mv build/luvi ${_build}
}

__lit() {
    cd lit.git

    git fetch --tags --prune --progress --no-recurse-submodules --depth=1 origin master

    latest_tagged=$(git rev-list --tags --max-count=1)
    lit_version=$(git describe --tags "$latest_tagged")
    if [ "${latest_tagged}" != "$(git rev-parse HEAD)" ]; then
        lit_version="${lit_version}-dev+$(git rev-parse --short HEAD)"
    fi

    ${_build}/luvi . -- make . ${_build}/lit ${_build}/luvi
}

__luvit() {
    cd luvit.git

    git fetch --tags --prune --progress --no-recurse-submodules --depth=1 origin master

    latest_tagged=$(git rev-list --tags --max-count=1)
    luvit_version=$(git describe --tags "$latest_tagged")
    if [ "${latest_tagged}" != "$(git rev-parse HEAD)" ]; then
        luvit_version="${luvit_version}-dev+$(git rev-parse --short HEAD)"
    fi

    ${_build}/lit make . ${_build}/luvit ${_build}/luvi
}

__package() {
    cd build

    artifact="luvit-bin-$(uname -s)-$(uname -m).tar.gz"
    echo "artifact=$artifact" >>$GITHUB_ENV

    tar czf $artifact *
}

# uraimo/run-on-arch-action has an issue where we cannot write to $GITHUB_ENV, so we need to pull that code out of the container
__package_docker_inner() {
    cd build

    artifact="luvit-bin-$(uname -s)-$(uname -m).tar.gz"

    tar czf $artifact *

    echo "$artifact" > "artifact.name"
}

__package_docker_outer() {
    cd build

    artifact=$(cat "artifact.name")

    echo "artifact=$artifact" >>$GITHUB_ENV
}

case "$1" in
clone) __clone ;;
luvi) __luvi ;;
lit) __lit ;;
luvit) __luvit ;;
package) __package ;;
package_docker_inner) __package_docker_inner ;;
package_docker_outer) __package_docker_outer ;;
esac
