#!/bin/sh

cd $1

updpkgsums
makepkg -f
makepkg --printsrcinfo >.SRCINFO

eval $(grep -E 'pkgver=' PKGBUILD)

# git add PKGBUILD .SRCINFO
# git commit -m "Update to $pkgver"

# find */* -type d -exec rm {} -rf \;