#!/bin/sh

info "running parse commands"

[ -z "$darch_dir" ] && darch_dir=$(getarg darch_dir=)

[ -z "$darch_rootfs"] && darch_rootfs=$(getarch darch_rootfs)

warn "darch_dir is $darch_dir"
warn "darch rootfs is $darch_rootfs"

darch_dir_path=`echo $darch_dir | sed 's/.*\://g'`
darch_dir_device=`echo $darch_dir | sed 's/:.*//'`

warn "darch_dir_path is $darch_dir_path"
warn "darch_dir_device is $darch_dir_device"

#exit 1

root=$darch_dir_device
#rd.live.dir=${darch_dir_path#/}
#rd.live.squashimg=$darch_rootfs

warn "new root is $root"
