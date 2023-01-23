&git clone https://github.com/luvit/luvit luvit --recurse-submodules
&git clone https://github.com/luvit/luvi luvi --recurse-submodules
&git clone https://github.com/luvit/lit lit --recurse-submodules

cd luvit

$latest_tagged=$(git rev-list --tags --max-count=1)
$luvit_version=$(git describe --tags "$latest_tagged")

&git checkout $latest_tagged --recurse-submodules

cd ../luvi

$latest_tagged=$(git rev-list --tags --max-count=1)
$luvi_version=$(git describe --tags "$latest_tagged")

&git checkout $latest_tagged --recurse-submodules
Write-Output $luvi_version | Out-File -FilePath "VERSION" -Encoding utf8 -Append

cd ../lit

$latest_tagged=$(git rev-list --tags --max-count=1)
$lit_version=$(git describe --tags "$latest_tagged")

&git checkout $latest_tagged --recurse-submodules

Write-Output "LUVIT_VERSION=$luvit_version"  | Out-File -FilePath $env:GITHUB_ENV -Encoding utf8 -Append
Write-Output "LUVI_VERSION=$luvi_version"  | Out-File -FilePath $env:GITHUB_ENV -Encoding utf8 -Append
Write-Output "LIT_VERSION=$lit_version"  | Out-File -FilePath $env:GITHUB_ENV -Encoding utf8 -Append