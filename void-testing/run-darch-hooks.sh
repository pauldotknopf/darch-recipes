#!/bin/sh

# Load some common helper commands.
type getarg >/dev/null 2>&1 || . /lib/dracut-lib.sh
command -v unpack_archive >/dev/null || . /lib/img-lib.sh

set -x

[ -z "$darch_dir" ] && darch_dir=$(getarg darch_dir=)
[ -z "$darch_rootfs" ] && darch_rootfs=$(getarch darch_rootfs)
darch_dir_path=`echo $darch_dir | sed 's/.*\://g'`
darch_dir_device=`echo $darch_dir | sed 's/:.*//'`

darch_hooks_dir="/run/initramfs/live${darch_dir_path}/hooks"

warn "running hooks in $darch_hooks_dir"
emergency_shell

if [ -e "$darch_hooks_dir" ]; then
    for hook_dir in $darch_hooks_dir/*; do
        hook_name=`basename ${hook_dir}`
        export DARCH_ROOT_FS="/run/rootfsbase"
        export DARCH_HOOK_DIR="${darch_hooks_dir}/${hook_name}"

        warn "running hook $hook_name"
        emergency_shell

        /bin/bash -c ". $DARCH_HOOK_DIR/hook && run"
    done
fi

warn "finished running hooks"
emergency_shell