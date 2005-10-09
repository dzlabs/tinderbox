#!/bin/sh
#
# Copyright (c) 2005 FreeBSD GNOME Team <freebsd-gnome@FreeBSD.org>
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
# $MCom: portstools/tinderbox/lib/tc_command.sh,v 1.6 2005/10/09 05:51:22 ade Exp $
#

export defaultCvsupHost="cvsup12.FreeBSD.org"
export cvsupProg="/usr/local/bin/cvsup"

#---------------------------------------------------------------------------
# Generic routines
#---------------------------------------------------------------------------
generateSupFile () {
    echo "*default host=$4"
    echo "*default base=$1"
    echo "*default prefix=$1"
    echo "*default release=cvs tag=$3"
    echo "*default delete use-rel-suffix"

    if [ $5 = 1 ]; then
	echo "*default compress"
    fi

    echo "$2-all"
}

tcExists () {
    list=$(${pb}/scripts/tc list$1 2>/dev/null)
    echo ${list} | grep -qw $2
}

cleanDirs () {
    name=$1; shift; dirs="$*"

    echo -n "${name}: cleaning up any previous leftovers... "
    for dir in $*
    do
	# perform the first remove
	rm -rf ${dir} >/dev/null 2>&1

	# this may not have succeeded if there are schg files around
	if [ -d ${dir} ]; then
	    chflags -R noschg ${dir} >/dev/null 2>&1
	    rm -rf ${dir} >/dev/null 2>&1
	    if [ $? != 0 ]; then
		echo "FAILED (rm ${dir})"
		exit 1
	    fi
	fi

	# now recreate the directory
	mkdir -p ${dir} >/dev/null 2>&1
	if [ $? != 0 ]; then
	    echo "FAILED (mkdir ${dir})"
 	    exit 1
	fi
    done
    echo "done."
}

#---------------------------------------------------------------------------
# Jail handling
#---------------------------------------------------------------------------

createJailUsage () {
    if [ ! -z "$*" ]; then
	echo "createJail: $*"
    fi
    echo "usage: create Jail -j <name> -t <tag> [-d <description>]"
    echo "       [-C] [-H <cvsuphost>] [-m <mountsrc>]"
    echo "       [-u <updatecommand>|CVSUP|NONE] [-I]"
    exit 1
}

createJail () {
    # set up defaults
    cvsupHost=${defaultCvsupHost}
    cvsupCompress=0
    descr=""
    jailName=""
    mountSrc=""
    tag=""
    updateCmd="CVSUP"
    init=1

    # argument handling
    shift
    while getopts d:j:m:t:u:CH:I arg
    do
	case "${arg}" in

	d)	descr="${OPTARG}";;
	j)	jailName="${OPTARG}";;
	m)	mountSrc="${OPTARG}";;
	t)	tag="${OPTARG}";;
	u)	updateCmd="${OPTARG}";;
	C)	cvsupCompress=1;;
	H)	cvsupHost="${OPTARG}";;
	I)	init=0;;
	?)	createJailUsage;;

	esac
    done

    # argument validation
    if [ -z "${jailName}" ]; then
	createJailUsage "no jail name specified"
    fi

    valid=$(echo ${jailName} | awk '{if (/^[[:digit:]]/) {print;}}')
    if [ -z "${valid}" ]; then
	createJailUsage \
		"jail name must begin with a FreeBSD major version number"
    fi

    if tcExists Jails ${jailName}; then
	createJailUsage "jail \"${jailName}\" already exists"
    fi

    if [ -z "${tag}" ]; then
	createJailUsage "no src tag name specified"
    fi

    # clean out any previous directories
    basedir=${pb}/jails/${jailName}
    cleanup_mounts -d jail -j ${jailName}
    cleanDirs ${jailName} ${basedir}

    # set up the directory
    echo -n "${jailName}: set up directory... "
    mkdir -p ${basedir}/src

    # set up the sup file (if needed)
    if [ "${updateCmd}" != "NONE" ]; then
	echo -n "and supfile... "
    	generateSupFile ${basedir} src ${tag} ${cvsupHost} ${cvsupCompress} \
	    > ${basedir}/src-supfile
    fi
    echo "done."

    # add jail to datastore
    echo -n "${jailName}: adding Jail to datastore... "

    if [ ! -z "${descr}" ]; then
	descr="-d ${descr}"
    fi
    if [ ! -z "${updateCmd}" ]; then
	updateCmd="-u ${updateCmd}"
    fi
    if [ ! -z "${mountSrc}" ]; then
	mountSrc="-m ${mountSrc}"
    fi

    ${pb}/scripts/tc addJail -j ${jailName} \
	-t ${tag} ${updateCmd} ${mountSrc} "${descr}"
    if [ $? != 0 ]; then
	echo "FAILED."
	exit 1
    fi
    echo "done."

    # mount src/ if required
    if [ ! -z "${mountSrc}" ]; then
	echo -n "${jailName}: mounting src... "
	request_mount -q -d jail -j ${jailName}
	echo "done."
    fi

    # now initialize the jail (unless otherwise requested)
    if [ ${init} = 1 ]; then
	echo "${jailName}: initializing new jail..."
	${pb}/scripts/mkjail ${jailName}
	if [ $? != 0 ]; then
	    echo "FAILED."
	    exit 1
	fi
    fi

    echo "done."

    # finished
    exit 0
}

#---------------------------------------------------------------------------
# PortsTree handling
#---------------------------------------------------------------------------

createPortsTreeUsage () {
    if [ ! -z "$*" ]; then
	echo "createPortsTree: $*"
    fi
    echo "usage: create PortsTree -p <name> [-d <description>]"
    echo "       [-C] [-H <cvsuphost>] [-m <mountsrc>]"
    echo "       [-u <updatecommand>|CVSUP|NONE] [-w <cvsweburl>]"
    exit 1
}

createPortsTree () {
    # set up defaults
    cvsupHost=${defaultCvsupHost}
    cvsupCompress=0
    cvswebUrl=""
    descr=""
    mountSrc=""
    portsTreeName=""
    updateCmd="CVSUP"

    # argument handling
    shift
    while getopts d:m:p:u:w:CH: arg
    do
	case "${arg}" in

	d)	descr="${OPTARG}";;
	m)	mountSrc="${OPTARG}";;
	p)	portsTreeName="${OPTARG}";;
	u)	updateCmd="${OPTARG}";;
	w)	cvswebUrl="${OPTARG}";;
	C)	cvsupCompress=1;;
	H)	cvsupHost="${OPTARG}";;
	?)	createPortsTreeUsage;;

	esac
    done

    # argument validation
    if [ -z "${portsTreeName}" ]; then
	createPortsTreeUsage "no portstree name specified"
    fi

    if tcExists PortsTrees ${portsTreeName}; then
	createPortsTreeUsage "portstree \"${portsTreeName}\" already exists"
    fi

    # clean out any previous directories
    basedir=${pb}/portstrees/${portsTreeName}
    cleanup_mounts -d portstree -p ${portsTreeName}
    cleanDirs ${portsTreeName} ${basedir}

    # set up the directory
    echo -n "${portsTreeName}: set up directory... "
    mkdir -p ${basedir}/ports

    # set up the sup file (if needed)
    if [ "${updateCmd}" != "NONE" ]; then
	echo -n "and supfile... "
	generateSupFile ${basedir} ports . ${cvsupHost} ${cvsupCompress} \
	    > ${basedir}/ports-supfile
    fi
    echo "done."

    # add portstree to datastore
    echo -n "${portsTreeName}: adding PortsTree to datastore... "

    if [ ! -z "${descr}" ]; then
	descr="-d ${descr}"
    fi
    if [ -z "${updateCmd}" -o "${updateCmd}" = "CVSUP" ]; then
	updateProg="${cvsupProg} -g ${basedir}/ports-supfile"
	updateCmd="CVSUP"
    else
	updateProg="${updateCmd}"
    fi
    if [ ! -z "${mountSrc}" ]; then
	mountSrc="-m ${mountSrc}"
    fi
    if [ ! -z "${cvswebUrl}" ]; then
	cvswebUrl="-w ${cvswebUrl}"
    fi

    ${pb}/scripts/tc addPortsTree -p ${portsTreeName} \
	-u ${updateCmd} ${mountSrc} ${cvswebUrl} "${descr}"
    if [ $? != 0 ]; then
	echo "FAILED."
	exit 1
    fi
    echo "done."

    # mount ports/ if required
    if [ ! -z "${mountSrc}" ]; then
	echo -n "${portsTreeName}: mounting ports... "
	request_mount -q -d portstree -p ${portsTreeName}
	echo "done."
    fi

    # update ports tree if requested
    if [ "${updateProg}" != "NONE" ]; then
	echo "${portsTreeName}: updating portstree with ${updateProg}..."
	eval ${updateProg} >/dev/null 2>&1
	if [ $? != 0 ]; then
	    echo "FAILED."
	    exit 1
	fi
	echo "done."
    fi

    # finished
    exit 0
}

#---------------------------------------------------------------------------
# Build handling
#---------------------------------------------------------------------------

createBuildUsage () {
    if [ ! -z "$*" ]; then
	echo "createBuild: $*"
    fi
    echo "usage: create Build -b <name> -j <jailname> -p <portstreename>"
    echo "       [-d <description>] [-i]"
    exit 1
}

createBuild () {
    # set up defaults
    buildName=""
    descr=""
    init=0
    jailName=""
    portsTreeName=""

    # argument handling
    shift
    while getopts b:d:ij:p: arg
    do
	case "${arg}" in

	b)	buildName="${OPTARG}";;
	d)	descr="${OPTARG}";;
	i)	init=1;;
	j)	jailName="${OPTARG}";;
	p)	portsTreeName="${OPTARG}";;
	?)	createBuildUsage;;

	esac
    done

    # argument validation
    if [ -z "${buildName}" ]; then
	createBuildUsage "no build name specified"
    fi
    if [ -z "${jailName}" ]; then
	createBuildUsage "no jail name specified"
    fi
    if [ -z "${portsTreeName}" ]; then
	createBuildUsage "no portstree name specified"
    fi

    if tcExists Builds ${buildName}; then
	createBuildUsage "build \"${buildName}\" already exists"
    fi
    if ! tcExists Jails ${jailName}; then
	createBuildUsage "jail \"${jailName}\" does not exist"
    fi
    if ! tcExists PortsTrees ${portsTreeName}; then
	createBuildUsage "portstree \"${portsTreeName}\" does not exist"
    fi

    # clean out any previous directories
    cleanDirs ${buildName} ${pb}/builds/${buildName} ${pb}/${buildName}

    # add build to datastore
    echo -n "${buildName}: adding Build to datastore... "

    if [ ! -z "${descr}" ]; then
	descr="-d ${descr}"
    fi

    ${pb}/scripts/tc addBuild -b ${buildName} \
	-j ${jailName} -p ${portsTreeName} "${descr}"
    if [ $? != 0 ]; then
	echo "FAILED."
	exit 1
    fi
    echo "done."

    if [ ${init} = 1 ]; then
	echo -n "${buildName}: initializing..."
	${pb}/scripts/mkbuild ${buildName}

	if [ $? != 0 ]; then
	    echo "FAILED."
	    exit 1
	fi
	echo "done."
    fi

    # finished
    exit 0
}

#---------------------------------------------------------------------------
# Main program
#---------------------------------------------------------------------------

createUsage () {
    if [ ! -z "$*" ]; then
	echo "create: $*"
    fi
    echo "usage: create Jail|PortsTree|Build <arguments>"
    exit 1
}

# don't try this at home, folks
if [ `id -u` != 0 ]; then
    echo "create: must run as root"
    exit 1
fi

# find out where we're located, and set prefix accordingly
pb=$0
[ -z "$(echo "${pb}" | sed 's![^/]!!g')" ] && \
pb=$(type "$pb" | sed 's/^.* //g')
pb=$(realpath $(dirname $pb))
pb=${pb%%/scripts}
export pb

# pull in all the helper functions
. ${pb}/scripts/lib/tinderbox_shlib.sh

# and off we go

if [ $# -lt 2 ]; then
    createUsage
fi

case $1 in

[Jj]ail)		createJail ${1+"$@"};;
[Pp]orts[Tt]ree)	createPortsTree ${1+"$@"};;
[Bb]uild)		createBuild ${1+"$@"};;
*)			createUsage "unknown operator: $1"

esac

exit 0
