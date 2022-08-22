#!/bin/bash
set -euo pipefail

source_url="https://busybox.net/downloads/busybox-1.35.0.tar.bz2"
source_dir="busybox-1.35.0"

toolchain_url="https://musl.cc/x86_64-linux-musl-native.tgz"
toolchain_dir="x86_64-linux-musl-native"

pushd $sources_dir
    if [ ! -d $source_dir ]
    then
        wget -qO- $source_url | tar -xj
        pushd $source_dir
            wget -qO- $toolchain_url | tar -xz
        popd
    fi

    pushd $source_dir
        cp -v $config_dir/busybox.config busybox.config
        cp busybox.config .config
        make -j$(nproc) CC=${toolchain_dir}/bin/x86_64-linux-musl-cc LDFLAGS=-static
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
popd
