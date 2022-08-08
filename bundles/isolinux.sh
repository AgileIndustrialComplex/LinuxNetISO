#!/bin/bash
set -euo pipefail

source sources.sh

pushd $sources_dir/$syslinux_dir > /dev/null
    cp bios/core/isolinux.bin $pack_dir/isolinux/isolinux.bin
    cp bios/com32/elflink/ldlinux/ldlinux.c32 $pack_dir/isolinux/ldlinux.c32
    cp isolinux.cfg $pack_dir/isolinux/isolinux.cfg
popd > /dev/null