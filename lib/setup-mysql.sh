#!/bin/sh
#-
# Copyright (c) 2004-2005 FreeBSD GNOME Team <freebsd-gnome@FreeBSD.org>
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
# $MCom: portstools/tinderbox/lib/setup-mysql.sh,v 1.2 2005/09/03 22:13:14 marcus Exp $
#

DB_MAN_PREREQS="databases/p5-DBD-mysql41 databases/mysql41-client"
DB_OPT_PREREQS="databases/php4-mysql"

tinder_echo "INFO: Checking for prerequisites for mysql database driver ..."
if [ -n "${DB_MAN_PREREQS}" ]; then
    missing=$(check_prereqs ${DB_MAN_PREREQS})

    if [ $? = 1 ]; then
	tinder_echo "ERROR: The following mandatory dependencies are missing.  These must be installed prior to running the Tinderbox setup script."
	tinder_echo "ERROR:    ${missing}"
	exit 1
    fi
fi

if [ -n "${DB_OPT_PREREQS}" ]; then
    missing=$(check_prereqs ${DB_OPT_PREREQS})

    if [ $? = 1 ]; then
	tinder_echo "WARN: The following option dependencies are missing.  These are required to use the Tinderbox web front-ends."
	tinder_echo "WARN:    ${missing}"
    fi
fi
tinder_echo "DONE."
echo ""

db_name=""
db_admin=""
db_host=""
db_user=""
do_db=0
schema_file=${pb}/scripts/tinderbox-mysql.schema

dbinfo=$(get_dbinfo mysql)
if [ $? = 0 ]; then
    db_admin_host=${dbinfo%:*}
    db_name=${dbinfo##*:}
    db_admin=${db_admin_host%:*}
    db_host=${db_admin_host#*:}
    do_db=1
else
    tinder_echo "WARN: You must first create a database for Tinderbox, and load the database schema from ${schema_file}.  Consult ${TINDERBOX_URL} for more information on creating and initializing the Tinderbox database."
fi

if [ ${do_db} = 1 ]; then
    if [ ! -f ${schema_file} ]; then
	tinder_exit "ERROR: Database schema file ${schema_file} is missing.  Database configuration cannot be completed."
    fi

    tinder_echo "INFO: Checking to see if database ${db_name} already exists on ${db_host} ..."
    tinder_echo "INFO: The next prompt will be for the ${db_admin}'s password on the database server ${db_host}."
    dbexist=$(/usr/local/bin/mysql -u${db_admin} -B -s -p -h ${db_host} -e "SHOW DATABASES LIKE '${db_name}'" mysql)

    if [ x"${dbexist}" = x"${db_name}" ]; then
	tinder_echo "WARN: A database with the name ${db_name} already exists on ${db_host}.  Do you want to use this database for Tinderbox (note: if you type 'n', setup will abort)?"
	read -p "(y/n) " i
	case "${i}" in
	    [Yy]|[Yy][Ee][Ss])
	        # continue
		;;
	    *)
	        tinder_exit "INFO: Setup aborted by user."
		;;
	esac
    else
	tinder_echo "INFO: Database ${db_name} does not exist.  Creating database ${db_name} on ${db_host} ..."
	tinder_echo "INFO: The next prompt will be for ${db_admin}'s password on the database server ${db_host}."
	/usr/local/bin/mysqladmin -u${db_admin} -p -h ${db_host} create ${db_name}
    fi

    if [ $? != 0 ]; then
	tinder_exit "ERROR: Database creation failed!  Consult the output above for more information." $?
    fi

    tinder_echo "DONE."
    echo ""

    tinder_echo "INFO: Loading Tinderbox schema into ${db_name} ..."
    load_schema ${schema_file} mysql ${db_admin} ${db_host} ${db_name}

    if [ $? != 0 ]; then
	tinder_exit "ERROR: Database schema load failed!  Consult the output above for more information." $?
    fi

    tinder_echo "DONE."
    echo ""

    finished=0
    while [ ${finished} != 1 ]; do
	read -p "Enter the desired username for the Tinderbox database : " db_user
	pwfinished=0
	while [ ${pwfinished} != 1 ]; do
	    stty -echo
	    read -p "Enter the desired password for ${db_user} : " db_pass
	    stty echo
	    echo ""
	    stty -echo
	    read -p "Confirm password for ${db_user} : " confirm_pass
	    stty echo
	    echo ""
	    if [ ${db_pass} = ${confirm_pass} ]; then
		pwfinished=1
	    else
		echo 1>&2 "WARN: Passwords do not match!"
	    fi
	done

	echo 1>&2 "Are these the settings you want:"
	echo 1>&2 "    Database username      : ${db_user}"
	echo 1>&2 "    Database user password : ****"
	read -p "(y/n)" option

	case "${option}" in
	    [Yy]|[Yy][Ee][Ss])
	        finished=1
		;;
	esac
    done

    grant_host=""
    if [ ${db_host} = "localhost" ]; then
	grant_host="localhost"
    else
	grant_host=$(hostname)
    fi

    tinder_echo "INFO: Adding permissions to ${db_name} for ${db_user} ..."
    tinder_echo "INFO: The next prompt will be for ${db_admin}'s password on the database server ${db_host}."
    /usr/local/bin/mysql -u${db_admin} -p -h ${db_host} -e "GRANT SELECT, INSERT, UPDATE, DELETE ON ${db_name}.* TO '${db_user}'@'${grant_host}' IDENTIFIED BY '${db_pass}' ; FLUSH PRIVILEGES" mysql

    if [ $? != 0 ]; then
	tinder_exit "ERROR: Database privilege configuration failed!  Consult the output above for more information." $?
    fi

    tinder_echo "DONE."
    echo ""

    cat > ${pb}/scripts/ds.ph << EOT
\$DB_DRIVER       = '${db_driver}';
\$DB_HOST         = '${db_host}';
\$DB_NAME         = '${db_name}';
\$DB_USER         = '${db_user}';
\$DB_PASS         = '${db_pass}';
\$DBI_TYPE        = 'database';

1;
EOT
fi
