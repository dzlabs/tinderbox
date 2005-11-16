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
# $MCom: portstools/tinderbox/lib/tc_command.sh,v 1.19 2005/11/16 01:07:14 ade Exp $
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
    if $? != 0 ]; then
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
    README="${pb}/scripts/README"
    TINDERBOX_URL="http://tinderbox.marcuscom.com/"

    clear

    tinderEcho "Welcome to the Tinderbox Setup script.  This script will guide you through some of the automated Tinderbox setup steps.  Once this script completes , you should review the documentation in ${README} or on the web at ${TINDERBOX_URL} to complete your setup."
    echo ""

    read -p "Hit <ENTER> to get started: " dummy

    # First, check to see that all of the pre-requisites are installed.
    tinderEcho "INFO: Checking prerequisites ..."

    missing=$(checkPreReqs ${MAN_PREREQS})
    if [ $? != 0 ]; then
	tinderEcho "ERROR: The following mandatory dependencies are missing.  These must be installed prior to running the Tinderbox setup script."
	tinderEcho "ERROR:   ${missing}"
	exit 1
    fi

    # Now, check the optional pre-reqs (for web usage).
    missing=$(checkPreReqs ${OPT_PREREQS})
    if [ $? != 0 ]; then
	tinderEcho "WARN: The following option dependencies are missing.  These are required to use the Tinderbox web front-ends."
	tinderEcho "WARN:  ${missing}"
    fi

    tinderEcho "DONE."
    echo ""

    # Now install the default preferences files.
    tinderEcho "INFO: Creating default configuration files ..."
    for f in ${PREF_FILES} ; do
	if [ ! -f ${pb}/scripts/${f}.dist ]; then
	    tinderExit "ERROR: Missing required distribution file ${pb}/scripts/${f}.dist.  Please download and extract Tinderbox again."
	fi
	if [ -f ${pb}/scripts/${f} ]; then
	    cp -p ${pb}/scripts/${f} ${pb}/scripts/${f}.bak
	fi
	cp -f ${pb}/scripts/${f}.dist ${pb}/scripts/${f}
    done
    tinderEcho "DONE."
    echo ""

    # Now create the database if we can.
    tinderEcho "INFO: Beginning database configuration."

    db_driver=$(getDbDriver)

    if [ ! -f "${pb}/scripts/lib/setup-${db_driver}.sh" ]; then
	tinderEcho "ERROR: Failed to locate a setup script for the ${db_driver} database driver."
	exit 1
    fi

    . ${pb}/scripts/lib/setup-${db_driver}.sh

    tinderEcho "INFO: Database configuration complete."
    echo ""

    # We're done now.  However, we don't want to be calling 'tc init'
    # here since the user may need to configure tinderbox.ph first
    tinderExit "Congratulations!  The scripted portion of Tinderbox has completed successfully.  You should now verify the settings in ${pb}/scripts/tinderbox.ph are correct for your environment, then run '${pb}/scripts/tc init' to complete the setup.  Be sure to checkout ${TINDERBOX_URL} for further instructions." 0
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
    if ${pb}/scripts/tc dsversion >/dev/null 2>&1 ; then
	DSVERSION=$(${pb}/scripts/tc dsversion)
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

    if [ $? = 0 ]; then
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

    if [ ${do_load} = 0 ]; then
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

    updateCmdName=$(${pb}/scripts/tc getUpdateCmd -j ${jailName})
    jailDir=${pb}/jails/${jailName}

    case "${updateCmdName}" in

    CVSUP)	updateCmd="${cvsupProg} -g ${jailDir}/src-supfile";;
    NONE)	updateCmd="NONE";;
    "^/.*")	updateCmd="${updateCmdName} ${jailName}";;
    *)		updateCmd="${pb}/scripts/${updateCmd} ${jailName}";;

    esac

    updateTree jail ${jailName} -j ${jailDir} ${updateCmd}
    return 0
}

buildJailCleanup () {
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
    jailSrcMt=$(${pb}/scripts/tc getSrcMount -j ${jailName})
    jailObj=$(${pb}/scripts/tc configGet | awk -F= '/^JAIL_OBJDIR/ {print $2}')
    jailBase=${pb}/jails/${jailName}

    if [ -z "${jailObj}" ]; then
	J_OBJDIR=${jailBase}/obj
	J_SRCDIR=${jailBase}/src
	J_TMPDIR=${jailBase}/tmp
	if [ -n "${jailSrcMt}" ]; then
	    reqmt="-r"
	fi
    else
	J_OBJDIR=${jailObj}/${jailName}/obj
	J_TMPDIR=${jailObj}/${jailName}/tmp
	if [ -n "${jailSrcMt}" ]; then
	    J_SRCDIR=${jailObj}/${jailName}/src
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
    cleanDirs ${jailName} ${J_TMPDIR} ${J_OBJDIR}

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

    # Make world
    echo "${jailName}: making world"
    cd ${SRCBASE} && env DESTDIR=${J_TMPDIR} \
	make world > ${jailBase}/world.log 2>&1
    if [ $? != 0 ]; then
	echo "ERROR: world failed - see ${jailBase}/world.log"
	exit 1
    fi

    # Make a complete distribution
    echo "${jailName}: making distribution"
    cd ${SRCBASE}/etc && env DESTDIR=${J_TMPDIR} \
	make distribution > ${jailBase}/distribution.log 2>&1
    if [ $? != 0 ]; then
	echo "ERROR: distribution failed - see ${jailBase}/distribution.log"
	exit 1
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
    mkdir -p ${pb}/jails/${jailName}
    TARBALL=${pb}/jails/${jailName}/${jailName}.tar
    tar -C ${J_TMPDIR} -cf ${TARBALL}.new . && \
	mv -f ${TARBALL}.new ${TARBALL}
    if [ $? != 0 ]; then
	echo "ERROR: tarball creation failed."
        exit 1
    fi

    # Update the last-built time
    ${pb}/scripts/tc updateJailLastBuilt -j ${jailName}

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
    cvsupCompress=0
    descr=""
    jailName=""
    mountSrc=""
    tag=""
    updateCmd="CVSUP"
    init=1

    # argument handling
    while getopts d:j:m:t:u:CH:I arg >/dev/null 2>&1
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
    basedir=${pb}/jails/${jailName}
    cleanupMounts -t jail -j ${jailName}
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

    ${pb}/scripts/tc addJail -j ${jailName} \
	-t ${tag} ${updateCmd} ${mountSrc} "${descr}"
    if [ $? != 0 ]; then
	echo "FAILED."
	exit 1
    fi
    echo "done."

    # now initialize the jail (unless otherwise requested)
    if [ ${init} = 1 ]; then
	echo "${jailName}: initializing new jail..."
	makeJail -j ${jailName}
	if [ $? != 0 ]; then
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

    updateCmdName=$(${pb}/scripts/tc getUpdateCmd -p ${portsTreeName})
    portsTreeDir=${pb}/portstrees/${portsTreeName}

    case "${updateCmdName}" in

    CVSUP)	updateCmd="${cvsupProg} -g ${portsTreeDir}/ports-supfile";;
    NONE)	updateCmd="NONE";;
    "^/.*")	updateCmd="${updateCmdName} ${portsTreeName}";;
    *)		updateCmd="${pb}/scripts/${updateCmd} ${portsTreeName}";;

    esac

    updateTree portstree ${portsTreeName} -p ${portsTreeDir} ${updateCmd}
    return 0
}

createPortsTree () {
    # set up defaults
    cvsupHost=${defaultCvsupHost}
    cvsupCompress=0
    cvswebUrl=""
    descr=""
    init=1
    mountSrc=""
    portsTreeName=""
    updateCmd="CVSUP"

    # argument handling
    while getopts d:m:p:u:w:CH:I arg >/dev/null 2>&1
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
    basedir=${pb}/portstrees/${portsTreeName}
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

    ${pb}/scripts/tc addPortsTree -p ${portsTreeName} \
	-u ${updateCmd} ${mountSrc} ${cvswebUrl} "${descr}"
    if [ $? != 0 ]; then
	echo "FAILED."
	exit 1
    fi
    echo "done."

    if [ ${init} = 1 ]; then
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

    if [ ! -f ${pb}/${build} ]; then
	echo "enterBuild: Build directory (${pb}/${build}) does not exist"
	return 1
    fi

    sleepName=$(echo ${portDir} | sed -e 'y/\//_/')

    if [ ! -d ${pb}/${build}/usr/ports/${portDir} ]; then
	echo "enterBuild: Build environment does not exist yet, sleeping."
	while [ ! -d ${pb}/${build}/usr/ports/${portDir} ]; do
	    sleep 1
	done
    fi

    if [ ! -f ${pb}/${build}/usr/ports/${portDir}/.sleepme ]; then
	echo "enterBuild: Build not marked for sleeping. Marking it."
	touch ${pb}/${build}/usr/ports/${portDir}/.sleepme
	if [ ! -f ${pb}/${build}/usr/ports/${portDir}/.sleepme ]; then
	    echo "enterBuild: cannot touch ${pb}/${build}/usr/ports/${portDir}/.sleepme."
	    return 1
	fi
	autoSleep=1
    fi

    while [ ! -f ${pb}/${build}/tmp/.sleep_${sleepName} ]; do
	echo "enterBuild: Build not yet sleeping, waiting 15 seconds."
	sleep 15
    done

    cp ${pb}/scripts/lib/enterbuild ${pb}/${build}/root
    chroot ${pb}/${build} /root/enterbuild ${portDir}
    rm -f ${pb}/${build}/tmp/.sleep_${sleepName}

    echo "enterBuild: Continuing port build."

    if [ ${autoSleep} = 1 ]; then
        resp="y"
    else
	echo -n "Remove .sleepme too? [yN] "
	read resp
    fi
    if [ "${resp}" = "y" ]; then
	rm -f ${pb}/$build}/usr/ports/${portDir}/.sleepme
	if [ -f ${pb}/$build}/usr/ports/${portDir}/.sleepme ]; then
	    echo "enterBuild: failed to remove ${pb}/$build}/usr/ports/${portDir}/.sleepme!"
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
    jailName=$(${pb}/scripts/tc getJailForBuild -b ${buildName})

    BUILD_DIR=${pb}/${buildName}
    JAIL_TARBALL=${pb}/jails/${jailName}/${jailName}.tar

    if [ ! -f ${JAIL_TARBALL} ]; then
	echo "ERROR: tarball for jail \"${jailName}\" doesn't exist."
	echo "ERROR: run \"tc makeJail -j ${jailName}\" first."
	exit 1
    fi

    # Clean up any previous build tree
    cleanupMounts -t buildsrc -b ${buildName}
    cleanupMounts -t buildports -b ${buildName}
    cleanupMounts -t ccache -b ${buildName}
    cleanupMounts -t distcache -b ${buildName}
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
    init=0
    jailName=""
    portsTreeName=""

    # argument handling
    while getopts b:d:ij:p: arg >/dev/null 2>&1
    do
	case "${arg}" in

	b)	buildName="${OPTARG}";;
	d)	descr="${OPTARG}";;
	i)	init=1;;
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
	makeBuild -b ${buildName}

	if [ $? != 0 ]; then
	    echo "FAILED."
	    exit 1
	fi
	echo "done."
    fi

    # finished
    return 0
}

#---------------------------------------------------------------------------
# Build one or more packages
#---------------------------------------------------------------------------

tinderbuild_reset () {
    cleanupMounts -t buildsrc -b $1
    cleanupMounts -t buildports -b $1
    cleanupMounts -t ccache -b $1
    cleanupMounts -t distcache -b $1
    umount -f ${pb}/$1/dev >/dev/null 2>&1
    umount -f ${pb}/$1/compat/linux/proc >/dev/null 2>&1
}

tinderbuild_cleanup () {
    rm -f ${lock}
    ${pb}/scripts/tc updateBuildStatus -b ${build} -s IDLE
    ${pb}/scripts/tc sendBuildCompletionMail -b ${build}
    tinderbuild_reset ${build}

    exit $1
}

tinderbuild_setup () {
    # Make sure everything is dismounted, clean out the build tree
    # and recreate it from scratch
    echo "INFO: Creating build directory for ${build}"
    tinderbuild_reset ${build}
    makeBuild -b ${build}

    # set up the rest of the chrooted environment, we really do
    # not need to be doing this every single time portbuild is called

    chroot=${pb}/${build}
    echo "INFO: Finalizing chroot environment"

    # Mount ports/
    if ! requestMount -t buildports -b ${build} -r ${nullfs}; then
	echo "tinderbuild: cant mount ports source"
	tinderbuild_cleanup 1
    fi
    ln -sf ../a/ports ${pb}/${build}/usr/ports

    # Mount src/
    if ! requestMount -t buildsrc -b ${build} -r ${nullfs}; then
	echo "tinderbuild: cant mount jail source"
	tinderbuild_cleanup 1
    fi

    # handle OS version dependent bits and pieces
    libc_hackery=""
    case ${osmajor} in

    4)
	mkdir -p ${chroot}/libexec
	mkdir -p ${chroot}/lib
	if [ "${ARCH}" = "i386" -o "${ARCH}" = "amd64" ]; then
	    cp -p /sbin/mount_linprocfs /sbin/mount /sbin/umount ${chroot}/sbin
	    cp -p /lib/libufs.so.[0-9]* ${chroot}/lib
	fi
	cp -p /libexec/ld-elf.so.1 ${chroot}/libexec
	cp -p /lib/libkvm.so.[0-9]* /lib/libm.so.[0-9]* ${chroot}/lib
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
	chflags noschg ${chroot}/lib/${libc_hackery} >/dev/null 2>&1
	cp -p /lib/${libc_hackery} ${chroot}/lib
    fi

    # For use by pnohang
    # XXX: though killall may not work since it's a dynamic executable
    cp -p /rescue/ps ${chroot}/bin
    cp -p /usr/bin/killall ${chroot}/bin

    # Mount /dev, since we're going to be chrooting shortly
    mount -t devfs devfs ${chroot}/dev >/dev/null 2>&1

    # Some linux-related ports need linprocfs
    if [ ${ARCH} = "i386" -o ${ARCH} = "amd64" ]; then
	mkdir -p ${chroot}/compat/linux/proc
	mount_linprocfs linprocfs ${chroot}/compat/linux/proc
    fi

    # Install a couple of tinderbox binaries
    if ! cp -p ${pb}/scripts/lib/buildscript ${chroot}; then
	echo "ERROR: cant copy buildscript"
	tinderbuild_cleanup 1
    fi

    if ! cc -o ${chroot}/pnohang -static ${pb}/scripts/lib/pnohang.c; then
	echo "ERROR: cant compile pnohang"
	tinderbuild_cleanup 1
    fi

    # Hack to fix some recent pkg_add problems in some releases
    if [ -f ${pb}/jails/${jail}/pkg_install.tar ]; then
	tar -C ${chroot} -xf ${pb}/jails/${jail}/pkg_install.tar
    fi

    # Handle the distfile cache
    if [ -n "${DISTFILE_CACHE}" ]; then
	if ! requestMount -t distcache -b ${build} -s ${DISTFILE_CACHE}; then
	    echo "tinderbuild: cant mount distfile cache"
	    tinderbuild_cleanup 1
	fi

	if [ ${cleandistfiles} = 1 ]; then
	    echo "INFO: Cleaning out distfile cache"
	    rm -rf ${chroot}/distcache/*
	fi
    fi

    # Handle ccache
    if [ ${CCACHE_ENABLED} = 1 ]; then

	# per-build, or per-jail, ccache?
	if [ ${CCACHE_JAIL} = 1 ]; then
	    ccacheDir=${pb}/${CCACHE_DIR}/${jail}
	else
	    ccacheDir=${pb}/${CCACHE_DIR}/${build}
	fi

	# create directories if need be
	mkdir -p ${ccacheDir} ${pb}/${build}/ccache

	if ! requestMount -t ccache -b ${build} -s ${ccacheDir} ${nullfs}; then
	    echo "tinderbuild: cant mount ccache"
	    tinderbuild_cleanup 1
	fi

	if [ -f ${pb}/jails/${jail}/ccache.tar ]; then
	    tar -C ${chroot} -xf ${pb}/jails/${jail}/ccache.tar
	    if [ -n "${CCACHE_MAX_SIZE}" ]; then
		chroot ${chroot} /opt/ccache -M ${CCACHE_MAX_SIZE}
	    fi
	fi
    fi
}

tinderbuild_phase () {
    num=$1
    jobs=$2

    echo "================================================"
    echo "building packages (phase ${num})"
    echo "================================================"

    echo "started at $(date)"
    start=$(date +%s)

    cd ${PACKAGES}/All && make -k -j${jobs} all \
	> ${pb}/builds/${build}/make.${num} 2>&1 </dev/null

    echo "ended at $(date)"
    end=$(date +%s)

    echo "phase ${num} took $(date -u -j -r $((${end} - ${start})) |
		awk '{print $4}')"
    echo $(echo $(ls -1 ${PACKAGES}/All | wc -l) - 1 | bc) "packages built"
    echo $(echo $(du -sh ${PACKAGES} | awk '{print $1}')) " of packages"
}

tinderbuild () {
    # set up defaults
    build=""
    ports=""
    cleandistfiles=0
    cleanpackages=0
    init=0
    jobs=1
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
		echo "ERROR: Build, \"$1\" is not a valid build."
		exit 1
	    fi
	    build=$1
	    ;;

	x-jobs)
	    shift
	    if ! expr -- "$1" : "^[[:digit:]]\{1,\}$" >/dev/null 2>&1 ; then
		echo "ERROR: The argument to -jobs must be a number."
		exit 1
	    elif [ $1 -lt 1 ]; then
		echo "ERROR: The argument to -jobs must be a number >= 1."
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

	-*)			return 1;;
	*)			ports="${ports} $1";;

	esac

	shift
    done

    if [ -z "${build}" ]; then
	return 1
    fi

    lock=${pb}/builds/${build}/lock

    if [ -e ${lock} ]; then
	echo "ERROR: Lock file ${lock} exists; exiting."
	exit 1
    fi

    if ! touch ${lock} ; then
	echo "ERROR: Lock file ${lock} could not be created; exiting."
	exit 1
    fi

    # Let the datastore known what we're doing.
    ${pb}/scripts/tc updateBuildStatus -b ${build} -s PREPARE

    trap "tinderbuild_cleanup 2" 1 2 3 9 10 11 15

    # XXX: This is a crude hack to normalize ${ports}
    ports=$(echo ${ports})

    # Setup the environment for this jail
    jail=$(${pb}/scripts/tc getJailForBuild -b ${build})
    portstree=$(${pb}/scripts/tc getPortsTreeForBuild -b ${build})

    requestMount -t jail -j ${jail}
    buildenv ${jail} ${portstree} ${build}
    cleanupMounts -t jail -j ${jail}

    # Remove the make logs.
    rm -f ${pb}/builds/${build}/make.*

    # Clean up packages if specific ports dirs were specified
    # on the command line
    for port in ${ports}; do
	pkgname=$(${pb}/scripts/tc getPortLastBuiltVersion \
			-b ${build} -d ${port})
	if [ ! -z "${pkgname}" ]; then
	    find -H ${PACKAGES} -name ${pkgname}${PKGSUFFIX} -delete
	fi
    done

    # Clean out all old packages if requested
    if [ ${cleanpackages} = 1 ]; then
	rm -rf ${PACKAGES}
	rm -rf ${pb}/logs/${build}
	rm -rf ${pb}/errors/${build}
    fi

    # Make the package directories
    mkdir -p ${PACKAGES}
    mkdir -p ${pb}/logs/${build}
    mkdir -p ${pb}/errors/${build}

    # (Re)create jail if needed
    if [ ${init} = 1 -o \( ! -d ${pb}/${build} -a \
			   ! -f ${pb}/jails/${jail}/${jail}.tar \) ]; then
	echo "INFO: Updating ${jail} jail for ${build}"
	${pb}/scripts/tc makeJail -j ${jail}
    fi

    # Update ports tree if required
    if [ ${updateports} = 1 ]; then
	echo "INFO: Updating ${portstree} portstree for ${build}"
	${pb}/scripts/tc updatePortsTree -p ${portstree}
    fi

    # Create makefile if required
    if [ ${skipmake} = 0 ]; then
	echo "INFO: creating makefile..."

	# Need to do this in a subshell so as to only hide the host
	# environment during makefile creation
	(
	    export PORTBUILD_ARGS="$(echo ${pbargs})"
	    buildenvNoHost
	    if ! requestMount -t portstree -p ${portstree}; then
		echo "tinderbuild: cant mount portstree: ${portstree}"
		exit 1
	    fi
	    ${pb}/scripts/lib/makemake ${noduds} ${build} ${ports}
	)
	if [ $? != 0 ]; then
	    echo "ERROR: failed to generate Makefile for ${build}"
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
    *)		echo "ERROR: tinderbox: unhandled OS version: ${osmajor}"
		tinderbuild_cleanup 1
		;;
    esac

    # Seatbelts off.  Away we go.
    ${pb}/scripts/tc updateBuildStatus -b ${build} -s PORTBUILD
    tinderbuild_phase 0 ${jobs}
    tinderbuild_phase 1 ${jobs}
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
    recursive=$3

    jail=$(${pb}/scripts/tc getJailForBuild -b ${build})
    portsTree=$(${pb}/scripts/tc getPortsTreeForBuild -b ${build})

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

    ${pb}/scripts/tc addPortToOneBuild -b ${build} -d ${portDir} ${recursive}

    cleanupMounts -t jail -j ${jail}
    cleanupMounts -t portstree -p ${portsTree}
}

addPort () {
    # set up defaults
    build=""
    allBuilds=0
    portDir=""
    recursive=""

    # argument handling
    while getopts ab:d:r arg >/dev/null 2>&1
    do
	case "${arg}" in

	a)	allBuilds=1;;
	b)	build="${OPTARG}";;
	d)	portDir="${OPTARG}";;
	r)	recursive="-r";;
	?)	return 1;;

	esac
    done

    # argument validation
    if [ -z "${portDir}" ]; then
	echo "addPort: no port specified"
	return 1
    fi

    if [ ${allBuilds} = 1 ]; then
	if [ ! -z "${build}" ]; then
	    echo "addPort: -a and -b are mutually exclusive"
	    return 1
	fi

	allBuilds=$(${pb}/scripts/tc listBuilds 2>/dev/null)
	if [ -z "${allBuilds}" ]; then
	    echo "addPort: no builds are configured"
	    return 1
	fi

	for build in ${allBuilds}
	do
	    addPortToBuild ${build} ${portDir} ${recursive}
	done
    else
	if ! tcExists Builds ${build}; then
	    echo "addPort: no such build: ${build}"
	    return 1
	fi

	addPortToBuild ${build} ${portDir} ${recursive}
    fi

    return 0
}
