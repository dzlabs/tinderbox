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
# $MCom: portstools/tinderbox/setup.sh,v 1.16 2005/09/04 00:00:45 marcus Exp $
#

pb=$0
[ -z "$(echo "${pb}" | sed 's![^/]!!g')" ] && \
pb=$(type "$pb" | sed 's/^.* //g')
pb=$(realpath $(dirname $pb))
pb=${pb%%/scripts}

MAN_PREREQS="lang/perl5.8 net/p5-Net security/p5-Digest-MD5"
OPT_PREREQS="lang/php[45] databases/pear-DB www/php[45]-session"
PREF_FILES="rawenv tinderbox.ph"
README="${pb}/scripts/README"
TINDERBOX_URL="http://tinderbox.marcuscom.com/"

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

db_driver=$(get_dbdriver)

if [ ! -f "${pb}/scripts/lib/setup-${db_driver}.sh" ]; then
    tinder_echo "ERROR: Failed to locate a setup script for the ${db_driver} database driver."
    exit 1
fi

. ${pb}/scripts/lib/setup-${db_driver}.sh

tinder_echo "INFO: Database configuration complete."
echo ""

# We're done now.  We don't want to call tc init here since the user may need
# to configure tinderbox.ph first.
tinder_exit "Congratulations!  The scripted portion of Tinderbox has completed successfully.  You should now verify the settings in ${pb}/scripts/tinderbox.ph are correct for your environment, then run '${pb}/scripts/tc init' to complete the setup.  Be sure to checkout ${TINDERBOX_URL} for further instructions." 0
