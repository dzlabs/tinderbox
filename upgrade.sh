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
# $MCom: portstools/tinderbox/upgrade.sh,v 1.1 2005/07/20 04:23:18 marcus Exp $
#

pb=$0
[ -z "$(echo "${pb}" | sed 's![^/]!!g')" ] && \
pb=$(type "$pb" | sed 's/^.* //g')
pb=$(realpath $(dirname $pb))
pb=${pb%%/scripts}

VERSION="2.0.0"
RAWENV_HEADER="## rawenv TB v2 -- DO NOT EDIT"
REMOVE_FILES="Build.pm BuildPortsQueue.pm Host.pm Jail.pm MakeCache.pm Port.pm PortsTree.pm TBConfig.pm TinderObject.pm TinderboxDS.pm User.pm setup_shlib.sh tinderbox_shlib.sh tinderlib.pl"
TINDERBOX_URL="http://tinderbox.marcuscom.com"

. ${pb}/scripts/upgrade/mig_shlib.sh

echo "Welcome to the Tinderbox Upgrade and Migration script.  This script will guide you through an upgrade to Tinderbox ${VERSION}." | /usr/bin/fmt 75 79

read -p "Hit <ENTER> to get started: " i

# First, migrate the database, if needed.
db_host=""
db_name=""
do_load=0
dbinfo=$(get_dbinfo)
if [ $? = 0 ]; then
    db_host=$(echo ${dbinfo} | cut -d':' -f1)
    db_name=$(echo ${dbinfo} | cut -d':' -f2)
    do_load=1
fi

rc=$(mig_db ${do_load} ${db_host} ${db_name})
while [ ${rc} = 1 ]; do
    rc=$(mig_db ${do_load} ${db_host} ${db_name})
done

if [ ${rc} != 0 ]; then
    echo "ERROR: Database migration failed!  Consult the output above for more information." | /usr/bin/fmt 75 79
    exit ${rc}
fi

# Now migrate rawenv if needed.
rc=$(mig_rawenv ${pb}/scripts/rawenv)

if [ ${rc} != 0 ]; then
    echo "Rawenv migration failed!  Consult the output above for more information." | /usr/bin/fmt 75 79
    exit ${rc}
fi

# Finally, migrate any remaining file data.
rc=$(mig_files ${pb}/scripts/rawenv)

if [ ${rc} != 0 ]; then
    echo "Files migration failed!  Consult the output above for more information." | /usr/bin/fmt 75 79
    exit ${rc}
fi

"Congratulations!  Tinderbox migration is complete.  Please refer to ${TINDERBOX_URL} for a list of what is new in this version as well as general Tinderbox documentation." | /usr/bin/fmt 75 79

exit 0
