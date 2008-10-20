# Copyright (c) 2008 FreeBSD GNOME Team <freebsd-gnome@FreeBSD.org>
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
# $MCom: portstools/tinderbox/lib/db-pgsql.sh,v 1.3 2008/10/20 00:15:36 marcus Exp $
#
export DB_MAN_PREREQS="databases/p5-DBD-Pg databases/postgresql*-client"
export DB_OPT_PREREQS="databases/php5-pgsql"

if [ -n "${db_admin_pass}" ]; then
    export PGPASSWORD=${db_admin_pass}
    export DB_PROMPT='true'
    export DB_SCHEMA_LOAD='/usr/local/bin/psql -U ${db_admin} -h ${db_host} -d ${db_name} < "${schema_file}"'
    export DB_DUMP='/usr/local/bin/pg_dump -U ${db_admin} -h ${db_host} --data-only --inserts --table=%%TABLE%% ${db_name} >> ${tmpfile}'
    export DB_DROP='/usr/local/bin/dropdb -U ${db_admin} -h ${db_host} ${db_name}'
    export DB_CHECK='/usr/local/bin/psql -U ${db_admin} -h ${db_host} -c "SELECT 0" ${db_name}'
    export DB_CREATE='/usr/local/bin/createdb -O ${db_user} -U ${db_admin} -h ${db_host} ${db_name}'
    export DB_GRANT='echo "Make sure ${db_user} owns the database ${db_name} as well as all of its tables."'
    export DB_QUERY='/usr/local/bin/psql -U ${db_admin} -h ${db_host} -t -q -A -F " " -c "${query}" ${db_name}'
else
    export DB_PROMPT='echo "The next prompt will be for ${db_admin}'"'"'s password to the ${db_name} database." | /usr/bin/fmt 75 79'
    export DB_SCHEMA_LOAD='/usr/local/bin/psql -U ${db_admin} -W -h ${db_host} -d ${db_name} < "${schema_file}"'
    export DB_DUMP='/usr/local/bin/pg_dump -U ${db_admin} -W -h ${db_host} --data-only --inserts --table=%%TABLE%% ${db_name} >> ${tmpfile}'
    export DB_DROP='/usr/local/bin/dropdb -U ${db_admin} -h ${db_host} -W ${db_name}'
    export DB_CHECK='/usr/local/bin/psql -U ${db_admin} -h ${db_host} -W -c "SELECT 0" ${db_name}'
    export DB_CREATE='/usr/local/bin/createdb -O ${db_user} -U ${db_admin} -h ${db_host} -W ${db_name}'
    export DB_GRANT='echo "Make sure ${db_user} owns the database ${db_name} as well as all of its tables."'
    export DB_QUERY='/usr/local/bin/psql -U ${db_admin} -W -h ${db_host} -t -q -A -F " " -c "${query}" ${db_name}'
fi
