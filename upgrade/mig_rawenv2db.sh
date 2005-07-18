#!/bin/sh

pb=$0
[ -z "$(echo "${pb}" | sed 's![^/]!!g')" ] && \
pb=$(type "$pb" | sed 's/^.* //g')
pb=$(realpath $(dirname $pb))
pb=${pb%%/scripts}


call_tc() {
	echo "INFO: calling ${pb}/scripts/tc $@"
	${pb}/scripts/tc "$@"
}

mig_rawenv2db() {

	rawenv="${1}"
	
	if [ ! -s "${rawenv}" ] ; then
		return 0
	else

		while read line ; do
			var=${line%=*}
			value=$( echo ${line#*=} | sed 's/"//g')

			case "${var}" in
				CCACHE_ENABLED)		call_tc configCcache -e;;
				CCACHE_DIR)		call_tc configCcache -c "${value}";;
				CCACHE_MAX_SIZE)	call_tc configCcache -s "${value}";;
				CCACHE_LOGFILE)		call_tc configCcache -l "${value}";;
				DISTFILE_CACHE)		call_tc configDistfile -c "${value}";;
				\#TINDERD_SLEEPTIME)	call_tc configTinderd -t "${value}";;
				\#MOUNT_PORTSTREE*)	name=${var#*_*_}
							call_tc setPortsMount -p "${name}" -m "${value}";;
				\#MOUNT_JAIL*)		name=${var#*_*_}
							call_tc setSrcMount -j "${name}" -m "${value}";;
			esac
		done < "${rawenv}"
	fi
	
}

mig_rawenv2db "${pb}/scripts/rawenv"
