
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
