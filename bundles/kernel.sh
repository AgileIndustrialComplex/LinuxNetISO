#!/bin/bash
set -euo pipefail

source_url="https://www.kernel.org/pub/linux/kernel/v5.x/linux-5.10.17.tar.xz"
source_dir="linux-5.10.17"

pushd $sources_dir
    if [ ! -d $source_dir ]
    then
        wget -qO- $source_url | tar -xJ
    fi

    mkdir -pv $pack_dir/isolinux
    if [ ! -f $pack_dir/isolinux/vmlinuz ] || [ $force_kernel ]
    then
        pushd $source_dir
            cp -v $config_dir/kernel.config kernel.config
            
            make mrproper
            cp kernel.config .config
            
            make -j$(nproc)
            cp arch/x86/boot/bzImage $pack_dir/isolinux/vmlinuz
        popd > /dev/null
    fi 
popd
