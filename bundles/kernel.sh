#!/bin/bash
set -euo pipefail

source sources.sh

mkdir -pv $pack_dir/isolinux
if [ ! -f $pack_dir/isolinux/vmlinuz ]
then
    echo "Build kernel"
    pushd $sources_dir/$kernel_dir
        make mrproper
        cp kernel.config .config
        make -j$(nproc)
        cp arch/x86/boot/bzImage $pack_dir/isolinux/vmlinuz
    popd > /dev/null
fi 