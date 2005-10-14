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
# $MCom: portstools/tinderbox/lib/tc_command.sh,v 1.9 2005/10/14 06:18:15 ade Exp $
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
# Tinderbox setup
#---------------------------------------------------------------------------

Setup () {
    MAN_PREREQS="lang/perl5.8 net/p5-Net security/p5-Digest-MD5"
    OPT_PREREQS="lang/php[45] databases/pear-DB www/php[45]-session"
    PREF_FILES="rawenv tinderbox.ph"
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

    RAWENV_HEADER="## rawenv TB v3 -- DO NOT EDIT"
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

    # Now migrate rawenv if needed.
    echo ""
    if ! migRawEnv ${pb}/scripts/rawenv ; then
	tinderExit "ERROR: Rawenv migration failed!  Consult the output above for more information." 1
    fi

    # Finally, migrate any remaining file data.
    echo ""
    if ! migFiles ${pb}/scripts/rawenv ; then
	tinderExit "ERROR: Files migration failed!  Consult the output above for more information." 1
    fi

    echo ""
    tinderExit "Congratulations!  Tinderbox migration is complete.  Please refer to ${TINDERBOX_URL} for a list of what is new in this version as well as general Tinderbox documentation." 0
}

#---------------------------------------------------------------------------
# Jail creation
#---------------------------------------------------------------------------

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
    cleanupMounts -d jail -j ${jailName}
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
# PortsTree creation
#---------------------------------------------------------------------------

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
    while getopts d:m:p:u:w:CH: arg >/dev/null 2>&1
    do
	case "${arg}" in

	d)	descr="${OPTARG}";;
	m)	mountSrc="${OPTARG}";;
	p)	portsTreeName="${OPTARG}";;
	u)	updateCmd="${OPTARG}";;
	w)	cvswebUrl="${OPTARG}";;
	C)	cvsupCompress=1;;
	H)	cvsupHost="${OPTARG}";;
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
    cleanupMounts -d portstree -p ${portsTreeName}
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

    # mount ports/ if required, to verify it exists
    if [ ! -z "${mountSrc}" ]; then
	echo -n "${portsTreeName}: verifying mount point... "
	requestMount -q -d portstree -p ${portsTreeName}
	if [ $? != 0 ]; then
	    echo "FAILED."
	    exit 1
	fi
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
    cleanupMounts -d portstree -p ${portsTreeName}
    return 0
}

#---------------------------------------------------------------------------
# Build creation
#---------------------------------------------------------------------------

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
# Make a Jail [previously mkjail]
#---------------------------------------------------------------------------

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

    # We only care about SRCBASE, so the other parameters can be anything
    buildenv ${pb} "NULL" ${jailName} "NULL"

    # Mount the source directory, if appropriate
    requestMount -q -r -d jail -j ${jailName}

    # Update the source tree, if requested
    update_cmd=$(${pb}/scripts/tc getSrcUpdateCmd -j ${jailName})
    if [ ! -z "${update_cmd}" ]; then
	echo "INFO: Updating jail with command ${update_cmd}"
	eval ${update_cmd} > ${pb}/jails/${jailName}/update.log 2>&1
	if [ $? != 0 ]; then
	    echo "ERROR: Jail update failed"
	    exit 1
	fi
    fi

    # Use a specific object directory if so requested.  In this case,
    # we also use a subdirectory for the temporary copy of the installed
    # OS image
    if [ -n "${JAIL_OBJDIR}" ]; then
        export MAKEOBJDIRPREFIX=${JAIL_OBJDIR}
	JAIL_TMPDIR=${JAIL_OBJDIR}/tmp/${jailName}
    else
	JAIL_TMPDIR=${pb}/jails/${jailName}/tmp
    fi

    # clean up after any previous build attempts
    cleanDirs ${jailName} ${JAIL_TMPDIR}

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

    # Use a specific object directory if so requested
    if [ -n "${JAIL_OBJDIR}" ]; then
	export MAKEOBJDIRPREFIX=${JAIL_OBJDIR}
    fi

    # Make world
    cd ${SRCBASE} && env DESTDIR=${JAIL_TMPDIR} make world
    if [ $? != 0 ]; then
	echo "ERROR: make world failed.  See above output."
	exit 1
    fi

    # Make a complete distribution
    cd ${SRCBASE}/etc && env DESTDIR=${JAIL_TMPDIR} make distribution
    if [ $? != 0 ]; then
	echo "ERROR: make distribution failed.  See above output."
	exit 1
    fi

    # Various hacks to keep the ports building environment happy
    ln -sf dev/null ${JAIL_TMPDIR}/kernel
    ln -sf aj ${JAIL_TMPDIR}/etc/malloc.conf
    touch -f ${JAIL_TMPDIR}/etc/fstab
    touch -f ${JAIL_TMPDIR}/etc/wall_cmos_clock

    MTREE_DIR=${SRCBASE}/etc/mtree
    mtree -deU -f ${MTREE_DIR}/BSD.root.dist  -p ${JAIL_TMPDIR}/
    mtree -deU -f ${MTREE_DIR}/BSD.var.dist   -p ${JAIL_TMPDIR}/var
    mtree -deU -f ${MTREE_DIR}/BSD.usr.dist   -p ${JAIL_TMPDIR}/usr
    mtree -deU -f ${MTREE_DIR}/BSD.local.dist -p ${JAIL_TMPDIR}/usr/local

    date '+%Y%m%d' > ${JAIL_TMPDIR}/var/db/port.mkversion
    mkdir -p ${JAIL_TMPDIR}/var/run

    rm -f ${JAIL_TMPDIR}/usr/lib/aout/lib*_p.a

    # Create the jail tarball
    TARBALL=${pb}/jails/${jailName}/${jailName}.tar
    tar -C ${JAIL_TMPDIR} -cf ${TARBALL}.new . && \
	mv -f ${TARBALL}.new ${TARBALL}
    if [ $? != 0 ]; then
	echo "ERROR: tarball creation failed.  See above output."
        exit 1
    fi

    # Update the last-built time
    ${pb}/scripts/tc updateJailLastBuilt -j ${jailName}

    # Finally, clean up
    cleanDirs ${jailName} ${JAIL_TMPDIR}

    cd ${pb}		# so we don't end up killing ourselves
    cleanupMounts -d jail -j ${jailName}

    return 0
}

#---------------------------------------------------------------------------
# Make a Build [previously mkbuild]
# XXX: the only consumer of this appears to be tinderbuild further on
#      down, so it's possible we don't need this as a public function
#---------------------------------------------------------------------------

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
    cleanupMounts -d build -b ${buildName}
    cleanDirs ${buildName} ${BUILD_DIR}

    # Extract the tarball
    tar -C ${BUILD_DIR} -xpf ${JAIL_TARBALL}

    # Finalize environment
    cp -f /etc/resolv.conf ${BUILD_DIR}/etc

    return 0
}

#---------------------------------------------------------------------------
# Build one or more packages
#---------------------------------------------------------------------------

tinderbuild_cleanup () {
    rm -f ${lock}
    ${pb}/scripts/tc updateBuildStatus -b ${build} -s IDLE
    ${pb}/scripts/tc sendBuildCompletionMail -b ${build}

    cleanupMounts -d jail -j ${jail}
    cleanupMounts -d portstree -p ${portstree}

    exit $1
}

tinderbuild_phase () {
    num=$1

    echo "================================================"
    echo "building packages (phase ${num})"
    echo "================================================"

    echo "started at $(date)"
    start=$(date +%s)

    cd ${PACKAGES}/All && \
	make -k -j1 all > ${pb}/builds/${build}/make.${num} 2>&1 </dev/null

    echo "ended at $(date)"
    end=$(date +%s)

    echo "phase ${num} took $(date -u -j -r $((${end} - ${start})) |
		awk '{print $4}')"
    echo $(echo $(ls -1 ${PACKAGES}/All | wc -l) - 1 | bc) "packages built"
    echo $(echo $(du -sh ${PACKAGES} | awk '{print $1}')) " of packages"
}

tinderbuild () {
    # set defaults
    _builds=$(${pb}/scripts/tc listBuilds)
    build=""
    ports=""
    init=0
    cleanpackages=0
    updateports=0
    noduds=0
    noclean=0
    plistcheck=0
    nullfs=0
    cleandistfiles=0
    skipmake=0
    fetchorig=0
    error=2

    # argument processing
    # XXX: at least for now, we're keeping the code the same here,
    #      though it should probably be rewritten to be more getopts
    #      friendly

    while [ $# -gt 0 ]; do
	case "x$1" in

	x-b)	shift
		for _build in ${_builds}; do
		    if [ "${_build}" = "$1" ]; then
			build=$1
			break
		    fi
		done
		if [ "x${build}" = "x" ]; then
		    echo "ERROR: Build, \"$1\" is not a valid build."
		    exit 1
		fi
		;;

	x-init)			init=1;;
	x-updateports)		updateports=1;;
	x-cleanpackages)	cleanpackages=1;;
	x-skipmake)		skipmake=1;;
	x-noduds)		noduds=1;;
	x-noclean)		noclean=1;;
	x-plistcheck)		plistcheck=1;;
	x-nullfs)		nullfs=1;;
	x-cleandistfiles)	cleandistfiles=1;;
	x-fetch-original)	fetchorig=1;;
	-*)			return 1;;
	*)			ports="${ports} $1";;

	esac

	shift
    done


    if [ "x${build}" = "x" ]; then
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

    trap "tinderbuild_cleanup ${error}" 1 2 3 9 10 11 15

    # XXX This is a crude hack to normalize ${ports}
    ports=$(echo ${ports})

    jail=$(${pb}/scripts/tc getJailForBuild -b ${build})
    portstree=$(${pb}/scripts/tc getPortsTreeForBuild -b ${build})

    # Setup the environment for this jail.
    buildenv ${pb} ${build} ${jail} ${portstree}

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

    # First we check to see if we need to clean out old packages.
    if [ "$cleanpackages" = "1" ]; then
	rm -rf ${PACKAGES}
	rm -rf ${pb}/logs/${build}
	rm -rf ${pb}/errors/${build}
    fi

    if [ -n "${DISTFILE_CACHE}" -a "$cleandistfiles" = "1" ]; then
	requestMount -d distcache -b ${build} -s ${DISTFILE_CACHE}
	rm -rf ${pb}/${build}/distcache/*
	cleanupMounts -d distcache -b ${build}
    fi

    requestMount -q -r -d portstree -p ${portstree}
    requestMount -q -r -d jail -j ${jail}

    mkdir -p ${PACKAGES}
    mkdir -p ${pb}/logs/${build}
    mkdir -p ${pb}/errors/${build}

    if [ "$updateports" = "1" ]; then
	echo "INFO: Running ${update_cmd} to update the ports tree"
	${pb}/scripts/tc updatePortsTree -p ${portstree}
    fi

    if [ "$skipmake" = "0" ]; then
	duds=
	if [ "$noduds" = "1" ]; then
	    duds="-n"
	fi
	if [ "$noclean" = "1" ]; then
	    export NOCLEAN=1
	fi
	if [ "$plistcheck" = "1" ]; then
	    export PLISTCHECK=1
	fi
	if [ "$nullfs" = "1" ]; then
	    export NULLFS=1
	fi
	if [ "$fetchorig" = "1" ]; then
	    export FETCHORIG=1
	fi

        ${pb}/scripts/lib/makemake ${duds} ${build} ${ports}
	if [ $? != 0 ]; then
	    echo "ERROR: Failed to generate Makefile for ${build}"
	    tinderbuild_cleanup 1
	fi
    fi

    # Then we check to see if we need to create our jail directory.
    if [ "$init" = "1" -o \( ! -d ${pb}/${build} -a \
			     ! -f ${pb}/jails/${jail}/${jail}.tar \) ]; then
	echo "INFO: Initializing a new build directory for ${build}..."
	${pb}/scripts/tc makeJail -j ${jail}
	${pb}/scripts/tc makeBuild -b ${build}
    else
	echo "INFO: Creating build directory for ${build} from repository..."
	${pb}/scripts/tc makeBuild -b ${build}
    fi

    ${pb}/scripts/tc updateBuildStatus -b ${build} -s PORTBUILD

    # We build the packages in two phases to make sure we get everything
    tinderbuild_phase 0
    tinderbuild_phase 1

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
