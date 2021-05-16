#!/bin/bash
set -eu

get_changelog() {
    pushd "$1.git" >/dev/null

    latest_tagged=$(git rev-list --tags --max-count=1)
    git log --format=format:"- [\`%h\`](https://github.com/luvit/$1/commit/%H) %s (%an)" "$latest_tagged..HEAD"

    popd >/dev/null
}

get_version() {
    pushd "$1.git" >/dev/null

    latest_tagged=$(git rev-list --tags --max-count=1)
    version=$(git describe --tags "$latest_tagged")
    if [ "${latest_tagged}" != "$(git rev-parse HEAD)" ]; then
        version="${version}-dev+$(git rev-parse --short HEAD)"
    fi

    popd >/dev/null

    echo $version
}

git clone https://github.com/luvit/luvit luvit.git
git clone https://github.com/luvit/luvi luvi.git
git clone https://github.com/luvit/lit lit.git

luvit_version=$(get_version luvit)
luvi_version=$(get_version luvi)
lit_version=$(get_version lit)

echo -n "" >RELEASE
echo "# Versions" >>RELEASE
echo "" >>RELEASE
echo "Luvit $luvit_version" >>RELEASE
echo "Luvi $luvi_version" >>RELEASE
echo "Lit $lit_version" >>RELEASE
echo "" >>RELEASE
echo "# Changelogs" >>RELEASE
echo "" >>RELEASE
echo "## Luvit" >>RELEASE
echo "" >>RELEASE

get_changelog luvit >>RELEASE

echo "" >>RELEASE
echo "" >>RELEASE
echo "## Luvi" >>RELEASE
echo "" >>RELEASE

get_changelog luvi >>RELEASE

echo "" >>RELEASE
echo "" >>RELEASE
echo "## Lit" >>RELEASE
echo "" >>RELEASE

get_changelog lit >>RELEASE

echo "" >>RELEASE

echo "tag=$(date '+%Y-%m-%d')" >>$GITHUB_ENV
