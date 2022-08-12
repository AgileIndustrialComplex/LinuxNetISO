#!/bin/bash
set -euo pipefail

kernel_url="https://www.kernel.org/pub/linux/kernel/v5.x/linux-5.10.17.tar.xz"
kernel_dir="linux-5.10.17"

pushd $sources_dir
    if [ ! -d $kernel_dir ]
    then
        echo "Downloading kernel"
        wget -qO- $kernel_url | tar -xJ
    fi
popd

mkdir -pv $pack_dir/isolinux
if [ ! -f $pack_dir/isolinux/vmlinuz ]
then
    echo "Build kernel"
    pushd $sources_dir/$kernel_dir
        cp -v $config_dir/kernel.config kernel.config
        make mrproper
        cp kernel.config .config
        make -j$(nproc)
        cp arch/x86/boot/bzImage $pack_dir/isolinux/vmlinuz
    popd > /dev/null
fi 