#!/bin/sh

# Change this next line.
MAINTAINER="wxs@FreeBSD.org"

maint=$(make -C ${CHROOT}/a/ports/${PORTDIR} maintainer)
if [ ${maint} = ${MAINTAINER} ]; then
    echo "FORCE_MAKE_JOBS=yes" >> ${CHROOT}/etc/make.conf
fi
