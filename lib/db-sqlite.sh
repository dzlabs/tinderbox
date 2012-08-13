export DB_MAN_PREREQS="databases/sqlite3 databases/p5-DBD-SQLite"
export DB_OPT_PREREQS="databases/php5-pdo_sqlite"

export DB_PROMPT=''
export DB_SCHEMA_LOAD='/usr/local/bin/sqlite3 -batch ${db_name} < "${schema_file}"'
export DB_DUMP=''
export DB_DROP='rm -f ${db_name}'
export DB_CHECK='/usr/local/bin/sqlite3 ${db_name} "SELECT 0;"'
export DB_CREATE=''
export DB_GRANT=''
export DB_QUERY='/usr/local/bin/sqlite3 ${db_name} ${query}'
export DB_USER_PROMPT=''
export DB_CREATE_USER=''
