#!/bin/bash
set -euo pipefail

syslinux_url="https://kernel.org/pub/linux/utils/boot/syslinux/6.xx/syslinux-6.03.tar.gz"
syslinux_dir="syslinux-6.03"

pushd $sources_dir
    if [ ! -d $syslinux_dir ]
    then
        echo "Downloading syslinux"
        wget -qO- $syslinux_url | tar -xz
    fi
popd

pushd $sources_dir/$syslinux_dir > /dev/null
    cp -v $config_dir/isolinux.cfg $pack_dir/isolinux/isolinux.cfg
    cp bios/core/isolinux.bin $pack_dir/isolinux/isolinux.bin
    cp bios/com32/elflink/ldlinux/ldlinux.c32 $pack_dir/isolinux/ldlinux.c32
popd > /dev/null