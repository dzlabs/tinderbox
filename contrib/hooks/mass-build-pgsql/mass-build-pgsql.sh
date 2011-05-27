#!/bin/sh
# postPortBuild

# If PGSQL needs authentication use ~/.pgpass !
PSQL=/usr/local/bin/psql
USR=tinderbox_user
DB=tinderbox_database

LOG_DIR=/var/log
LOG=${LOG_DIR}/tb_postPortBuild.log

_updateBuildPortsQueueEntryStatus() {
    BUILD_ID=`${PSQL} -U ${USR} -d ${DB} -q -t -A -c "select build_id from builds where build_name = '${BUILD}';"`
    if [ ! -z $BUILD_ID ]; then
        ${PSQL} -U ${USR} -d ${DB} -q -c "UPDATE build_ports_queue SET status = '${STATUS}' where build_id = ${BUILD_ID} and port_directory = '${PORTDIR}';"
        if [ $? -eq 0 ]; then
            printf "BUILD: %-24s ; STATUS: %-8s ; PORTDIR: %-30s\n" ${BUILD} ${STATUS} ${PORTDIR}
        fi
    fi
    return 0
}

# we are only interested in status SUCCESS and FAIL
#if [ "${STATUS}" = "SUCCESS" ]; then
if [ "${STATUS}" = "SUCCESS" -o "${STATUS}" = "FAIL" ]; then
    _updateBuildPortsQueueEntryStatus | /usr/bin/tee -a ${LOG}
fi

