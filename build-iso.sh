#!/bin/bash

init=runit
chroot_dir="/var/lib/artools/buildiso/base/artix/rootfs"


_set_color() {
    if [ -t 1 ]; then
        RED=$(printf '\033[31m')
        GREEN=$(printf '\033[32m')
        YELLOW=$(printf '\033[33m')
        BLUE=$(printf '\033[34m')
        BOLD=$(printf '\033[1m')
        RESET=$(printf '\033[m')
    else
        RED=""
        GREEN=""
        YELLOW=""
        BLUE=""
        BOLD=""
        RESET=""
    fi
}

## Show an INFO message...
_msg_info() {
    local _subject="${1}"
    local _msg="${2}"
    printf '%s[%s] INFO: %s\n' "${YELLOW}${BOLD}" "${_subject}" "${RESET}${BOLD}${_msg}${RESET}"
}

## Customize installation.
_make_customize_chroot() {
    _msg_info "ARTIX-CHROOT" "Running customize_chroot.sh in '${chroot_dir}' chroot..."
    chmod +x "${chroot_dir}/root/customize_chroot.sh"
    artix-chroot "${chroot_dir}" "/root/customize_chroot.sh"
    rm -f "${chroot_dir}/root/customize_chroot.sh"
    _msg_info "ARTIX-CHROOT" "Done! customize_chroot.sh run successfully..."
}

_set_color
trap "" EXIT
buildiso -i $init -p base -x

## Check if `customize_chroot.sh` exists.
if [[ -e $(pwd)/base/root-overlay/root/customize_chroot.sh ]]; then
    _make_customize_chroot
fi


buildiso -i $init -p base -sc
buildiso -i $init -p base -bc
buildiso -i $init -p base -zc || exit 1
