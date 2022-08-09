#!/bin/bash
set -euo pipefail

source sources.sh

pushd $sources_dir
    if [ ! -d $kernel_dir ]
    then
        echo "Downloading kernel"
        wget -qO- $kernel_url | tar -xJ
    fi
    if [ ! -d $syslinux_dir ]
    then
        echo "Downloading syslinux"
        wget -qO- $syslinux_url | tar -xz
    fi
    if [ ! -d $dhcpcd_dir ]
    then
        echo "Downloading dhcpcd"
        wget -qO- $dhcpcd_url | tar -xJ
    fi
    if [ ! -d $busybox_dir ]
    then
        echo "Downloading busybox"
        wget -qO- $busybox_url | tar -xj
    fi

    cp -v $config_dir/kernel.config $kernel_dir/kernel.config
    cp -v $config_dir/busybox.config $busybox_dir/busybox.config
    cp -v $config_dir/isolinux.cfg $syslinux_dir/isolinux.cfg
popd

