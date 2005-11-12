#-
# Copyright (c) 2004-2005 FreeBSD GNOME Team <freebsd-gnome@FreeBSD.org>
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
# 1. Redistributions of source code must retain the above copyright
#	notice, this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright
#	notice, this list of conditions and the following disclaimer in the
#	documentation and/or other materials provided with the distribution.
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
# $MCom: portstools/tinderbox/lib/tinderlib.sh,v 1.20 2005/11/12 21:23:14 ade Exp $
#

tinderEcho () {
    echo "$1" | /usr/bin/fmt 75 79
}

tinderExit () {
    tinderEcho "$1"

    if [ -n "$2" ] ; then
	exit $2
    else
	exit 255
    fi
}

killMountProcesses () {
    dir=$1

    pids="XXX"
    while [ ! -z "${pids}" ]; do
	pids=$(fstat -f "${dir}" | tail +2 | awk '{print $3}' | sort -u)

	if [ ! -z "${pids}" ]; then
	    echo "Killing off pids in ${dir}"
	    ps -p ${pids}
	    kill -KILL ${pids} 2> /dev/null
	    sleep 2
	fi
    done
}

cleanupMount () {
    mount=$1

    if [ -d ${mount} ] ; then
	if [ $(fstat -f ${mount} | wc -l) -gt 1 ] ; then
	    killMountProcesses ${mount}
	fi
	umount ${mount} || echo "Cleanup of ${chroot}${mount} failed!"
    fi
}

cleanupMounts () {
    _build=""
    _jail=""
    _portstree=""
    _destination=""
    _ARCH=${ARCH:=$(uname -m)}

    while getopts d:b:p:j: OPT
    do
	case ${OPT} in

	d)	  _destination=${OPTARG};;
	b)	  _build=${OPTARG};;
	p)	  _portstree=${OPTARG};;
	j)	  _jail=${OPTARG};;

	esac
    done

    case ${_destination} in

    jail)	if [ -z "${_jail}" ] ; then
		    echo "jail has to be filled!" >&2
		    return 1
		fi
		_destination=${pb}/jails/${_jail}
		;;

    portstree)	if [ -z "${_portstree}" ] ; then
		    echo "portstree has to be filled!" >&2
		    return 1
		fi
		_destination=${pb}/portstrees/${_portstree}
		;;

    build)	if [ -z "${_build}" ] ; then
		    echo "build has to be filled!" >&2
		    return 1
		fi
		_destination=${pb}/${_build}
		if [ "${_ARCH}" = "i386" -o "${_ARCH}" = "amd64" ] ; then
		    umount -f ${_destination}/compat/linux/proc >/dev/null 2>&1
		fi
		;;

    distcache)	if [ -z "${_build}" ] ; then
		    echo "build has to be filled!" >&2
		    return 1
		fi
		_destination=${pb}/${_build}/distcache
		;;

    *)		echo "unknown destination type!"
		return 1
		;;

    esac

    df | grep ' '${_destination}'[/$]' | sed 's|.* ||g' | sort -r | \
   	while read mountpoint ; do
	    cleanupMount ${mountpoint}
	done

    return 0
}

requestMount () {
    _source=""
    _destination=""
    _nullfs=0
    _readonly=0
    _build=""
    _jail=""
    _portstree=""
    _fq_source=0
    _quiet=0
    _ccache_dir=${CCACHE_DIR:=/ccache}
    _nullfs=0

    while getopts qnrs:d:b:p:j: OPT
    do
	case ${OPT} in

	n)	_nullfs=1;;
	r)	_readonly=1;;
	s)	_source=${OPTARG};;
	d)	_destination=${OPTARG};;
	b)	_build=${OPTARG};;
	p)	_portstree=${OPTARG};;
	j)	_jail=${OPTARG};;
	q)	_quiet=1;;

	esac
    done

    case ${_destination} in

    jail)	if [ -z "${_jail}" ] ; then
		    echo "jail has to be filled!" >&2
		    return 1
		fi
		_destination=${pb}/jails/${_jail}/src
		if [ -z "${_source}" ] ; then
		    _source=$(${pb}/scripts/tc getSrcMount -j ${_jail})
		fi
		_fq_source=1
		;;

    portstree)	if [ -z "${_portstree}" ] ; then
		    echo "portstree has to be filled!" >&2
		    return 1
		fi
		_destination=${pb}/portstrees/${_portstree}/ports
		if [ -z "${_source}" ] ; then
		    _source=$(${pb}/scripts/tc getPortsMount -p ${_portstree})
		fi
		_fq_source=1
		;;

    buildsrc)	if [ -z "${_build}" ] ; then
		    echo "build has to be filled!" >&2
		    return 1
		fi
		_jail=$(${pb}/scripts/tc getJailForBuild -b ${_build})
		_destination=${pb}/${_build}/usr/src
		if [ -z "${_source}" ] ; then
		    _source=$(${pb}/scripts/tc getSrcMount -j ${_jail})
		    if [ -z "${_source}" ] ; then
			_source=${_source:=${pb}/jails/${_jail}/src}
		    else
			_fq_source=1
		    fi
		fi
		;;

    buildports)	if [ -z "${_build}" ] ; then
		    echo "build has to be filled!" >&2
		    return 1
		fi
		_portstree=$(${pb}/scripts/tc getPortsTreeForBuild -b ${_build})
		_destination=${pb}/${_build}/a/ports
		if [ -z "${_source}" ] ; then
		    _source=$(${pb}/scripts/tc getPortsMount -p ${_portstree})
		    if [ -z "${_source}" ] ; then
			_source=${_source:=${pb}/portstrees/${_portstree}/ports}
		    else
			_fq_source=1
		    fi
		fi
		;;

    distcache)	_destination=${pb}/${_build}/distcache
		_fq_source=1
		;;

    ccache)	_destination=${pb}/${_build}/${_ccache_dir}
		;;

    *)		echo "unknown destination type!"
		return 1
		;;

    esac

    if [ -z "${_source}" ] ; then
	[ ${_quiet} -ne 1 ] && echo "source has to be filled!" >&2
	return 1
    fi

    if [ -z "${_destination}" ] ; then
	echo "destination has to be filled!" >&2
	return 1
    fi

    # is the filesystem already mounted?
    filesystem=$(df ${_destination} | awk '{a=$1}  END {print a}')
    mountpoint=$(df ${_destination} | awk '{a=$NF} END {print a}')

    if [ "${filesystem}" = "${_source}" -a \
	 "${mountpoint}" = "${_destination}" ] ; then
	return 0
    fi

    # is _nullfs mount specified?
    if [ ${_nullfs} -eq 1 -a ${_fq_source} -ne 1 ] ; then
	_options="-t nullfs"
    else
	# it probably has to be a nfs mount then
	# lets check what kind of _source we have. If it is allready in
	# a nfs format, we don't need to adjust anything
	case ${_source} in

	[a-zA-Z0-9\.-_]*:/*)
		_options="-o nfsv3,intr"
		;;

	*)
		if [ ${_fq_source} -eq 1 ] ; then
		    # some _source's are full qualified sources, means
		    # don't try to detect sth. or fallback to localhost.
		    # The user wants exactly what he specified as _source
		    # don't modify anything. If it's not a nfs mount, it has
		    # to be a nullfs mount.
		    _options="-t nullfs"
		else
		    _options="-o nfsv3,intr"

		    # find out the filesystem the requested source is in
		    filesystem=$(df ${_source} | awk '{a=$1}  END {print a}')
		    mountpoint=$(df ${_source} | awk '{a=$NF} END {print a}')
		    # determine if the filesystem the requested source
		    # is a nfs mount, or a local filesystem

		    case ${filesystem} in

		    [a-zA-Z0-9\.-_]*:/*)
			# maybe our destination is a subdirectory of the
			# mountpoint and not the mountpoint itself.
			# if that is the case, add the subdir to the mountpoint
			_source="${filesystem}/$(echo $_source | \
					sed 's|'${mountpoint}'||')"
			;;

		    *)
			# not a nfs mount, nullfs not specified, so
			# mount it as nfs from localhost
			_source="localhost:/${_source}"
			;;

		    esac

		fi
		;;
	esac
    fi

    if [ ${_readonly} -eq 1 ] ; then
	options="${_options} -r"
    fi

    # Sanity check, and make sure the destination directory exists
    if [ ! -d ${_destination} ]; then
	mkdir -p ${_destination}
    fi

    mount ${_options} ${_source} ${_destination}
    return ${?}
}

buildenvlist () {
    jail=$1
    portstree=$2
    build=$3

    ${pb}/scripts/tc configGet

    cat ${pb}/scripts/lib/tinderbox.env

    if [ -n "${jail}" ]; then
	cat ${pb}/jails/${jail}/jail.env 2>/dev/null
    fi
    if [ -n "${portstree}" ]; then
	cat ${pb}/portstrees/${portstree}/portstree.env 2>/dev/null
    fi
    if [ -n "${build}" ]; then
	cat ${pb}/builds/${build}/build.env 2>/dev/null
    fi
}

buildenv () {
    jail=$1
    portstree=$2
    build=$3

    major_version=$(echo ${jail} | sed -E -e 's|(^.).*$|\1|')
    save_IFS=${IFS}
    IFS='
'

    for _tb_var in `buildenvlist "${jail} "${portstree}" "${build}"`
    do
	var=$(echo ${_tb_var} | sed \
		-e "s|^#${major_version}||; \
		    s|##PB##|${pb}|g; \
		    s|##BUILD##|${build}|g; \
		    s|##JAIL##|${jail}|g; \
		    s|##PORTSTREE##|${portstree}|g" \
		-E -e 's|\^\^([^\^]+)\^\^|${\1}|g')
	eval "export ${var}" >/dev/null 2>&1
    done

    IFS=${save_IFS}

    # One final tweak that we can't easily handle with a file
    eval "unset DISPLAY" >/dev/null 2>&1
}

getDbDriver () {
    db_drivers="mysql pgsql"
    finished=0
    db_driver=""

    while [ ${finished} != 1 ]; do
        read -p "Enter database driver (${db_drivers}): " db_driver

	if echo ${db_drivers} | grep -qw "${db_driver}"; then
	    finished=1
	else
	    echo 1>&2 "Invalid database driver, ${db_driver}."
	fi
    done

    echo ${db_driver}
}

getDbInfo () {
    db_driver=$1

    db_host=""
    db_name=""
    db_admin=""

    read -p "Does this host have access to connect to the Tinderbox database as a database administrator? (y/n)" option

    finished=0
    while [ ${finished} != 1 ]; do
        case "${option}" in
            [Yy]|[Yy][Ee][Ss])
	        read -p "Enter database admin user [root]: " db_admin
                read -p "Enter database host [localhost]: " db_host
	        read -p "Enter database name [tinderbox]: " db_name
	        ;;
            *)
	        return 1
	        ;;
        esac

	db_admin=${db_admin:-"root"}
	db_host=${db_host:-"localhost"}
	db_name=${db_name:-"tinderbox"}

	echo 1>&2 "Are these settings corrrect:"
	echo 1>&2 "    Database Administrative User : ${db_admin}"
	echo 1>&2 "    Database Host                : ${db_host}"
	echo 1>&2 "    Database Name                : ${db_name}"
	read -p "(y/n)" option

	case "${option}" in
	    [Yy]|[Yy][Ee][Ss])
	        finished=1
		;;
        esac
	option="YES"
    done

    echo "${db_admin}:${db_host}:${db_name}"

    return 0
}

loadSchema () {
    schema_file=$1
    db_driver=$2
    db_admin=$3
    db_host=$4
    db_name=$5

    MYSQL_LOAD='/usr/local/bin/mysql -u${db_admin} -p -h ${db_host} ${db_name} < "${schema_file}"'
    MYSQL_LOAD_PROMPT='echo "The next prompt will be for ${db_admin}'"'"'s password to the ${db_name} database." | /usr/bin/fmt 75 79'

    PGSQL_LOAD='/usr/local/bin/psql -U ${db_admin} -W -h ${db_host} -d ${db_name} < "${schema_file}"'
    PGSQL_LOAD_PROMPT='echo "The next prompt will be for ${db_admin}'"'"'s password to the ${db_name} database." | /usr/bin/fmt 75 79'

    rc=0
    case "${db_driver}" in
	mysql)
	    eval ${MYSQL_LOAD_PROMPT}
	    eval ${MYSQL_LOAD}
	    rc=$?
	    ;;
	pgsql)
	    eval ${PGSQL_LOAD_PROMPT}
	    eval ${PGSQL_LOAD}
	    rc=$?
	    ;;
	*)
	    echo "Unsupported database driver: ${db_driver}"
	    return 1
	    ;;
    esac

    return ${rc}
}

checkPreReqs () {
    reqs="$@"
    error=0
    missing=""

    for r in ${reqs} ; do
	if [ -z $(pkg_info -Q -O ${r}) ]; then
	    missing="${missing} ${r}"
	    error=1
	fi
    done

    echo "${missing}"

    return ${error}
}

migDb () {
    do_load=$1
    db_driver=$2
    db_host=$3
    db_name=$4
    mig_file=${pb}/scripts/upgrade/mig_${db_driver}_tinderbox-${MIG_VERSION_FROM}_to_${MIG_VERSION_TO}.sql

    if [ -s "${mig_file}" ]; then
	if [ ${do_load} = 1 ]; then
	    tinderEcho "INFO: Migrating database schema from ${MIG_VERSION_FROM} to ${MIG_VERSION_TO} ..."
	    if ! loadSchema "${mig_file}" ${db_driver} ${db_host} ${db_name} ; then
	        tinderEcho "ERROR: Failed to load upgrade database schema."
	        return 2
	    fi
	    tinderEcho "DONE."
	else
	    tinderEcho "WARN: You must load ${mig_file} to complete your upgrade."
	fi
    else
	return 1
    fi

    return 0
}
