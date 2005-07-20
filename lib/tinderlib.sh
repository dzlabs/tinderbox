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
# $MCom: portstools/tinderbox/lib/tinderlib.sh,v 1.13 2005/07/20 03:51:07 marcus Exp $
#

kill_procs()
{
	dir=$1

	pids="XXX"
	while [ ! -z "${pids}" ]; do
		pids=$(fstat -f "$dir" | tail +2 | awk '{print $3}' | sort -u)
		if [ ! -z "${pids}" ]; then
			echo "Killing off pids in ${dir}"
			ps -p $pids
			kill -KILL ${pids} 2> /dev/null
			sleep 2
		fi
	done
}

cleanup_mount() {
	mount=$1

	if [ -d ${mount} ] ; then
		if [ $(fstat -f ${mount} | wc -l) -gt 1 ] ; then
			kill_procs ${mount}
		fi
		umount ${mount} || echo "Cleanup of ${chroot}${mount} failed!"
	fi
}

cleanup_mounts() {

	_build=
	_jail=
	_portstree=
	_destination=

	_ARCH=${ARCH:=$(uname -m)}

	_pb=${pb:=/space}
	# Just in case /space is a symlink
	_pb=$(realpath ${_pb})

	while getopts d:b:p:j: OPT ; do
		case ${OPT} in
			d)	  _destination=${OPTARG}
				;;
			b)	  _build=${OPTARG}
				;;
			p)	  _portstree=${OPTARG}
				;;
			j)	  _jail=${OPTARG}
				;;
		esac
	done

	case ${_destination} in
		jail)
			if [ -z "${_jail}" ] ; then
				echo "jail has to be filled!" >&2
				return 1
			fi
			_destination=${_pb}/jails/${_jail}
			;;
		portstree)
			if [ -z "${_portstree}" ] ; then
				echo "portstree has to be filled!" >&2
				return 1
			fi
			_destination=${_pb}/portstrees/${_portstree}
			;;
		build)
			if [ -z "${_build}" ] ; then
				echo "build has to be filled!" >&2
				return 1
			fi
			_destination=${_pb}/${_build}
			if [ "${_ARCH}" = "i386" ] ; then
				umount -f ${_destination}/compat/linux/proc >/dev/null 2>&1
			fi
			;;
		distcache)
			if [ -z "${_build}" ] ; then
				echo "build has to be filled!" >&2
				return 1
			fi
			_destination=${_pb}/${_build}/distcache
			;;
		*)	  echo "unknown destination type!"
			return 1
			;;
	esac

	df | grep ' '${_destination}'[/$]' | sed 's|.* ||g' | sort -r | while read mountpoint ; do
		cleanup_mount ${mountpoint}
	done

	return 0
}

request_mount() {

	_source=
	_destination=
	_nullfs=0
	_readonly=0
	_build=
	_jail=
	_portstree=
	_fq_source=0
	_quiet=0

	_pb=${pb:=/space}
	# Just in case /space is a symlink
	_pb=$(realpath ${_pb})
	_ccache_dir=${CCACHE_DIR:=/ccache}

	_nullfs=0

	while getopts qnrs:d:b:p:j: OPT ; do
		case ${OPT} in
			n)	_nullfs=1
				;;
			r)	_readonly=1
				;;
			s)	_source=${OPTARG}
				;;
			d)	_destination=${OPTARG}
				;;
			b)	_build=${OPTARG}
				;;
			p)	_portstree=${OPTARG}
				;;
			j)	_jail=${OPTARG}
				;;
			q)	_quiet=1
				;;
		esac
	done

	case ${_destination} in
		jail)
			if [ -z "${_jail}" ] ; then
				echo "jail has to be filled!" >&2
				return 1
			fi
			_destination=${_pb}/jails/${_jail}/src
			if [ -z "${_source}" ] ; then
				_source=$(${_pb}/scripts/tc getSrcMount -j ${_jail})
			fi
			_fq_source=1
			;;
		portstree)
			if [ -z "${_portstree}" ] ; then
				echo "portstree has to be filled!" >&2
				return 1
			fi
			_destination=${_pb}/portstrees/${_portstree}/ports
			if [ -z "${_source}" ] ; then
				_source=$(${_pb}/scripts/tc getPortsMount -p ${_portstree})
			fi
			_fq_source=1
			;;
		buildsrc)
			if [ -z "${_build}" ] ; then
				echo "build has to be filled!" >&2
				return 1
			fi
			_jail=$(${_pb}/scripts/tc getJailForBuild -b ${_build})
			_destination=${_pb}/${_build}/usr/src
			if [ -z "${_source}" ] ; then
				_source=$(${_pb}/scripts/tc getSrcMount -j ${_jail})
				if [ -z "${_source}" ] ; then
					_source=${_source:=${_pb}/jails/${_jail}/src}
				else
					_fq_source=1
				fi
			fi
			;;
		buildports)
			if [ -z "${_build}" ] ; then
				echo "build has to be filled!" >&2
				return 1
			fi
			_portstree=$(${_pb}/scripts/tc getPortsTreeForBuild -b ${_build})
			_destination=${_pb}/${_build}/a/ports
			if [ -z "${_source}" ] ; then
				_source=$(${_pb}/scripts/tc getPortsMount -p ${_portstree})
				if [ -z "${_source}" ] ; then
					_source=${_source:=${_pb}/portstrees/${_portstree}/ports}
				else
					_fq_source=1
				fi
			fi
			;;
		distcache)
			_destination=${_pb}/${_build}/distcache
			_fq_source=1
			;;
		ccache)
			_destination=${_pb}/${_build}/${_ccache_dir}
			;;
		*)	echo "unknown destination type!"
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
	if [ "${filesystem}" = "${_source}" -a "${mountpoint}" = "${_destination}" ] ; then
		return 0
	fi

	# is _nullfs mount specified?
	if [ ${_nullfs} -eq 1 ] ; then
		_options="-t nullfs"
	else # it probably has to be a nfs mount then
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
							# maybe our destination is a subdirectory of the mountpoint
							# and not the mountpoint itself
							# if that is the case, add the subdir to the mountpoint (sed)
							_source="${filesystem}/$(echo $_source | sed 's|'${mountpoint}'||')"
							;;
						*)
							# not a nfs mount, nullfs not specified - mount it as nfs
							# from localhost
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

	mount ${_options} ${_source} ${_destination}

	return ${?}
}

buildenv () {
	pb=$1
	build=$2
	jail=$3
	portstree=$4

	major_version=$(echo ${jail} | sed -E -e 's|(^.).*$|\1|')

	save_IFS=${IFS}
	IFS='
'
	for _tb_var in `cat ${pb}/scripts/rawenv ; ${pb}/scripts/tc configGet`; do
		var=$(echo ${_tb_var} | sed \
			-e "s|^#${major_version}||; \
			    s|##PB##|${pb}|g; \
			    s|##BUILD##|${build}|g; \
			    s|##JAIL##|${jail}|g; \
			    s|##PORTSTREE##|${portstree}|g" \
			-E -e 's|\^\^([^\^]+)\^\^|${\1}|g')
		eval "export ${var}" > /dev/null 2>&1
	done

	IFS=${save_IFS}
}
