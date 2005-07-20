#!/bin/sh
#-
# Copyright (c) 2004-2005 FreeBSD GNOME Team <freebsd-gnome@FreeBSD.org>
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
# 1. Redistributions of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in the
#    documentation and/or other materials provided with the distribution.
#
# THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ``AS IS'' AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
# OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
# HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
# LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
# OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
# SUCH DAMAGE.
#
# $MCom: portstools/tinderbox/upgrade/mig_shlib.sh,v 1.10 2005/07/20 16:20:31 marcus Exp $
#

pb=$0
[ -z "$(echo "${pb}" | sed 's![^/]!!g')" ] && \
pb=$(type "$pb" | sed 's/^.* //g')
pb=$(realpath $(dirname $pb))
pb=${pb%%/scripts}

. ${pb}/scripts/lib/setup_shlib.sh

mig_rawenv() {

	rawenv=$1
	tinder_echo "INFO: Migrating ${rawenv} ..."

	if [ ! -f "${rawenv}" ] ; then
		tinder_echo "INFO: ${rawenv} does not exist."
	else
	    	first_line=$(head -1 "${rawenv}")

		if [ x"${first_line}" = x"${RAWNEV_HEADER}" ]; then
		    	return 0
		fi


		while read line ; do
			var=${line%=*}
			value=$(echo ${line#*=} | sed 's/"//g')

			case "${var}" in
				CCACHE_ENABLED)		call_tc configCcache -e;;
				CCACHE_DIR)		call_tc configCcache -c "${value}";;
				CCACHE_MAX_SIZE)	call_tc configCcache -s "${value}";;
				CCACHE_LOGFILE)		call_tc configCcache -l "${value}";;
				CCACHE_JAIL)		call_tc configCcache -j;;
				DISTFILE_CACHE)		call_tc configDistfile -c "${value}";;
				\#TINDERD_SLEEPTIME)	call_tc configTinderd -t "${value}";;
				\#MOUNT_PORTSTREE*)	name=${var#*_*_}
							call_tc setPortsMount -p "${name}" -m "${value}";;
				\#MOUNT_JAIL*)		name=${var#*_*_}
							call_tc setSrcMount -j "${name}" -m "${value}";;
			esac
		done < "${rawenv}"

		cp -p "${rawenv}" "${rawenv}.bak"
		rm -f "${rawenv}"

	fi
	tinder_echo "DONE."
	return 0
}

mig_db() {
    do_load=$1
    db_host=$2
    db_name=$3
    mig_file=${pb}/scripts/upgrade/mig_tinderbox-${MIG_VERSION_FROM}_to_${MIG_VERSION_TO}.sql

    if [ -s "${mig_file}" ]; then
	if [ ${do_load} = 1 ]; then
	    tinder_echo "INFO: Migrating database schema from ${MIG_VERSION_FROM} to ${MIG_VERSION_TO} ..."
	    if ! load_schema "${mig_file}" ${db_host} ${db_name} ; then
	        tinder_echo "ERROR: Failed to load upgrade database schema."
	        return 2
	    fi
	    tinder_echo "DONE."
	else
	    tinder_echo "WARN: You must load ${mig_file} to complete your upgrade."
	fi
    else
	return 1
    fi

    return 0
}

mig_files() {
    rawenv=$1

    tinder_echo "INFO: Migrating files ..."

    if [ ! -f "${rawenv}.dist" ] ; then
        tinder_echo "ERROR: ${rawenv}.dist does not exist!"
	return 1
    else
        if [ ! -f "${rawenv}" ]; then
            cp "${rawenv}.dist" "${rawenv}"
        else
            if ! cmp -s "${rawenv}.dist" "${rawenv}" ; then
                cp -p "${rawenv}" "${rawenv}.bak"
               cp "${rawenv}.dist" "${rawenv}"
            fi
        fi
    fi

    for d in ${REMOVE_FILES} ; do
	rm -f ${d}
    done

    tinder_echo "DONE."

    return 0
}
