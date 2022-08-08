#!/bin/bash
set -euo pipefail

source sources.sh

echo "Build dhcpcd"
pushd $sources_dir/$dhcpcd_dir
    ./configure                      \
            --prefix=/               \
            --sysconfdir=/etc        \
            --libexecdir=/lib/dhcpcd \
            --enable-static          \
            --dbdir=/var/lib/dhcpcd  \
            --runstatedir=/run       \
            --privsepuser=dhcpcd
    make
    make DESTDIR=$rootfs_dir install
popd