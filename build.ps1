$ErrorActionPreference = 'Stop' 
$ProgressPreference = "SilentlyContinue"

$Fake = $False
$Compress = $False

for ($i = 0; $i -lt $args.count; $i++) {
    switch -regex ($args[$i]) {
        "-q|--fake" { $Fake = $True }
        "-c|--compress" { $Compress = $True }
        Default {
            Write-Host "unknown argument: ${args[$i]}"
            exit 1
        }
    }
} 

$LUVIT_REPO = "luvit.git"
$LUVI_REPO = "luvi.git"
$LIT_REPO = "lit.git"
$VERSION = Get-Date -Format "yyyyMMdd"
$ARTIFACTS = Resolve-Path -Path .
$SYSTEM = "Windows"

if ([System.Environment]::Is64BitProcess) {
    $ARCH = "x86_64"
} else {
    $ARCH = "i686"
}

if (Test-Path env:LUVIT_REPO) { $LUVIT_REPO = $env:LUVIT_REPO }
if (Test-Path env:LUVI_REPO) { $LUVI_REPO = $env:LUVI_REPO }
if (Test-Path env:LIT_REPO) { $LIT_REPO = $env:LIT_REPO }
if (Test-Path env:VERSION) { $VERSION = $env:VERSION }
if (Test-Path env:ARTIFACTS) { $ARTIFACTS = $env:ARTIFACTS }

Resolve-Path -Path "$LUVIT_REPO" -OutVariable LUVIT_REPO > $null
Resolve-Path -Path "$LUVI_REPO" -OutVariable LUVI_REPO > $null
Resolve-Path -Path "$LIT_REPO" -OutVariable LIT_REPO > $null

$LUVIT_REPO = $LUVIT_REPO -join ""
$LUVI_REPO = $LUVI_REPO -join ""
$LIT_REPO = $LIT_REPO -join ""

# Fetch tags to properly version binaries
Write-Host "Fetching Tags..."

Start-Process -FilePath "git" -Wait -NoNewWindow -ArgumentList "--git-dir='$LUVIT_REPO/.git'", "fetch", "--tags" > $null
Start-Process -FilePath "git" -Wait -NoNewWindow -ArgumentList "--git-dir='$LUVI_REPO/.git'", "fetch", "--tags" > $null
Start-Process -FilePath "git" -Wait -NoNewWindow -ArgumentList "--git-dir='$LIT_REPO/.git'", "fetch", "--tags" > $null

$LUVIT_VERSION=(git --git-dir="$LUVIT_REPO/.git" describe) -replace "\-.+", "" -replace "v", ""
$LUVI_VERSION=(git --git-dir="$LUVI_REPO/.git" describe) -replace "\-.+", "" -replace "v", ""
$LIT_VERSION=(git --git-dir="$LIT_REPO/.git" describe) -replace "\-.+", "" -replace "v", ""

Write-Host "Installation Configuration"
Write-Host "  SYSTEM: $SYSTEM"
Write-Host "  ARCH: $ARCH"
Write-Host ""
Write-Host "  ARTIFACTS: $ARTIFACTS"
Write-Host "  VERSION: $VERSION"
Write-Host ""
Write-Host "  LUVIT_REPO: $LUVIT_REPO"
Write-Host "  LUVI_REPO: $LUVI_REPO"
Write-Host "  LIT_REPO: $LIT_REPO"
Write-Host ""
Write-Host "  LUVIT_VERSION: $LUVIT_VERSION"
Write-Host "  LUVI_VERSION: $LUVI_VERSION"
Write-Host "  LIT_VERSION: $LIT_VERSION"

if ($Fake -eq $True) {
    exit 0
} else {
    Write-Host ""
}

Write-Host "Configuring Installation Directory: $ARTIFACTS"

New-Item -Path "$ARTIFACTS" -ItemType Directory -ErrorAction SilentlyContinue > $null

Write-Host "Building Luvi $LUVI_VERSION"

Set-Location $LUVI_REPO

Start-Process -FilePath "./make.bat" -Wait -NoNewWindow -ArgumentList "clean"
Start-Process -FilePath "./make.bat" -Wait -NoNewWindow -ArgumentList "reset"
Start-Process -FilePath "./make.bat" -Wait -NoNewWindow -ArgumentList "regular-asm"
Start-Process -FilePath "./make.bat" -Wait -NoNewWindow 
Start-Process -FilePath "./make.bat" -Wait -NoNewWindow -ArgumentList "test"

Write-Host "Installing Luvi to $ARTIFACTS"

Copy-Item -Path "./luvi.exe" -Destination "$ARTIFACTS/luvi.exe"

Write-Host "Building Lit $LIT_VERSION"

Set-Location $LIT_REPO

Start-Process -FilePath "$ARTIFACTS/luvi.exe" -Wait -NoNewWindow -ArgumentList ".", "--", "make", ".", "$ARTIFACTS/lit.exe", "$ARTIFACTS/luvi.exe"

Write-Host "Building Luvit $LUVIT_VERSION"

Set-Location $LUVIT_REPO

Start-Process -FilePath "$ARTIFACTS/lit.exe" -Wait -NoNewWindow -ArgumentList "make", ".", "$ARTIFACTS/luvit.exe", "$ARTIFACTS/luvi.exe"

Write-Host "Builds Complete"

if ($Compress -eq $True) {
    Set-Location $ARTIFACTS

    $tarball = "luvit-$VERSION-$SYSTEM-$ARCH.zip"

    Compress-Archive -Path "luvit.exe", "luvi.exe", "lit.exe" -DestinationPath "$tarball" -CompressionLevel "Optimal"

    if (Test-Path env:GITHUB_ENV) {
        Write-Output "TARBALL=$tarball" | Out-File -FilePath $env:GITHUB_ENV -Encoding utf8 -Append
    }
}

# See: PowerShell/PowerShell Issue #11461
exit 0