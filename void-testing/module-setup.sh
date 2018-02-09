#!/bin/bash

# called by dracut
check() {
    echo "checking..."
    return 0
}

depends() {
    echo lvm dmsquash-live
    return 0
}

install() {
    set -x

    inst_multiple bash basename env

    echo "installing darch3"
    # Parse the "darch_dir" commands and set "root=live:" to trigger the dmsquash-live handlers
    inst_hook cmdline 29 "$moddir/parse-darch.sh"
    # We are overriding the file put by dmsquash-live, so that we can
    # mount the squash file using our method
    rm "${initdir}/sbin/dmsquash-live-root"
    inst_script "$moddir/live-darch.sh" "/sbin/dmsquash-live-root"
    # Install script to run hooks before chrooting.
    inst_hook pre-pivot 20 "$moddir/run-darch-hooks.sh"

    echo "rd.shell" > ${initdir}/etc/cmdline.d/00-darch.conf
    echo "rd.debug" >> ${initdir}/etc/cmdline.d/00-darch.conf
    echo "rd.retry=10" >> ${initdir}/etc/cmdline.d/00-darch.conf 
}
