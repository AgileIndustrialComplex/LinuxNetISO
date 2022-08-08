#!/bin/bash
set -euo pipefail

# check the shell
if ! test -n "$BASH_VERSION"
then
    echo "This script must be run using bash."
    exit 1
fi

commands=(
    realpath
    cp
    wget    # downloads
    tar     # unpacking archives
    make    # build system
    gcc     # compiler
    flex    # compile kernel
    bison   # compile kernel
    strip   # clear objects from executables
    find    # list files for initramfs
    cpio    # create initramfs archive
    gzip    # compress initramfs
    mkisofs # create bootable iso
)

# check for existance
all_commands_exist=0
for cmd in "${commands[@]}"
do
    if ! command -v $cmd &> /dev/null
    then
        echo "$cmd could not be found"
        all_commands_exist=1
    fi
done
if [ $all_commands_exist -eq 1 ]
then
    exit 1
fi

kernel_url="https://www.kernel.org/pub/linux/kernel/v5.x/linux-5.10.17.tar.xz"
kernel_dir="linux-5.10.17"
syslinux_url="https://kernel.org/pub/linux/utils/boot/syslinux/6.xx/syslinux-6.03.tar.gz"
syslinux_dir="syslinux-6.03"
dhcpcd_url="https://roy.marples.name/downloads/dhcpcd/dhcpcd-9.4.1.tar.xz"
dhcpcd_dir="dhcpcd-9.4.1"
busybox_url="https://busybox.net/downloads/busybox-1.35.0.tar.bz2"
busybox_dir="busybox-1.35.0"

build_root=$(pwd)
source_root=$(dirname $0 | xargs realpath)
build_dir="${build_root}/linux_net_build"
out_dir="${build_dir}/out"
iso_out_dir=$build_root

# make build dir
if [ ! -d $build_dir ]
then
    mkdir $build_dir
    mkdir $build_dir/system
    mkdir $out_dir
    mkdir $out_dir/isolinux
fi


pushd $build_dir > /dev/null

# get sources
cp $source_root/isolinux.cfg $build_dir

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

# build linux
if [ ! -f $out_dir/isolinux/vmlinuz ]
then
    echo "Build kernel"
    pushd $kernel_dir > /dev/null
    make mrproper
    cp $source_root/default.config .config
    make -j$(nproc)
    cp arch/x86/boot/bzImage $out_dir/isolinux/vmlinuz
    popd > /dev/null
fi 

# build init and initrd
echo "Build init"
pushd $busybox_dir > /dev/null
    cp $source_root/busybox.config .config
    make -j$(nproc)
popd > /dev/null

cp $busybox_dir/busybox system/busybox

pushd system > /dev/null
strip busybox
mkdir -p bin
mv busybox bin
for e in $(./bin/busybox --list);
do
    ln -sf busybox ./bin/$e
done

ln -sf bin sbin

mkdir -p etc/init.d

cat > etc/init.d/rcS << EOF
#!/bin/sh
mkdir /proc
mount -t proc none /proc
echo hello world

while :
do
  sleep 1000 # loop infinitely
done
EOF

chmod 777 etc/init.d/rcS

find . | cpio -o -H newc | gzip - > $out_dir/isolinux/initrd.gz
popd > /dev/null

# get isolinux
pushd $syslinux_dir > /dev/null
cp bios/core/isolinux.bin $out_dir/isolinux/isolinux.bin
cp bios/com32/elflink/ldlinux/ldlinux.c32 $out_dir/isolinux/ldlinux.c32
cp $build_dir/isolinux.cfg $out_dir/isolinux/isolinux.cfg
popd > /dev/null


# make iso
echo "Make iso"
mkisofs -R -l -L -D \
        -b isolinux/isolinux.bin \
        -c isolinux/boot.cat \
        -input-charset ascii \
        -no-emul-boot -boot-load-size 4 \
        -boot-info-table \
        -V NET \
        $out_dir \
        > $iso_out_dir/net.iso

popd > /dev/null
