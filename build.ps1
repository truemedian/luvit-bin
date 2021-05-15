$ErrorActionPreference = 'Stop' 
$ProgressPreference = "SilentlyContinue"

$_build = "$(Get-Location)/build"

function __clone() {
    mkdir ${_build}
    Write-Output "" | Out-File -FilePath "${_build}/INFO" -Encoding utf8 -Append -NoNewline

    &git clone https://github.com/luvit/luvit luvit.git --depth 1 --recurse-submodules --shallow-submodules
    &git clone https://github.com/luvit/luvi luvi.git --depth 1 --recurse-submodules --shallow-submodules
    &git clone https://github.com/luvit/lit lit.git --depth 1 --recurse-submodules --shallow-submodules
}

function __luvi() {
    Set-Location luvi.git

    &git fetch --tags --prune --progress --no-recurse-submodules --depth=1 origin master

    $latest_tagged = $(git rev-list --tags --max-count=1)
    $luvi_version = $(git describe --tags "$latest_tagged")
    if ( "${latest_tagged}" -ne "$(git rev-parse HEAD)" ) {
        $luvi_version = "${luvi_version}-dev+$(git rev-parse --short HEAD)"
    }

    Write-Output $luvi_version | Out-File -FilePath "VERSION" -Encoding utf8 -Append

    if ( "$env:BUILD_ARCH" -eq "i386" ) {
        &./make.bat regular32-asm
    }
    else {
        &./make.bat regular-asm
    }
    &./make.bat
    &./make.bat test

    Move-Item luvi.exe ${_build}

    Write-Output "Luvi $luvi_version" | Out-File -FilePath "${_build}/INFO" -Encoding utf8 -Append
}

function __lit() {
    Set-Location lit.git

    &git fetch --tags --prune --progress --no-recurse-submodules --depth=1 origin master

    $latest_tagged = $(git rev-list --tags --max-count=1)
    $lit_version = $(git describe --tags "$latest_tagged")
    if ( "${latest_tagged}" -ne "$(git rev-parse HEAD)" ) {
        $lit_version = "${lit_version}-dev+$(git rev-parse --short HEAD)"
    }

    &${_build}/luvi.exe . -- make . ${_build}/lit.exe ${_build}/luvi.exe

    Write-Output "Lit $lit_version" | Out-File -FilePath "${_build}/INFO" -Encoding utf8 -Append
}

function __luvit() {
    Set-Location luvit.git

    &git fetch --tags --prune --progress --no-recurse-submodules --depth=1 origin master

    $latest_tagged = $(git rev-list --tags --max-count=1)
    $luvit_version = $(git describe --tags "$latest_tagged")
    if ( "${latest_tagged}" -ne "$(git rev-parse HEAD)" ) {
        $luvit_version = "${luvit_version}-dev+$(git rev-parse --short HEAD)"
    }

    &${_build}/lit.exe make . ${_build}/luvit.exe ${_build}/luvi.exe

    Write-Output "Luvit $luvit_version" | Out-File -FilePath "${_build}/INFO" -Encoding utf8 -Append
}

function __package() {
    Set-Location build

    $artifact = "luvit-bin-Windows-$env:BUILD_ARCH.zip"
    Write-Output "Packaged: $(date '+%Y-%m-%d %H:%M:%S %:z')" | Out-File -FilePath "${_build}/INFO" -Encoding utf8 -Append
    Write-Output "artifact=$artifact"  | Out-File -FilePath $env:GITHUB_ENV -Encoding utf8 -Append

    &7z a -tzip -mx9 $artifact *
}

switch ($args[0]) {
    "clone" { __clone }
    "luvi" { __luvi }
    "lit" { __lit }
    "luvit" { __luvit }
    "package" { __package }
}