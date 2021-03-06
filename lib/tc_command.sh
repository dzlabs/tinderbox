#!/bin/sh
#
# Copyright (c) 2005-2008 FreeBSD GNOME Team <freebsd-gnome@FreeBSD.org>
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
# $MCom: portstools/tinderbox/lib/tc_command.sh,v 1.157 2012/10/27 17:38:49 marcus Exp $
#

export _defaultUpdateHost="cvsup18.FreeBSD.org"
export _defaultUpdateType="CSUP"

use_pkgng=no
use_pkgng=$(make -VWITH_PKGNG)

#---------------------------------------------------------------------------
# Generic routines
#---------------------------------------------------------------------------
generateUpdateCode () {
    case ${1} in

    "jail")	  treeDir=$(tinderLoc jail ${2})
		  updateCollection="src-all"
		  ;;

    "portstree")  treeDir=$(tinderLoc portstree ${2})
		  updateCollection="ports-all"
		  ;;

    *)		  echo "ERROR: ${1} ${2}: unknown tree type"
		  exit 1
		  ;;

    esac

    case ${3} in

    "NONE")	if [ -x ${treeDir}/update.sh ]; then
		    echo "ERROR: ${1} ${2}: found update script (NONE)"
		    exit 1
		fi
		;;

    "USER")	if [ ! -x ${treeDir}/update.sh ]; then
		    echo "ERROR: ${1} ${2}: no update script (USER)"
		    exit 1
		fi
		;;

    "LFTP")
    		if [ -z "${5}" -o "${5}" = "UNUSED" ]; then
		    echo "ERROR: ${1} ${2}: no tag specified for ${3}"
		    exit 1
		fi

		updateArch="${7}"
		if [ -z "${updateArch}" ]; then
		    updateArch=$(uname -p)
		fi

		updateCmd="/usr/local/bin/lftp"
		fetchCmd="/usr/bin/fetch"
		fetchSets="base src"
		if [ "${updateArch}" = "amd64" ]; then
		   fetchSets="${fetchSets} lib32"
		fi
		fetchSufx=".txz"
		fetchUrl="ftp://${4}/pub/FreeBSD/releases/${updateArch}/${5}"


		if [ ! -x "${updateCmd}" ]; then
		    echo "ERROR: ${2} ${3}: ${updateCmd} missing"
		    exit 1
		fi

		if [ -d ${treeDir} ]; then
		    echo "${2}: cleaning out old directories"
		    cleanDirs ${2} ${treeDir}
		fi
		if [ ! -d ${treeDir} ]; then
		    echo "${2}: creating top-level directory"
		    mkdir -p ${treeDir} >/dev/null 2>&1
		fi

		if [ "$(${fetchCmd} -s ${fetchUrl}/${fetchSets%% *}${fetchSufx})" != "Unknown" ]; then
		  ( updateCmd="${fetchCmd}"
		    echo "#!/bin/sh"
		    echo "mkdir -p ${treeDir}/sets"
		    echo "cd ${treeDir}/sets"
		    for set in ${fetchSets}; do
		        echo "${updateCmd} -r ${fetchUrl}/${set}${fetchSufx}"
		    done
		    echo "mkdir ${treeDir}/src"
		    echo "tar --unlink -xpf src${fetchSufx} -s '/usr//' -C ${treeDir}"
		  ) > ${treeDir}/update.sh
		else
		  ( updateCmd="/usr/local/bin/lftp"
		    echo "#!/bin/sh"
		    echo "mkdir -p ${treeDir}/sets"
		    echo "cd ${treeDir}/sets"
		    echo "${updateCmd} -c \"open ftp://${4}/pub/FreeBSD/releases/${updateArch}/${5}/; mirror base\""
		    echo "${updateCmd} -c \"open ftp://${4}/pub/FreeBSD/releases/${updateArch}/${5}/; mirror dict\""
		    if [ "${updateArch}" = "amd64" ]; then
		        echo "${updateCmd} -c \"open ftp://${4}/pub/FreeBSD/releases/${updateArch}/${5}/; mirror lib32\""
		    fi
		    echo "${updateCmd} -c \"open ftp://${4}/pub/FreeBSD/releases/${updateArch}/${5}/; mirror proflibs\""
		    echo "${updateCmd} -c \"open ftp://${4}/pub/FreeBSD/releases/${updateArch}/${5}/; mirror src\""
		    echo "cd src"
		    echo "sed -i \"\" 's|usr/src|src|' install.sh"
		    echo "export DESTDIR=${treeDir}"
		    echo "mkdir ${treeDir}/src"
		    echo "yes | sh ./install.sh all"
		  ) > ${treeDir}/update.sh
		fi
		chmod +x ${treeDir}/update.sh
		;;

    "CVSUP"|"CSUP")
    		if [ -z "${5}" -o "${5}" = "UNUSED" ]; then
		    echo "ERROR: ${1} ${2}: no tag specified for ${3}"
		    exit 1
		fi

		updateCmd=""
		if [ "${3}" = "CVSUP" ]; then
		    updateCmd="/usr/local/bin/cvsup"
		elif [ "${3}" = "CSUP" ]; then
		    if [ -x /usr/bin/csup ]; then
			updateCmd="/usr/bin/csup"
		    else
			updateCmd="/usr/local/bin/csup"
		    fi
		fi
		if [ -z "${updateCmd}" ]; then
		    echo "ERROR: ${2}: unable to determine updateCmd for ${3}"
		    exit 1
		fi
		if [ ! -x "${updateCmd}" ]; then
		    echo "ERROR: ${2} ${3}: ${updateCmd} missing"
		    exit 1
		fi

		if [ -d ${treeDir} ]; then
		    echo "${2}: cleaning out old directories"
		    cleanDirs ${2} ${treeDir}
		fi
		if [ ! -d ${treeDir} ]; then
		    echo "${2}: creating top-level directory"
		    mkdir -p ${treeDir} >/dev/null 2>&1
		fi

		( echo "*default host=${4}"
		  echo "*default base=${treeDir} prefix=${treeDir}"
		  echo "*default release=cvs delete use-rel-suffix"
		  if [ ${6} -eq 1 ]; then
		      echo "*default compress"
		  fi
		  echo ""
		  echo "${updateCollection} tag=${5}"
		) > ${treeDir}/supfile

		( echo "#!/bin/sh"
		  echo "${updateCmd} ${treeDir}/supfile"
		) > ${treeDir}/update.sh
		chmod +x ${treeDir}/update.sh
		;;
    "SVN")
    		if [ -z "${8}" ]; then
		    echo "ERROR: ${1} ${2}: no protocol specified for ${3}"
		    exit 1
		fi

    		if [ -z "${9}" ]; then
		    echo "ERROR: ${1} ${2}: no host directory specified for ${3}"
		    exit 1
		fi

		updateCmd="/usr/local/bin/svn"

		if [ ! -x "${updateCmd}" ]; then
		    echo "ERROR: ${2} ${3}: ${updateCmd} missing"
		    exit 1
		fi

		if [ -d ${treeDir} ]; then
		    echo "${2}: cleaning out old directories"
		    cleanDirs ${2} ${treeDir}
		fi

		if [ ! -d ${treeDir} ]; then
		    echo "${2}: creating top-level directory"
		    mkdir -p ${treeDir} >/dev/null 2>&1
		fi

		case ${1} in
		"jail")		treeSubDir="src"
		;;
		"portstree")	treeSubDir="ports"
		;;
		esac

		( echo "#!/bin/sh"
		  echo "cd ${treeDir}"
		  echo "if [ ! -d ${treeDir}/${treeSubDir} ]; then"
		  echo "${updateCmd} co ${8}://${4}/${9} ${treeSubDir}"
		  echo "else"
		  echo "cd ${treeDir}/${treeSubDir}"
		  echo "${updateCmd} up"
		  echo "fi"
		) > ${treeDir}/update.sh
		chmod +x ${treeDir}/update.sh
		;;

    *)		echo "ERROR: ${1} ${2}: unknown update type: ${3}"
		exit 1;;

    esac
}

setupDefaults () {
    globalenv=$(tinderLoc scripts etc/env)/GLOBAL
    if [ -f ${globalenv} ]; then
	. ${globalenv}
    fi
    if [ -z "${defaultUpdateHost}" ]; then
        export defaultUpdateHost=${_defaultUpdateHost}
    fi
    if [ -z "${defaultUpdateType}" ]; then
        export defaultUpdateType=${_defaultUpdateType}
    fi
}

tcExists () {
    list=$($(tinderLoc scripts tc) list$1 2>/dev/null)
    for obj in ${list}; do
	if [ x"${obj}" = x"$2" ]; then
	    return 0
	fi
    done

    return 1
}

updateTree () {
    what=$1
    name=$2
    flag=$3
    dir=$4

    tc=$(tinderLoc scripts tc)
    updateCmd=$(${tc} getUpdateCmd ${flag} ${name})

    if [ "${updateCmd}" = "NONE" ]; then
	echo "updateTree: ${what} ${name}: nothing to do"
	return 0
    fi

    if [ ! -x ${dir}/update.sh ]; then
	echo "updateTree: ${what} ${name}: missing update script!"
	return 1
    fi

    echo "${name}: updating ${what} with ${updateCmd}"

    if [ "${updateCmd}" = "USER" ]; then
        eval ${dir}/update.sh ${name} > ${dir}/update.log 2>&1
    else
	eval ${dir}/update.sh > ${dir}/update.log 2>&1
    fi
    if [ $? -ne 0 ]; then
	echo "updateTree: ${what} ${name}: update failed"
	echo "    see ${dir}/update.log for more details"
	return 1
    fi
}

#---------------------------------------------------------------------------
# Tinderbox setup
#---------------------------------------------------------------------------

Setup () {
    MAN_PREREQS="lang/perl5.[81]*@perl-5.[81]*"
    OPT_PREREQS="lang/php[45]@php[45]-* www/php[45]-session@php[45]-session* archivers/p5-Compress-Bzip2@p5-Compress-Bzip2-*"
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

    db_host=""
    db_name=""
    db_admin=""
    do_load=0
    db_driver=$(getDbDriver)
    case "${db_driver}" in
        sqlite)
            dbinfo=$(getDbInfoSQLite)
            ;;
        *)
            dbinfo=$(getDbInfo ${db_driver})
            ;;
    esac
    db_res=$?
    genschema=$(tinderLoc scripts sql/genschema)
    if [ ${db_res} = 0 ] && [ ${db_driver} != "sqlite" ]; then
        db_admin_host_name=${dbinfo%:*}
        db_admin_host=${db_admin_host_name%:*}
        db_name=${db_admin_host_name##*:}
        db_admin=${db_admin_host%:*}
        db_host=${db_admin_host#*:}
        db_admin_pass=${dbinfo##*:}
        do_load=1
    else
        db_name=${dbinfo}
        do_load=1
    fi

    if [ ${do_load} = 0 ]; then
	tinderEcho "WARN: You must first create a database for Tinderbox, and generate the schema by running ${genschema} with the appropriate database driver argument.  Once the schema is generated, it must be loaded into the newly created database.  Consult ${TINDERBOX_URL} for more information on creating and initializing the Tinderbox database."
    else
	dblib=$(tinderLoc scripts lib/db-${db_driver}.sh)
	if [ ! -f ${dblib} ]; then
	    tinderExit "ERROR: There is no database library file for database driver: ${db_driver}" 1
	fi
	. ${dblib}

        if ! createDb "${db_driver}" "${db_admin}" "${db_host}" "${db_name}" 1; then
    	    tinderExit "ERROR: Error creating the new database!  Consult the output above for more information." $?
        fi
    fi

    tinderEcho "INFO: Database configuration complete."
    echo ""

    # We're done now.  However, we don't want to be calling 'tc init'
    # here since the user may need to configure tinderbox.ph first
    tph=$(tinderLoc scripts tinderbox.ph)
    tinit="$(tinderLoc scripts tc) init"

    tinderExit "Congratulations!  The scripted portion of Tinderbox has completed successfully.  You should now verify the settings in ${tph} are correct for your environment, then run \"${tinit}\" to complete the setup.  Be sure to checkout ${TINDERBOX_URL} for further instructions." 0
}

#---------------------------------------------------------------------------
# Tinderbox upgrade
#---------------------------------------------------------------------------

Upgrade () {
    VERSION="3.0"
    TINDERBOX_URL="http://tinderbox.marcuscom.com/"
    DB_MIGRATION_PATH="${VERSION}"

    bkup_file=""

    # argument processing
    while [ $# -gt 0 ]; do
	case "x$1" in
	    x-backup)
	        shift
	        bkup_file="$1"
		;;
	    x-*) return 1;;
	esac
	shift
    done

    tc=$(tinderLoc scripts tc)

    clear

    tinderEcho "Welcome to the Tinderbox Upgrade and Migration script.  This script will guide you through an upgrade to Tinderbox ${VERSION}."
    echo ""

    read -p "Hit <ENTER> to get started: " i

    # Check if the current Datastore Version is ascertainable
    good_dsversion=1
    dsversion=$(${tc} dsversion 2>/dev/null)
    if [ $? != 0 ]; then
	good_dsversion=0
    fi

    # Cleanup files that are no longer needed.
    echo ""
    tinderEcho "INFO: Cleaning up stale files..."
    REMOVE_FILES="buildscript create enterbuild makemake mkbuild mkjail pnohang.c portbuild rawenv rawenv.dist tbkill.sh tinderbuild tinderbox-mysql.schema tinderbox-pgsql.schema setup.sh upgrade.sh lib/Build.pm lib/BuildPortsQueue.pm lib/Hook.pm lib/Host.pm lib/Jail.pm lib/MakeCache.pm lib/Port.pm lib/PortFailPattern.pm lib/PortFailReason.pm lib/PortsTree.pm lib/TBConfig.pm lib/TinderObject.pm lib/TinderboxDS.pm lib/User.pm lib/tinderbox_shlib.sh lib/setup-mysql.sh lib/setup-pgsql.sh lib/setup_shlib.sh upgrade/mig_mysql_tinderbox-1.X_to_2.0.0.sql upgrade/mig_mysql_tinderbox-2.0.0_to_2.1.0.sql upgrade/mig_mysql_tinderbox-2.1.0_to_2.1.1.sql upgrade/mig_mysql_tinderbox-2.1.1_to_2.2.0.sql upgrade/mig_mysql_tinderbox-2.2.0_to_2.3.0.sql upgrade/mig_mysql_tinderbox-2.3.0_to_2.3.1.sql upgrade/mig_mysql_tinderbox-2.3.1_to_2.3.2.sql upgrade/mig_mysql_tinderbox-2.3.2_to_2.3.3.sql upgrade/mig_mysql_tinderbox-2.3.3_to_2.4.0.sql upgrade/mig_pgsql_tinderbox-2.1.1_to_2.2.0.sql upgrade/mig_pgsql_tinderbox-2.2.0_to_2.3.0.sql upgrade/mig_pgsql_tinderbox-2.3.0_to_2.3.1.sql upgrade/mig_pgsql_tinderbox-2.3.1_to_2.3.2.sql upgrade/mig_pgsql_tinderbox-2.3.2_to_2.3.3.sql upgrade/mig_pgsql_tinderbox-2.3.3_to_2.4.0.sql upgrade/mig_shlib.sh etc/rc.d/tinderd.sh"
    for f in ${REMOVE_FILES}; do
        rm -f "${pb}/scripts/${f}"
    done

    # First, backup the current data.
    echo ""
    db_host=""
    db_name=""
    db_admin=""
    do_load=0
    db_driver=$(getDbDriver)
    case "${db_driver}" in
        sqlite)
            dbinfo=$(getDbInfoSQLite)
            ;;
        *)
            dbinfo=$(getDbInfo ${db_driver})
            ;;
    esac
    if [ $? = 0 ]; then
        db_admin_host_name=${dbinfo%:*}
	db_admin_host=${db_admin_host_name%:*}
        db_name=${db_admin_host_name##*:}
        db_admin=${db_admin_host%:*}
        db_host=${db_admin_host#*:}
	db_admin_pass=${dbinfo##*:}
        do_load=1
    fi

    if [ ${do_load} = 0 ]; then
        tinderEcho "WARN: Database migration was not done.  If you have already loaded the database schema, type 'y' or 'yes' to continue the migration."
        echo ""
        read -p "Do you wish to continue? (y/N)" i
        case ${i} in
    	    [Yy]|[Yy][Ee][Ss])
    	        # continue
    	        ;;
    	    *)
    	        tinderExit "INFO: Upgrade aborted by user." 0
    	        ;;
        esac
    else
	dblib=$(tinderLoc scripts lib/db-${db_driver}.sh)
	if [ ! -f ${dblib} ]; then
	    tinderExit "ERROR: There is no database library file for database driver: ${db_driver}" 1
	fi
	. ${dblib}
	if [ -z "${bkup_file}" -a ${good_dsversion} = 0 ]; then
	    eval ${DB_PROMPT}
	    query="SELECT Config_Option_Value FROM config WHERE Config_Option_Name='__DSVERSION__' AND Host_Id='-1'"
	    dsversion=$(eval ${DB_QUERY})
	fi

        if [ "${dsversion}" = "1.X" ]; then
	    tinderExit "ERROR: Upgrades are only supported from 2.0 onwards." 1
        fi

        dsmajor=$(echo ${dsversion} | awk -F'\\.' '{print $1}')
        curmajor=$(echo ${VERSION} | awk -F'\\.' '{print $1}')
        major_upgrade=0
	if [ -n "${bkup_file}" ]; then
	    major_upgrade=1
        elif [ ${dsmajor} -lt ${curmajor} ]; then
	    major_upgrade=1
        fi

	if [ ${major_upgrade} = 1 ]; then
	    if [ -z "${bkup_file}" ]; then
                bkup_file=$(mktemp /tmp/tb_dbbak.XXXXXX)
                if [ $? != 0 ]; then
    	            tinderExit "Failed to create temp file for database backup." $?
                fi
	        if ! backupDb "${bkup_file}" "${db_driver}" "${db_admin}" "${db_host}" "${db_name}" ; then
    	            tinderExit "ERROR: Database backup failed!  Consult the output above for more information." $?
    	            rm -f ${bkup_file}
                fi
	    fi
            if ! dropDb "${db_driver}" "${db_admin}" "${db_host}" "${db_name}" ; then
    	        tinderExit "ERROR: Error dropping the old database!  Consult the output above for more information.  Once the problem is corrected, run \"${tc} Upgrade -backup ${bkup_file}\" to resume migration." $?
            fi
            if ! createDb "${db_driver}" "${db_admin}" "${db_host}" "${db_name}" 0; then
    	        tinderExit "ERROR: Error creating the new database!  Consult the output above for more information.  Once the problem is corrected, run \"${tc} Upgrade -backup ${bkup_file}\" to resume migration." $?
            fi
# XXX This will not work for Postgres as any new tables will be created with
# the wrong owner.
            if ! loadSchema "${bkup_file}" "${db_driver}" "${db_admin}" "${db_admin}" "${db_host}" "${db_name}" ; then
    	        tinderExit "ERROR: Database restoration failed!  Consult the output above for more information.  Once the problem is corrected, run \"${tc} Upgrade -backup ${bkup_file}\" to resume migration." $?
            fi
            rm -f ${bkup_file}
        else
	    set -- ${DB_MIGRATION_PATH}
	    while [ -n "${1}" -a -n "${2}" ] ; do
	        MIG_VERSION_FROM=${1}
	        MIG_VERSION_TO=${2}

	        if [ ${MIG_VERSION_FROM} = ${dsversion} ] ; then
		    migDb ${do_load} ${db_driver} ${db_admin} ${db_admin} ${db_host} ${db_name}
		    case $? in
		        2)
		            tinderExit "ERROR: Database migration failed!  Consult the output above for more information." 2
			    ;;
	                1)
		            tinderExit "ERROR: No Migration Script available to migrate ${MIG_VERSION_FROM} to ${MIG_VERSION_TO}" 1
			    ;;
		        0)
		            dsversion=${MIG_VERSION_TO}
			    ;;
		    esac
	        fi
	        shift
	    done
	fi
    fi

    # Migrate .env files.
    echo ""
    tinderEcho "INFO: Migrating .env files..."
    envdir=$(tinderLoc scripts etc/env)
    if [ ! -d ${envdir} ]; then
        mkdir -p ${envdir}
    fi
    jails=$(${tc} listJails 2>/dev/null)
    for jail in ${jails}; do
        f=$(tinderLoc jail ${jail})
        if [ -f "${f}/jail.env" ]; then
    	    mv -f "${f}/jail.env" "${envdir}/jail.${jail}"
        fi
    done

    builds=$(${tc} listBuilds 2>/dev/null)
    for build in ${builds}; do
        f=$(tinderLoc build ${build})
        if [ -f "${f}/build.env" ]; then
    	    mv -f "${f}/build.env" "${envdir}/build.${build}"
        fi
    done

    portstrees=$(${tc} listPortsTrees 2>/dev/null)
    for portstree in ${portstrees}; do
        f=$(tinderLoc portstree ${portstree})
        if [ -f "${f}/portstree.env" ]; then
    	    mv -f "${f}/portstree.env" "${envdir}/portstree.${portstree}"
        fi
    done

    echo ""
    tinderEcho "INFO: Migrating user-defined update scripts ..."
    setupDefaults
    for jail in ${jails}; do
	f=$(tinderLoc jail ${jail})
	ucmd=$(${tc} getUpdateCmd -j ${jail} 2>/dev/null)
	if [ x"${ucmd}" != x"CVSUP" -a x"${ucmd}" != x"CSUP" -a x"${ucmd}" != x"NONE" ]; then
	    if [ -f "${ucmd}" ]; then
		mv -f "${ucmd}" "${f}/update.sh"
		chmod +x "${f}/update.sh"
		query="UPDATE jails SET jail_update_cmd='USER' WHERE jail_name='${jail}'"
		if [ ${do_load} != 0 ]; then
		    eval ${DB_PROMPT}
		    eval ${DB_QUERY}
		    if [ $? != 0 ]; then
			tinderEcho "WARN: Failed to set the update command for Jail ${jail}.  See the output above for more details.  Before this Jail can be updated, you must manually run the SQL query ${query}."
		    fi
		else
		    tinderEcho "WARN: You must manually set the update command for ${jail} to \"USER\" using the query ${query}."
		fi
	    fi
	elif [ x"${ucmd}" = x"CVSUP" -o x"${ucmd}" = x"CSUP" ]; then
	    updateCmd="/usr/bin/csup"
	    if [ x"${ucmd}" = x"CVSUP" ]; then
		updateCmd="/usr/local/bin/cvsup"
	    fi
	    ( echo "#!/bin/sh"
	      echo "${updateCmd} ${f}/supfile"
	    ) > ${f}/update.sh
	    chmod +x ${f}/update.sh
	    if [ -f "${f}/src-supfile" ]; then
		mv -f "${f}/src-supfile" "${f}/supfile"
	    fi
	fi
    done

    for portstree in ${portstrees}; do
	f=$(tinderLoc portstree ${portstree})
	ucmd=$(${tc} getUpdateCmd -p ${portstree} 2>/dev/null)
	if [ x"${ucmd}" != x"CVSUP" -a x"${ucmd}" != x"CSUP" -a x"${ucmd}" != x"NONE" ]; then
	    if [ -f "${ucmd}" ]; then
		mv -f "${ucmd}" "${f}/update.sh"
		chmod +x "${f}/update.sh"
		query="UPDATE ports_trees SET ports_tree_update_cmd='USER' WHERE ports_tree_name='${portstree}'"
		if [ ${do_load} != 0 ]; then
		    eval ${DB_PROMPT}
		    eval ${DB_QUERY}
		    if [ $? != 0 ]; then
			tinderEcho "WARN: Failed to set the update command for PortsTree ${portstree}.  See the output above for more details.  Before this PortsTree can be updated, you must manually run the SQL query ${query}."
		    fi
		else
		    tinderEcho "WARN: You must manually set the update command for ${portstree} to \"USER\" using the query ${query}."
		fi
	    fi
	elif [ x"${ucmd}" = x"CVSUP" -o x"${ucmd}" = "CSUP" ]; then
	    updateCmd="/usr/bin/csup"
	    if [ x"${ucmd}" = x"CVSUP" ]; then
		updateCmd="/usr/local/bin/cvsup"
	    fi
	    ( echo "#!/bin/sh"
	      echo "${updateCmd} ${f}/supfile"
	    ) > ${f}/update.sh
	    chmod +x ${f}/update.sh
	    if [ -f "${f}/ports-supfile" ]; then
		mv -f "${f}/ports-supfile" "${f}/supfile"
	    fi
	fi
    done

    echo ""
    init

    echo ""
    tinderExit "Congratulations! Tinderbox migration is complete.  Please refer to ${TINDERBOX_URL} for a list of what is new in this version as well as general Tinderbox documentation.  You must also go through ${pb}/scripts/tinderbox.ph, and synchronize it with the new properties in ${pb}/scripts/tinderbox.ph.dist." 0
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

    updateCmd=$($(tinderLoc scripts tc) getUpdateCmd -j ${jailName})
    jailArch=$($(tinderLoc scripts tc) getJailArch -j ${jailName})

    execute_hook "preJailUpdate" "JAIL=${jailName} UPDATE_CMD=${updateCmd} PB=${pb} JAIL_ARCH=${jailArch}"
    if [ $? -ne 0 ]; then
	echo "updateJail: hook preJailUpdate failed. Terminating."
	return 1
    fi
    if ! requestMount -t jail -j ${jailName}; then
	echo "updateJail: ${jailName}: mount failed"
	exit 1
    fi
    updateTree jail ${jailName} -j $(tinderLoc jail ${jailName})
    rc=$?
    execute_hook "postJailUpdate" "JAIL=${jailName} RC=${rc} PB=${pb}"

    cleanupMounts -t jail -j ${jailName}

    if [ ${rc} -ne 0 ]; then
	exit ${rc}
    fi

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

    updateCmd=$(${tc} getUpdateCmd -j ${jailName})

    # Hackery to set SRCBASE accordingly for all combinations
    tc=$(tinderLoc scripts tc)
    jailSrcMt=$(${tc} getSrcMount -j ${jailName})
    HOST_WORKDIR=$(${tc} configGet | awk -F= '/^HOST_WORKDIR/ {print $2}')
    jailBase=$(tinderLoc jail ${jailName})
    if [ ! -d ${jailBase} ]; then
	mkdir -p ${jailBase}
	if [ $? -ne 0 ]; then
	    echo "buildJail: cannot create: ${jailBase}"
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
	    echo "buildJail: cannot mount source directory"
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
    export __MAKE_CONF="${jailBase}/make.conf"
    export SRCCONF="${jailBase}/src.conf"

    # Get the architecture types for both the host and the jail
    jailArch=$(${tc} getJailArch -j ${jailName})
    myArch=$(uname -m)

    execute_hook "preJailBuild" "JAIL=${jailName} DESTDIR=${J_TMPDIR} JAIL_ARCH=${jailArch} MY_ARCH=${myArch} JAIL_OBJDIR=${JAIL_OBJDIR} SRCBASE=${SRCBASE} PB=${pb}"
    if [ $? -ne 0 ]; then
	echo "buildJail: Terminating Jail build since hook preJailBuild failed."
	return 1
    fi

    if [ "${updateCmd}" = "LFTP" ]; then
	export DESTDIR=${J_TMPDIR}
        if [ -f ${jailBase}/sets/base.txz ]; then
	    cd ${jailBase}/sets && tar --unlink -xpf base.txz -C ${DESTDIR} 
	    if [ -f ${jailBase}/sets/lib32.txz ]; then
	      cd ${jailBase}/sets && tar --unlink -xpf lib32.txz -C ${DESTDIR}
	    fi
	else
	    cd ${jailBase}/sets/base && yes | sh ./install.sh > ${jailBase}/world.tmp 2>&1
	    rc=$?
	    if [ ${rc} -eq 0 -a -d "${jailBase}/sets/lib32" ]; then
	        cd ${jailBase}/sets/lib32 && yes | sh ./install.sh >> ${jailBase}/world.tmp 2>&1
	        rc=$?
	    fi
	fi
	execute_hook "postJailBuild" "JAIL=${jailName} DESTDIR=${J_TMPDIR} JAIL_ARCH=${jailArch} MY_ARCH=${myArch} JAIL_OBJDIR=${JAIL_OBJDIR} SRCBASE=${SRCBASE} PB=${pb} RC=${rc}"
	if [ ${rc} -ne 0 ]; then
	    echo "ERROR: world failed - see ${jailBase}/world.tmp"
	    buildJailCleanup 1 ${jailName} ${J_SRCDIR}
	fi
    else
        # Make world
        echo "${jailName}: making world"

        # determine if we're cross-building world
        crossEnv=""
        if [ "${jailArch}" != "${myArch}" ]; then
	    crossEnv="TARGET_ARCH=${jailArch}"
        fi

        ncpus=$(/sbin/sysctl hw.ncpu | awk '{print $2}')
        factor=$(echo "$ncpus*2+1" | /usr/bin/bc -q)

        if [ -n "${NO_JAIL_JOBS}" ]; then
	    factor=1
        fi

        cd ${SRCBASE} && env DESTDIR=${J_TMPDIR} ${crossEnv} \
	    make -j${factor} -DNO_CLEAN world > ${jailBase}/world.tmp 2>&1
        rc=$?
        execute_hook "postJailBuild" "JAIL=${jailName} DESTDIR=${J_TMPDIR} JAIL_ARCH=${jailArch} MY_ARCH=${myArch} JAIL_OBJDIR=${JAIL_OBJDIR} SRCBASE=${SRCBASE} PB=${pb} RC=${rc}"
        if [ ${rc} -ne 0 ]; then
	    echo "ERROR: world failed - see ${jailBase}/world.tmp"
	    buildJailCleanup 1 ${jailName} ${J_SRCDIR}
        fi

        # Make a complete distribution
        echo "${jailName}: making distribution"

        # determine if we're cross-building world
        crossEnv=""
        if [ "${jailArch}" != "${myArch}" ]; then
	    crossEnv="TARGET_ARCH=${jailArch}"
        fi
        cd ${SRCBASE} && env DESTDIR=${J_TMPDIR} ${crossEnv} \
	    make distribution > ${jailBase}/distribution.tmp 2>&1
        if [ $? -ne 0 ]; then
	    echo "ERROR: distribution failed - see ${jailBase}/distribution.tmp"
	    buildJailCleanup 1 ${jailName} ${J_SRCDIR}
	fi
    fi

    # Various hacks to keep the ports building environment happy
    touch -f ${J_TMPDIR}/etc/fstab

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
	mv -f ${jailBase}/${logfile}.tmp ${jailBase}/${logfile}.log 2>/dev/null
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
    updateTag="UNUSED"
    updateCompress=0
    descr=""
    jailName=""
    jailArch=$(uname -m)
    mountSrc=""
    init=1
    protocol=""
    updateHostDirectory=""

    setupDefaults
    updateHost=${defaultUpdateHost}
    updateType=${defaultUpdateType}

    # argument handling
    while getopts a:d:j:m:t:u:CD:H:IP: arg >/dev/null 2>&1
    do
	case "${arg}" in

	a)	jailArch="${OPTARG}";;
	d)	descr="${OPTARG}";;
	j)	jailName="${OPTARG}";;
	m)	mountSrc="${OPTARG}";;
	t)	updateTag="${OPTARG}";;
	u)	updateType="${OPTARG}";;
	C)	updateCompress=1;;
	D)	updateHostDirectory="${OPTARG}";;
	H)	updateHost="${OPTARG}";;
	I)	init=0;;
	P)	protocol="${OPTARG}";;
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

    if [ -z "${updateType}" ]; then
	echo "createJail: no update type specified"
	return 1
    fi

    echo "${jailName}: initializing tree"
    generateUpdateCode jail ${jailName} ${updateType} ${updateHost} \
		       ${updateTag} ${updateCompress} ${jailArch} \
		       ${protocol} ${updateHostDirectory}

    echo -n "${jailName}: adding to datastore... "

    if [ ! -z "${descr}" ]; then
	descr="-d ${descr}"
    fi

    if [ ! -z "${mountSrc}" ]; then
	mountSrc="-m ${mountSrc}"
    fi

    tc=$(tinderLoc scripts tc)
    ${tc} addJail -j ${jailName} -u ${updateType} ${mountSrc} \
		  -t ${updateTag} -a ${jailArch} "${descr}"
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
    updateCmd=$(${tc} getUpdateCmd -p ${portsTreeName})
    execute_hook "prePortsTreeUpdate" "PORTSTREE=${portsTreeName} \"UPDATE_CMD=${updateCmd}\" PB=${pb}"
    if [ $? -ne 0 ];then
	echo "${portsTreeName}: hook prePortsTreeUpdate failed. Terminating."
	return 1
    fi
    if ! requestMount -t portstree -p ${portsTreeName}; then
	echo "updatePortsTree: ${portsTreeName}: mount failed"
	exit 1
    fi
    updateTree portstree ${portsTreeName} \
	       -p $(tinderLoc portstree ${portsTreeName})
    rc=$?
    execute_hook "postPortsTreeUpdate" "PORTSTREE=${portsTreeName} \"UPDATE_CMD=${updateCmd}\" PB=${pb} RC=${rc}"
    if [ $? -ne 0 ]; then
	echo "updatePortsTree: ${portsTreeName}: hook postPortsTreeUpdate failed. Terminating."
        cleanupMounts -t portstree -p ${portsTreeName}
	return 1
    fi

    cleanupMounts -t portstree -p ${portsTreeName}

    if [ ${rc} -ne 0 ]; then
	exit ${rc}
    fi

    # Update the last-built time
    ${tc} updatePortsTreeLastBuilt -p ${portsTreeName}

    # Update the last-built time
    ${tc} updatePortsTreeLastBuilt -p ${portsTreeName}

    return 0
}

createPortsTree () {
    # set up defaults
    updateCompress=0
    cvswebUrl=""
    descr=""
    init=1
    mountSrc=""
    portsTreeName=""
    protocol=""
    updateHostDirectory=""

    setupDefaults
    updateHost=${defaultUpdateHost}
    updateType=${defaultUpdateType}

    # argument handling
    while getopts d:m:p:u:w:CD:H:IP: arg >/dev/null 2>&1
    do
	case "${arg}" in

	d)	descr="${OPTARG}";;
	m)	mountSrc="${OPTARG}";;
	p)	portsTreeName="${OPTARG}";;
	u)	updateType="${OPTARG}";;
	w)	cvswebUrl="${OPTARG}";;
	C)	updateCompress=1;;
	D)	updateHostDirectory="${OPTARG}";;
	H)	updateHost="${OPTARG}";;
	I)	init=0;;
	P)	protocol="${OPTARG}";;
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

    if [ -z "${updateType}" ]; then
	echo "createPortsTree: no update type specified"
	return 1
    fi

    echo "${portsTreeName}: initializing tree"
    generateUpdateCode portstree ${portsTreeName} ${updateType} \
		       ${updateHost} "." ${updateCompress} "" \
		       ${protocol} ${updateHostDirectory}

    # add portstree to datastore
    echo -n "${portsTreeName}: adding to datastore... "

    if [ ! -z "${descr}" ]; then
	descr="-d ${descr}"
    fi

    if [ ! -z "${mountSrc}" ]; then
	mountSrc="-m ${mountSrc}"
    fi

    if [ ! -z "${cvswebUrl}" ]; then
	cvswebUrl="-w ${cvswebUrl}"
    fi

    tc=$(tinderLoc scripts tc)
    ${tc} addPortsTree -p ${portsTreeName} -u ${updateType} \
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

    execute_hook "preBuildExtract" "BUILD=${buildName} DESTDIR=${BUILD_DIR} JAIL=${jailName} PB=${pb}"
    if [ $? -ne 0 ]; then
	echo "makeBuild: Terminating Build extraction since hook preBuildExtract failed."
	exit 1
    fi

    # Clean up any previous build tree
    tinderbuild_reset ${buildName}
    cleanDirs ${buildName} ${BUILD_DIR}

    if [ "${MD_FSTYPE}" = "ufs" -o "${MD_FSTYPE}" = "zfs" ]; then
	if [ ${MD_SIZE} -gt 0 ]; then
	    # setup md (ramdisk) backing for the build
	    mdconfig -a -t swap -s ${MD_SIZE} > /tmp/tinderbuild_md.${build}
	    read MD_UNIT </tmp/tinderbuild_md.${build}

	    if [ "${MD_FSTYPE}" = "ufs" ]; then
		newfs -m 0 -o time /dev/${MD_UNIT}
		mount /dev/${MD_UNIT} ${BUILD_DIR}
	    else
		zpool create ${MD_UNIT} /dev/${MD_UNIT}
		zfs set compression=on ${MD_UNIT}
		zfs set mountpoint=${BUILD_DIR} ${MD_UNIT}
	    fi
	fi
    elif [ -n "${MD_FSTYPE}" ]; then
	echo "You must define either ufs or zfs as your memory device."
    fi

    # Extract the tarball
    echo "makeBuild: extracting jail tarball"
    tar -C ${BUILD_DIR} -xpf ${JAIL_TARBALL}

    execute_hook "postBuildExtract" "BUILD=${buildName} DESTDIR=${BUILD_DIR} JAIL=${jailName} PB=${pb} RC=0"

    # Finalize environment
    cp -f /etc/resolv.conf ${BUILD_DIR}/etc

    return 0
}

resetBuild () {
    # set up defaults
    build=""
    nullfs=""
    cleandistfiles="0"

    # argument handling
    while getopts b:n arg >/dev/null 2>&1
    do
	case "${arg}" in

	b)	build="${OPTARG}";;
	n)	nullfs="-n";;
	?)	exit 1;;

	esac
    done

    # argument validation
    if [ -z "${build}" ]; then
	echo "resetBuild: no buildname specified"
	exit 1
    fi

    if ! tcExists Builds ${build}; then
	echo "resetBuild: build \"${build}\" doesn't exist"
	exit 1
    fi

    tc=$(tinderLoc scripts tc)

    jail=$(${tc} getJailForBuild -b ${build})
    portstree=$(${tc} getPortsTreeForBuild -b ${build})

    requestMount -t jail -j ${jail}
    cleanenv
    buildenv ${jail} ${portstree} ${build}
    cleanupMounts -t jail -j ${jail}

    tinderbuild_setup
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

    tbcleanup_jail

    cleanupMounts -t buildsrc -b $1
    cleanupMounts -t buildports -b $1
    cleanupMounts -t buildccache -b $1
    cleanupMounts -t builddistcache -b $1
    cleanupMounts -t buildoptions -b $1
    umount -f $(tinderLoc buildroot $1)/dev >/dev/null 2>&1

    if [ "${MD_FSTYPE}" = "ufs" -o "${MD_FSTYPE}" = "zfs" ]; then
	if [ -f /tmp/tinderbuild_md.${build} ]; then
	    read MD_UNIT </tmp/tinderbuild_md.${build}
	    df | grep ${build} | grep ${MD_UNIT}
	    if [ $? -eq 0 ]; then
		if [ "${MD_FSTYPE}" = "ufs" ]; then
		    umount -f /dev/${MD_UNIT}
		else
		    zpool destroy ${MD_UNIT}
		fi
		mdconfig -d -u ${MD_UNIT}
	    fi
	fi
    fi
}

tinderbuild_cleanup () {
    trap "" 1 2 3 9 10 11 15
    echo "tinderbuild: Cleaning up after tinderbuild.  Please be patient."

    tbcleanup_jail

    rm -f ${lock}

    tc=$(tinderLoc scripts tc)
    ${tc} updateBuildStatus -b ${build} -s IDLE
    ${tc} updateBuildRemakeCount -b ${build} -c 0
    ${tc} sendBuildCompletionMail -b ${build}
    tinderbuild_reset ${build}
    cleanupMounts -t portstree -p ${portstree}
    rm -f "/tmp/tb_pipe0.${build}_${date}"
    rm -f "/tmp/tb_pipe1.${build}_${date}"
    rm -f "/tmp/tb_pipe2.${build}_${date}"
    echo 

    exit $1
}

tinderbuild_setup () {
    # Make sure everything is dismounted, clean out the build tree
    # and recreate it from scratch

    tc=$(tinderLoc scripts tc)
    HOST_WORKDIR=$(${tc} configGet | awk -F= '/^HOST_WORKDIR/ {print $2}')

    echo "tinderbuild: Creating build directory for ${build}"
    makeBuild -b ${build}

    # set up the rest of the chrooted environment, we really do
    # not need to be doing this every single time portbuild is called

    buildRoot=$(tinderLoc buildroot ${build})
    echo "tinderbuild: Finalizing chroot environment"

    # Mount ports/
    if ! requestMount -t buildports -b ${build} -r ${nullfs}; then
	echo "tinderbuild: cannot mount ports source"
	tinderbuild_cleanup 1
    fi
    ln -sf ../a/ports ${buildRoot}/usr/ports

    # Mount src/
    if ! requestMount -t buildsrc -b ${build} -r ${nullfs}; then
	echo "tinderbuild: cannot mount jail source"
	tinderbuild_cleanup 1
    fi

    # For use by pnohang
    # XXX: though killall may not work since it's a dynamic executable
    cp -p /rescue/mount /rescue/umount ${buildRoot}/sbin
    cp -p /rescue/ps ${buildRoot}/bin

    # Mount /dev, since we're going to be chrooting shortly
    mount -t devfs devfs ${buildRoot}/dev >/dev/null 2>&1

    # Install a couple of tinderbox binaries
    if ! cp -p $(tinderLoc scripts lib/buildscript) ${buildRoot}; then
	echo "tinderbuild: ${build}: cannot copy buildscript"
	tinderbuild_cleanup 1
    fi

    if ! cc -o ${buildRoot}/pnohang -static \
	$(tinderLoc scripts lib/pnohang.c); then
	echo "tinderbuild: ${build}: cannot compile pnohang"
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
	    echo "tinderbuild: cannot mount distfile cache"
	    tinderbuild_cleanup 1
	fi

	if [ ${cleandistfiles} -eq 1 ]; then
	    echo "tinderbuild: ${build}: Cleaning out distfile cache"
	    rm -rf $(tinderLoc builddistcache ${build})/*
	fi
    fi

    # Handle ccache
    cctar=$(tinderLoc jail ${jail})/ccache.tar
    if [ ${CCACHE_ENABLED} -eq 1 -a -f ${cctar} ]; then

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
	    echo "tinderbuild: cannot mount ccache"
	    tinderbuild_cleanup 1
	fi

	echo "tinderbuild: ${build}: Setting up ccache"
	tar -C ${buildRoot} -xf ${cctar}
	if [ -n "${CCACHE_MAX_SIZE}" ]; then
	    chroot ${buildRoot} /opt/ccache -M ${CCACHE_MAX_SIZE}
	fi
    fi

    if [ ${OPTIONS_ENABLED} -eq 1 ]; then
	optionsDir=$(tinderLoc options ${build})

	mkdir -p ${optionsDir} $(tinderLoc buildoptions ${build})

	if ! requestMount -t buildoptions -b ${build} \
	    	-s ${optionsDir} ${nullfs}; then
	    echo "tinderbuild: cannot mount options"
	    tinderbuild_cleanup 1
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

    remake_cnt=$(cd ${pkgDir}/All && make -n all 2>/dev/null | wc -l)
    tc=$(tinderLoc scripts tc)
    ${tc} updateBuildRemakeCount -b ${build} -c ${remake_cnt}

    cd ${pkgDir}/All && make PACKAGES=${pkgDir} -k -j${jobs} all \
	> $(tinderLoc builddata ${build})/make.${num} 2>&1 </dev/null

    if [ -n "${logdir}" ]; then
	if [ ${LOG_DOCOPY} -eq 1 ]; then
	    cp $(tinderLoc builddata ${build})/make.${num} ${logdir}/make.${num}
	else
	    ln -s $(tinderLoc builddata ${build})/make.${num} ${logdir}/make.${num}
	fi
    fi

    echo "ended at $(date)"
    end=$(date +%s)

    echo -n "phase ${num} took "
    duration=$((${end} - ${start}))
    days=$((${duration} / 86400))
    case ${days} in
    0)	;;
    1)  echo -n "1 day ";;
    *)  echo -n "${days} days ";;
    esac
    echo "$(env LANG=C date -u -j -r ${duration} | awk '{print $4}')"

    echo $(echo $(ls -1 ${pkgDir}/All | wc -l) - 1 | bc) "packages built"
    echo $(echo $(du -sh ${pkgDir} | awk '{print $1}')) " of packages"
}

setup_logging () {
    date=$1
    build=$2
    logdir=$3

    pipe0="/tmp/tb_pipe0.${build}_${date}"
    pipe1="/tmp/tb_pipe1.${build}_${date}"
    pipe2="/tmp/tb_pipe2.${build}_${date}"

    rm -f ${pipe1}
    mkfifo ${pipe1}
    cat <${pipe1} &

    rm -f ${pipe2}
    mkfifo ${pipe2}
    cat >"${logdir}/tinderbuild.log" <${pipe2} &

    rm -f ${pipe0}
    mkfifo ${pipe0}
    tee ${pipe1} >${pipe2} <${pipe0} &

    exec 1>${pipe0} 2>&1
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
    onlymake=0
    noduds=""
    nullfs=""
    pbargs=""
    skipmake=0
    updateports=0
    norebuild=0
    date=""
    logdir=""

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

#	x-jobs)
#	    shift
#	    if ! expr -- "$1" : "^[[:digit:]]\{1,\}$" >/dev/null 2>&1 ; then
#		echo "tinderbuild: The argument to -jobs must be a number."
#		exit 1
#	    elif [ $1 -lt 1 ]; then
#		echo "tinderbuild: The argument to -jobs must be a number >= 1."
#		exit 1
#	    fi
#	    jobs=$1
#	    ;;

	x-cleandistfiles)	cleandistfiles=1;;
	x-cleanpackages)	cleanpackages=1;;
	x-init)			init=1;;
	x-skipmake)		skipmake=1;;
	x-onlymake)		onlymake=1;;
	x-updateports)		updateports=1;;
	x-norebuild)		norebuild=1;;

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
    date=$(date +%Y%m%d%H%M%S)
    ${tc} updateBuildStatus -b ${build} -s PREPARE

    trap "tinderbuild_cleanup 2" 1 2 3 9 10 11 15

    # XXX: This is a crude hack to normalize ${ports}
    ports=$(echo ${ports})

    # Setup the environment for this jail
    jail=$(${tc} getJailForBuild -b ${build})
    portstree=$(${tc} getPortsTreeForBuild -b ${build})

    requestMount -t jail -j ${jail}
    cleanenv
    buildenv ${jail} ${portstree} ${build}
    cleanupMounts -t jail -j ${jail}

    if [ -n "${LOG_DIRECTORY}" ]; then
	logdir="${LOG_DIRECTORY}/${build}-${date}"
	mkdir -p ${logdir}
	if [ $? -eq 0 ]; then
	    pbargs="${pbargs} -logdir ${logdir}"
	    if [ ${LOG_DOCOPY} -eq 1 ]; then
		pbargs="${pbargs} -docopy"
	    fi
            if [ -t 1 ]; then
	        setup_logging ${date} ${build} ${logdir}
            fi
	else
	    logdir=""
	fi
    fi

    if [ ${LOG_COMPRESSLOGS} -eq 1 ]; then
	pbargs="${pbargs} -compress-logs"
    fi

    # Remove the make logs.
    rm -f ${buildData}/make.*

    # Determine where we're going to write out packages
    pkgDir=$(tinderLoc packages ${build})

    # Clean up packages if specific ports dirs were specified
    # on the command line
    if [ ${norebuild} = 0 ]; then
        for port in ${ports}; do
	    pkgname=$(${tc} getPortLastBuiltVersion -b ${build} -d ${port})
	    if [ ! -z "${pkgname}" ]; then
	        find -H ${pkgDir} -name ${pkgname}${PKGSUFFIX} -delete
	    fi
        done
    fi

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
	    buildenvNoHost ${build}
	    if ! requestMount -t portstree -p ${portstree}; then
		echo "tinderbuild: cannot mount portstree: ${portstree}"
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

    if [ ${onlymake} -eq 1 ]; then
	echo "onlymake specified: not running tinderbuild"
	tinderbuild_cleanup 0
    fi

    # Set up the chrooted environment
    osmajor=$(echo ${jail} | sed -E -e 's|(^[[:digit:]]+).*$|\1|')
    if [ ${osmajor} -lt 6 ]; then
	echo "tinderbuild: unhandled OS version: ${osmajor}"
	tinderbuild_cleanup 1
    fi

    tinderbuild_setup

    # Seatbelts off.  Away we go.
    ${tc} updateBuildStatus -b ${build} -s PORTBUILD
    tinderbuild_phase 0 ${jobs} ${pkgDir}
    error=$?
    if [ ${onceonly} -ne 1 ]; then
	if [ ${error} -ne 0 ] ; then
	    tinderbuild_setup
	fi
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

    read -p "Enter a default cvsup host [${_defaultUpdateHost}]: " host
    if [ -z "${host}" ]; then
	host=${_defaultUpdateHost}
    fi

    read -p "Enter a default update type or command [${_defaultUpdateType}]: " type
    if [ -z "${type}" ]; then
	type=${_defaultUpdateType}
    fi

    globalenv=$(tinderLoc scripts etc/env)/GLOBAL
    echo "export defaultUpdateHost=${host}" >> ${globalenv}
    echo "export defaultUpdateType=${type}" >> ${globalenv}

    tinderEcho "Default update host and type have been set.  These can be changed later by modifying ${globalenv}."

    return 0
}

#---------------------------------------------------------------------------
# add port to builds
#---------------------------------------------------------------------------

addPortToBuild_cleanup () {
    jail=$1
    portsTree=$2

    cleanupMounts -t jail -j ${jail}
    cleanupMounts -t portstree -p ${portsTree}
}

addPortToBuild () {
    build=$1
    portDir=$2
    norecurse=$3
    options=$4
    cleanOptions=$5

    tc=$(tinderLoc scripts tc)
    jail=$(${tc} getJailForBuild -b ${build})
    portsTree=$(${tc} getPortsTreeForBuild -b ${build})

    if ! requestMount -t jail -j ${jail} -r; then
	echo "addPortToBuild: cannot mount jail source"
	exit 1
    fi
    if ! requestMount -t portstree -p ${portsTree} -r; then
	echo "addPortToBuild: cannot mount portstree source"
	exit 1
    fi

    trap "addPortToBuild_cleanup ${jail} ${portsTree}" 1 2 3 9 10 11 15

    # Save TERM since we need that for OPTIONS
    save_TERM=${TERM}
    save_SRCBASE=
    if [ -n "${SRCBASE}" ]; then
	save_SRCBASE=${SRCBASE}
    fi

    buildenv ${jail} ${portsTree} ${build}
    buildenvNoHost ${build}

    export PORTSDIR=$(tinderLoc portstree ${portsTree})/ports
    if [ -z "${portDir}" ]; then
	${tc} addPortToOneBuild -b ${build} ${norecurse}
    else
        if [ ! -d ${PORTSDIR}/${portDir} ]; then
            echo "addPort: Unknown port ${portDir}"
            exit 1
        fi
        ${tc} addPortToOneBuild -b ${build} -d ${portDir} ${norecurse}
    fi
    if [ ${options} -eq 1 -a ${OPTIONS_ENABLED} -eq 1 ]; then
	pdirs=""
	if [ -z "${portDir}" ]; then
	    pdirs=$(${tc} getPortsForBuild -b ${build} 2>/dev/null)
	else
	    pdirs="${PORTSDIR}/${portDir}"
	fi
	rmconfig=true
	if [ ${cleanOptions} -eq 1 ]; then
	    if [ -z "${norecurse}" ]; then
		rmconfig="make rmconfig-recursive"
	    else
		rmconfig="make rmconfig"
	    fi
	fi
	for pdir in ${pdirs}; do
	    if [ -d ${pdir} ]; then
	        export TERM=${save_TERM}
	        read -p "Generating options for ${build}; hit Enter to continue..." key
	        echo ""
	        if [ -z "${norecurse}" ]; then
		    ( cd ${pdir} && ${rmconfig} \
		      && make -k config-recursive )
	        else
		    ( cd ${pdir} && ${rmconfig} \
		      && make config )
	        fi
	    fi
	done
    fi

    if [ -n "${save_SRCBASE}" ]; then
	export SRCBASE=${save_SRCBASE}
    else
	unset SRCBASE
    fi

    addPortToBuild_cleanup ${jail} ${portsTree}
}

addPort () {
    # set up defaults
    build=""
    allBuilds=0
    portDir=""
    norecurse=""
    options=0
    cleanOptions=1

    # argument handling
    while getopts ab:d:oOR arg >/dev/null 2>&1
    do
	case "${arg}" in

	a)	allBuilds=1;;
	b)	build="${OPTARG}";;
	d)	portDir="${OPTARG}";;
	o)      options=1;;
	O)	options=1 ; cleanOptions=0;;
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
	    addPortToBuild ${build} ${portDir} "${norecurse}" ${options} ${cleanOptions}
	done
    else
	if ! tcExists Builds ${build}; then
	    echo "addPort: no such build: ${build}"
	    return 1
	fi

	addPortToBuild ${build} ${portDir} "${norecurse}" ${options} ${cleanOptions}
    fi

    return 0
}

rescanPorts () {
    # set up defaults
    build=""
    allBuilds=0
    norecurse=""
    options=0
    cleanOptions=1

    # argument handling
    while getopts ab:oOR arg >/dev/null 2>&1
    do
	case "${arg}" in

	a)	allBuilds=1;;
	b)	build="${OPTARG}";;
	o)      options=1;;
	O)	options=1 ; cleanOptions=0;;
	R)	norecurse="-R";;
	?)	return 1;;

	esac
    done

    # argument validation
    if [ ${allBuilds} -eq 1 ]; then
	if [ ! -z "${build}" ]; then
	    echo "rescanPorts: -a and -b are mutually exclusive"
	    return 1
	fi

	tc=$(tinderLoc scripts tc)
	allBuilds=$(${tc} listBuilds 2>/dev/null)
	if [ -z "${allBuilds}" ]; then
	    echo "rescanPorts: no builds are configured"
	    return 1
	fi

	for build in ${allBuilds}
	do
	    addPortToBuild ${build} "" "${norecurse}" ${options} ${cleanOptions}
	done
    else
	if ! tcExists Builds ${build}; then
	    echo "rescanPorts: no such build: ${build}"
	    return 1
	fi

	addPortToBuild ${build} "" "${norecurse}" ${options} ${cleanOptions}
    fi

    return 0
}

#---------------------------------------------------------------------------
# copy a Build
#---------------------------------------------------------------------------

copyBuild () {
    # set up defaults
    copyEnv=1
    copyOptions=1
    copyPorts=1
    copyPkgs=0
    copyCcache=0
    src=""
    dest=""

    # argument handling
    while getopts cd:EOPps: arg >/dev/null 2>&1
    do
	case "${arg}" in

	E)	copyEnv=0;;
	O)	copyOptions=0;;
	P)	copyPorts=0;;
	p)	copyPkgs=1;;
	c)	copyCcache=1;;
	s)	src="${OPTARG}";;
	d)	dest="${OPTARG}";;
	?)	return 1;;

        esac
    done

    if ! tcExists Builds ${src}; then
	echo "copyBuild: source build does not exist: ${src}"
	return 1
    fi

    if ! tcExists Builds ${dest}; then
	echo "copyBuild: destination build does not exist: ${dest}"
	return 1
    fi

    tc=$(tinderLoc scripts tc)
    jail=$(${tc} getJailForBuild -b ${src})
    portsTree=$(${tc} getPortsTreeForBuild -b ${src})

    buildenv ${jail} ${portsTree} ${src}
    buildenvNoHost ${src}

    if [ ${copyEnv} -eq 1 ]; then
	envDir=$(tinderLoc scripts etc/env)
	if [ -f ${envDir}/build.${src} ]; then
	    cp -p ${envDir}/build.${src} ${envDir}/build.${dest}
	fi
    fi

    if [ ${copyOptions} -eq 1 ]; then
	srcOptionsDir=$(tinderLoc options ${src})
	if [ -n "${srcOptionsDir}" -a -d "${srcOptionsDir}" ]; then
	    destOptionsDir=$(tinderLoc options ${dest})
	    if [ -n "${destOptionsDir}" ]; then
		if [ ! -d ${destOptionsDir} ]; then
		    mkdir -p ${destOptionsDir}
		fi
		(
		  cd ${srcOptionsDir}
		  tar -cpf - . | tar -C ${destOptionsDir} -xpf -
		)
	    else
		echo "copyBuild: not copying OPTIONS to ${dest} since it has no OPTIONS directory"
	    fi
	else
	    echo "copyBuild: invalid OPTIONS directory for ${src}: \"${srcOptionsDir}\""
	fi
    fi

    if [ ${copyPkgs} -eq 1 ]; then
	srcPkgDir=$(tinderLoc packages ${src})
	if [ -d ${srcPkgDir} ]; then
	    destPkgDir=$(tinderLoc packages ${dest})
	    if [ ! -d ${destPkgDir} ]; then
		mkdir -p ${destPkgDir}
	    fi
	    (
	      cd ${srcPkgDir}
	      tar -cpf - . | tar -C ${destPkgDir} -xpf -
	    )
	else
	    echo "copyBuild: invalid package directory for ${src}: \"${srcPkgDir}\""
	fi
    fi

    if [ ${copyCcache} -eq 1 ]; then
	srcCcacheDir=$(tinderLoc ccache ${src})
	if [ -n "${srcCcacheDir}" -a -d "${srcCcacheDir}" ]; then
	    destCcacheDir=$(tinderLoc ccache ${dest})
	    if [ -n "${destCcacheDir}" ]; then
		if [ ! -d ${destCcacheDir} ]; then
		    mkdir -p ${destCcacheDir}
		fi
		(
		  cd ${srcCcacheDir}
		  tar -cpf - . | tar -C ${destCcacheDir} -xpf -
		)
	    else
		echo "copyBuild: not copying ccache to ${dest} since it has no ccache directory"
	    fi
	else
	    echo "copyBuild: invalid ccache directory for ${src}: \"${srcCcacheDir}\""
	fi
    fi

    if [ ${copyPorts} -eq 1 ]; then
        doPkgs=""
	if [ ${copyPkgs} -eq 1 ]; then
	    doPkgs="-p"
        fi
	${tc} copyBuildPorts -s ${src} -d ${dest} ${doPkgs}
    fi
}

#---------------------------------------------------------------------------
# cleanup a Tinderbox
#---------------------------------------------------------------------------

tbcleanup_cleanup () {
    portstrees=$*

    for portstree in ${portstrees} ; do
        cleanupMounts -t portstree -p ${portstree}
    done
}

tbcleanup_jail () {
    jname=j$(echo ${build} | sed -E -e 's|\.||')

    # Stop the jail if running
    jls -qj ${jname} > /dev/null 2>&1 && jail -r ${jname}
}

tbcleanup () {
    # set up defaults
    cleanDistfiles=0
    cleanErrors=1
    cleanPkgs=0

    # argument handling
    while getopts dEp arg >/dev/null 2>&1
    do
	case "${arg}" in

	d)	cleanDistfiles=1;;
	E)	cleanErrors=0;;
	p)	cleanPkgs=1;;
	?)	return 1;;

	esac
    done

    tc=$(tinderLoc scripts tc)
    builds=$(${tc} listBuilds 2>/dev/null)
    ports=$(${tc} listPorts 2>/dev/null)
    nonexistentPorts=""

    portstrees=$(${tc} listPortsTrees 2>/dev/null)
    trap "tbcleanup_cleanup ${portstrees}" 1 2 3 9 10 11 15
    for portstree in ${portstrees} ; do
        if ! requestMount -t portstree -p ${portstree} -r; then
            echo "tbcleanup: cannot mount portstree source"
            exit 1
        fi
    done
    disttmp=""
    DISTFILE_CACHE=""
    if [ ${cleanDistfiles} = 1 ]; then
	DISTFILE_CACHE=$(${tc} configGet | awk -F= '/^DISTFILE_CACHE/ {print $2}')
	if [ -n "${DISTFILE_CACHE}" ]; then
	    disttmp=$(mktemp -q /tmp/tbcleanup.XXXXXX)
	    if [ $? != 0 ]; then
	        echo "Failed to create temp file; distfile cleanup will not be done"
	        cleanDistfiles=0
	    fi
	else
	    cleanDistfiles=0
        fi
    fi
    for port in ${ports} ; do
	pathFound=0
        for portstree in ${portstrees} ; do
	    path=$(tinderLoc portstree ${portstree})
	    path="${path}/ports/${port}/Makefile"
	    if [ -e ${path} ]; then
	        if [ ${cleanDistfiles} = 1 ]; then
		    oldcwd=${PWD}
		    path=$(tinderLoc portstree ${portstree})
		    cd "${path}/ports/${port}"
		    distinfo=$(env PORTSDIR="${path}/ports" make -V DISTINFO_FILE)
		    if [ -f "${distinfo}" ]; then
			for df in $(grep '^SHA256' ${distinfo} | awk -F '[\(\)]' '{print $2}'); do
			    if ! grep -q "^${df}\$" ${disttmp}; then
				echo ${df} >> ${disttmp}
			    fi
			done
		    fi
		    cd ${oldcwd}
		    pathFound=1
		else
		    pathFound=1
		    break
	        fi
	    fi
	done

	if [ ${pathFound} = 0 -a ${cleanErrors} = 1 ]; then
	    echo "Removing database entry for nonexistent port ${port}"
	    ${tc} rmPort -d ${port} -f -c
	elif [ ${pathFound} = 0 -a ${cleanErrors} = 0 ]; then
	    nonexistentPorts="${nonexistentPorts} ${port}"
	fi
    done

    tbcleanup_cleanup ${portstrees}

    if [ ${cleanDistfiles} = 1 ]; then
	echo "Pruning stale distfiles from distfile cache: ${DISTFILE_CACHE}"
	for df in $(find ${DISTFILE_CACHE} -type f); do
	    relfile=$(echo ${df} | sed -e "s|^${DISTFILE_CACHE}/||")
	    if ! grep -q "^${relfile}\$" ${disttmp}; then
		echo "Removing stale distfile ${relfile}"
		/bin/rm -f ${df}
	    fi
        done
	find ${DISTFILE_CACHE} -type d -empty | xargs rmdir
	/bin/rm -f ${disttmp}
    fi

    for build in ${builds} ; do
	jail=$(${tc} getJailForBuild -b ${build} 2>/dev/null)
	portstree=$(${tc} getPortsTreeForBuild -b ${build} 2>/dev/null)

	cleanenv
	buildenv ${jail} ${portstree} ${build}

	if [ -n "${WITH_PKGNG}" ]; then
	    package_suffix=".txz"
	else
	    package_suffix=$(${tc} getPackageSuffix -j ${jail} 2>/dev/null)
	fi

	echo ${build}

        # Delete database records for nonexistent packages.
	ports=$(${tc} getPortsForBuild -b ${build} 2>/dev/null)

        if ! requestMount -t portstree -p ${portstree} -r; then
            echo "tbcleanup: cannot mount portstree source"
            exit 1
        fi
        trap "tbcleanup_cleanup ${portstree}" 1 2 3 9 10 11 15

	pkgs_seen=""
	pkg_path=$(tinderLoc packages ${build})
	for port in ${ports} ; do
	    path="/nonexistent"
	    if ${tc} getPortLastBuiltVersion -d ${port} -b ${build} >/dev/null 2>&1 ; then
		lbv=$(${tc} getPortLastBuiltVersion -d ${port} -b ${build} 2>/dev/null)
		path="${pkg_path}/All/${lbv}${package_suffix}"
		pkgs_seen="${pkgs_seen} ${lbv}${package_suffix}"
	    fi
	    if [ ! -e ${path} ]; then
	        dodelete=1
		if [ ${cleanErrors} = 0 ]; then
		    status=$(${tc} getPortLastBuiltStatus -d ${port} -b ${build} 2>/dev/null)
		    if [ "${status}" != "SUCCESS" ]; then
		        dodelete=0
		    fi
		fi
		if [ ${dodelete} = 1 ]; then
		    echo "Removing build port database entry for port with nonexistent package ${port}/${build}"
		    ${tc} rmPort -d ${port} -b ${build} -f -c
		    if echo ${nonexistentPorts} | grep -qw ${port}; then
			echo "Removing database entry for nonexistent port ${port}"
			${tc} rmPort -d ${port} -f -c
		    fi
		fi
	    fi

	    path=$(tinderLoc portstree ${portstree})
	    path="${path}/ports/${port}/Makefile"

	    if [ ! -e ${path} ]; then
		echo "Removing build port database entry for nonexistent port ${build}/${port}"
		${tc} rmPort -d ${port} -b ${build} -f -c
	    fi
	done

	if [ ${cleanPkgs} = 1 ]; then
	    	for pkg in $(find ${pkg_path}/All -name "*.${package_suffix}"); do
	    		if ! echo ${pkgs_seen} | grep -qw ${pkg}; then
			    	echo "Removing stale package ${build}/${pkg}"
		    		/bin/rm -f "${pkg_path}/All/${pkg}"
			fi
	        done

		echo "Pruning broken package symlinks for build ${build}"
		find -L ${pkg_path} -type l -exec rm -f -- {} +
        fi

        tbcleanup_cleanup ${portstree}

	# Delete unreferenced log files.
	dir=$(tinderLoc buildlogs ${build})
	errorDir=$(tinderLoc builderrors ${build})

	for file_name in $(/bin/ls -1 ${dir}) ; do
	    expr -- ${file_name} : '^.*\.log$' > /dev/null
	    lres=$?
	    expr -- ${file_name} : '^.*\.log\.bz2$' > /dev/null
	    lzres=$?
	    if [ ${lres} -eq 0 -o ${lzres} -eq 0 ]; then
		result=$(${tc} isLogCurrent -b ${build} -l ${file_name} 2>/dev/null)
		if [ ${result} != 1 ]; then
		    if [ ${cleanErrors} = 1 -o ! -L "${errorDir}/${file_name}" ]; then
		        echo "Deleting stale log ${dir}/${file_name}"
		        /bin/rm -f "${dir}/${file_name}"
		    fi
		    if [ ${cleanErrors} = 1 ]; then
			/bin/rm -f "${errorDir}/${file_name}"
		    fi
		fi
	    fi
	done
    done
}

#---------------------------------------------------------------------------
# kill a tinderbuild
#---------------------------------------------------------------------------
tbkill () {
    # set up defaults
    build=""
    sig=15

    # argument handling
    while getopts b:s: arg >/dev/null 2>&1
    do
	case "${arg}" in

	b)	build="${OPTARG}";;
	s)	sig="${OPTARG}";;
	?)	return 1;;

	esac
    done

    if [ -z "${build}" ]; then
	echo "tbkill: no Build specified"
	return 1
    fi

    tbpid=$(pgrep -f -f "/bin/sh.*tinderbuild.*${build}")
    if [ -z "${tbpid}" ]; then
	return 0
    fi

    makepid=$(pgrep -f -f -P ${tbpid} "make")
    makechild=$(pgrep -P ${makepid})
    pbpid=$(pgrep -f -f "/bin/sh.*/portbuild")

    kill -${sig} ${pbpid} ${makechild} ${makepid} ${tbpid}
}

#---------------------------------------------------------------------------
# display the Tinderbox version
#---------------------------------------------------------------------------
tbversion () {
    version=$(tinderLoc scripts .version)
    if [ -f "${version}" ]; then
	cat ${version}
    else
	echo "tbversion: no version info found"
    fi
}

