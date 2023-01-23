#!/bin/sh
set -eu

git clone https://github.com/luvit/luvit luvit --recurse-submodules
git clone https://github.com/luvit/luvi luvi --recurse-submodules
git clone https://github.com/luvit/lit lit --recurse-submodules

cd luvit

latest_tagged=$(git rev-list --tags --max-count=1)
luvit_version=$(git describe --tags "$latest_tagged")

git checkout $latest_tagged --recurse-submodules

cd ../luvi

latest_tagged=$(git rev-list --tags --max-count=1)
luvi_version=$(git describe --tags "$latest_tagged")

git checkout $latest_tagged --recurse-submodules
echo "$luvi_version" >VERSION

cd ../lit

latest_tagged=$(git rev-list --tags --max-count=1)
lit_version=$(git describe --tags "$latest_tagged")

git checkout $latest_tagged --recurse-submodules

echo "LUVIT_VERSION=$luvit_version" >>$GITHUB_ENV
echo "LUVI_VERSION=$luvi_version" >>$GITHUB_ENV
echo "LIT_VERSION=$lit_version" >>$GITHUB_ENV
