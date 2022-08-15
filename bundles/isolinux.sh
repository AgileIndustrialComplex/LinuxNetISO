#!/bin/bash
set -euo pipefail

source_url="https://kernel.org/pub/linux/utils/boot/syslinux/6.xx/syslinux-6.03.tar.gz"
source_dir="syslinux-6.03"

pushd $sources_dir
    if [ ! -d $source_dir ]
    then
        wget -qO- $source_url | tar -xz
    fi

    pushd $source_dir
        cp -v $config_dir/isolinux.cfg $pack_dir/isolinux/isolinux.cfg
        cp bios/core/isolinux.bin $pack_dir/isolinux/isolinux.bin
        cp bios/com32/elflink/ldlinux/ldlinux.c32 $pack_dir/isolinux/ldlinux.c32
    popd
popd

