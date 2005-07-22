#!/bin/sh
#
# $FreeBSD$
#   $MCom: portstools/tinderbox/etc/rc.d/tinderd.sh,v 1.1 2005/07/22 21:50:55 marcus Exp $
#

# PROVIDE: tinderd
# REQUIRE: LOGIN abi
# BEFORE:  securelevel
# KEYWORD: FreeBSD shutdown

# Add the following line to /etc/rc.conf to enable `tinderd':
#
#tinderd_enable="YES"
#

. "/etc/rc.subr"

name="tinderd"
rcvar=`set_rcvar`

# read settings, set default values
load_rc_config "$name"
: ${tinderd_enable="NO"}
: ${tinderd_directory="/space/scripts"}
: ${tinderd_flags=""}

# path to your executable, might be libxec, bin, sbin, ...
command="${tinderd_directory}/tinderd"

# needed when your daemon is a perl script
command_interpreter="/bin/sh"

# extra required arguments
command_args=">/dev/null &"

# use when the daemon requires a configuration file to run,

required_files="${tinderd_directory}/rawenv"

run_rc_command "$1"
