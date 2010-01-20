#!/bin/sh
#
# $MCom: portstools/tinderbox/contrib/hooks/compress_wrkdir/compress_wrkdir.sh,v 1.1 2010/01/20 23:58:25 itetcu Exp $
#
# If installed as a postPortBuild Hook, it will compress the wrkdir. Since this
# is a time consuming job, by default it only compresses it for failed builds.
# If you want to compress all the wrkdirs, uncomment COMPRESS_ALL bellow.
# If you don't change the path, tindy's WebUI will show a link to the tarball.

#COMPRESS_ALL=true

if [ "${STATUS}" != "SUCCESS" -o -n "${COMPRESS_ALL}" ]; then
  if [ "${STATUS}" != "DUD" ]; then
    mkdir -p "${PB}/wrkdirs/${BUILD}" && \
    cd ${TBROOT}/${BUILD}/a/ports/${PORTDIR} && objdir=$(make -V WRKDIR) && \
    objdir=`echo ${objdir} | sed "s,${TBROOT}/${BUILD}/,${TBROOT}/${BUILD}/work/,"` && \
    tar cfjC ${TBROOT}/wrkdirs/${BUILD}/${PACKAGE_NAME}.tbz ${objdir}/.. work
  fi
fi

