#!/bin/bash
set -eu

get_changelog() {
    pushd "$1.git" >/dev/null

    latest_tagged=$(git rev-list --tags --max-count=1)
    git log --format=format:"- [\`%h\`](https://github.com/luvit/$1/commit/%H) %s (%an)" "$latest_tagged..HEAD"

    popd >/dev/null
}

get_latest_tag() {
    pushd "$1.git" >/dev/null

    latest_tagged=$(git rev-list --tags --max-count=1)
    version=$(git describe --tags "$latest_tagged")

    popd >/dev/null

    echo $version
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

luvit_latest=$(get_latest_tag luvit)
luvi_latest=$(get_latest_tag luvi)
lit_latest=$(get_latest_tag lit)

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
echo "## Luvit commits since $(get_latest_tag luvit)" >>RELEASE
echo "" >>RELEASE

if [ "$luvit_latest" != "$luvit_version" ]; then
    get_changelog luvit >>RELEASE
else
    echo -n "None" >>RELEASE
fi

echo "" >>RELEASE
echo "" >>RELEASE
echo "## Luvi commits since $(get_latest_tag luvi)" >>RELEASE
echo "" >>RELEASE

if [ "$luvi_latest" != "$luvi_version" ]; then
    get_changelog luvi >>RELEASE
else
    echo -n "None" >>RELEASE
fi

echo "" >>RELEASE
echo "" >>RELEASE
echo "## Lit commits since $(get_latest_tag lit)" >>RELEASE
echo "" >>RELEASE

if [ "$lit_latest" != "$lit_version" ]; then
    get_changelog lit >>RELEASE
else
    echo -n "None" >>RELEASE
fi

echo "" >>RELEASE

echo "tag=$(date '+%Y-%m-%d')" >>$GITHUB_ENV
