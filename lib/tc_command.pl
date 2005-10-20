#!/usr/bin/perl
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
# $MCom: portstools/tinderbox/lib/tc_command.pl,v 1.83 2005/10/20 14:45:57 marcus Exp $
#

my $pb;

BEGIN {
        $pb = $ENV{'pb'};

        push @INC, "$pb/scripts";
        push @INC, "$pb/scripts/lib";

        require lib;
        import lib "$pb/scripts";
        import lib "$pb/scripts/lib";
}

use strict;

use TinderboxDS;
use MakeCache;
use Getopt::Std;
use vars qw(
    %COMMANDS
    $SUBJECT
    $SMTP_HOST
    $SERVER_HOST
    $SERVER_PROTOCOL
    $SENDER
    $SHOWBUILD_URI
    $SHOWPORT_URI
    $LOG_URI
);

require "tinderbox.ph";
require "tinderlib.pl";

my $ds = new TinderboxDS();

%COMMANDS = (
        "init" => {
                help  => "Initialize a tinderbox environment",
                usage => "",
        },
        "dsversion" => {
                func  => \&dsversion,
                help  => "Print the datastore version",
                usage => "",
        },
        "configGet" => {
                func   => \&configGet,
                help   => "Print current Tinderbox configuration",
                usage  => "[-G | -h <host name>]",
                optstr => 'h:G',
        },
        "configCcache" => {
                func  => \&configCcache,
                help  => "Configure Tinderbox ccache parameters",
                usage =>
                    "[-d | -e] [-c <cache mount src>] [-s <max cache size>] [-j | -J] [-l <debug logfile> | -L] [-h <host name> | -G] | -G -h <host name>",
                optstr => 'dec:s:l:LjJh:G',
        },
        "configDistfile" => {
                func  => \&configDistfile,
                help  => "Configure Tinderbox distfile parameters",
                usage =>
                    "[-c <distfile cache mount src> | -C] [-h <host name> | -G] | -G -h <host name>",
                optstr => 'c:Ch:G',
        },
        "configJail" => {
                func  => \&configJail,
                help  => "Configure Tinderbox Jail parameters",
                usage =>
                    "[-o <jail object directory> | -O] [-h <host name> | -G] | -G -h <host name>",
                optstr => 'o:Oh:G',
        },
        "configTinderd" => {
                func => \&configTinderd,
                help =>
                    "Configure Tinderbox tinder daemon (tinderd) parameters",
                usage =>
                    "[-t <sleep time>] [-h <host name> | -G] | -G -h <host name>",
                optstr => 't:h:G',
        },
        "listJails" => {
                func  => \&listJails,
                help  => "List all jails in the datastore",
                usage => "",
        },
        "listBuilds" => {
                func  => \&listBuilds,
                help  => "List all builds in the datastore",
                usage => "",
        },
        "listPortsTrees" => {
                func  => \&listPortsTrees,
                help  => "List all portstrees in the datastore",
                usage => "",
        },
        "listBuildPortsQueue" => {
                func   => \&listBuildPortsQueue,
                help   => "Lists the Ports to Build Queue",
                usage  => "[-h <host>] [-r] [-s <status>]",
                optstr => 'h:s:r',
        },
        "listPortFailPatterns" => {
                func => \&listPortFailPatterns,
                help =>
                    "List all port failure patterns, their reasons, and regular expressions",
                usage  => "[-i <ID>]",
                optstr => 'i:',
        },
        "listPortFailReasons" => {
                func  => \&listPortFailReasons,
                help  => "List all port failure reasons and their descriptions",
                usage => "[-t <tag>]",
                optstr => 't:',
        },
        "reorgBuildPortsQueue" => {
                func   => \&reorgBuildPortsQueue,
                help   => "Reorganizes the Ports to Build Queue",
                usage  => "[-h <host>]",
                optstr => 'h:',
        },
        "addHost" => {
                func   => \&addHost,
                help   => "Add a host to the datastore",
                usage  => "[-h <hostname>]",
                optstr => 'h:',
        },
        "addBuild" => {
                func  => \&addBuild,
                help  => "Add a build to the datastore",
                usage =>
                    "-b <build name> -j <jail name> -p <portstree name> [-d <build description>]",
                optstr => 'b:j:p:d:',
        },
        "addJail" => {
                func  => \&addJail,
                help  => "Add a jail to the datastore",
                usage =>
                    "-j <jail name> -t <jail tag> [-d <jail description>] [-m <src mount source>] [-u <jail update command|CVSUP|NONE>]",
                optstr => 'm:j:t:u:d:',
        },
        "addPortsTree" => {
                func  => \&addPortsTree,
                help  => "Add a portstree to the datastore",
                usage =>
                    "-p <portstree name> [-d <portstree description>] [-m <ports mount source>] [-u <portstree update command|NONE|CVSUP>] [-w <CVSweb URL>]",
                optstr => 'm:p:u:d:w:',
        },
        "addPort" => {
                func => \&addPort,
                help =>
                    "Add a port, and optionally, its dependencies, to the datastore",
                usage  => "{-b <build name> | -a} -d <port directory> [-r]",
                optstr => 'ab:d:r',
        },
        "addBuildPortsQueueEntry" => {
                func  => \&addBuildPortsQueueEntry,
                help  => "Adds a Port to the Ports to Build Queue",
                usage =>
                    "-b <build name> -d <port directory> [-h <hostname>] [-p <priority>]",
                optstr => 'b:d:h:p:',
        },
        "addPortFailPattern" => {
                func  => \&addPortFailPattern,
                help  => "Add a port failure pattern to the datastore",
                usage =>
                    "-i <ID> -r <reason tag> -e <expression> [-p <parent ID>]",
                optstr => 'i:r:e:p:',
        },
        "addPortFailReason" => {
                func  => \&addPortFailReason,
                help  => "Add a port failure reason to the datastore",
                usage =>
                    "-t <tag> [-d <description>] [-y COMMON|RARE|TRANSIENT]",
                optstr => 't:d:y:',
        },
        "getJailForBuild" => {
                func   => \&getJailForBuild,
                help   => "Get the jail name associated with a given build",
                usage  => "-b <build name>",
                optstr => 'b:',
        },
        "getPortsTreeForBuild" => {
                func  => \&getPortsTreeForBuild,
                help  => "Get the portstree name assoicated with a given build",
                usage => "-b <build name>",
                optstr => 'b:',
        },
        "getTagForJail" => {
                func   => \&getTagForJail,
                help   => "Get the tag for a given jail",
                usage  => "-j <jail name>",
                optstr => 'j:',
        },
        "getSrcUpdateCmd" => {
                func   => \&getSrcUpdateCmd,
                help   => "Get the update command for the given jail",
                usage  => "-j <jail name>",
                optstr => 'j:',
        },
        "getPortsUpdateCmd" => {
                func   => \&getPortsUpdateCmd,
                help   => "Get the update command for the given portstree",
                usage  => "-p <portstree name>",
                optstr => 'p:',
        },
        "getSrcMount" => {
                func   => \&getSrcMount,
                help   => "Get the src mount source for the given jail",
                usage  => "-j <jail name>",
                optstr => 'j:',
        },
        "getPortsMount" => {
                func   => \&getPortsMount,
                help   => "Get the ports mount source for the given portstree",
                usage  => "-p <portstree name>",
                optstr => 'p:',
        },
        "setSrcMount" => {
                func   => \&setSrcMount,
                help   => "Set the src mount source for the given jail",
                usage  => "-j <jail name> -m <mountsource>",
                optstr => 'j:m:',
        },
        "setPortsMount" => {
                func   => \&setPortsMount,
                help   => "Set the ports mount source for the given portstree",
                usage  => "-p <portstree name> -m <mountsource>",
                optstr => 'p:m:',
        },
        "rmHost" => {
                func   => \&rmHost,
                help   => "Removes a host from the datastore",
                usage  => "[-h <hostname>]",
                optstr => 'h:',
        },
        "rmBuildPortsQueue" => {
                func => \&rmBuildPortsQueue,
                help =>
                    "Removes all Ports from the Ports to Build Queue for one host",
                usage  => "[-h <hostname>]",
                optstr => 'h:',
        },
        "rmBuildPortsQueueEntry" => {
                func  => \&rmBuildPortsQueueEntry,
                help  => "Removes a Port from the Ports to Build Queue",
                usage =>
                    "-i <Build_Ports_Queue_Id> | -b <build name> -d <port directory> [-h <hostname>]",
                optstr => 'i:b:d:h:',
        },
        "rmPort" => {
                func => \&rmPort,
                help =>
                    "Remove a port from the datastore, and optionally its package and logs from the file system",
                usage  => "-d <port directory> [-b <build name>] [-f] [-c]",
                optstr => 'fb:d:c',
        },
        "rmBuild" => {
                func   => \&rmBuild,
                help   => "Remove a build from the datastore",
                usage  => "-b <build name> [-f]",
                optstr => 'b:f',
        },
        "rmPortsTree" => {
                func   => \&rmPortsTree,
                help   => "Remove a portstree from the datastore",
                usage  => "-p <portstree name> [-f]",
                optstr => 'p:f',
        },
        "rmJail" => {
                func   => \&rmJail,
                help   => "Remove a jail from the datastore",
                usage  => "-j <jail name> [-f]",
                optstr => 'j:f',
        },
        "rmPortFailPattern" => {
                func   => \&rmPortFailPattern,
                help   => "Remove a port failure pattern from the datastore",
                usage  => "-i <ID> [-f]",
                optstr => 'i:f',
        },
        "rmPortFailReason" => {
                func   => \&rmPortFailReason,
                help   => "Remove a port failure reason from the datastore",
                usage  => "-t <tag> [-f]",
                optstr => 't:f',
        },
        "updatePortsTree" => {
                func => \&updatePortsTree,
                help =>
                    "Run the configured update command on the specified portstree",
                usage  => "-p <portstree name> [-l <last built timestamp>]",
                optstr => 'p:l:',
        },
        "updateBuildPortsQueueEntryCompletionDate" => {
                func => \&updateBuildPortsQueueEntryCompletionDate,
                help =>
                    "Update the specified Build Ports Queue Entry completion time",
                usage  => "-i <id> [-l <completion timestamp>]",
                optstr => 'i:l:',
        },

        "updateJailLastBuilt" => {
                func   => \&updateJailLastBuilt,
                help   => "Update the specified jail's last built time",
                usage  => "-j <jail name> [-l <last built timestamp>]",
                optstr => 'j:l:',
        },
        "updatePortLastBuilt" => {
                func => \&updatePortLastBuilt,
                help =>
                    "Update the specified port's last built time for the specified build",
                usage =>
                    "-d <port directory> -b <build name> [-l <last built timestamp>]",
                optstr => 'd:b:l:',
        },
        "updatePortLastSuccessfulBuilt" => {
                func => \&updatePortLastSuccessfulBuilt,
                help =>
                    "Update the specified port's last successful built time for the specified build",
                usage =>
                    "-d <port directory> -b <build name> [-l <last built timestamp>]",
                optstr => 'd:b:l:',
        },
        "updatePortLastStatus" => {
                func => \&updatePortLastStatus,
                help =>
                    "Update the specified port's last build status for the specified build",
                usage =>
                    "-d <port directory> -b <build name> -s <UNKNOWN|SUCCESS|FAIL>",
                optstr => 'd:b:s:',
        },
        "updatePortLastFailReason" => {
                func => \&updatePortLastFailReason,
                help =>
                    "Update the specified port's last build failure reason for the specified build",
                usage  => "-d <port directory> -b <build name> -r <reason tag>",
                optstr => 'd:b:r:',
        },
        "updatePortLastBuiltVersion" => {
                func => \&updatePortLastBuiltVersion,
                help =>
                    "Update the specified port's last built version for the specified build",
                usage =>
                    "-d <port directory> -b <build name> -v <last built version>",
                optstr => 'd:b:v:',
        },
        "updateBuildStatus" => {
                func   => \&updateBuildStatus,
                help   => "Update the current status for the specific build",
                usage  => "-b <build name> -s <IDLE|PORTBUILD>",
                optstr => 'b:s:',
        },
        "updateBuildPortsQueueEntryStatus" => {
                func => \&updateBuildPortsQueueEntryStatus,
                help =>
                    "Update the current status for the specific queue entry",
                usage  => "-i id -s <ENQUEUED|PROCESSING|SUCCESS|FAIL>",
                optstr => 'i:s:',
        },
        "getPortLastBuiltVersion" => {
                func => \&getPortLastBuiltVersion,
                help =>
                    "Get the last built version for the specified port and build",
                usage  => "-d <port directory> -b <build name>",
                optstr => 'd:b:',
        },
        "updateBuildCurrentPort" => {
                func => \&updateBuildCurrentPort,
                help =>
                    "Update the port currently being built for the specify build",
                usage  => "-b <build name> [-n <package name>]",
                optstr => 'b:n:',
        },
        "sendBuildCompletionMail" => {
                func => \&sendBuildCompletionMail,
                help =>
                    "Send email to the build interest list when a build completes",
                usage  => "-b <build name> [-u <user>]",
                optstr => 'b:u:',
        },
        "addBuildUser" => {
                func   => \&addBuildUser,
                help   => "Add a user to a given build's interest list",
                usage  => "{-b <build name> | -a} -u <username> [-c] [-e]",
                optstr => 'ab:ceu:',
                ,
        },
        "addUser" => {
                func  => \&addUser,
                help  => "Add a user to the datastore",
                usage =>
                    "-u <username> [-e <emailaddress>] [-p <password>] [-w]",
                optstr => 'u:e:p:w',
        },
        "updateUser" => {
                func  => \&updateUser,
                help  => "Update user preferences",
                usage =>
                    "-u <username> [-e <emailaddress>] [-p <password>] [-w]",
                optstr => 'u:e:p:w',
        },
        "updatePortFailReason" => {
                func => \&updatePortFailReason,
                help =>
                    "Update the type or description of a port failure reason",
                usage  => "-t <tag> <[-d <descr>] | [-y <type>]>",
                optstr => 't:d:y:',
        },
        "setWwwAdmin" => {
                func   => \&setWwwAdmin,
                help   => "Defines which user is the www admin",
                usage  => "-u <username>",
                optstr => 'u:',
        },
        "updateBuildUser" => {
                func => \&updateBuildUser,
                help =>
                    "Update email preferences for the given user for the given build",
                usage  => "{-b <build name> | -a} -u <username> [-c] [-e]",
                optstr => 'ab:u:ce',
        },
        "rmUser" => {
                func   => \&rmUser,
                help   => "Remove a user from the datastore",
                usage  => "[-b <build name>] -u <username> [-f]",
                optstr => 'fb:u:',
        },
        "sendBuildErrorMail" => {
                func => \&sendBuildErrorMail,
                help =>
                    "Send email to the build interest list when a port fails to build",
                usage =>
                    "-b <build name> -d <port directory> [-p <package name>]",
                optstr => 'b:d:p:',
        },
        "listUsers" => {
                func  => \&listUsers,
                help  => "List all users in the datastore",
                usage => "",
        },
        "listBuildUsers" => {
                func   => \&listBuildUsers,
                help   => "List all users in the interest list for a build",
                usage  => "-b <build name>",
                optstr => 'b:',
        },
        "processLog" => {
                func   => \&processLog,
                help   => "Analyze a logfile to find the failure reason",
                usage  => "-l <logfile>",
                optstr => 'l:',
        },
        "tbcleanup" => {
                func => \&tbcleanup,
                help =>
                    "Cleanup old build logs, and prune old database entries for which no package exists",
                usage => "",
        },

        # The following commands are actually handled by shell code, but we put
        # them in here (with a NULL function) to consolidate the usage handling,
        # and niceties such as command listing/completion.

        "Setup" => {
                help  => "Set up a new tinderbox",
                usage => "",
        },

        "Upgrade" => {
                help  => "Upgrade an existing tinderbox",
                usage => "",
        },

        "createJail" => {
                help  => "Create a new jail",
                usage =>
                    "-j <jailname> [-t <tag>] [-d <description>] [-C] [-H <cvsuphost>] [-m <mountsrc>] -u <updatecommand>|CVSUP|NONE [-I]",
                optstr => 'j:t:d:CH:m:u:I',
        },

        "createPortsTree" => {
                help  => "Create a new portstree",
                usage =>
                    "-p <portstreename> [-d <description>] [-C] [-H <cvsuphost>] [-m <mountsrc>] -u <updatecommand>|CVSUP|NONE [-w <cvsweburl>]",
                optstr => 'p:d:CH:m:u:w:',
        },

        "createBuild" => {
                help  => "Create a new build",
                usage =>
                    "-b <buildname> -j <jailname> -p <portstreename> [-d <description>] [-i]",
                optstr => 'b:j:p:d:',
        },

        "makeJail" => {
                help   => "Update and build an existing jail",
                usage  => "-j <jailname>",
                optstr => 'j:',
        },

        "makeBuild" => {
                help   => "Populate a build prior to tinderbuild",
                usage  => "-b <buildname>",
                optstr => 'b:',
        },

        "tinderbuild" => {
                help  => "Generate packages from an installed Build",
                usage =>
                    "-b <build name> [-init] [-cleanpackages] [-updateports] [-skipmake] [-noclean] [-noduds] [-plistcheck] [-nullfs] [-cleandistfiles] [-fetch-original] [portdir/portname [...]]",
                optstr => 'b:',
        },

);

#---------------------------------------------------------------------------
# Helper functions
#---------------------------------------------------------------------------

sub usage {
        my $cmd = shift;

        print STDERR "usage: tc ";

        if (!defined($cmd) || !defined($COMMANDS{$cmd})) {
                my $max   = 0;
                my $match = 0;
                foreach (keys %COMMANDS) {
                        if ((length $_) > $max) {
                                $max = length $_;
                        }
                }
                print STDERR "<command>\n";
                print STDERR "Where <command> is one of:\n";
                foreach my $key (sort keys %COMMANDS) {
                        if (!defined($cmd)) {
                                printf STDERR "  %-${max}s: %s\n", $key,
                                    $COMMANDS{$key}->{'help'};
                                $match++;
                        } else {
                                if ($key =~ /^$cmd/) {
                                        printf STDERR "  %-${max}s: %s\n", $key,
                                            $COMMANDS{$key}->{'help'};
                                        $match++;
                                }
                        }
                }
                if (!$match) {
                        foreach my $key (sort keys %COMMANDS) {
                                printf STDERR "  %-${max}s: %s\n", $key,
                                    $COMMANDS{$key}->{'help'};
                        }
                }
        } else {
                print STDERR "$cmd " . $COMMANDS{$cmd}->{'usage'} . "\n";
        }

        cleanup($ds, 1, undef);
}

sub failedShell {
        my $command = shift;
        usage($command);
        cleanup($ds, 1, undef);
}

#---------------------------------------------------------------------------
# Main dispatching function
#---------------------------------------------------------------------------

if (!scalar(@ARGV)) {
        usage();
}

my $ds      = new TinderboxDS();
my $opts    = {};
my $command = $ARGV[0];
shift;

if (defined($COMMANDS{$command})) {
        if ($COMMANDS{$command}->{'optstr'}) {
                getopts($COMMANDS{$command}->{'optstr'}, $opts)
                    or usage($command);
        }
        if (defined($COMMANDS{$command}->{'func'})) {
                &{$COMMANDS{$command}->{'func'}}();
        } else {
                failedShell($command);
        }
} else {
        usage($command);
}

cleanup($ds, 0, undef);

#---------------------------------------------------------------------------
# Tinderbox commands from here on
#---------------------------------------------------------------------------

sub dsversion {
        my $version = $ds->getDSVersion()
            or cleanup($ds, 1,
                      "Failed to retreive datastore version: "
                    . $ds->getError()
                    . "\n");

        print $version . "\n";
}

sub _configGetHost {
        my $hostname = shift;
        my $host;

        if ($hostname) {
                if (!$ds->isValidHost($hostname)) {
                        cleanup($ds, 1, "Unknown host, " . $hostname . "\n");
                }
                $host = $ds->getHostByName($hostname);
        } else {
                $host = undef;
        }

        return $host;
}

sub configGet {
        my $configlet = undef;
        my $host      = undef;
        my $merged    = 1;
        my $hostname;

        if (scalar(@_)) {
                $configlet = shift;
                $host      = shift;
        }

        if (!$host) {
                if ($opts->{'h'}) {
                        $host = _configGetHost($opts->{'h'});
                } elsif ($opts->{'G'}) {
                        $host = undef;
                } else {
                        $hostname = getHostname();
                        if ($ds->isValidHost($hostname)) {
                                $host = $ds->getHostByName($hostname);
                        }
                }
        }

        if ($opts->{'G'} || $opts->{'h'}) {
                $merged = undef;
        }

        my @config = $ds->getConfig($configlet, $host, $merged);

        if (@config) {
                map {
                        print $_->getOptionName() . "="
                            . $_->getOptionValue() . "\n"
                } @config;
        } elsif (defined($ds->getError())) {
                cleanup($ds, 1,
                              "Failed to get configuration: "
                            . $ds->getError()
                            . "\n");
        } else {
                cleanup($ds, 1,
                        "There is no configuration available for this Tinderbox.\n"
                );
        }
}

sub configCcache {
        my @config = ();
        my ($enabled, $logfile, $jail);
        my $host;

        if (       ($opts->{'d'} && $opts->{'e'})
                || ($opts->{'l'} && $opts->{'L'})
                || ($opts->{'j'} && $opts->{'J'}))
        {
                usage("configCcache");
        }

        $host = _configGetHost($opts->{'h'});

        if (scalar(keys %{$opts}) == 0
                || (scalar(keys %{$opts}) == 1 && ($opts->{'h'} ^ $opts->{'G'}))
            )
        {
                configGet("ccache", $host);
                cleanup($ds, 0, undef);
        }

        if ($opts->{'G'} && $host) {
                $ds->defaultConfig("ccache", $host);
                cleanup($ds, 0, undef);
        }

        $enabled = new TBConfig();
        $enabled->setOptionName("enabled");

        $logfile = new TBConfig();
        $logfile->setOptionName("logfile");

        $jail = new TBConfig();
        $jail->setOptionName("jail");

        if ($opts->{'e'}) {
                my $nolink = new TBConfig();
                $enabled->setOptionValue("1");
                $nolink->setOptionName("nolink");
                $nolink->setOptionValue("1");
                push @config, $enabled;
                push @config, $nolink;
        }

        if ($opts->{'d'}) {
                $enabled->setOptionValue("0");
                push @config, $enabled;
        }

        if ($opts->{'c'}) {
                my $cdir = new TBConfig();
                $cdir->setOptionName("dir");
                $cdir->setOptionValue($opts->{'c'});
                push @config, $cdir;
        }

        if ($opts->{'s'}) {
                my $size = new TBConfig();
                $size->setOptionName("max_size");
                $size->setOptionValue($opts->{'s'});
                push @config, $size;
        }

        if ($opts->{'j'}) {
                $jail->setOptionValue("1");
                push @config, $jail;
        }

        if ($opts->{'J'}) {
                $jail->setOptionValue("0");
                push @config, $jail;
        }

        if ($opts->{'L'}) {
                $logfile->setOptionValue(undef);
                push @config, $logfile;
        }

        if ($opts->{'l'}) {
                $logfile->setOptionValue($opts->{'l'});
                push @config, $logfile;
        }

        $ds->updateConfig("ccache", $host, @config)
            or cleanup($ds, 1,
                      "Failed to update ccache configuration: "
                    . $ds->getError()
                    . "\n");
}

sub configDistfile {
        my @config = ();
        my $cache;
        my $host;

        if ($opts->{'c'} && $opts->{'C'}) {
                usage("configDistfile");
        }

        $host = _configGetHost($opts->{'h'});

        if (scalar(keys %{$opts}) == 0
                || (scalar(keys %{$opts}) == 1 && ($opts->{'h'} ^ $opts->{'G'}))
            )
        {
                configGet("distfile", $host);
                cleanup($ds, 0, undef);
        }

        if ($opts->{'G'} && $host) {
                $ds->defaultConfig("distfile", $host);
                cleanup($ds, 0, undef);
        }

        $cache = new TBConfig();
        $cache->setOptionName("cache");

        if ($opts->{'c'}) {
                $cache->setOptionValue($opts->{'c'});
                push @config, $cache;
        }

        if ($opts->{'C'}) {
                $cache->setOptionValue(undef);
                push @config, $cache;
        }

        $ds->updateConfig("distfile", $host, @config)
            or cleanup($ds, 1,
                      "Failed to update distfile configuration: "
                    . $ds->getError()
                    . "\n");
}

sub configTinderd {
        my @config = ();
        my $sleeptime;
        my $host;

        $host = _configGetHost($opts->{'h'});

        if (scalar(keys %{$opts}) == 0
                || (scalar(keys %{$opts}) == 1 && ($opts->{'h'} ^ $opts->{'G'}))
            )
        {
                configGet("tinderd", $host);
                cleanup($ds, 0, undef);
        }

        if ($opts->{'G'} && $host) {
                $ds->defaultConfig("tinderd", $host);
                cleanup($ds, 0, undef);
        }

        $sleeptime = new TBConfig();
        $sleeptime->setOptionName("sleeptime");

        if ($opts->{'t'}) {
                $sleeptime->setOptionValue($opts->{'t'});
                push @config, $sleeptime;
        }

        $ds->updateConfig("tinderd", $host, @config)
            or cleanup($ds, 1,
                      "Failed to update tinderd configuration: "
                    . $ds->getError()
                    . "\n");
}

sub configJail {
        my @config = ();
        my $objdir;
        my $host;

        if ($opts->{'o'} && $opts->{'O'}) {
                usage("jail");
        }

        $host = _configGetHost($opts->{'h'});

        if (scalar(keys %{$opts}) == 0
                || (scalar(keys %{$opts}) == 1 && ($opts->{'h'} ^ $opts->{'G'}))
            )
        {
                configGet("jail", $host);
                cleanup($ds, 0, undef);
        }

        if ($opts->{'G'} && $host) {
                $ds->defaultConfig("jail", $host);
                cleanup($ds, 0, undef);
        }

        $objdir = new TBConfig();
        $objdir->setOptionName("objdir");

        if ($opts->{'o'}) {
                $objdir->setOptionValue($opts->{'o'});
                push @config, $objdir;
        }

        if ($opts->{'O'}) {
                $objdir->setOptionValue(undef);
                push @config, $objdir;
        }

        $ds->updateConfig("jail", $host, @config)
            or cleanup($ds, 1,
                      "Failed to update tinderd configuration: "
                    . $ds->getError()
                    . "\n");
}

sub listJails {
        my @jails = $ds->getAllJails();

        if (@jails) {
                map { print $_->getName() . "\n" } @jails;
        } elsif (defined($ds->getError())) {
                cleanup($ds, 1,
                        "Failed to list jails: " . $ds->getError() . "\n");
        } else {
                cleanup($ds, 1,
                        "There are no jails configured in the datastore.\n");
        }
}

sub listBuilds {
        my @builds = $ds->getAllBuilds();

        if (@builds) {
                map { print $_->getName() . "\n" } @builds;
        } elsif (defined($ds->getError())) {
                cleanup($ds, 1,
                        "Failed to list builds: " . $ds->getError() . "\n");
        } else {
                cleanup($ds, 1,
                        "There are no builds configured in the datastore.\n");
        }
}

sub listPortsTrees {
        my @portstrees = $ds->getAllPortsTrees();

        if (@portstrees) {
                map { print $_->getName() . "\n" } @portstrees;
        } elsif (defined($ds->getError())) {
                cleanup($ds, 1,
                        "Failed to list portstrees: " . $ds->getError() . "\n");
        } else {
                cleanup($ds, 1,
                        "There are no portstrees configured in the datastore.\n"
                );
        }
}

sub listPortFailPatterns {
        if ($opts->{'i'}) {
                my $pattern = $ds->getPortFailPatternById($opts->{'i'});

                if (!defined($pattern)) {
                        cleanup($ds, 1,
                                "Failed to find port failure pattern with the ID "
                                    . $opts->{'i'}
                                    . " in the datastore.\n");
                }

                print "ID        : " . $pattern->getId() . "\n";
                print "Reason    : " . $pattern->getReason() . "\n";
                print "Expression:\n";
                print $pattern->getExpr() . "\n";
        } else {
                my @portFailPatterns = $ds->getAllPortFailPatterns();

                if (@portFailPatterns) {
                        foreach my $pattern (@portFailPatterns) {
                                my $id     = $pattern->getId();
                                my $reason = $pattern->getReason();
                                my $expr   = $pattern->getExpr();
                                format PATTERN_TOP =
ID           Reason                 Expression
-------------------------------------------------------------------------------
.
                                format PATTERN =
@<<<<<<<<<<  @<<<<<<<<<<<<<<<<<<<   ^<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
$id          $reason                $expr
~                                   ^<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
                                    $expr
~                                   ^<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
                                    $expr
~                                   ^<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
                                    $expr
~                                   ^<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
                                    $expr
~                                   ^<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
                                    $expr
~                                   ^<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
                                    $expr
~                                   ^<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
                                    $expr
~                                   ^<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
                                    $expr
~                                   ^<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
                                    $expr
~                                   ^<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
                                    $expr
~                                   ^<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<...
                                    $expr
.
                                $~ = "PATTERN";
                                $^ = "PATTERN_TOP";
                                write;
                        }
                } elsif (defined($ds->getError())) {
                        cleanup($ds, 1,
                                      "Failed to list port failure patterns: "
                                    . $ds->getError()
                                    . "\n");
                } else {
                        cleanup(
                                $ds, 1,
                                "There are no port failure patterns configured in
the datastore.\n"
                        );
                }
        }
}

sub listPortFailReasons {
        if ($opts->{'t'}) {
                my $reason = $ds->getPortFailReasonByTag($opts->{'t'});

                if (!defined($reason)) {
                        cleanup($ds, 1,
                                "Failed to find port failure reason with tag "
                                    . $opts->{'t'}
                                    . " in the datastore.\n");
                }

                print "Tag        : " . $reason->getTag() . "\n";
                print "Type       : " . $reason->getType() . "\n";
                print "Description:\n";
                print $reason->getDescr() . "\n";
        } else {
                my @portFailReasons = $ds->getAllPortFailReasons();

                if (@portFailReasons) {
                        foreach my $reason (@portFailReasons) {
                                my $tag   = $reason->getTag();
                                my $type  = $reason->getType();
                                my $descr = $reason->getDescr();
                                next if $tag =~ /^__.+__$/;
                                format REASON_TOP =
Tag                    Type           Description
-------------------------------------------------------------------------------
.
                                format REASON =
@<<<<<<<<<<<<<<<<<<<   @<<<<<<<<<     ^<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
$tag                   $type          $descr
~                                     ^<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
                                      $descr
~                                     ^<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
                                      $descr
~                                     ^<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
                                      $descr
~                                     ^<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
                                      $descr
~                                     ^<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
                                      $descr
~                                     ^<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
                                      $descr
~                                     ^<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
                                      $descr
~                                     ^<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
                                      $descr
~                                     ^<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<...
                                      $descr

.
                                $~ = "REASON";
                                $^ = "REASON_TOP";
                                write;
                        }
                } elsif (defined($ds->getError())) {
                        cleanup($ds, 1,
                                      "Failed to list port failure reasons: "
                                    . $ds->getError()
                                    . "\n");
                } else {
                        cleanup($ds, 1,
                                "There are no port failure reasons configured in the datastore.\n"
                        );
                }
        }
}

sub addHost {
        my $hostname = getHostname();

        if ($opts->{'h'}) {
                $hostname = $opts->{'h'};
        }

        if ($ds->isValidHost($hostname)) {
                cleanup($ds, 1,
                        "A host named $hostname is already in the datastore.\n"
                );
        }

        my $host = new Host();
        $host->setName($hostname);

        my $rc = $ds->addHost($host);

        if (!$rc) {
                cleanup($ds, 1,
                              "Failed to add host $hostname to the datastore: "
                            . $ds->getError()
                            . ".\n");
        }
}

sub addBuild {
        if (!$opts->{'b'} || !$opts->{'j'} || !$opts->{'p'}) {
                usage("addBuild");
        }

        my $name      = $opts->{'b'};
        my $jail      = $opts->{'j'};
        my $portstree = $opts->{'p'};

        if ($ds->isValidBuild($name)) {
                cleanup($ds, 1,
                        "A build named $name is already in the datastore.\n");
        }

        if (!$ds->isValidJail($jail)) {
                cleanup($ds, 1, "No such jail, \"$jail\", in the datastore.\n");
        }

        if (!$ds->isValidPortsTree($portstree)) {
                cleanup($ds, 1,
                        "No such portstree, \"$portstree\", in the datastore.\n"
                );
        }

        my $jCls = $ds->getJailByName($jail);
        my $pCls = $ds->getPortsTreeByName($portstree);

        my $build = new Build();
        $build->setName($name);
        $build->setJailId($jCls->getId());
        $build->setPortsTreeId($pCls->getId());
        $build->setDescription($opts->{'d'}) if ($opts->{'d'});

        my $rc = $ds->addBuild($build);

        if (!$rc) {
                cleanup($ds, 1,
                              "Failed to add build $name to the datastore: "
                            . $ds->getError()
                            . ".\n");
        }
}

sub addJail {
        if (!$opts->{'j'} || !$opts->{'t'}) {
                usage("addJail");
        }

        my $name = $opts->{'j'};
        my $tag  = $opts->{'t'};

        if ($ds->isValidJail($name)) {
                cleanup($ds, 1,
                        "A jail named $name is already in the datastore.\n");
        }

        if ($name !~ /^\d/) {
                cleanup($ds, 1,
                        "The first character in a jail name must be a FreeBSD major version number.\n"
                );
        }

        my $update_cmd = "CVSUP";
        if ($opts->{'u'}) {
                $update_cmd = $opts->{'u'};
        }

        my $jail = new Jail();

        $jail->setName($name);
        $jail->setTag($tag);
        $jail->setUpdateCmd($update_cmd);
        $jail->setDescription($opts->{'d'}) if ($opts->{'d'});
        $jail->setSrcMount($opts->{'m'})    if ($opts->{'m'});

        my $rc = $ds->addJail($jail);

        if (!$rc) {
                cleanup($ds, 1,
                              "Failed to add jail $name to the datastore: "
                            . $ds->getError()
                            . ".\n");
        }
}

sub addPortsTree {
        if (!$opts->{'p'}) {
                usage("addPortsTree");
        }

        my $name = $opts->{'p'};

        if ($ds->isValidPortsTree($name)) {
                cleanup($ds, 1,
                        "A portstree named $name is already in the datastore.\n"
                );
        }

        my $update_cmd = "CVSUP";
        if ($opts->{'u'}) {
                $update_cmd = $opts->{'u'};
        }

        my $portstree = new PortsTree();

        $portstree->setName($name);
        $portstree->setUpdateCmd($update_cmd);
        $portstree->setDescription($opts->{'d'}) if ($opts->{'d'});
        $portstree->setPortsMount($opts->{'m'})  if ($opts->{'m'});
        $portstree->setCVSwebURL($opts->{'w'})   if ($opts->{'w'});
        $portstree->setLastBuilt($ds->getTime());

        my $rc = $ds->addPortsTree($portstree);

        if (!$rc) {
                cleanup($ds, 1,
                              "Failed to add portstree $name to the datastore: "
                            . $ds->getError()
                            . ".\n");
        }
}

sub addPort {
        my %requestMountArgs;

        if (       (!$opts->{'b'} && !$opts->{'a'})
                || ($opts->{'b'} && $opts->{'a'})
                || !$opts->{'d'})
        {
                usage("addPort");
        }

        my $buildname = $opts->{'b'};
        if ($buildname && !$ds->isValidBuild($buildname)) {
                cleanup($ds, 1, "Unknown build, $buildname\n");
        }

        my @builds = ();
        if ($opts->{'a'}) {
                @builds = $ds->getAllBuilds();
        } else {
                push @builds, $ds->getBuildByName($buildname);
        }

        foreach my $build (@builds) {
                my $jail      = $ds->getJailById($build->getJailId());
                my $portstree = $ds->getPortsTreeById($build->getPortsTreeId());
                my $tag       = $jail->getTag();
                my $bname     = $build->getName();
                my $jname     = $jail->getName();
                my $ptname    = $portstree->getName();

                $requestMountArgs{'quiet'}     = 1;
                $requestMountArgs{'build'}     = $bname;
                $requestMountArgs{'jail'}      = $jname;
                $requestMountArgs{'portstree'} = $ptname;

                $requestMountArgs{'destination'} = "portstree";
                requestMount($pb, %requestMountArgs);

                $requestMountArgs{'destination'} = "jail";
                requestMount($pb, %requestMountArgs);

                buildenv($pb, $bname, $jname, $ptname);
                $ENV{'LOCALBASE'}  = "/nonexistentlocal";
                $ENV{'X11BASE'}    = "/nonexistentx";
                $ENV{'PKG_DBDIR'}  = "/nonexistentdb";
                $ENV{'PORT_DBDIR'} = "/nonexistentportdb";
                $ENV{'LINUXBASE'}  = "/nonexistentlinux";

                my $makecache =
                    new MakeCache($ENV{'PORTSDIR'}, $ENV{'PKGSUFFIX'});

                if ($opts->{'r'}) {
                        my @deps = ($opts->{'d'});
                        my %seen = ();
                        while (my $port = shift @deps) {
                                if (!$seen{$port}) {
                                        addPorts(
                                                $port,      $build,
                                                $makecache, \@deps
                                        );
                                        $seen{$port} = 1;
                                }
                        }
                } else {
                        addPorts($opts->{'d'}, $build, $makecache, undef);
                }
        }
}

sub addBuildPortsQueueEntry {
        my $admin;
        my $user_id;

        if (!$opts->{'b'} || !$opts->{'d'}) {
                usage("addBuildPortsQueueEntry");
        }

        my $priority = $opts->{'p'} ? $opts->{'p'} : 10;

        my $hostname = getHostname();
        if ($opts->{'h'}) {
                $hostname = $opts->{'h'};
        }

        if (!$ds->isValidHost($hostname)) {
                cleanup($ds, 1, "Unknown host, " . $hostname . "\n");
        }

        if (!$ds->isValidBuild($opts->{'b'})) {
                cleanup($ds, 1, "Unknown build, " . $opts->{'b'} . "\n");
        }

        my $build = $ds->getBuildByName($opts->{'b'});
        my $host  = $ds->getHostByName($hostname);

        if ($admin = $ds->getWwwAdmin()) {
                $user_id = $admin->getId();
        } else {
                $user_id = 0;
        }

        $ds->addBuildPortsQueueEntry($build, $opts->{'d'}, $host, $priority,
                $user_id);
}

sub addPortFailPattern {
        my $parent;
        my $pattern;

        if (!$opts->{'e'} || !$opts->{'r'} || !$opts->{'i'}) {
                usage("addPortFailPattern");
        }

        $parent = $opts->{'p'} ? $opts->{'p'} : 0;

        if ($opts->{'i'} % 100 == 0) {
                cleanup($ds, 1,
                        "IDs that are evenly divisible by 100 are reserved for system patterns.\n"
                );
        }

        if ($opts->{'i'} > 2147483647 || $opts->{'i'} < 0) {
                cleanup($ds, 1,
                        "IDs must be greater than 0, and less than 2147483647.\n"
                );
        }

        if ($ds->isValidPortFailPattern($opts->{'i'})) {
                cleanup($ds, 1,
                              "A pattern with the ID "
                            . $opts->{'i'}
                            . " already exists in the datastore.\n");
        }

        if (!$ds->isValidPortFailPattern($parent)) {
                cleanup($ds, 1, "No such parent pattern ID, $parent.\n");
        }

        if (!$ds->isValidPortFailReason($opts->{'r'})) {
                cleanup($ds, 1, "No such reason tag, " . $opts->{'r'} . ".\n");
        }

        if (!eval { 'tinderbox' =~ /$opts->{'e'}/, 1 }) {
                cleanup($ds, 1,
                        "Bad regular expression, '" . $opts->{'e'} . "': $@\n");
        }

        $pattern = new PortFailPattern();
        $pattern->setId($opts->{'i'});
        $pattern->setReason($opts->{'r'});
        $pattern->setParent($parent);
        $pattern->setExpr($opts->{'e'});

        my $rc = $ds->addPortFailPattern($pattern);

        if (!$rc) {
                cleanup($ds, 1,
                              "Failed to add pattern "
                            . $opts->{'i'}
                            . " to the datastore: "
                            . $ds->getError()
                            . ".\n");
        }
}

sub addPortFailReason {
        my $descr;
        my $type;
        my $reason;

        if (!$opts->{'t'}) {
                usage("addPortFailReason");
        }

        $descr = $opts->{'d'} ? $opts->{'d'} : "";
        $type  = $opts->{'y'} ? $opts->{'y'} : "COMMON";

        if ($ds->isValidPortFailReason($opts->{'t'})) {
                cleanup($ds, 1,
                              "There is already a reason with tag, "
                            . $opts->{'t'}
                            . " in the datastore.\n");
        }

        $reason = new PortFailReason();
        $reason->setTag($opts->{'t'});
        $reason->setDescr($descr);
        $reason->setType($type);

        my $rc = $ds->addPortFailReason($reason);

        if (!$rc) {
                cleanup($ds, 1,
                              "Failed to add reason "
                            . $opts->{'t'}
                            . " to the datastore: "
                            . $ds->getError()
                            . ".\n");
        }
}

sub listBuildPortsQueue {
        my $raw;
        my $status   = $opts->{'s'};
        my $hostname = getHostname();

        if ($opts->{'h'}) {
                $hostname = $opts->{'h'}
        }

        if ($opts->{'r'}) {
                $raw = 1
        }

        if (!$ds->isValidHost($hostname)) {
                cleanup($ds, 1, "Unknown host, " . $hostname . "\n");
        }

        my $host = $ds->getHostByName($hostname);

        my @buildportsqueue = $ds->getBuildPortsQueueByHost($host, $status);

        if (@buildportsqueue) {
                if ($raw ne 1) {
                        print
                            "+=====+===========================+=====================================+=====+\n";
                        print
                            "|  Id | Build Name                | Port Directory                      | Pri |\n";
                        print
                            "+=====+===========================+=====================================+=====+\n";
                }
                foreach my $buildport (@buildportsqueue) {
                        if ($buildport) {
                                my $build =
                                    $ds->getBuildById($buildport->getBuildId());
                                if ($raw eq 1) {
                                        print $buildport->getId() . ":"
                                            . $buildport->getUserId() . ":"
                                            . $build->getName() . ":"
                                            . $buildport->getPortDirectory()
                                            . ":"
                                            . $buildport->getEmailOnCompletion()
                                            . "\n";
                                } else {
                                        printf(
                                                "| %3d | %-25s | %-35s | %3d |\n",
                                                $buildport->getId(),
                                                $build->getName(),
                                                $buildport->getPortDirectory(),
                                                $buildport->getPriority()
                                        );
                                        print
                                            "+-----+---------------------------+-------------------------------------+-----+\n";
                                }
                        }
                }
        } elsif (defined($ds->getError())) {
                cleanup($ds, 1,
                              "Failed to list BuildPortsQueue: "
                            . $ds->getError()
                            . "\n");
        } else {
                cleanup($ds, 1,
                        "There is no BuildPortsQueue configured in the datastore.\n"
                );
        }
}

sub getJailForBuild {
        if (!$opts->{'b'}) {
                usage("getJailForBuild");
        }

        if (!$ds->isValidBuild($opts->{'b'})) {
                cleanup($ds, 1, "Unknown build, " . $opts->{'b'} . "\n");
        }

        my $build = $ds->getBuildByName($opts->{'b'});
        my $jail  = $ds->getJailById($build->getJailId());

        print $jail->getName() . "\n";
}

sub getPortsTreeForBuild {
        if (!$opts->{'b'}) {
                usage("getPortsTreeForBuild");
        }

        if (!$ds->isValidBuild($opts->{'b'})) {
                cleanup($ds, 1, "Unknown build, " . $opts->{'b'} . "\n");
        }

        my $build     = $ds->getBuildByName($opts->{'b'});
        my $portstree = $ds->getPortsTreeById($build->getPortsTreeId());

        print $portstree->getName() . "\n";
}

sub getTagForJail {
        if (!$opts->{'j'}) {
                usage("getTagForJail");
        }

        if (!$ds->isValidJail($opts->{'j'})) {
                cleanup($ds, 1, "Unknown jail, " . $opts->{'j'} . "\n");
        }

        my $jail = $ds->getJailByName($opts->{'j'});

        print $jail->getTag() . "\n";
}

sub getSrcUpdateCmd {
        if (!$opts->{'j'}) {
                usage("getSrcUpdateCmd");
        }

        my $jail_name = $opts->{'j'};

        if (!$ds->isValidJail($jail_name)) {
                cleanup($ds, 1, "Unknown jail, $jail_name\n");
        }

        my $jail = $ds->getJailByName($jail_name);

        my $update_cmd = $jail->getUpdateCmd();

        if ($update_cmd eq "CVSUP") {
                $update_cmd =
                    "/usr/local/bin/cvsup -g $pb/jails/$jail_name/src-supfile";
        } elsif ($update_cmd eq "NONE") {
                $update_cmd = "";
        } else {
                $update_cmd = "$pb/scripts/$update_cmd $jail_name";
        }

        print $update_cmd . "\n";
}

sub getSrcMount {
        if (!$opts->{'j'}) {
                usage("getSrcMount");
        }

        my $jail_name = $opts->{'j'};

        if (!$ds->isValidJail($jail_name)) {
                cleanup($ds, 1, "Unknown jail, $jail_name\n");
        }

        my $jail = $ds->getJailByName($jail_name);

        my $mount_src = $jail->getSrcMount();

        print $mount_src . "\n";
}

sub getPortsMount {
        if (!$opts->{'p'}) {
                usage("getPortsMount");
        }

        my $portstree_name = $opts->{'p'};

        if (!$ds->isValidPortsTree($portstree_name)) {
                cleanup($ds, 1, "Unknown portstree, $portstree_name\n");
        }

        my $portstree = $ds->getPortsTreeByName($portstree_name);

        my $mount_src = $portstree->getPortsMount();

        print $mount_src . "\n";
}

sub setSrcMount {
        if (!$opts->{'j'} || !$opts->{'m'}) {
                usage("setSrcMount");
        }

        my $jail_name = $opts->{'j'};

        if (!$ds->isValidJail($jail_name)) {
                cleanup($ds, 1, "Unknown jail, $jail_name\n");
        }

        my $jail = $ds->getJailByName($jail_name);

        $jail->setSrcMount($opts->{'m'});

        my $rc = $ds->updateJail($jail);

        if (!$rc) {
                cleanup($ds, 1,
                              "Failed to set the SrcMount for jail "
                            . $jail->getName() . ": "
                            . $ds->getError()
                            . "\n");
        }
}

sub setPortsMount {
        if (!$opts->{'p'} || !$opts->{'m'}) {
                usage("setPortsMount");
        }

        my $portstree_name = $opts->{'p'};

        if (!$ds->isValidPortsTree($portstree_name)) {
                cleanup($ds, 1, "Unknown portstree, $portstree_name\n");
        }

        my $portstree = $ds->getPortsTreeByName($portstree_name);

        $portstree->setPortsMount($opts->{'m'});

        my $rc = $ds->updatePortsTree($portstree);

        if (!$rc) {
                cleanup($ds, 1,
                              "Failed to set the PortsMount for portstree "
                            . $portstree->getName() . ": "
                            . $ds->getError()
                            . "\n");
        }
}

sub getPortsUpdateCmd {
        if (!$opts->{'p'}) {
                usage("getPortsUpdateCmd");
        }

        my $portstree_name = $opts->{'p'};

        if (!$ds->isValidPortsTree($portstree_name)) {
                cleanup($ds, 1, "Unknown portstree, $portstree_name\n");
        }

        my $portstree = $ds->getPortsTreeByName($portstree_name);

        my $update_cmd = $portstree->getUpdateCmd();

        if ($update_cmd eq "CVSUP") {
                $update_cmd =
                    "/usr/local/bin/cvsup -g $pb/portstrees/$portstree_name/ports-supfile";
        } elsif ($update_cmd eq "NONE") {
                $update_cmd = "";
        } else {
                $update_cmd = "$pb/scripts/$update_cmd $portstree_name";
        }

        print $update_cmd . "\n";
}

sub reorgBuildPortsQueue {

        my $hostname = getHostname();

        if ($opts->{'h'}) {
                $hostname = $opts->{'h'};
        }

        if (!$ds->isValidHost($hostname)) {
                cleanup($ds, 1, "Unknown host, " . $hostname . "\n");
        }

        my $host = $ds->getHostByName($hostname);

        my $rc = $ds->reorgBuildPortsQueue($host);

        if (!$rc) {
                cleanup($ds, 1,
                              "Failed to reorganize BuildPortsQueue for host "
                            . $host->getName() . ": "
                            . $ds->getError()
                            . "\n");
        }
}

sub updateBuildPortsQueueEntryStatus {

        if (!$opts->{'i'} || !$opts->{'s'}) {
                usage("updateBuildPortsQueueEntryStatus");
        }

        if (!$ds->isValidBuildPortsQueueId($opts->{'i'})) {
                cleanup($ds, 1,
                              "Unknown Build Ports Queue Entry, "
                            . $opts->{'i'}
                            . "\n");
        }

        my $rc =
            $ds->updateBuildPortsQueueEntryStatus($opts->{'i'}, $opts->{'s'});

        if (!$rc) {
                cleanup($ds, 1,
                              "Failed to update BuildPortsQueueEntryStatus "
                            . $opts->{'i'} . ": "
                            . $ds->getError()
                            . "\n");
        }
}

sub rmBuildPortsQueue {

        my $hostname = getHostname();

        if ($opts->{'h'}) {
                $hostname = $opts->{'h'};
        }
        if (!$ds->isValidHost($hostname)) {
                cleanup($ds, 1, "Unknown host, " . $hostname . "\n");
        }

        my $host = $ds->getHostByName($hostname);

        my $rc = $ds->removeBuildPortsQueue($host);

        if (!$rc) {
                cleanup($ds, 1,
                              "Failed to remove BuildPortsQueue for host "
                            . $host->getName() . ": "
                            . $ds->getError()
                            . "\n");
        }
}

sub rmBuildPortsQueueEntry {
        my $buildportsqueue;

        if (!$opts->{'i'} && (!$opts->{'b'} || !$opts->{'d'})) {
                usage("rmBuildPortsQueueEntry");
        }

        if ($opts->{'i'}) {
                if (!$ds->isValidBuildPortsQueueId($opts->{'i'})) {
                        cleanup($ds, 1,
                                      "Unknown BuildPortsQueueId "
                                    . $opts->{'i'}
                                    . "\n");
                }

                $buildportsqueue = $ds->getBuildPortsQueueById($opts->{'i'});
        } else {
                my $hostname = getHostname();

                if ($opts->{'h'}) {
                        $hostname = $opts->{'h'};
                }
                if (!$ds->isValidHost($hostname)) {
                        cleanup($ds, 1, "Unknown host, " . $hostname . "\n");
                }

                if (!$ds->isValidBuild($opts->{'b'})) {
                        cleanup($ds, 1,
                                "Unknown build, " . $opts->{'b'} . "\n");
                }

                my $build = $ds->getBuildByName($opts->{'b'});
                my $host  = $ds->getHostByName($hostname);
                $buildportsqueue =
                    $ds->getBuildPortsQueueByKeys($build, $opts->{'d'}, $host);
                if (!$buildportsqueue) {
                        cleanup($ds, 1,
                                      "Unknown BuildPortsQueueEntry "
                                    . $opts->{'d'} . " "
                                    . $opts->{'b'} . " "
                                    . $hostname
                                    . "\n");
                }
        }

        my $rc = $ds->removeBuildPortsQueueEntry($buildportsqueue);

        if (!$rc) {
                cleanup($ds, 1,
                              "Failed to remove BuildPortsQueue Entry "
                            . $buildportsqueue->getId() . ": "
                            . $ds->getError()
                            . "\n");
        }
}

sub rmHost {
        my $hostname = getHostname();

        if ($opts->{'h'}) {
                $hostname = $opts->{'h'};
        }

        if (!$ds->isValidHost($hostname)) {
                cleanup($ds, 1, "Not a valid host: $hostname\n");
        }

        my $host = $ds->getHostByName($hostname);
        my $rc   = $ds->removeHost($host);

        if (!$rc) {
                cleanup($ds, 1,
                        "Failed to remove host $hostname from the datastore: "
                            . $ds->getError()
                            . ".\n");
        }
}

sub rmPort {
        if (!$opts->{'d'}) {
                usage("rmPort");
        }

        if ($opts->{'b'}) {
                if (!$ds->isValidBuild($opts->{'b'})) {
                        cleanup($ds, 1,
                                "Unknown build, " . $opts->{'b'} . "\n");
                }
        }

        my $port = $ds->getPortByDirectory($opts->{'d'});

        if (!defined($port)) {
                cleanup($ds, 1, "Unknown port, " . $opts->{'d'} . "\n");
        }

        unless ($opts->{'f'}) {
                if ($opts->{'b'}) {
                        print "Really remove port "
                            . $opts->{'d'}
                            . " for build "
                            . $opts->{'b'} . "? ";
                } else {
                        print "Really remove port " . $opts->{'d'} . "? ";
                }
                my $response = <STDIN>;
                print "\n";
                cleanup($ds, 0, undef) unless ($response =~ /^y/i);
        }

        my @builds = ();
        my $rc;
        if ($opts->{'c'} && !$opts->{'b'}) {
                @builds = $ds->getAllBuilds();
        } elsif ($opts->{'c'} && $opts->{'b'}) {
                push @builds, $ds->getBuildByName($opts->{'b'});
        }
        foreach my $build (@builds) {
                if (my $version = $ds->getPortLastBuiltVersion($port, $build)) {
                        my $jail   = $ds->getJailById($build->getJailId());
                        my $sufx   = $ds->getPackageSuffix($jail);
                        my $pkgdir = join("/", $pb, 'jails', $build->getName());
                        my $logpath =
                            join("/", $pb, 'logs', $build->getName(), $version);
                        my $errpath = join("/",
                                $pb, 'errors', $build->getName(), $version);
                        if (-d $pkgdir) {
                                print
                                    "Removing all packages matching ${version}${sufx} starting from $pkgdir.\n";
                                system(
                                        "/usr/bin/find -H $pkgdir -name ${version}${sufx} -delete"
                                );
                        }
                        if (-f $logpath . ".log") {
                                print "Removing ${logpath}.log.\n";
                                unlink($logpath . ".log");
                        }
                        if (-f $errpath . ".log") {
                                print "Removing ${errpath}.log.\n";
                                unlink($errpath . ".log");
                        }
                }
        }

        if ($opts->{'b'}) {
                $rc =
                    $ds->removePortForBuild($port,
                        $ds->getBuildByName($opts->{'b'}));
        } else {
                $rc = $ds->removePort($port);
        }

        if (!$rc) {
                cleanup($ds, 1,
                        "Failed to remove port: " . $ds->getError() . "\n");
        }
}

sub rmBuild {
        if (!$opts->{'b'}) {
                usage("rmBuild");
        }

        if (!$ds->isValidBuild($opts->{'b'})) {
                cleanup($ds, 1, "Unknown build " . $opts->{'b'} . "\n");
        }

        unless ($opts->{'f'}) {
                print "Really remove build " . $opts->{'b'} . "? ";
                my $response = <STDIN>;
                cleanup($ds, 0, undef) unless ($response =~ /^y/i);
        }

        my $rc = $ds->removeBuild($ds->getBuildByName($opts->{'b'}));

        if (!$rc) {
                cleanup($ds, 1,
                              "Failed to remove build "
                            . $opts->{'b'} . ": "
                            . $ds->getError()
                            . "\n");
        }
}

sub rmJail {
        if (!$opts->{'j'}) {
                usage("rmJail");
        }

        if (!$ds->isValidJail($opts->{'j'})) {
                cleanup($ds, 1, "Unknown jail " . $opts->{'j'} . "\n");
        }

        my $jail   = $ds->getJailByName($opts->{'j'});
        my @builds = $ds->findBuildsForJail($jail);

        unless ($opts->{'f'}) {
                if (@builds) {
                        print
                            "Removing this jail will also remove the following builds:\n";
                        foreach my $build (@builds) {
                                print "\t" . $build->getName() . "\n";
                        }
                }
                print "Really remove jail " . $opts->{'j'} . "? ";
                my $response = <STDIN>;
                cleanup($ds, 0, undef) unless ($response =~ /^y/i);
        }

        my $rc;
        foreach my $build (@builds) {
                $rc = $ds->removeBuild($build);
                if (!$rc) {
                        cleanup($ds, 1,
                                      "Failed to remove build "
                                    . $build->getName()
                                    . " as part of removing jail "
                                    . $opts->{'j'} . ": "
                                    . $ds->getError()
                                    . "\n");
                }
        }

        $rc = $ds->removeJail($jail);

        if (!$rc) {
                cleanup($ds, 1,
                              "Failed to remove jail "
                            . $opts->{'j'} . ": "
                            . $ds->getError()
                            . "\n");
        }
}

sub rmPortsTree {
        if (!$opts->{'p'}) {
                usage("rmPortsTree");
        }

        if (!$ds->isValidPortsTree($opts->{'p'})) {
                cleanup($ds, 1, "Unknown portstree " . $opts->{'p'} . "\n");
        }

        my $portstree = $ds->getPortsTreeByName($opts->{'p'});
        my @builds    = $ds->findBuildsForPortsTree($portstree);

        unless ($opts->{'f'}) {
                if (@builds) {
                        print
                            "Removing this portstree will also remove the following builds:\n";
                        foreach my $build (@builds) {
                                print "\t" . $build->getName() . "\n";
                        }
                }
                print "Really remove portstree " . $opts->{'p'} . "? ";
                my $response = <STDIN>;
                cleanup($ds, 0, undef) unless ($response =~ /^y/i);
        }

        my $rc;
        foreach my $build (@builds) {
                $rc = $ds->removeBuild($build);
                if (!$rc) {
                        cleanup($ds, 1,
                                      "Failed to remove build "
                                    . $build->getName()
                                    . " as part of removing portstree "
                                    . $opts->{'p'} . ": "
                                    . $ds->getError()
                                    . "\n");
                }
        }

        $rc = $ds->removePortsTree($portstree);

        if (!$rc) {
                cleanup($ds, 1,
                              "Failed to remove portstree "
                            . $opts->{'p'} . ": "
                            . $ds->getError()
                            . "\n");
        }
}

sub rmUser {
        if (!$opts->{'u'}) {
                usage("rmUser");
        }

        if ($opts->{'b'}) {
                if (!$ds->isValidBuild($opts->{'b'})) {
                        cleanup($ds, 1,
                                "Unknown build, " . $opts->{'b'} . "\n");
                }
        }

        my $user = $ds->getUserByName($opts->{'u'});

        if (!defined($user)) {
                cleanup($ds, 1, "Unknown user, " . $opts->{'u'} . "\n");
        }

        unless ($opts->{'f'}) {
                if ($opts->{'b'}) {
                        print "Really remove user "
                            . $opts->{'u'}
                            . " for build "
                            . $opts->{'b'} . "? ";
                } else {
                        print "Really remove user " . $opts->{'u'} . "? ";
                }
                my $response = <STDIN>;
                print "\n";
                cleanup($ds, 0, undef) unless ($response =~ /^y/i);
        }

        my $rc;
        if ($opts->{'b'}) {
                $rc =
                    $ds->removeUserForBuild($user,
                        $ds->getBuildByName($opts->{'b'}));
        } else {
                $rc = $ds->removeUser($user);
        }

        if (!$rc) {
                cleanup($ds, 1,
                        "Failed to remove user: " . $ds->getError() . "\n");
        }
}

sub rmPortFailPattern {
        my $pattern;

        if (!$opts->{'i'}) {
                usage("rmPortFailPattern");
        }

        $pattern = $ds->getPortFailPatternById($opts->{'i'});

        if (!defined($pattern)) {
                cleanup($ds, 1,
                              "Unknown port failure pattern ID, "
                            . $opts->{'i'}
                            . ".\n");
        }

        if ($opts->{'i'} % 100 == 0) {
                cleanup($ds, 1,
                              "Cannot remove system defined pattern "
                            . $opts->{'i'}
                            . ".\n");
        }

        unless ($opts->{'f'}) {
                print "Really remove port failure pattern "
                    . $opts->{'i'} . "? ";
                my $response = <STDIN>;
                print "\n";
                cleanup($ds, 0, undef) unless ($response =~ /^y/i);
        }

        my $rc = $ds->removePortFailPattern($pattern);

        if (!$rc) {
                cleanup($ds, 1,
                              "Failed to remove port failure pattern: "
                            . $ds->getError()
                            . "\n");
        }
}

sub rmPortFailReason {
        my $reason;
        my @patterns;

        if (!$opts->{'t'}) {
                usage("rmPortFailReason");
        }

        $reason = $ds->getPortFailReasonByTag($opts->{'t'});

        if (!defined($reason)) {
                cleanup($ds, 1,
                              "Unknown port failure reason tag, "
                            . $opts->{'t'}
                            . ".\n");
        }

        @patterns = $ds->findPortFailPatternsWithReason($reason);

        unless ($opts->{'f'}) {
                if (@patterns) {
                        print
                            "Removing this port failure reason will also remove the following port failure patterns:\n";
                        foreach my $pattern (@patterns) {
                                print "\t" . $pattern->getId() . "\n";
                        }
                }
                print "Really remove port failure reason "
                    . $opts->{'t'} . "? ";
                my $response = <STDIN>;
                cleanup($ds, 0, undef) unless ($response =~ /^y/i);
        }

        my $rc;
        foreach my $pattern (@patterns) {
                $rc = $ds->removePortFailPattern($pattern);
                if (!$rc) {
                        cleanup($ds, 1,
                                      "Failed to remove port failure pattern "
                                    . $pattern->getId()
                                    . " as part of removing port failure reason "
                                    . $opts->{'t'} . ": "
                                    . $ds->getError()
                                    . "\n");
                }
        }

        $rc = $ds->removePortFailReason($reason);

        if (!$rc) {
                cleanup($ds, 1,
                              "Failed to remove port failure reason . "
                            . $opts->{'t'} . ": "
                            . $ds->getError()
                            . "\n");
        }
}

sub updatePortsTree {
        if (!$opts->{'p'}) {
                usage("updatePortsTree");
        }

        my $name = $opts->{'p'};

        if (!$ds->isValidPortsTree($name)) {
                cleanup($ds, 1, "Unknown portstree $name\n");
        }

        my $portstree  = $ds->getPortsTreeByName($name);
        my $update_cmd = $portstree->getUpdateCmd();

        $portstree->setLastBuilt($opts->{'l'});

        if ($update_cmd eq "CVSUP") {
                if (!-x "/usr/local/bin/cvsup") {
                        cleanup($ds, 1,
                                "Failed to find executable cvsup in /usr/local/bin.\n"
                        );
                }
                $update_cmd =
                    "/usr/local/bin/cvsup -g $pb/portstrees/$name/ports-supfile";
        } elsif ($update_cmd eq "NONE") {
                $update_cmd = "";
        } else {
                $update_cmd .= " $name";
        }

        my $rc = 0;    # Allow null update commands to succeed.
        if ($update_cmd) {
                $rc = system($update_cmd);
        }

        if (!$rc) {

                # The command completed successfully, so update the
                # Last_Built time.
                $ds->updatePortsTreeLastBuilt($portstree)
                    or cleanup($ds, 1,
                        "Failed to update last built value in the datastore: "
                            . $ds->getError()
                            . "\n");
        } else {
                cleanup($ds, 1,
                        "Failed to update the portstree.  See output above.\n");
        }
}

sub updateBuildPortsQueueEntryCompletionDate {
        if (!$opts->{'i'}) {
                usage("updateBuildPortsQueueEntryCompletionDate");
        }

        if (!$ds->isValidBuildPortsQueueId($opts->{'i'})) {
                cleanup($ds, 1,
                        "Unknown BuildPortsQueueEntry, " . $opts->{'i'} . "\n");
        }

        my $buildportsqueue = $ds->getBuildPortsQueueById($opts->{'i'});

        $buildportsqueue->setCompletionDate($opts->{'l'});

        $ds->updateBuildPortsQueueEntryCompletionDate($buildportsqueue)
            or cleanup(
                $ds,
                1,
                "Failed to update completion time value in the datastore: "
                    . $ds->getError() . "\n"
            );
}

sub updateJailLastBuilt {
        if (!$opts->{'j'}) {
                usage("updateJailLastBuilt");
        }

        if (!$ds->isValidJail($opts->{'j'})) {
                cleanup($ds, 1, "Unknown jail, " . $opts->{'j'} . "\n");
        }

        my $jail = $ds->getJailByName($opts->{'j'});

        $jail->setLastBuilt($opts->{'l'});

        $ds->updateJailLastBuilt($jail)
            or cleanup($ds, 1,
                      "Failed to update last built value in the datastore: "
                    . $ds->getError()
                    . "\n");
}

sub updatePortLastBuilt {
        if (!$opts->{'d'} || !$opts->{'b'}) {
                usage("updatePortLastBuilt");
        }

        my $port = $ds->getPortByDirectory($opts->{'d'});
        if (!defined($port)) {
                cleanup($ds, 1,
                              "Port, "
                            . $opts->{'d'}
                            . " is not in the datastore.\n");
        }

        if (!$ds->isValidBuild($opts->{'b'})) {
                cleanup($ds, 1, "Unknown build, " . $opts->{'b'} . "\n");
        }

        my $build = $ds->getBuildByName($opts->{'b'});

        if (!$ds->isPortForBuild($port, $build)) {
                cleanup($ds, 1,
                              "Port, "
                            . $opts->{'d'}
                            . " is not a valid port for build, "
                            . $opts->{'b'}
                            . "\n");
        }

        $ds->updatePortLastBuilt($port, $build, $opts->{'l'})
            or cleanup($ds, 1,
                      "Failed to update last built value in the datastore: "
                    . $ds->getError()
                    . "\n");
}

sub updatePortLastSuccessfulBuilt {
        if (!$opts->{'d'} || !$opts->{'b'}) {
                usage("updatePortLastSuccessfulBuilt");
        }

        my $port = $ds->getPortByDirectory($opts->{'d'});
        if (!defined($port)) {
                cleanup($ds, 1,
                              "Port, "
                            . $opts->{'d'}
                            . " is not in the datastore.\n");
        }

        if (!$ds->isValidBuild($opts->{'b'})) {
                cleanup($ds, 1, "Unknown build, " . $opts->{'b'} . "\n");
        }

        my $build = $ds->getBuildByName($opts->{'b'});

        if (!$ds->isPortForBuild($port, $build)) {
                cleanup($ds, 1,
                              "Port, "
                            . $opts->{'d'}
                            . " is not a valid port for build, "
                            . $opts->{'b'}
                            . "\n");
        }

        $ds->updatePortLastSuccessfulBuilt($port, $build, $opts->{'l'})
            or cleanup(
                $ds,
                1,
                "Failed to update last successful built value in the datastore: "
                    . $ds->getError() . "\n"
            );
}

sub updatePortLastStatus {
        if (!$opts->{'d'} || !$opts->{'b'} || !$opts->{'s'}) {
                usage("updatePortLastStatus");
        }

        my $port = $ds->getPortByDirectory($opts->{'d'});
        if (!defined($port)) {
                cleanup($ds, 1,
                              "Port, "
                            . $opts->{'d'}
                            . " is not in the datastore.\n");
        }

        if (!$ds->isValidBuild($opts->{'b'})) {
                cleanup($ds, 1, "Unknown build, " . $opts->{'b'} . "\n");
        }

        my $build = $ds->getBuildByName($opts->{'b'});

        if (!$ds->isPortForBuild($port, $build)) {
                cleanup($ds, 1,
                              "Port, "
                            . $opts->{'d'}
                            . " is not a valid port for build, "
                            . $opts->{'b'}
                            . "\n");
        }

        $ds->updatePortLastStatus($port, $build, $opts->{'s'})
            or cleanup(
                $ds,
                1,
                "Failed to update last status value in the datastore: "
                    . $ds->getError() . "\n"
            );
}

sub updatePortLastBuiltVersion {
        if (!$opts->{'d'} || !$opts->{'b'} || !$opts->{'v'}) {
                usage("updatePortLastBuiltVersion");
        }

        my $port = $ds->getPortByDirectory($opts->{'d'});
        if (!defined($port)) {
                cleanup($ds, 1,
                              "Port, "
                            . $opts->{'d'}
                            . " is not in the datastore.\n");
        }

        if (!$ds->isValidBuild($opts->{'b'})) {
                cleanup($ds, 1, "Unknown build, " . $opts->{'b'} . "\n");
        }

        my $build = $ds->getBuildByName($opts->{'b'});

        if (!$ds->isPortForBuild($port, $build)) {
                cleanup($ds, 1,
                              "Port, "
                            . $opts->{'d'}
                            . " is not a valid port for build, "
                            . $opts->{'b'}
                            . "\n");
        }

        $ds->updatePortLastBuiltVersion($port, $build, $opts->{'v'})
            or cleanup(
                $ds,
                1,
                "Failed to update last built version value in the datastore: "
                    . $ds->getError() . "\n"
            );
}

sub updateBuildStatus {
        my %status_hash = (
                IDLE      => 0,
                PREPARE   => 1,
                PORTBUILD => 2,
        );

        if (!$opts->{'b'}) {
                usage("updateBuildStatus");
        }

        if (!$ds->isValidBuild($opts->{'b'})) {
                cleanup($ds, 1, "Unknown build, " . $opts->{'b'} . "\n");
        }

        my $build = $ds->getBuildByName($opts->{'b'});

        my $build_status;
        if (!defined($status_hash{$opts->{'s'}})) {
                $build_status = "IDLE";
        } else {
                $build_status = $opts->{'s'};
        }
        $build->setStatus($build_status);

        $ds->updateBuildStatus($build)
            or cleanup($ds, 1,
                "Failed to update last build status value in the datastore: "
                    . $ds->getError()
                    . "\n");
}

sub getPortLastBuiltVersion {
        if (!$opts->{'d'} || !$opts->{'b'}) {
                usage("getPortLastBuiltVersion");
        }

        my $port = $ds->getPortByDirectory($opts->{'d'});
        if (!defined($port)) {
                cleanup($ds, 1,
                              "Port, "
                            . $opts->{'d'}
                            . " is not in the datastore.\n");
        }

        if (!$ds->isValidBuild($opts->{'b'})) {
                cleanup($ds, 1, "Unknown build, " . $opts->{'b'} . "\n");
        }

        my $build = $ds->getBuildByName($opts->{'b'});

        if (!$ds->isPortForBuild($port, $build)) {
                cleanup($ds, 1,
                              "Port, "
                            . $opts->{'d'}
                            . " is not a valid port for build, "
                            . $opts->{'b'}
                            . "\n");
        }

        my $version = $ds->getPortLastBuiltVersion($port, $build);
        if (!defined($version) && $ds->getError()) {
                cleanup($ds, 1,
                              "Failed to get last update version for port "
                            . $opts->{'d'}
                            . " for build "
                            . $opts->{'b'} . ": "
                            . $ds->getError()
                            . "\n");
        }

        print $version . "\n";
}

sub updateBuildCurrentPort {
        if (!$opts->{'b'}) {
                usage("updateBuildCurrentPort");
        }

        if (!$ds->isValidBuild($opts->{'b'})) {
                cleanup($ds, 1, "Unknown build, " . $opts->{'b'} . "\n");
        }

        my $build = $ds->getBuildByName($opts->{'b'});

        $ds->updateBuildCurrentPort($build, $opts->{'n'})
            or cleanup($ds, 1,
                      "Failed to get last update build current port for build "
                    . $opts->{'b'} . ": "
                    . $ds->getError()
                    . "\n");
}

sub sendBuildErrorMail {
        if (!$opts->{'b'} || !$opts->{'d'}) {
                usage("sendBuildErrorMail");
        }

        my $buildname = $opts->{'b'};
        my $portdir   = $opts->{'d'};

        if (!$ds->isValidBuild($buildname)) {
                cleanup($ds, 1, "Unknown build, $buildname\n");
        }

        my $build = $ds->getBuildByName($buildname);
        my $port  = $ds->getPortByDirectory($portdir);

        my $version = $opts->{'p'};
        if (!$version) {
                $version = $ds->getPortLastBuiltVersion($port, $build);
        }

        my $subject = $SUBJECT . " Port $portdir failed for build $buildname";
        my $now     = scalar localtime;
        my $data    = <<EOD;
Port $portdir failed for build $buildname on $now.  The error log can be
found at:

${SERVER_PROTOCOL}://${SERVER_HOST}${LOG_URI}/$buildname/${version}.log

EOD
        if (defined($port)) {
                my $portid = $port->getId();
                $data .= <<EOD;
More details can be found at:

${SERVER_PROTOCOL}://${SERVER_HOST}${SHOWPORT_URI}$portid

EOD
        }

        $data .= <<EOD;
Please do not reply to this email.
EOD

        my @users = $ds->getBuildCompletionUsers($build);

        if (scalar(@users)) {

                my @addrs = ();
                foreach my $user (@users) {
                        push @addrs, $user->getEmail();
                }

                my $rc =
                    sendMail($SENDER, \@addrs, $subject, $data, $SMTP_HOST);

                if (!$rc) {
                        cleanup($ds, 1, "Failed to send email.");
                }
        }
}

sub sendBuildCompletionMail {
        my @users;
        if (!$opts->{'b'}) {
                usage("sendBuildCompletionMail");
        }

        my $buildname = $opts->{'b'};

        if (!$ds->isValidBuild($buildname)) {
                cleanup($ds, 1, "Unknown build, $buildname\n");
        }

        my $build = $ds->getBuildByName($buildname);

        my $subject = $SUBJECT . " Build $buildname completed";
        my $now     = scalar localtime;
        my $data    = <<EOD;
Build $buildname completed on $now.  Details can be found at:

${SERVER_PROTOCOL}://${SERVER_HOST}${SHOWBUILD_URI}$buildname

Please do not reply to this email.
EOD

        if ($opts->{'u'}) {
                push @users, $ds->getUserById($opts->{'u'});
        } else {
                @users = $ds->getBuildCompletionUsers($build);
        }

        if (scalar(@users)) {

                my @addrs = ();
                foreach my $user (@users) {
                        push @addrs, $user->getEmail();
                }

                my $rc =
                    sendMail($SENDER, \@addrs, $subject, $data, $SMTP_HOST);

                if (!$rc) {
                        cleanup($ds, 1, "Failed to send email.");
                }
        }
}

sub addUser {
        if (!$opts->{'u'}) {
                usage("addUser");
        }

        my $user = new User();

        $user->setName($opts->{'u'});
        $user->setEmail($opts->{'e'})    if ($opts->{'e'});
        $user->setPassword($opts->{'p'}) if ($opts->{'p'});
        $opts->{'w'} ? $user->setWwwEnabled(1) : $user->setWwwEnabled(0);

        my $rc = $ds->addUser($user);

        if (!$rc) {
                cleanup($ds, 1,
                              "Failed to add user to the datastore: "
                            . $ds->getError()
                            . "\n");
        }
}

sub updateUser {
        if (!$opts->{'u'}) {
                usage("updateUser");
        }

        my $username = $opts->{'u'};

        if (!$ds->isValidUser($username)) {
                cleanup($ds, 1, "Unknown user, $username\n");
        }

        my $user = $ds->getUserByName($username);

        $user->setName($username);
        $user->setEmail($opts->{'e'})    if ($opts->{'e'});
        $user->setPassword($opts->{'p'}) if ($opts->{'p'});
        $opts->{'w'} ? $user->setWwwEnabled(1) : $user->setWwwEnabled(0);

        my $rc = $ds->updateUser($user);

        if (!$rc) {
                cleanup($ds, 1,
                              "Failed to update user preferences: "
                            . $ds->getError()
                            . "\n");
        }
}

sub updatePortFailReason {
        my $reason;

        if (!$opts->{'t'} || (!$opts->{'y'} && !$opts->{'d'})) {
                usage("updatePortFailReason");
        }

        if (!$ds->isValidPortFailReason($opts->{'t'})) {
                cleanup($ds, 1,
                        "Unknown port failure reason, " . $opts->{'t'} . ".\n");
        }

        $reason = $ds->getPortFailReasonByTag($opts->{'t'});

        $reason->setType($opts->{'y'})  if $opts->{'y'};
        $reason->setDescr($opts->{'d'}) if $opts->{'d'};

        my $rc = $ds->updatePortFailReason($reason);

        if (!$rc) {
                cleanup($ds, 1,
                              "Failed to update port failure reason: "
                            . $ds->getError()
                            . "\n");
        }
}

sub setWwwAdmin {
        my $old_admin;
        my $old_id;

        if (!$opts->{'u'}) {
                usage("setWwwAdmin");
        }

        my $username = $opts->{'u'};
        if (!$ds->isValidUser($username)) {
                cleanup($ds, 1, "Unknown user, $username\n");
        }

        if ($old_admin = $ds->getWwwAdmin()) {
                $old_id = $old_admin->getId();
        } else {
                $old_id = 0;
        }

        my $user = $ds->getUserByName($username);

        my $rc = $ds->setWwwAdmin($user);

        if (!$rc) {
                cleanup($ds, 1,
                        "Failed to set www admin: " . $ds->getError() . "\n");
        }

        $rc = $ds->moveBuildPortsQueueFromUserToUser($old_id, $user->getId());
}

sub addBuildUser {
        return _updateBuildUser($opts, "addBuildUser");
}

sub updateBuildUser {
        return _updateBuildUser($opts, "updateBuildUser");
}

sub listUsers {
        my @users = $ds->getAllUsers();

        if (@users) {
                map { print $_->getName() . "\n" } @users;
        } elsif (defined($ds->getError())) {
                cleanup($ds, 1,
                        "Failed to list users: " . $ds->getError() . "\n");
        } else {
                cleanup($ds, 1,
                        "There are no users configured in the datastore.\n");
        }
}

sub listBuildUsers {
        if (!$opts->{'b'}) {
                usage("listBuildUsers");
        }

        if (!$ds->isValidBuild($opts->{'b'})) {
                cleanup($ds, 1, "Unknown build, " . $opts->{'b'} . "\n");
        }

        my $build = $ds->getBuildByName($opts->{'b'});
        my @users = $ds->getUsersForBuild($build);

        if (@users) {
                map { print $_->getName() . "\n" } @users;
        } elsif (defined($ds->getError())) {
                cleanup($ds, 1,
                        "Failed to list users: " . $ds->getError() . "\n");
        } else {
                cleanup($ds, 1,
                        "There are no users configured for this build.\n");
        }
}

sub processLog {
        my $log_text = "";
        my @patterns;
        my %parents = ();
        my $reason  = '__nofail__';

        if (!$opts->{'l'}) {
                usage("processLog");
        }

        unless (open(LOG, $opts->{'l'})) {
                cleanup($ds, 1,
                              "Failed to open "
                            . $opts->{'l'}
                            . " for reading: $!.\n");
        }

        while (<LOG>) {
                $log_text .= $_;
        }

        close(LOG);

        @patterns = $ds->getAllPortFailPatterns();
        $parents{'0'} = 1;

        foreach my $pattern (@patterns) {
                next if $pattern->getId() <= 0;
                my $expr = $pattern->getExpr();
                if ($log_text =~ /$expr/m) {
                        if ($pattern->getReason() eq '__parent__') {
                                $parents{$pattern->getId()} = 1;
                        } else {
                                if ($parents{$pattern->getParent()}) {
                                        $reason = $pattern->getReason();
                                        last;
                                }
                        }
                }
        }

        print $reason . "\n";
}

sub updatePortLastFailReason {
        my $port;
        my $build;
        my $reason;

        if (!$opts->{'d'} || !$opts->{'b'} || !$opts->{'r'}) {
                usage("updatePortLastFailReason");
        }

        $port = $ds->getPortByDirectory($opts->{'d'});
        if (!defined($port)) {
                cleanup($ds, 1,
                              "Port, "
                            . $opts->{'d'}
                            . " is not in the datastore.\n");
        }

        if (!$ds->isValidBuild($opts->{'b'})) {
                cleanup($ds, 1, "Unknown build, " . $opts->{'b'} . "\n");
        }

        $build = $ds->getBuildByName($opts->{'b'});

        if (!$ds->isPortForBuild($port, $build)) {
                cleanup($ds, 1,
                              "Port, "
                            . $opts->{'d'}
                            . " is not a valid port for build, "
                            . $opts->{'b'}
                            . "\n");
        }

        if (!$ds->isValidPortFailReason($opts->{'r'})) {
                cleanup($ds, 1,
                        "Unknown failure reason, " . $opts->{'r'} . "\n");
        }

        $reason = $ds->getPortFailReasonByTag($opts->{'r'});

        $ds->updatePortLastFailReason($port, $build, $reason)
            or cleanup($ds, 1,
                "Failed to update last failure reason value in the datastore: "
                    . $ds->getError()
                    . "\n");
}

sub _updateBuildUser {
        my $opts     = shift;
        my $function = shift;

        if (       (!$opts->{'b'} && !$opts->{'a'})
                || ($opts->{'b'} && $opts->{'a'})
                || !$opts->{'u'})
        {
                usage($function);
        }

        my $buildname = $opts->{'b'};
        if ($buildname && !$ds->isValidBuild($buildname)) {
                cleanup($ds, 1, "Unknown build, $buildname\n");
        }

        my $username = $opts->{'u'};
        if (!$ds->isValidUser($username)) {
                cleanup($ds, 1, "Unknown user, $username\n");
        }

        my $user = $ds->getUserByName($username);

        if (!$user->getEmail()) {
                cleanup($ds, 1,
                        "User, $username, does not have an email address\n");
        }

        my @builds = ();
        if ($opts->{'a'}) {
                @builds = $ds->getAllBuilds();
        } else {
                push @builds, $ds->getBuildByName($buildname);
        }

        foreach my $build (@builds) {
                if ($ds->isUserForBuild($user, $build)) {
                        $ds->updateBuildUser($build, $user, $opts->{'c'},
                                $opts->{'e'});
                } else {
                        $ds->addUserForBuild($user, $build, $opts->{'c'},
                                $opts->{'e'});
                }
        }
}

sub addPorts {
        my $port  = shift;
        my $build = shift;
        my $cache = shift;
        my $deps  = shift;

        my $portdir = $ENV{'PORTSDIR'} . "/" . $port;
        return if (!-d $portdir);

        if (defined($deps)) {
                my @list;
                push @list, $cache->BuildDependsList($port);
                push @list, $cache->RunDependsList($port);

                my %uniq;
                foreach my $dep (grep { !$uniq{$_}++ } @list) {
                        next unless $dep;
                        push @{$deps}, $dep;
                }
        }

        my $pCls = new Port();
        $pCls->setDirectory($port);
        $pCls->setName($cache->Name($port));
        $pCls->setMaintainer($cache->Maintainer($port));
        $pCls->setComment($cache->Comment($port));

        # Only add the port if it isn't already in the datastore.
        my $rc;
        if (!$ds->isPortInDS($pCls)) {
                $rc = $ds->addPort(\$pCls);
                if (!$rc) {
                        warn "WARN: Failed to add port "
                            . $pCls->getDirectory() . ": "
                            . $ds->getError() . "\n";
                }
        } else {
                $rc = $ds->updatePort(\$pCls);
                if (!$rc) {
                        warn "WARN: Failed to update port "
                            . $pCls->getDirectory() . ": "
                            . $ds->getError() . "\n";
                }
        }

        if (!$ds->isPortInBuild($pCls, $build)) {
                $rc = $ds->addPortForBuild($pCls, $build);
                if (!$rc) {
                        warn "WARN: Failed to add port for build, "
                            . $build->getName() . ": "
                            . $ds->getError() . "\n";
                }
        }
}

sub tbcleanup {
        my @builds = $ds->getAllBuilds();

        foreach my $build (@builds) {
                print $build->getName() . "\n";
                my $jail           = $ds->getJailById($build->getJailId());
                my $package_suffix = $ds->getPackageSuffix($jail);

                # Delete unreferenced log files.
                my $dir = join("/", $pb, 'logs', $build->getName());
                opendir(DIR, $dir) || die "Failed to open $dir: $!\n";

                while (my $file_name = readdir(DIR)) {
                        if ($file_name =~ /\.log$/) {
                                my $result =
                                    $ds->isLogCurrent($build, $file_name);
                                if (!$result) {
                                        print
                                            "Deleting stale log $dir/$file_name\n";
                                        unlink "$dir/$file_name";
                                }
                        }
                }

                closedir(DIR);

                # Delete database records for nonexistent packages.
                my @ports = $ds->getPortsForBuild($build);
                foreach my $port (@ports) {
                        if ($ds->getPortLastBuiltVersion($port, $build)) {
                                my $path = join(
                                        "/", $pb,
                                        'packages',
                                        $build->getName(),
                                        "All",
                                        $ds->getPortLastBuiltVersion($port,
                                                $build)
                                            . $package_suffix
                                );
                                if (!-e $path) {
                                        print
                                            "Removing database entry for nonexistent package "
                                            . $build->getName() . "/"
                                            . $ds->getPortLastBuiltVersion(
                                                $port, $build)
                                            . "\n";
                                        $ds->removePortForBuild($port, $build);
                                }
                        }
                }
        }
}
