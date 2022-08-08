#!/bin/bash
set -euo pipefail

source sources.sh

echo "Build busybox"
pushd $sources_dir/$busybox_dir
    cp busybox.config .config
    make -j$(nproc)
    strip busybox

    mkdir -pv ./bin
    cp -pv busybox ./bin
    pushd bin
        for e in $(./busybox --list);
        do
            ln -svf busybox $e
        done
    popd
    cp -vP bin/* $rootfs_dir/bin
    ln -svf ../bin/init $rootfs_dir/sbin/init
popd