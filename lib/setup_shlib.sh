#!/bin/sh
#-
# Copyright (c) 2004-2005 FreeBSD GNOME Team <freebsd-gnome@FreeBSD.org>
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions # are met:
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
# $MCom: portstools/tinderbox/lib/setup_shlib.sh,v 1.14 2005/07/21 17:52:46 marcus Exp $
#

pb=$0
[ -z "$(echo "${pb}" | sed 's![^/]!!g')" ] && \
pb=$(type "$pb" | sed 's/^.* //g')
pb=$(realpath $(dirname $pb))
pb=${pb%%/scripts}


call_tc() {
	echo "INFO: calling ${pb}/scripts/tc $@"
	${pb}/scripts/tc "$@"
}

get_dbdriver() {
    echo "mysql" # XXX
}

get_dbinfo() {
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

        if [ -z "${db_admin}" ]; then
	    db_admin="root"
        fi

        if [ -z "${db_host}" ]; then
	    db_host="localhost"
        fi

        if [ -z "${db_name}" ]; then
	    db_name="tinderbox"
        fi

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

load_schema() {
    schema_file=$1
    db_driver=$2
    db_admin=$3
    db_host=$4
    db_name=$5

    MYSQL_LOAD='/usr/local/bin/mysql -u${db_admin} -p -h ${db_host} ${db_name} < "${schema_file}"'
    MYSQL_LOAD_PROMPT='echo "The next prompt will be for ${db_admin}'"'"'s password to the ${db_name} database." | /usr/bin/fmt 75 79'

    rc=0
    case "${db_driver}" in
	mysql)
	    eval ${MYSQL_LOAD_PROMPT}
	    eval ${MYSQL_LOAD}
	    rc=$?
	    ;;
	*)
	    echo "Unsupported database driver: ${db_driver}"
	    return 1
	    ;;
    esac

    return ${rc}
}

check_prereqs() {
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
