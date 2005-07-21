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
# $MCom: portstools/tinderbox/setup.sh,v 1.9 2005/07/21 17:03:21 marcus Exp $
#

pb=$0
[ -z "$(echo "${pb}" | sed 's![^/]!!g')" ] && \
pb=$(type "$pb" | sed 's/^.* //g')
pb=$(realpath $(dirname $pb))
pb=${pb%%/scripts}

MAN_PREREQS="lang/perl5.8"
OPT_PREREQS="lang/php4 databases/php4-mysql databases/pear-DB www/php4-session"
PREF_FILES="rawenv tinderbox.ph"
README="${pb}/scripts/README"
SCHEMA_FILE="${pb}/scripts/tinderbox.schema"
TINDERBOX_URL="http://tinderbox.marcuscom.com/"

## Database-specific variables
# Each command can make use of the following variables:
#  db_admin : Database administrative user (e.g. root)
#  db_driver : Database driver (e.g. mysql)
#  db_host : Database host (e.g. localhost)
#  db_name : Database name (e.g. tinderbox)
#  db_user : Database user for Tinderbox (e.g. tinder)
#  db_pass : Database user password
##

# MySQL-specific variables
MYSQL_CREATEDB='/usr/local/bin/mysqladmin -u${db_admin} -p -h ${db_host} create ${db_name}'
MYSQL_CREATEDB_PROMPT='tinder_echo "INFO: The next prompt will be for ${db_admin}'"'"'s password on the database server ${db_host}."'
MYSQL_GRANT='/usr/local/bin/mysql -u${db_admin} -p -h ${db_host} -e "GRANT SELECT, INSERT, UPDATE, DELETE ON ${db_name}.* TO '"'"'${db_user}'"'"'@'"'"'${grant_host}'"'"' IDENTIFIED BY '"'"'${db_pass}'"'"' ; FLUSH PRIVILEGES" mysql'
MYSQL_GRANT_PROMPT=${MYSQL_CREATEDB_PROMPT}
MYSQL_DB_PREREQS="databases/p5-DBD-mysql41 databases/mysql41-client"

. ${pb}/scripts/lib/setup_shlib.sh
. ${pb}/scripts/lib/tinderbox_shlib.sh

clear

tinder_echo "Welcome to the Tinderbox Setup script.  This script will guide you through some of the automated Tinderbox setup steps.  Once this script completes, you should review the documentation in ${README} or on the web at ${TINDERBOX_URL} to complete your setup."
echo ""

read -p "Hit <ENTER> to get started: " i

# First, check to see that all of the pre-requisites are installed.
tinder_echo "INFO: Checking prerequisites ..."
missing=$(check_prereqs ${MAN_PREREQS})

if [ $? = 1 ]; then
    tinder_echo "ERROR: The following mandatory dependencies are missing.  These must be installed prior to running the Tinderbox setup script."
    tinder_echo "ERROR:   ${missing}"
    exit 1
fi

# Now, check the optional pre-reqs (for web usage).
missing=$(check_prereqs ${OPT_PREREQS})

if [ $? = 1 ]; then
    tinder_echo "WARN: The following option dependencies are missing.  These are required to use the Tinderbox web front-ends."
    tinder_echo "WARN:  ${missing}"
fi
tinder_echo "DONE."
echo ""

# Now install the default preferences files.
tinder_echo "INFO: Creating default configuration files ..."
for f in ${PREF_FILES} ; do
    if [ ! -f ${pb}/scripts/${f}.dist ]; then
	tinder_exit "ERROR: Missing required distribution file ${pb}/scripts/${f}.dist.  Please download and extract Tinderbox again."
    fi
    if [ -f ${pb}/scripts/${f} ]; then
	cp -p ${pb}/scripts/${f} ${pb}/scripts/${f}.bak
    fi
    cp -f ${pb}/scripts/${f}.dist ${pb}/scripts/${f}
done
tinder_echo "DONE."
echo ""

# Now create the database if we can.
tinder_echo "INFO: Beginning database configuration."
db_host=""
db_name=""
db_user=""
db_pass=""
db_admin=""
db_driver=""
createdb_cmd=""
createdb_prompt=""
grant_cmd=""
grant_prompt=""
db_prereqs=""
do_db=0
dbinfo=$(get_dbinfo)
if [ $? = 0 ]; then
    db_driver_admin=${dbinfo%|*}
    db_host_name=${dbinfo#*|}
    db_host=${db_host_name%:*}
    db_name=${db_host_name#*:}
    db_driver=${db_driver_admin%:*}
    db_admin=${db_driver_admin#*:}
    case "${db_driver}" in
	mysql)
	    createdb_cmd=${MYSQL_CREATEDB}
	    createdb_prompt=${MYSQL_CREATEDB_PROMPT}
	    grant_cmd=${MYSQL_GRANT}
	    grant_prompt=${MYSQL_GRANT_PROMPT}
	    db_prereqs=${MYSQL_DB_PREREQS}
	    ;;
	*)
	    tinder_exit "ERROR: Unsupport database driver: ${db_driver}"
	    ;;
    esac
    do_db=1
else
    tinder_echo "WARN: You must first create a database for Tinderbox, and load the database schema from ${SCHEMA_FILE}.  Consult ${TINDERBOX_URL} for more information on creating and initializing the Tinderbox database."
fi

if [ ${do_db} = 1 ]; then
    if [ ! -f ${SCHEMA_FILE} ]; then
	tinder_exit "ERROR: Database schema file ${SCHEMA_FILE} is missing.  Database configuration cannot be completed."
    fi
    if [ -n "${db_prereqs}" ]; then
        tinder_echo "INFO: Checking for prerequisites for ${db_driver} database driver ..."
        missing=$(check_prereqs ${db_prereqs})

        if [ $? = 1 ]; then
	    tinder_echo "ERROR: The following mandatory dependencies are missing.  These must be installed prior to running the Tinderbox setup script."
	    tinder_echo "ERROR:  ${missing}"
	    exit 1
        fi
        tinder_echo "DONE."
	echo ""
    fi

    tinder_echo "INFO: Creating database ${db_name} on ${db_host} ..."
    eval ${createdb_prompt}
    eval ${createdb_cmd}

    if [ $? != 0 ]; then
	tinder_exit "ERROR: Database creation failed!  Consult the output above for more information." $?
    fi

    tinder_echo "DONE."
    echo ""

    tinder_echo "INFO: Loading Tinderbox schema into ${db_name} ..."
    load_schema ${SCHEMA_FILE} ${db_driver} ${db_admin} ${db_host} ${db_name}

    if [ $? != 0 ]; then
	tinder_exit "ERROR: Database schema load failed!  Consult the output above for more information." $?
    fi

    tinder_echo "DONE."
    echo ""

    read -p "Enter the desired username for the Tinderbox database : " db_user
    finished=0
    while [ ${finished} != 1 ]; do
        stty -echo
        read -p "Enter the desired password for ${db_user} : " db_pass
	stty echo
	echo ""
	stty -echo
        read -p "Confirm password for ${db_user} : " confirm_pass
        stty echo
	echo ""
	if [ ${db_pass} = ${confirm_pass} ]; then
	    finished=1
	else
	    tinder_echo "WARN: Passwords do not match!"
	fi
    done

    grant_host=""
    if [ ${db_host} = "localhost" ]; then
	grant_host="localhost"
    else
	grant_host=$(hostname)
    fi

    tinder_echo "INFO: Adding permissions to ${db_name} for ${db_user} ..."
    eval ${grant_prompt}

    eval ${grant_cmd}

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

1;
EOT

    tinder_echo "INFO: Database configuration complete."
    echo ""
fi

# We're done now.  We don't want to call tc init here since the user may need
# to configure tinderbox.ph first.
tinder_exit "Congratulations!  The scripted portion of Tinderbox has completed successfully.  You should now verify the settings in ${pb}/scripts/tinderbox.ph are correct for your environment, then run '${pb}/scripts/tc init' to complete the setup.  Be sure to checkout ${TINDERBOX_URL} for further instructions." 0
