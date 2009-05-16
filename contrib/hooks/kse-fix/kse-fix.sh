#!/bin/sh

major_version=$(echo ${JAIL} | sed -E -e 's|(^.).*$|\1|')
if [ ${major_version} -lt 7 ]; then
    cp ${PB}/patches/libmap.conf ${CHROOT}/etc
fi
