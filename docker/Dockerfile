# Build environment for OpenWrt on the Milk-V Jupiter (SpacemiT K1).
#
# This tree is a 24.10-era OpenWrt fork and expects an older host toolchain.
# Bleeding-edge host compilers (e.g. GCC 16) break the build in several places
# (CMake bootstrap, cross-GCC libcody char8_t, safe-ctype macro clashes), so we
# build inside Debian Bookworm (GCC 12), which the tree compiles cleanly with.
FROM debian:bookworm

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential clang flex bison g++ gawk \
    gcc-multilib g++-multilib gettext git libncurses-dev libssl-dev \
    python3 python3-setuptools python3-dev \
    rsync unzip zlib1g-dev file wget ca-certificates time bc \
    libelf-dev ecj fastjar java-propose-classpath \
 && rm -rf /var/lib/apt/lists/*
