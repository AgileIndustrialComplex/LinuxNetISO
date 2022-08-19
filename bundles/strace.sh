#!/bin/bash
set -euo pipefail

source_url="https://github.com/strace/strace/releases/download/v5.19/strace-5.19.tar.xz"
source_dir="strace-5.19"

pushd $sources_dir
    if [ ! -d $source_dir ]
    then
        wget -qO- $source_url | tar -xJ
    fi

    if [ ! -f $rootfs_dir/bin/strace ]
    then
        pushd $source_dir
            ./configure LDFLAGS='-static -pthread' --enable-mpers=check
            make -j$(nproc)
            strip src/strace
            cp src/strace $rootfs_dir/bin
        popd > /dev/null
    fi
popd

