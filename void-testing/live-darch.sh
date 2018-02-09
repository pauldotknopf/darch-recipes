#!/bin/bash

set -x

# Load some common helper commands.
type getarg >/dev/null 2>&1 || . /lib/dracut-lib.sh
command -v unpack_archive >/dev/null || . /lib/img-lib.sh

warn "running live-darch.sh"
emergency_shell

[ -z "$darch_dir" ] && darch_dir=$(getarg darch_dir=)
[ -z "$darch_rootfs" ] && darch_rootfs=$(getarch darch_rootfs)
darch_dir_path=`echo $darch_dir | sed 's/.*\://g'`
darch_dir_device=`echo $darch_dir | sed 's/:.*//'`

warn "parsed"
emergency_shell

[ -z "$1" ] && exit 1
livedev="$1"

warn "livedevice: $livedev"
warn "darch_dir_path: $darch_dir_path"
warn "darch_dir_device: $darch_dir_device"
warn "darch_rootfs: $darch_rootfs"

warn "parsed"
emergency_shell

ln -s $livedev /run/initramfs/livedev

mkdir -m 0755 -p /run/initramfs/live

warn "going to mount"
emergency_shell

mount -n $livedev /run/initramfs/live
if [ "$?" != "0" ]; then
    warn "Failed to mount block device of live image. Try to mount source to /run/initramfs."
    emergency_shell
fi

warn "mounted"
emergency_shell

squashfs_file="/run/initramfs/live${darch_dir_path}/${darch_rootfs}"

if [ ! -e $squashfs_file ]; then
    warn "Squashfs file doesn't exist at $squashfs_file."
    emergency_shell
fi

mkdir /run/rootfsbase
mkdir /run/initramfs/squashro
mkdir /run/initramfs/squashrw

modprobe squashfs
modprobe overlay

mount -t squashfs "${squashfs_file}" /run/initramfs/squashro

if [ "$?" != "0" ]; then
    warn "Failed to mount $squashfs_file to /run/initramfs/squashro"
    emergency_shell
fi

mount -t tmpfs -o rw,noatime,mode=755 tmpfs /run/initramfs/squashrw
mkdir -p /run/initramfs/squashrw/upperdir /run/initramfs/squashrw/work
mount -t overlay overlay -o "lowerdir=/run/initramfs/squashro,upperdir=/run/initramfs/squashrw/upperdir,workdir=/run/initramfs/squashrw/work" "/run/rootfsbase"

if [ "$?" != "0" ]; then
    warn "Failed to mount overlay to /run/rootfsbase"
    emergency_shell
fi