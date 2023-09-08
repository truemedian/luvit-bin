#!/bin/env sh
set -uo pipefail

DEFAULT_CMAKE_FLAGS="-DCMAKE_BUILD_TYPE=Release -DWithSharedLibluv=OFF -DWithOpenSSL=ON -DWithSharedOpenSSL=OFF -DWithOpenSSLASM=ON -DWithPCRE=ON -DWithLPEG=ON -DWithSharedPCRE=OFF"
CMAKE_FLAGS=${CMAKE_FLAGS-$DEFAULT_CMAKE_FLAGS}

DEFAULT_INSTALL_PREFIX="${PWD}"
INSTALL_PREFIX=${PREFIX-$DEFAULT_INSTALL_PREFIX}

build_root=${PWD}

c_reset='\033[0m'
c_black='\033[1;30m'
c_red='\033[1;31m'
c_green='\033[1;32m'
c_yellow='\033[1;33m'
c_blue='\033[1;34m'
c_magenta='\033[1;35m'
c_cyan='\033[1;36m'
c_white='\033[1;37m'

realdir() {
    cd $1

    pwd
}

_indent() {
    printf "    "
}

_echo() {
    printf "$1\n"
}

log_error() {
    _echo "${c_red}[!]${c_reset} $1"
}

log_warn() {
    _echo "${c_yellow}[#]${c_reset} $1"
}

log_info() {
    _echo "${c_white}[*]${c_reset} $1"
}

log_debug() {
    _echo "${c_green}[@]${c_reset} $1"
}

run_cmd() {
    cmd="$@"
    log_debug "${c_green}$ ${c_cyan}${cmd}${c_reset}"

    _echo "$ ${cmd}" >>"${build_root}/install.log"

    if [ "$1" = "${cmake_command}" ] || [ "$1" = "${git_command}" ]; then
        $@ >>"${build_root}/install.log" 2>&1
    else
        $@ >>"${build_root}/install.log"
    fi

    if [ $? -eq 0 ]; then
        log_error "Build Failed. See Installation Log @ ${INSTALL_PREFIX}"
    fi
}

_echo "$(date)" >"${build_root}/install.log"

log_info "Installation Log at ${build_root}/install.log"

log_info "Checking For Dependencies"

# check_dep [name] [commands...]
check_dep() {
    name="$1"
    shift

    unset has_choices
    attempts="$@"
    if [ $# -gt 1 ]; then
        _indent
        log_info "${name} (${attempts})"

        has_choices=0
    fi

    unset has_dep
    while [ $# -gt 0 ]; do
        path=$(command -v $1 || true)

        if [ "${path}" != "" ]; then
            [ -n "${has_choices-}" ] && _indent
            _indent

            _echo "${c_green}[*]${c_reset} $1"

            has_dep=0
            eval "${name}_command='${path}'; ${name}_using='$1'"

            break
        else
            [ -n "${has_choices-}" ] && _indent
            _indent

            _echo "${c_red}[#]${c_reset} $1"
        fi

        shift
    done

    if [ -z "${has_dep-}" ]; then
        log_error "Missing ${name} (${attempts})"
        exit 1
    fi
}

check_dep cc ${CC-} clang gcc cc
check_dep cxx ${CXX-} clang++ g++ c++

check_dep git git
check_dep cmake cmake
check_dep make make
check_dep perl perl
check_dep getconf getconf

log_info "Setting Up Repositories"

log_info "Checkout luvit/luvit"
if [ -e luvit.d ] && [ -e luvit.d/.git ]; then
    _indent
    log_warn "luvit.d already exists and is a git repo, skipping checkout"
else
    run_cmd $git_command init luvit.d

    cd luvit.d
    run_cmd $git_command remote add origin https://github.com/luvit/luvit
    run_cmd $git_command fetch --tags --prune --progress --no-recurse-submodules --depth=1 origin master
    run_cmd $git_command checkout --progress --force master

    run_cmd $git_command submodule sync --recursive
    run_cmd $git_command submodule update --init --force --depth=1 --recursive
    cd $build_root
fi

log_info "Checkout luvit/luvi"
if [ -e luvi.d ] && [ -e luvi.d/.git ]; then
    _indent
    log_warn "luvi.d already exists and is a git repo, skipping checkout"

    cd luvi.d
else
    run_cmd $git_command init luvi.d

    cd luvi.d
    run_cmd $git_command remote add origin https://github.com/luvit/luvi
    run_cmd $git_command fetch --tags --prune --progress --no-recurse-submodules --depth=1 origin master
    run_cmd $git_command checkout --progress --force master

    run_cmd $git_command submodule sync --recursive
    run_cmd $git_command submodule update --init --force --depth=1 --recursive
fi

latest_ref=$($git_command rev-parse HEAD)
latest_tagged=$($git_command rev-list --tags --max-count=1)
LUVI_VERSION=$($git_command describe --tags "${latest_tagged}")
if [ "${latest_tagged}" != "${latest_ref}" ]; then
    LUVI_VERSION="${LUVI_VERSION}-dev"
fi
cd $build_root

log_info "Checkout luvit/lit"
if [ -e lit.d ] && [ -e lit.d/.git ]; then
    _indent
    log_warn "lit.d already exists and is a git repo, skipping checkout"
else
    run_cmd $git_command init lit.d

    cd lit.d
    run_cmd $git_command remote add origin https://github.com/luvit/lit
    run_cmd $git_command fetch --tags --prune --progress --no-recurse-submodules --depth=1 origin master
    run_cmd $git_command checkout --progress --force master

    run_cmd $git_command submodule sync --recursive
    run_cmd $git_command submodule update --init --force --depth=1 --recursive
    cd $build_root
fi

log_info "Setting Up Installation Location (${INSTALL_PREFIX})"
mkdir -p "${INSTALL_PREFIX}"

luvi_command="${INSTALL_PREFIX}/luvi"
lit_command="${INSTALL_PREFIX}/lit"
luvit_command="${INSTALL_PREFIX}/luvit"

log_info "Building Luvi (this will take some time...)"
cd luvi.d

printf "${LUVI_VERSION}" >VERSION

if [ -e build ]; then
    _indent
    log_warn "Clearing previous build"

    rm -r build
fi

CPUS=$($getconf_command _NPROCESSORS_ONLN 2>/dev/null) ||
    CPUS=$($getconf_command NPROCESSORS_ONLN 2>/dev/null) ||
    CPUS=1

run_cmd $cmake_command -H. -Bbuild ${CMAKE_FLAGS} -DCMAKE_C_COMPILER="${cc_command}" -DCMAKE_ASM_COMPILER="${cc_command}" -DCMAKE_CXX_COMPILER="${cxx_command}"
run_cmd $cmake_command --build build -j${CPUS}

cp build/luvi "$luvi_command"
cd $build_root

log_info "Building Lit"
run_cmd "${luvi_command}" lit.d -- make lit.d "${lit_command}" "${luvi_command}"

log_info "Building Luvit"
run_cmd "${lit_command}" make luvit.d "${luvit_command}" "${luvi_command}"

log_info "Cleaning Up"
rm -rf *.d

log_info "Installation Complete @ ${INSTALL_PREFIX}"
