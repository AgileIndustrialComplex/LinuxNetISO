#!/bin/bash
set -euo pipefail

strace_url="https://github.com/strace/strace/releases/download/v5.19/strace-5.19.tar.xz"
strace_dir="strace-5.19"

pushd $sources_dir
    if [ ! -d $strace_dir ]
    then
        echo "Downloading strace"
        wget -qO- $strace_url | tar -xJ
    fi
popd

echo "Build strace"
pushd $sources_dir/$strace_dir
    ./configure LDFLAGS='-static -pthread' --enable-mpers=check
    make -j$(nproc)
    strip src/strace
    cp src/strace $rootfs_dir/bin
popd > /dev/null
