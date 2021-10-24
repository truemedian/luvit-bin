
# Luvit Binaries

This repository provides build scripts that can be used to build luvit, lit and luvi from their source. Which is
necessary on systems that luvit does not provide prebuilt luvi binaries for. Releases are managed by a Github Action
which runs weekly to rebuild the binaries for all supported systems.

## Supported Systems

| Architecture | Systems                |
| ------------ |:---------------------- |
| x86_64       | Windows, Darwin, Linux |
| armv6l       | Linux                  |
| armv7l       | Linux                  |
| aarch64      | Linux                  |

## Install Script

### Linux and Darwin (MacOS)

```shell
curl -fL https://github.com/truemedian/luvit-bin/raw/main/install.sh | sh
```

### Windows

*Powershell install script TODO*

## Self-Build Script

If you wish to build luvit, luvi and lit yourself, or are on a system that does not have prebuilt binaries an install
script is included in this repository. The script is intended to be run by a user, and its interface has specifically
been designed to be easy to read.

### Dependencies

- C Compiler
- C++ Compiler
- git
- cmake
- make
- perl

### Configuration

| Variable    | Meaning                                         |
| ----------- | ----------------------------------------------- |
| CMAKE_FLAGS | Will overwrite the script's default cmake flags |
| PREFIX      | Will change the final executable's location.    |

`PREFIX` will default to `$PWD`, set it if you would like to install elsewhere.

### Running

You can either download and run it yourself, or run

```shell
curl -fL https://github.com/truemedian/luvit-bin/raw/main/scripts/build.sh | sh
```

To download and run the script automatically.
