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

installkernel() {
    instmods squashfs overlay
}

install() {
    echo "installing darch2"
    #inst_script "$moddir/live-darch.sh" "/sbin/live-darch"
    inst_hook cmdline 29 "$moddir/parse-darch.sh"
    inst_script "$moddir/rundarch.sh" "/sbin/rundarch"
    inst_hook pre-udev 30 "$moddir/darch-genrules.sh"

    echo "rd.shell" > ${initdir}/etc/cmdline.d/00-darch.conf
    echo "rd.debug" >> ${initdir}/etc/cmdline.d/00-darch.conf
    echo "rd.retry=10" >> ${initdir}/etc/cmdline.d/00-darch.conf
    dracut_need_initqueue   
}
