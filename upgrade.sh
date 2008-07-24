#!/bin/sh
#
# Copyright (c) 2008 FreeBSD GNOME Team <gnome@FreeBSD.org>
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
# $MCom: portstools/tinderbox/upgrade.sh,v 1.14 2008/07/24 14:48:45 marcus Exp $
#

pb=$0
[ -z "$(echo "${pb}" | sed 's![^/]!!g')" ] && \
pb=$(type "$pb" | sed 's/^.* //g')
pb=$(realpath $(dirname $pb))
pb=${pb%%/scripts}

VERSION="3.0"
TINDERBOX_URL="http://tinderbox.marcuscom.com/"

. ${pb}/scripts/lib/tinderlib.sh
tc=$(tinderLoc scripts tc)

clear

tinderEcho "Welcome to the Tinderbox Upgrade and Migration script.  This script will guide you through an upgrade to Tinderbox ${VERSION}."
echo ""

read -p "Hit <ENTER> to get started: " i

# Check if the current Datasource Version is ascertainable
if ! ${tc} dsversion >/dev/null 2>&1 ; then
    tinderExit "ERROR: Upgrade is only supported from Tinderbox 2.x." $?
fi

# Cleanup files that are no longer needed.
echo ""
tinderEcho "INFO: Cleaning up stale files..."
REMOVE_FILES="buildscript create enterbuild makemake mkbuild mkjail pnohang.c portbuild rawenv rawenv.dist tbkill.sh tinderbuild tinderd lib/Build.pm lib/BuildPortsQueue.pm lib/Hook.pm lib/Host.pm lib/Jail.pm lib/MakeCache.pm lib/Port.pm lib/PortFailPattern.pm lib/PortFailReason.pm lib/PortsTree.pm lib/TBConfig.pm lib/TinderObject.pm lib/TinderboxDS.pm lib/User.pm lib/tinderbox_shlib.sh"
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
dbinfo=$(getDbInfo ${db_driver})
if [ $? = 0 ]; then
    db_admin_host=${dbinfo%:*}
    db_name=${dbinfo##*:}
    db_admin=${db_admin_host%:*}
    db_host=${db_admin_host#*:}
    do_load=1
fi

if [ ${do_load} = 0 ]; then
    tinderEcho "WARN: Database migration was not done.  If you have already loaded the database schema, type 'y' or 'yes' to continue the migration."
    echo ""
    read -p "Do you wish to continue? (y/n)" i
    case ${i} in
	[Yy]|[Yy][Ee][Ss])
	    # continue
	    ;;
	*)
	    tinderExit "INFO: Upgrade aborted by user." 0
	    ;;
    esac
else
    bkup_file=$(mktemp /tmp/tb_dbbak.XXXXXX)
    if [ $? != 0 ]; then
	tinderExit "Failed to create temp file for database backup." $?
    fi
    if ! backupDb ${bkup_file} ${db_driver} ${db_admin} ${db_host} ${db_name} ; do
	tinderExit "ERROR: Database backup failed!  Consult the output above for more information." $?
	rm -f ${bkup_file}
    fi
    if ! dropDb ${db_driver} ${db_admin} ${db_host} ${db_name} ; then
	tinderExit "ERROR: Error dropping the old database!  Consult the output above for more information.  Once the problem is corrected, run \"update.sh -backup ${bkup_file}\" to resume migration." $?
    fi
    if ! createDb ${db_driver} ${db_admin} ${db_host} ${db_name} 0; then
	tinderExit "ERROR: Error creating the new database!  Consult the output above for more information.  Once the problem is corrected, run \"update.sh -backup ${bkup_file}\" to resume migration." $?
    fi
    if ! loadSchema ${bkup_file} ${db_driver} ${db_admin} ${db_host} ${db_name} ; then
	tinderExit "ERROR: Database restoration failed!  Consult the output above for more information.  Once the problem is corrected, run \"update.sh -backup ${bkup_file}\" to resume migration." $?
    fi
    rm -f ${bkup_file}
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
tinderExit "Congratulations! Tinderbox migration is complete.  Please refer to ${TINDERBOX_URL} for a list of what is new in this version as well as general Tinderbox documentation." 0
