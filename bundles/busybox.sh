#!/bin/bash
set -euo pipefail

busybox_url="https://busybox.net/downloads/busybox-1.35.0.tar.bz2"
busybox_dir="busybox-1.35.0"

pushd $sources_dir
    if [ ! -d $busybox_dir ]
    then
        echo "Downloading busybox"
        wget -qO- $busybox_url | tar -xj
    fi
popd

echo "Build busybox"
pushd $sources_dir/$busybox_dir
    cp -v $config_dir/busybox.config busybox.config
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