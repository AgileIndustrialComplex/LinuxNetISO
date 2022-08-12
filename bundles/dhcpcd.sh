#!/bin/bash
set -euo pipefail

dhcpcd_url="https://roy.marples.name/downloads/dhcpcd/dhcpcd-9.4.1.tar.xz"
dhcpcd_dir="dhcpcd-9.4.1"

pushd $sources_dir
    if [ ! -d $dhcpcd_dir ]
    then
        echo "Downloading dhcpcd"
        wget -qO- $dhcpcd_url | tar -xJ
    fi
popd

echo "Build dhcpcd"
pushd $sources_dir/$dhcpcd_dir
    ./configure                      \
            --prefix=/               \
            --sysconfdir=/etc        \
            --libexecdir=/lib/dhcpcd \
            --enable-static          \
            --dbdir=/var/lib/dhcpcd  \
            --runstatedir=/run       \
            --privsepuser=root
    make
    make DESTDIR=$rootfs_dir install
popd