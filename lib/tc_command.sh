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
# $MCom: portstools/tinderbox/lib/tc_command.sh,v 1.31 2006/01/29 18:02:31 marcus Exp $
#

export defaultCvsupHost="cvsup12.FreeBSD.org"
export defaultCvsupProg="/usr/local/bin/cvsup"

#---------------------------------------------------------------------------
# Generic routines
#---------------------------------------------------------------------------
generateSupFile () {
    echo "*default host=$4"
    echo "*default base=$1"
    echo "*default prefix=$1"
    echo "*default release=cvs tag=$3"
    echo "*default delete use-rel-suffix"

    if [ $5 -eq 1 ]; then
	echo "*default compress"
    fi

    echo "$2-all"
}

tcExists () {
    list=$($(tinderLoc scripts tc) list$1 2>/dev/null)
    echo ${list} | grep -qw $2
}

updateTree () {
    what=$1 
    name=$2
    flag=$3
    dir=$4
    shift 4
    cmd="$*"

    if [ -z "${cmd}" -o "${cmd}" = "NONE" ]; then
	return 0
    fi

    echo "updateTree: updating ${what} ${name}"

    if ! requestMount -t ${what} ${flag} ${name}; then
	echo "updateTree: ${what} ${name}: mount failed"
	exit 1
    fi

    eval ${cmd} > ${dir}/update.log 2>&1
    if [ $? -ne 0 ]; then
	echo "updateTree: ${what} ${name}: update failed"
	echo "    see ${dir}/update.log for more details"
	cleanupMounts -t ${what} ${flag} ${name}
	exit 1
    fi

    cleanupMounts -t ${what} ${flag} ${name}
}

#---------------------------------------------------------------------------
# Tinderbox setup
#---------------------------------------------------------------------------

Setup () {
    MAN_PREREQS="lang/perl5.8 net/p5-Net security/p5-Digest-MD5"
    OPT_PREREQS="lang/php[45] databases/pear-DB www/php[45]-session"
    PREF_FILES="tinderbox.ph"
    README="$(tinderLoc scripts README)"
    TINDERBOX_URL="http://tinderbox.marcuscom.com/"

    clear

    tinderEcho "Welcome to the Tinderbox Setup script.  This script will guide you through some of the automated Tinderbox setup steps.  Once this script completes , you should review the documentation in ${README} or on the web at ${TINDERBOX_URL} to complete your setup."
    echo ""

    read -p "Hit <ENTER> to get started: " dummy

    # First, check to see that all of the pre-requisites are installed.
    tinderEcho "INFO: Checking prerequisites ..."

    missing=$(checkPreReqs ${MAN_PREREQS})
    if [ $? -ne 0 ]; then
	tinderEcho "ERROR: The following mandatory dependencies are missing.  These must be installed prior to running the Tinderbox setup script."
	tinderEcho "ERROR:   ${missing}"
	exit 1
    fi

    # Now, check the optional pre-reqs (for web usage).
    missing=$(checkPreReqs ${OPT_PREREQS})
    if [ $? -ne 0 ]; then
	tinderEcho "WARN: The following option dependencies are missing.  These are required to use the Tinderbox web front-ends."
	tinderEcho "WARN:  ${missing}"
    fi

    tinderEcho "DONE."
    echo ""

    # Now install the default preferences files.
    tinderEcho "INFO: Creating default configuration files ..."
    for f in ${PREF_FILES} ; do
	distfile=$(tinderLoc scripts ${f})
	if [ ! -f "${distfile}.dist" ]; then
	    tinderExit "ERROR: Missing required distribution file ${distfile}.dist.  Please download and extract Tinderbox again."
	fi
	if [ -f ${distfile} ]; then
	    cp -p ${distfile} ${distfile}.bak
	fi
	cp -f ${distfile}.dist ${distfile}
    done
    tinderEcho "DONE."
    echo ""

    # Now create the database if we can.
    tinderEcho "INFO: Beginning database configuration."

    db_driver=$(getDbDriver)
    db_setup=$(tinderLoc scripts lib/setup-${db_driver}.sh)
    if [ ! -f "${db_setup}" ]; then
	tinderEcho "ERROR: Failed to locate a setup script for the ${db_driver} database driver."
	exit 1
    fi

    . ${db_setup}

    tinderEcho "INFO: Database configuration complete."
    echo ""

    # We're done now.  However, we don't want to be calling 'tc init'
    # here since the user may need to configure tinderbox.ph first
    tph=$(tinderLoc scripts tinderbox.ph)
    tinit=$(tinderLoc scripts init)

    tinderExit "Congratulations!  The scripted portion of Tinderbox has completed successfully.  You should now verify the settings in ${tph} are correct for your environment, then run \"${tinit}\" to complete the setup.  Be sure to checkout ${TINDERBOX_URL} for further instructions." 0
}

#---------------------------------------------------------------------------
# Tinderbox upgrade
#---------------------------------------------------------------------------

Upgrade () {
    VERSION="3.0.0"

    # DB_MIGRATION_PATH contains all versions where upgradeable SQL
    # schemas are available.
    # For example, with:
    #	DB_MIGRATION_PATH="1.X 2.0.0 2.0.1 2.1.0"
    # then there are scripts for 1.X->2.0.0, 2.0.0->2.0.1 and 2.0.1->2.1.0
    # so it is possible through intermediaries from 1.X->2.1.0 without having
    # to maintain scripts for every possible combination of existing and
    # new version numbers
    DB_MIGRATION_PATH="${VERSION}"

    REMOVE_FILES=""
    TINDERBOX_URL="http://tinderbox.marcuscom.com/"

    clear

    tinderEcho "Welcome to the Tinderbox Upgrade and Migration script.  This script will guide you through an upgrade to Tinderbox ${VERSION}."
    echo ""

    read -p "Hit <ENTER> to get started: " dummy

    # Check if the current Datasource Version is ascertainable
    tc=$(tinderLoc scripts tc)
    if ${tc} dsversion >/dev/null 2>&1 ; then
	DSVERSION=$(${tc} dsversion)
    else
	tinderExit "ERROR: Database migration failed!  Consult the output above for more information." $?
    fi

    # First, migrate the database, if needed.
    echo ""
    db_host=""
    db_name=""
    db_admin=""
    do_load=0
    db_driver=$(getDbDriver)
    dbinfo=$(getDbInfo ${db_driver})

    if [ $? -eq 0 ]; then
	db_admin_host=${dbinfo%:*}
	db_name=${dbinfo##*:}
	db_admin=${db_admin_host%:*}
	db_host=${db_admin_host#*:}
	do_load=1
    fi

    set -- $DB_MIGRATION_PATH
    while [ -n "${1}" -a -n "${2}" ] ; do
	MIG_VERSION_FROM=${1}
	MIG_VERSION_TO=${2}

	if [ ${MIG_VERSION_FROM} = ${DSVERSION} ] ; then
	    migDb ${do_load} ${db_driver} ${db_admin} ${db_host} ${db_name}
	    case $? in

            2)	tinderExit "ERROR: Database migration failed!  Consult the output above for more information." 2;;
            1)	tinderExit "ERROR: No Migration Script available to migrate ${MIG_VERSION_FROM} to ${MIG_VERSION_TO}" 1;;
            0)	DSVERSION=${MIG_VERSION_TO};;

	    esac
	fi

	shift
    done

    if [ ${do_load} -eq 0 ]; then
	tinderEcho "WARN: Database migration was not done.  If you proceed, you may encounter errors.  It is recommended you manually load any necessary schema updates, then re-run this script.  If you have already loaded the database schema, type 'y' or 'yes' to continue the migration."
	echo ""

	read -p "Do you wish to continue? (y/n)" dummy
	case ${i} in

        [Yy]|[Yy][Ee][Ss])	;;	# continue
	*)			tinderExit "INFO: Upgrade aborted by user.";;

	esac
    fi

    echo ""
    tinderExit "Congratulations!  Tinderbox migration is complete.  Please refer to ${TINDERBOX_URL} for a list of what is new in this version as well as general Tinderbox documentation." 0
}

#---------------------------------------------------------------------------
# Jail handling
#---------------------------------------------------------------------------

updateJail () {
    # set up defaults
    jailName=""

    # argument handling
    while getopts j: arg >/dev/null 2>&1
    do
	case "${arg}" in

	j)	jailName="${OPTARG}";;
	?)	return 1;;

	esac
    done

    # argument validation
    if [ -z "${jailName}" ]; then
	echo "updateJail: no jail name specified"
	return 1
    fi

    if ! tcExists Jails ${jailName}; then
	echo "updateJail: jail \"${jailName}\" doesn't exist"
	return 1
    fi

    tc=$(tinderLoc scripts tc)
    updateCmdName=$(${tc} getUpdateCmd -j ${jailName})
    jailDir=$(tinderLoc jail ${jailName})

    case "${updateCmdName}" in

    CVSUP)	updateCmd="${cvsupProg} -g ${jailDir}/src-supfile";;
    NONE)	updateCmd="NONE";;
    "^/.*")	updateCmd="${updateCmdName} ${jailName}";;
    *)		updateCmd="$(tinderLoc scripts ${updateCmd}) ${jailName}";;

    esac

    updateTree jail ${jailName} -j ${jailDir} ${updateCmd}
    return 0
}

buildJailCleanup () {
    trap "" 1 2 3 9 10 11 15
    echo "Cleaning up after Jail creation.  Please be patient."
    cd ${pb}
    cleanupMounts -t jail -j $2 -d $3
    exit $1
}

buildJail () {
    # set up defaults
    jailName=""

    # argument handling
    while getopts j: arg >/dev/null 2>&1
    do
	case "${arg}" in

	j)	jailName="${OPTARG}";;
	?)	return 1;;

	esac
    done

    # argument validation
    if [ -z "${jailName}" ]; then
	echo "buildJail: no jail name specified"
	return 1
    fi

    if ! tcExists Jails ${jailName}; then
	echo "buildJail: jail \"${jailName}\" doesn't exist"
	return 1
    fi

    # Hackery to set SRCBASE accordingly for all combinations
    tc=$(tinderLoc scripts tc)
    jailSrcMt=$(${tc} getSrcMount -j ${jailName})
    HOST_WORKDIR=$(${tc} configGet | awk -F= '/^HOST_WORKDIR/ {print $2}')
    jailBase=$(tinderLoc jail ${jailName})
    if [ ! -d ${jailBase} ]; then
	mkdir -p ${jailBase}
	if [ $? -ne 0 ]; then
	    echo "buildJail: cant create: ${jailBase}"
	    return 0
	fi
    fi

    J_OBJDIR=$(tinderLoc jailobj ${jailName})
    J_SRCDIR=$(tinderLoc jailsrc ${jailName})
    J_TMPDIR=$(tinderLoc jailtmp ${jailName})

    if [ -z "${HOST_WORKDIR}" ]; then
	if [ -n "${jailSrcMt}" ]; then
	    reqmt="-r"
	fi
    else
	if [ -n "${jailSrcMt}" ]; then
	    reqmt="-r -d ${J_SRCDIR}"
	else
	    J_SRCDIR=${jailBase}/src
	fi
    fi

    if [ -n "${reqmt}" ]; then
	if ! requestMount -t jail -j ${jailName} ${reqmt}; then
	    echo "buildJail: cant mount source directory"
	    return 1
	fi
    fi
    trap "buildJailCleanup 1 ${jailName} ${J_SRCDIR}" 1 2 3 9 10 11 15

    export SRCBASE=${J_SRCDIR}
    export MAKEOBJDIRPREFIX=${J_OBJDIR}
    buildenv ${jailName} "" ""

    # clean up after any previous build attempts
    cleanDirs ${jailName} ${J_OBJDIR} ${J_TMPDIR}

    # Set up environment
    # Certain locales cause build failures when trying to build older
    # jails on newer host machines

    unset LC_ALL
    unset LC_TIME
    unset LC_CTYPE
    unset LC_MONETARY
    unset LC_COLLATE
    unset LC_MESSAGES
    unset LC_NUMERIC
    unset LANG

    # We don't want the host environment getting in the way
    export __MAKE_CONF=/dev/null

    # Get the architecture types for both the host and the jail
    jailArch=$(${tc} getJailArch -j ${jailName})
    myArch=$(uname -m)

    # Make world
    echo "${jailName}: making world"

    # determine if we're cross-building world
    crossEnv=""
    if [ "${jailArch}" != "${myArch}" ]; then
	crossEnv="TARGET_ARCH=${jailArch}"
    fi
    cd ${SRCBASE} && env DESTDIR=${J_TMPDIR} ${crossEnv} \
	make world > ${jailBase}/world.tmp 2>&1
    if [ $? -ne 0 ]; then
	echo "ERROR: world failed - see ${jailBase}/world.tmp"
	buildJailCleanup 1 ${jailName} ${J_SRCDIR}
    fi

    # Make a complete distribution
    echo "${jailName}: making distribution"

    # determine if we're cross-building world - unfortunately 5.x
    # and below doesn't appear to have the "distribute" target in
    # the top-level makefile, so we have to do a little bit of hackery
    crossEnv=""
    if [ "${jailArch}" != "${myArch}" ]; then
	crossEnv="TARGET_ARCH=${jailArch} MACHINE_ARCH=${jailArch} MAKEOBJDIRPREFIX=${J_OBJDIR}/${jailArch} MACHINE=${jailArch}"
    fi
    cd ${SRCBASE}/etc && env DESTDIR=${J_TMPDIR} ${crossEnv} \
	make distribution > ${jailBase}/distribution.tmp 2>&1
    if [ $? -ne 0 ]; then
	echo "ERROR: distribution failed - see ${jailBase}/distribution.tmp"
	buildJailCleanup 1 ${jailName} ${J_SRCDIR}
    fi

    # Various hacks to keep the ports building environment happy
    ln -sf dev/null ${J_TMPDIR}/kernel		# XXX: still needed?
    ln -sf aj ${J_TMPDIR}/etc/malloc.conf
    touch -f ${J_TMPDIR}/etc/fstab
    touch -f ${J_TMPDIR}/etc/wall_cmos_clock

    MTREE_DIR=${SRCBASE}/etc/mtree
    mtree -deU -f ${MTREE_DIR}/BSD.root.dist \
	  -p ${J_TMPDIR}/ >/dev/null 2>&1
    mtree -deU -f ${MTREE_DIR}/BSD.var.dist \
	  -p ${J_TMPDIR}/var >/dev/null 2>&1
    mtree -deU -f ${MTREE_DIR}/BSD.usr.dist \
	  -p ${J_TMPDIR}/usr >/dev/null 2>&1
    mtree -deU -f ${MTREE_DIR}/BSD.local.dist \
	  -p ${J_TMPDIR}/usr/local >/dev/null 2>&1

    date '+%Y%m%d' > ${J_TMPDIR}/var/db/port.mkversion
    mkdir -p ${J_TMPDIR}/var/run

    rm -f ${J_TMPDIR}/usr/lib/aout/lib*_p.a

    # Create the jail tarball
    echo "${jailName}: creating tarball"
    jailDir=$(tinderLoc jail ${jailName})
    mkdir -p ${jailDir}
    TARBALL=$(tinderLoc jailtarball ${jailName})
    tar -C ${J_TMPDIR} -cf ${TARBALL}.new . && \
	mv -f ${TARBALL}.new ${TARBALL}
    if [ $? -ne 0 ]; then
	echo "ERROR: tarball creation failed."
	buildJailCleanup 1 ${jailName} ${J_SRCDIR}
    fi

    # Move new logfiles into place
    for logfile in world distribution
    do
	rm -f ${jailBase}/${logfile}.log
	mv -f ${jailBase}/${logfile}.tmp ${jailBase}/${logfile}.log
    done

    # Update the last-built time
    ${tc} updateJailLastBuilt -j ${jailName}

    # Finally, clean up
    cleanDirs ${jailName} ${J_TMPDIR} ${J_OBJDIR}

    buildJailCleanup 0 ${jailName} ${J_SRCDIR}
}

makeJail () {
    # set up defaults
    jailName=""

    # argument handling
    while getopts j: arg >/dev/null 2>&1
    do
        case "${arg}" in

	j)	jailName="${OPTARG}";;
	?)	return 1;;

	esac
    done

    # argument validation
    if [ -z "${jailName}" ]; then
	echo "makeJail: no jail name specified"
	return 1
    fi

    if ! tcExists Jails ${jailName}; then
	echo "makeJail: jail \"${jailName}\" doesn't exist"
	return 1
    fi

    updateJail -j ${jailName}
    buildJail  -j ${jailName}
}

createJail () {
    # set up defaults
    cvsupHost=${defaultCvsupHost}
    cvsupProg=${defaultCvsupProg}
    cvsupCompress=0
    descr=""
    jailName=""
    jailArch=$(uname -m)
    mountSrc=""
    tag=""
    updateCmd="CVSUP"
    init=1

    # argument handling
    while getopts a:d:j:m:t:u:CH:IP: arg >/dev/null 2>&1
    do
	case "${arg}" in

	a)	jailArch="${OPTARG}";;
	d)	descr="${OPTARG}";;
	j)	jailName="${OPTARG}";;
	m)	mountSrc="${OPTARG}";;
	t)	tag="${OPTARG}";;
	u)	updateCmd="${OPTARG}";;
	C)	cvsupCompress=1;;
	H)	cvsupHost="${OPTARG}";;
	I)	init=0;;
	P)	cvsupProg="${OPTARG}";;
	?)	return 1;;

	esac
    done

    # argument validation
    if [ -z "${jailName}" ]; then
	echo "createJail: no jail name specified"
	return 1
    fi

    valid=$(echo ${jailName} | awk '{if (/^[[:digit:]]/) {print;}}')
    if [ -z "${valid}" ]; then
	echo "createJail: jail name must begin with a FreeBSD major version"
	return 1
    fi

    if tcExists Jails ${jailName}; then
	echo "createJail: jail \"${jailName}\" already exists"
	return 1
    fi

    if [ -z "${updateCmd}" ]; then
	echo "createJail: no updatecommand specified"
	return 1
    fi

    if [ "${updateCmd}" = "CVSUP" -a -z "${tag}" ]; then
	echo "createJail: no src tag specified"
	return 1
    fi

    # clean out any previous directories
    basedir=$(tinderLoc jail ${jailName})
    cleanDirs ${jailName} ${basedir}

    # set up the directory
    echo -n "${jailName}: set up directory... "
    mkdir -p ${basedir}/src

    # set up the sup file (if needed)
    if [ "${updateCmd}" = "CVSUP" ]; then
	echo -n "and supfile... "
    	generateSupFile ${basedir} src ${tag} ${cvsupHost} ${cvsupCompress} \
	    > ${basedir}/src-supfile
    else
	tag="UNUSED"
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

    tc=$(tinderLoc scripts tc)
    ${tc} addJail -j ${jailName} -t ${tag} ${updateCmd} ${mountSrc} \
		  -a ${jailArch} "${descr}"
    if [ $? -ne 0 ]; then
	echo "FAILED."
	exit 1
    fi
    echo "done."

    # now initialize the jail (unless otherwise requested)
    if [ ${init} -eq 1 ]; then
	echo "${jailName}: initializing new jail..."
	makeJail -j ${jailName}
	if [ $? -ne 0 ]; then
	    echo "FAILED."
	    exit 1
	fi
    fi

    echo "done."

    # finished
    return 0
}

#---------------------------------------------------------------------------
# PortsTree handling
#---------------------------------------------------------------------------

updatePortsTree () {
    # set up defaults
    portsTreeName=""

    # argument handling
    while getopts p: arg >/dev/null 2>&1
    do
	case "${arg}" in

	p)	portsTreeName="${OPTARG}";;
	?)	return 1;;

	esac
    done

    # argument validation
    if [ -z "${portsTreeName}" ]; then
	echo "updatePortsTree: no portstree name specified"
	return 1
    fi

    if ! tcExists PortsTrees ${portsTreeName}; then
	echo "updatePortsTree: portstree \"${portsTreeName}\" doesn't exist"
	return 1
    fi

    tc=$(tinderLoc scripts tc)
    updateCmdName=$(${tc} getUpdateCmd -p ${portsTreeName})
    portsTreeDir=$(tinderLoc portstree ${portsTreeName})

    case "${updateCmdName}" in

    CVSUP)	updateCmd="${cvsupProg} -g ${portsTreeDir}/ports-supfile";;
    NONE)	updateCmd="NONE";;
    "^/.*")	updateCmd="${updateCmdName} ${portsTreeName}";;
    *)		updateCmd="$(tinderLoc scripts ${updateCmd}) ${portsTreeName}";;

    esac

    updateTree portstree ${portsTreeName} -p ${portsTreeDir} ${updateCmd}
    return 0
}

createPortsTree () {
    # set up defaults
    cvsupHost=${defaultCvsupHost}
    cvsupProg=${defaultCvsupProg}
    cvsupCompress=0
    cvswebUrl=""
    descr=""
    init=1
    mountSrc=""
    portsTreeName=""
    updateCmd="CVSUP"

    # argument handling
    while getopts d:m:p:u:w:CH:IP: arg >/dev/null 2>&1
    do
	case "${arg}" in

	d)	descr="${OPTARG}";;
	m)	mountSrc="${OPTARG}";;
	p)	portsTreeName="${OPTARG}";;
	u)	updateCmd="${OPTARG}";;
	w)	cvswebUrl="${OPTARG}";;
	C)	cvsupCompress=1;;
	H)	cvsupHost="${OPTARG}";;
	I)	init=0;;
	P)	cvsupProg="${OPTARG}";;
	?)	return 1;;

	esac
    done

    # argument validation
    if [ -z "${portsTreeName}" ]; then
	echo "createPortsTree: no portstree name specified"
	return 1
    fi

    if tcExists PortsTrees ${portsTreeName}; then
	echo "createPortsTree: portstree \"${portsTreeName}\" already exists"
	return 1
    fi

    if [ -z "${updateCmd}" ]; then
	echo "createPortsTree: no updatecommand specified"
	return 1
    fi

    # clean out any previous directories
    basedir=$(tinderLoc portstree ${portsTreeName})
    cleanupMounts -t portstree -p ${portsTreeName}
    cleanDirs ${portsTreeName} ${basedir}

    # set up the directory
    echo -n "${portsTreeName}: set up directory... "
    mkdir -p ${basedir}/ports

    # set up the sup file (if needed)
    if [ "${updateCmd}" = "CVSUP" ]; then
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

    if [ "${updateCmd}" = "CVSUP" ]; then
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

    tc=$(tinderLoc scripts tc)
    ${tc} addPortsTree -p ${portsTreeName} -u ${updateCmd} \
	${mountSrc} ${cvswebUrl} "${descr}"
    if [ $? -ne 0 ]; then
	echo "FAILED."
	exit 1
    fi
    echo "done."

    if [ ${init} -eq 1 ]; then
	updatePortsTree -p ${portsTreeName}
    fi

    return 0
}

#---------------------------------------------------------------------------
# Build handling
#---------------------------------------------------------------------------

enterBuild () {
    build=""
    portDir=""
    autoSleep=0
    resp="n"
    sleepName=""

    while getopts b:d: arg >/dev/null 2>&1
    do
	case "${arg}" in

	b)	build="${OPTARG}";;
	d)	portDir="${OPTARG}";;
	?)	return 1;;

        esac
    done

    if [ -z "${portDir}" ]; then
	echo "enterBuild: no port specified"
	return 1
    fi

    if [ -z "${build}" ]; then
	echo "enterBuild: no build specified"
	return 1
    fi

    if ! tcExists Builds ${build}; then
	echo "enterBuild: no such build: ${build}"
	return 1
    fi

    buildRoot=$(tinderLoc buildroot ${build})
    if [ ! -d ${buildRoot} ]; then
	echo "enterBuild: Build directory (${buildRoot}) does not exist"
	return 1
    fi

    sleepName=$(echo ${portDir} | sed -e 'y/\//_/')
    portFullDir=${buildRoot}/usr/ports/${portDir}

    if [ ! -d ${portFullDir} ]; then
	echo "enterBuild: Build environment does not exist yet, sleeping."
	while [ ! -d ${portFullDir} ]; do
	    sleep 1
	done
    fi

    if [ ! -f ${portFullDir}/.sleepme ]; then
	echo "enterBuild: Build not marked for sleeping. Marking it."
	touch ${portFullDir}/.sleepme
	if [ ! -f ${portFullDir}/.sleepme ]; then
	    echo "enterBuild: cannot touch ${portFullDir}/.sleepme."
	    return 1
	fi
	autoSleep=1
    fi

    while [ ! -f ${buildRoot}/tmp/.sleep_${sleepName} ]; do
	echo "enterBuild: Build not yet sleeping, waiting 15 seconds."
	sleep 15
    done

    echo 
    cp $(tinderLoc scripts lib/enterbuild) ${buildRoot}/root
    chroot ${buildRoot} /root/enterbuild ${portDir}
    rm -f ${buildRoot}/tmp/.sleep_${sleepName}

    echo "enterBuild: Continuing port build."

    if [ ${autoSleep} -eq 1 ]; then
        resp="y"
    else
	echo -n "Remove .sleepme too? [yN] "
	read resp
    fi
    if [ "${resp}" = "y" ]; then
	rm -f ${portFullDir}/.sleepme
	if [ -f ${portFullDir}/.sleepme ]; then
	    echo "enterBuild: failed to remove ${portFullDir}/.sleepme!"
	else
	    echo "enterBuild: .sleepme removed."
	fi
    fi
}

makeBuild () {
    # set up defaults
    buildName=""

    # argument handling
    while getopts b: arg >/dev/null 2>&1
    do
	case "${arg}" in

	b)	buildName="${OPTARG}";;
	?)	return 1;;

	esac
    done

    # argument validation
    if [ -z "${buildName}" ]; then
	echo "makeBuild: no buildname specified"
	return 1
    fi

    if ! tcExists Builds ${buildName}; then
	echo "makeBuild: build \"${buildName}\" doesn't exist"
	return 1
    fi

    # Find the jail associated with the build
    tc=$(tinderLoc scripts tc)
    jailName=$(${tc} getJailForBuild -b ${buildName})

    BUILD_DIR=$(tinderLoc buildroot ${buildName})
    JAIL_TARBALL=$(tinderLoc jailtarball ${jailName})

    if [ ! -f ${JAIL_TARBALL} ]; then
	echo "makeBuild: tarball for jail \"${jailName}\" doesn't exist."
	echo "           run \"tc makeJail -j ${jailName}\" first."
	exit 1
    fi

    # Clean up any previous build tree
    cleanupMounts -t buildsrc -b ${buildName}
    cleanupMounts -t buildports -b ${buildName}
    cleanupMounts -t buildccache -b ${buildName}
    cleanupMounts -t builddistcache -b ${buildName}
    cleanDirs ${buildName} ${BUILD_DIR}

    # Extract the tarball
    echo "makeBuild: extracting jail tarball"
    tar -C ${BUILD_DIR} -xpf ${JAIL_TARBALL}

    # Finalize environment
    cp -f /etc/resolv.conf ${BUILD_DIR}/etc

    return 0
}

createBuild () {
    # set up defaults
    buildName=""
    descr=""
    jailName=""
    portsTreeName=""

    # argument handling
    while getopts b:d:ij:p: arg >/dev/null 2>&1
    do
	case "${arg}" in

	b)	buildName="${OPTARG}";;
	d)	descr="${OPTARG}";;
	j)	jailName="${OPTARG}";;
	p)	portsTreeName="${OPTARG}";;
	?)	return 1;;

	esac
    done

    # argument validation
    if [ -z "${buildName}" ]; then
	echo "createBuild: no build name specified"
	return 1
    fi

    if tcExists Builds ${buildName}; then
	echo "createBuild: build \"${buildName}\" already exists"
	return 1
    fi

    if [ -z "${jailName}" ]; then
	echo "createBuild: no jail name specified"
	return 1
    fi

    if ! tcExists Jails ${jailName}; then
	echo "createBuild: jail \"${jailName}\" does not exist"
	return 1
    fi

    if [ -z "${portsTreeName}" ]; then
	echo "createBuild: no portstree name specified"
	return 1
    fi

    if ! tcExists PortsTrees ${portsTreeName}; then
	echo "createBuild: portstree \"${portsTreeName}\" does not exist"
	return 1
    fi

    # clean out any previous directories
    tc=$(tinderLoc scripts tc)
    HOST_WORKDIR=$(${tc} configGet | awk -F= '/^HOST_WORKDIR/ {print $2}')
    buildRoot=$(tinderLoc buildroot ${buildName})
    buildData=$(tinderLoc builddata ${buildName})

    cleanDirs ${buildName} ${buildRoot} ${buildData}

    # add build to datastore
    echo -n "${buildName}: adding Build to datastore... "

    if [ ! -z "${descr}" ]; then
	descr="-d ${descr}"
    fi

    ${tc} addBuild -b ${buildName} -j ${jailName} -p ${portsTreeName} "${descr}"
    if [ $? -ne 0 ]; then
	echo "FAILED."
	exit 1
    fi

    echo "done."
    return 0
}

#---------------------------------------------------------------------------
# Build one or more packages
#---------------------------------------------------------------------------

tinderbuild_reset () {
    cleanupMounts -t buildsrc -b $1
    cleanupMounts -t buildports -b $1
    cleanupMounts -t buildccache -b $1
    cleanupMounts -t builddistcache -b $1
    umount -f $(tinderLoc buildroot $1)/dev >/dev/null 2>&1
}

tinderbuild_cleanup () {
    trap "" 1 2 3 9 10 11 15
    echo "tinderbuild: Cleaning up after tinderbuild.  Please be patient."
    rm -f ${lock}

    tc=$(tinderLoc scripts tc)
    ${tc} updateBuildStatus -b ${build} -s IDLE
    ${tc} sendBuildCompletionMail -b ${build}
    tinderbuild_reset ${build}
    echo 

    exit $1
}

tinderbuild_setup () {
    # Make sure everything is dismounted, clean out the build tree
    # and recreate it from scratch

    tc=$(tinderLoc scripts tc)
    HOST_WORKDIR=$(${tc} configGet | awk -F= '/^HOST_WORKDIR/ {print $2}')

    echo "tinderbuild: Creating build directory for ${build}"
    tinderbuild_reset ${build}
    makeBuild -b ${build}

    # set up the rest of the chrooted environment, we really do
    # not need to be doing this every single time portbuild is called

    buildRoot=$(tinderLoc buildroot ${build})
    echo "tinderbuild: Finalizing chroot environment"

    # Mount ports/
    if ! requestMount -t buildports -b ${build} -r ${nullfs}; then
	echo "tinderbuild: cant mount ports source"
	tinderbuild_cleanup 1
    fi
    ln -sf ../a/ports ${buildRoot}/usr/ports

    # Mount src/
    if ! requestMount -t buildsrc -b ${build} -r ${nullfs}; then
	echo "tinderbuild: cant mount jail source"
	tinderbuild_cleanup 1
    fi

    # handle OS version dependent bits and pieces
    libc_hackery=""
    case ${osmajor} in

    4)
	mkdir -p ${buildRoot}/libexec
	mkdir -p ${buildRoot}/lib
	if [ "${ARCH}" = "i386" -o "${ARCH}" = "amd64" ]; then
	    cp -p /sbin/mount /sbin/umount ${buildRoot}/sbin
	    cp -p /lib/libufs.so.[0-9]* ${buildRoot}/lib
	fi
	cp -p /libexec/ld-elf.so.1 ${buildRoot}/libexec
	cp -p /lib/libkvm.so.[0-9]* /lib/libm.so.[0-9]* ${buildRoot}/lib
	if [ -f /lib/libc.so.6 ]; then
	    libc_hackery="libc.so.6"
	elif [ -f /lib/libc.so.5 ]; then
	    libc_hackery="libc.so.5"
	fi
	;;

    5)
	if [ -f /lib/libc.so.6 ]; then
	    libc_hackery="libc.so.6"
	fi
	;;

    6|7)
	if [ -f /lib/libc.so.5 ]; then
	    libc_hackery="libc.so.5"
	fi
	;;

    esac

    if [ -n "${libc_hackery}" ]; then
	chflags noschg ${buildRoot}/lib/${libc_hackery} >/dev/null 2>&1
	cp -p /lib/${libc_hackery} ${buildRoot}/lib
    fi

    # For use by pnohang
    # XXX: though killall may not work since it's a dynamic executable
    cp -p /rescue/ps ${buildRoot}/bin
    cp -p /usr/bin/killall ${buildRoot}/bin

    # Mount /dev, since we're going to be chrooting shortly
    mount -t devfs devfs ${buildRoot}/dev >/dev/null 2>&1

    # Install a couple of tinderbox binaries
    if ! cp -p $(tinderLoc scripts lib/buildscript) ${buildRoot}; then
	echo "tinderbuild: ${build}: cant copy buildscript"
	tinderbuild_cleanup 1
    fi

    if ! cc -o ${buildRoot}/pnohang -static \
	$(tinderLoc scripts lib/pnohang.c); then
	echo "tinderbuild: ${build}: cant compile pnohang"
	tinderbuild_cleanup 1
    fi

    # Hack to fix some recent pkg_add problems in some releases
    pitar=$(tinderLoc jail ${jail})/pkg_install.tar
    if [ -f ${pitar} ]; then
	tar -C ${buildRoot} -xf ${pitar}
    fi

    # Handle the distfile cache
    if [ -n "${DISTFILE_CACHE}" ]; then
	if ! requestMount -t builddistcache -b ${build} \
		-s ${DISTFILE_CACHE}; then
	    echo "tinderbuild: cant mount distfile cache"
	    tinderbuild_cleanup 1
	fi

	if [ ${cleandistfiles} -eq 1 ]; then
	    echo "tinderbuild: ${build}: Cleaning out distfile cache"
	    rm -rf $(tinderLoc builddistcache ${build})/*
	fi
    fi

    # Handle ccache
    if [ ${CCACHE_ENABLED} -eq 1 ]; then

	# per-build, or per-jail, ccache?
	if [ ${CCACHE_JAIL} -eq 1 ]; then
	    ccacheDir=$(tinderLoc ccache ${jail})
	else
	    ccacheDir=$(tinderLoc ccache ${build})
	fi

	# create directories if need be
	mkdir -p ${ccacheDir} $(tinderLoc buildccache ${build})

	if ! requestMount -t buildccache -b ${build} \
		-s ${ccacheDir} ${nullfs}; then
	    echo "tinderbuild: cant mount ccache"
	    tinderbuild_cleanup 1
	fi

	cctar=$(tinderLoc jail ${jail})/ccache.tar
	if [ -f ${cctar} ]; then
	    tar -C ${buildRoot} -xf ${cctar}
	    if [ -n "${CCACHE_MAX_SIZE}" ]; then
		chroot ${buildRoot} /opt/ccache -M ${CCACHE_MAX_SIZE}
	    fi
	fi
    fi
}

tinderbuild_phase () {
    num=$1
    jobs=$2
    pkgDir=$3

    echo "================================================"
    echo "building packages (phase ${num})"
    echo "================================================"

    echo "started at $(date)"
    start=$(date +%s)

    cd ${pkgDir}/All && make PACKAGES=${pkgDir} -k -j${jobs} all \
	> $(tinderLoc builddata ${build})/make.${num} 2>&1 </dev/null

    echo "ended at $(date)"
    end=$(date +%s)

    echo "phase ${num} took $(date -u -j -r $((${end} - ${start})) |
		awk '{print $4}')"
    echo $(echo $(ls -1 ${pkgDir}/All | wc -l) - 1 | bc) "packages built"
    echo $(echo $(du -sh ${pkgDir} | awk '{print $1}')) " of packages"
}

tinderbuild () {
    # set up defaults
    build=""
    ports=""
    cleandistfiles=0
    cleanpackages=0
    init=0
    jobs=1
    onceonly=0
    noduds=""
    nullfs=""
    pbargs=""
    skipmake=0
    updateports=0

    # argument processing
    while [ $# -gt 0 ]; do
	case "x$1" in

	x-b)
    	    shift
	    if ! tcExists Builds $1; then
		echo "tinderbuild: Build, \"$1\" is not a valid build."
		exit 1
	    fi
	    build=$1
	    ;;

	x-jobs)
	    shift
	    if ! expr -- "$1" : "^[[:digit:]]\{1,\}$" >/dev/null 2>&1 ; then
		echo "tinderbuild: The argument to -jobs must be a number."
		exit 1
	    elif [ $1 -lt 1 ]; then
		echo "tinderbuild: The argument to -jobs must be a number >= 1."
		exit 1
	    fi
	    jobs=$1
	    ;;

	x-cleandistfiles)	cleandistfiles=1;;
	x-cleanpackages)	cleanpackages=1;;
	x-init)			init=1;;
	x-skipmake)		skipmake=1;;
	x-updateports)		updateports=1;;

	# various arguments passed through to makemake and portbuild
	x-noduds)		noduds="-n";;

	x-fetch-original)	pbargs="${pbargs} -fetch-original";;
	x-noclean)		pbargs="${pbargs} -noclean";;
	x-nolog)		pbargs="${pbargs} -nolog";;
	x-nullfs)		pbargs="${pbargs} -nullfs"; nullfs="-n";;
	x-plistcheck)		pbargs="${pbargs} -plistcheck";;
	x-onceonly)		onceonly=1;;

	-*)			return 1;;
	*)			ports="${ports} $1";;

	esac

	shift
    done

    if [ -z "${build}" ]; then
	return 1
    fi

    buildData=$(tinderLoc builddata ${build})
    lock=${buildData}/lock

    if [ -e ${lock} ]; then
	echo "tinderbuild: Lock file ${lock} exists; exiting."
	exit 1
    fi

    if ! mkdir -p ${buildData} ; then
	echo "tinderbuild: couldn't create build directory; exiting."
	exit 1
    fi

    if ! touch ${lock} ; then
	echo "tinderbuild: Lock file ${lock} could not be created; exiting."
	exit 1
    fi

    # Let the datastore known what we're doing.
    tc=$(tinderLoc scripts tc)
    ${tc} updateBuildStatus -b ${build} -s PREPARE

    trap "tinderbuild_cleanup 2" 1 2 3 9 10 11 15

    # XXX: This is a crude hack to normalize ${ports}
    ports=$(echo ${ports})

    # Setup the environment for this jail
    jail=$(${tc} getJailForBuild -b ${build})
    portstree=$(${tc} getPortsTreeForBuild -b ${build})

    requestMount -t jail -j ${jail}
    buildenv ${jail} ${portstree} ${build}
    cleanupMounts -t jail -j ${jail}

    # Remove the make logs.
    rm -f ${buildData}/make.*

    # Determine where we're going to write out packages
    pkgDir=$(tinderLoc packages ${build})

    # Clean up packages if specific ports dirs were specified
    # on the command line
    for port in ${ports}; do
	pkgname=$(${tc} getPortLastBuiltVersion -b ${build} -d ${port})
	if [ ! -z "${pkgname}" ]; then
	    find -H ${pkgDir} -name ${pkgname}${PKGSUFFIX} -delete
	fi
    done

    buildLogs=$(tinderLoc buildlogs ${build})
    buildErrors=$(tinderLoc builderrors ${build})

    # Clean out all old packages if requested
    if [ ${cleanpackages} -eq 1 ]; then
	rm -rf ${pkgDir} ${buildLogs} ${buildErrors}
    fi

    # Make the package directories
    mkdir -p ${pkgDir} ${buildLogs} ${buildErrors}

    # (Re)create jail if needed
    jailDir=$(tinderLoc jail ${jail})
    if [ ${init} -eq 1 -o \( ! -d ${buildData} -a \
			   ! -f $(tinderLoc jailtarball ${jailDir}) \) ]; then
	echo "tinderbuild: Updating ${jail} jail for ${build}"
	${tc} makeJail -j ${jail}
    fi

    # Update ports tree if required
    if [ ${updateports} -eq 1 ]; then
	echo "tinderbuild: Updating ${portstree} portstree for ${build}"
	${tc} updatePortsTree -p ${portstree}
    fi

    # Create makefile if required
    if [ ${skipmake} -eq 0 ]; then
	echo "tinderbuild: creating makefile..."

	# Need to do this in a subshell so as to only hide the host
	# environment during makefile creation
	(
	    export PORTBUILD_ARGS="$(echo ${pbargs})"
	    buildenvNoHost
	    if ! requestMount -t portstree -p ${portstree}; then
		echo "tinderbuild: cant mount portstree: ${portstree}"
		exit 1
	    fi
	    env PORTSDIR=$(tinderLoc portstree ${portstree})/ports \
		$(tinderLoc scripts lib/makemake) ${noduds} ${build} ${ports}
	)
	if [ $? -ne 0 ]; then
	    echo "tinderbuild: failed to generate Makefile for ${build}"
	    cleanupMounts -t portstree -p ${portstree}
	    tinderbuild_cleanup 1
	else
	    cleanupMounts -t portstree -p ${portstree}
	fi
    fi

    # Set up the chrooted environment
    osmajor=$(echo ${jail} | sed -E -e 's|(^.).*$|\1|')
    case ${osmajor} in
    4|5|6|7)	tinderbuild_setup;;
    *)		echo "tinderbuild: unhandled OS version: ${osmajor}"
		tinderbuild_cleanup 1
		;;
    esac

    # Seatbelts off.  Away we go.
    ${tc} updateBuildStatus -b ${build} -s PORTBUILD
    tinderbuild_phase 0 ${jobs} ${pkgDir}
    if [ ${onceonly} -ne 1 ]; then
	tinderbuild_phase 1 ${jobs} ${pkgDir}
    fi
    tinderbuild_cleanup 0
}

#---------------------------------------------------------------------------
# Initialize tinderbox directories
#---------------------------------------------------------------------------

init () {
    for dir in builds errors logs packages portstrees wrkdirs
    do
	mkdir -p ${pb}/${dir}
    done

    return 0
}

#---------------------------------------------------------------------------
# add port to builds
#---------------------------------------------------------------------------

addPortToBuild () {
    build=$1
    portDir=$2
    norecurse=$3

    tc=$(tinderLoc scripts tc)
    jail=$(${tc} getJailForBuild -b ${build})
    portsTree=$(${tc} getPortsTreeForBuild -b ${build})

    if ! requestMount -t jail -j ${jail} -r; then
	echo "addPortToBuild: cant mount jail source"
	exit 1
    fi
    if ! requestMount -t portstree -p ${portsTree} -r; then
	echo "addPortToBuild: cant mount portstree source"
	exit 1
    fi

    buildenv ${jail} ${portsTree} ${build}
    buildenvNoHost

    export PORTSDIR=$(tinderLoc portstree ${portsTree})/ports
    ${tc} addPortToOneBuild -b ${build} -d ${portDir} ${norecurse}

    cleanupMounts -t jail -j ${jail}
    cleanupMounts -t portstree -p ${portsTree}
}

addPort () {
    # set up defaults
    build=""
    allBuilds=0
    portDir=""
    norecurse=""

    # argument handling
    while getopts ab:d:R arg >/dev/null 2>&1
    do
	case "${arg}" in

	a)	allBuilds=1;;
	b)	build="${OPTARG}";;
	d)	portDir="${OPTARG}";;
	R)	norecurse="-R";;
	?)	return 1;;

	esac
    done

    # argument validation
    if [ -z "${portDir}" ]; then
	echo "addPort: no port specified"
	return 1
    fi

    if [ ${allBuilds} -eq 1 ]; then
	if [ ! -z "${build}" ]; then
	    echo "addPort: -a and -b are mutually exclusive"
	    return 1
	fi

	tc=$(tinderLoc scripts tc)
	allBuilds=$(${tc} listBuilds 2>/dev/null)
	if [ -z "${allBuilds}" ]; then
	    echo "addPort: no builds are configured"
	    return 1
	fi

	for build in ${allBuilds}
	do
	    addPortToBuild ${build} ${portDir} ${norecurse}
	done
    else
	if ! tcExists Builds ${build}; then
	    echo "addPort: no such build: ${build}"
	    return 1
	fi

	addPortToBuild ${build} ${portDir} ${norecurse}
    fi

    return 0
}
