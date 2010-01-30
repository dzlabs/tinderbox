#!/bin/sh
#
# $MCom: portstools/tinderbox/contrib/hooks/compress_wrkdir/compress_wrkdir.sh,v 1.2 2010/01/30 15:05:56 itetcu Exp $
#
# If installed as a postPortBuild Hook, it will compress the WRKDIR. Since this
# is a time consuming job, by default it only compresses it for failed builds.
# If you want to compress all the WRKDIRs, uncomment COMPRESS_ALL bellow.
# If you don't change the path, tindy's WebUI will show a link to the tarball.
# If you un-comment DELETE_OLD, and the build was succesful an existing tarball
# corresponding to the current PKGNAME will be deleted.

#COMPRESS_ALL=true
#DELETE_OLD=true

compress_wrkdir () {
  mkdir -p "${PB}/wrkdirs/${BUILD}" && \
  cd ${PB}/${BUILD}/a/ports/${PORTDIR} && objdir=$(make -V WRKDIR) && \
  objdir=`echo ${objdir} | sed "s,${PB}/${BUILD}/,${PB}/${BUILD}/work/,"` && \
  tar cfjC ${PB}/wrkdirs/${BUILD}/${PACKAGE_NAME}.tbz ${objdir}/.. work &&
  return 0
}

if [ "${STATUS}" = "SUCCESS" ]; then
  if [ -n "${DELETE_OLD}" ]; then
    rm ${PB}/wrkdirs/${BUILD}/${PACKAGE_NAME}.tbz
  fi
  if [ -n "${COMPRESS_ALL}" ]; then
    compress_wrkdir
  fi
elif [ "${STATUS}" != "DUD" ]; then
  compress_wrkdir
fi
