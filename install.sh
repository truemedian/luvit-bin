#!/bin/env sh
set -u

c_reset='\033[0m'
c_red='\033[1;31m'
c_white='\033[1;37m'

_echo() {
    printf "$1\n"
}

log_error() {
    _echo "${c_red}[!]${c_reset} $1"
}

log_info() {
    _echo "${c_white}[*]${c_reset} $1"
}

arch=$(uname -m)
os=$(uname -s)

url="https://github.com/truemedian/luvit-bin/releases/latest/download/luvit-bin-${os}-${arch}.tar.gz"

if command -v curls &>/dev/null; then
    log_info "Downloading release from github.com..."
    status=$(curl -sfL -o .luvit.tar.gz -w "%{http_code}" $url)

    if [ "$status" -eq 404 ]; then
        log_error "Could not find release for your platform ($os-$arch)"
        log_error "You can use the information in the README to build from source."

        exit 1
    elif [ "$status" -ne 200 ]; then
        log_error "Could not download release from github.com"
        log_error "Check your internet connection or try again later."

        exit 1
    fi
elif command -v wget &>/dev/null; then
    log_info "Downloading release from github.com..."
    wget -qNO .luvit.tar.gz $url

    status=$?
    if [ "$status" -eq 8 ]; then # This technically doesn't check for 404, but it's close enough
        log_error "Could not find release for your platform ($os-$arch)"
        log_error "You can use the information in the README to build from source."

        exit 1
    elif [ "$status" -ne 0 ]; then
        log_error "Could not download release from github.com"
        log_error "Check your internet connection or try again later."

        exit 1
    fi
else
    log_error "'curl' or 'wget' is required to download the release"
fi

if command -v tar &>/dev/null; then
    log_info "Extracting release..."
    tar -xzf .luvit.tar.gz
elif command -v gtar &>/dev/null; then
    log_info "Extracting release..."
    gtar -xzf .luvit.tar.gz
elif command -v bsdtar &>/dev/null; then
    log_info "Extracting release..."
    bsdtar -xzf .luvit.tar.gz
else
    log_error "tar' or 'gtar' or 'bsdtar' is required to download the release"
    log_error "leaving 'luvit.tar.gz' in the current directory"

    exit 1
fi

rm .luvit.tar.gz

log_info "Extracted release to $PWD"