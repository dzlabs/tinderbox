#!/usr/bin/perl

use strict;
use TinderboxDS;
use Getopt::Std;
use vars qw(
    %COMMANDS
    $BUILD_ROOT
);

require "tinderbox.ph";
require "tinderlib.pl";

%COMMANDS = (
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
        "listPortsTree" => {
                func  => \&listPortsTrees,
                help  => "List all portstrees in the datastore",
                usage => "",
        },
        "addBuild" => {
                func  => \&addBuild,
                help  => "Add a build to the datastore",
                usage =>
                    "-n <build name> -j <jail name> -p <portstree name> [-d <build description>]",
        },
        "addJail" => {
                func  => \&addJail,
                help  => "Add a jail to the datastore",
                usage =>
                    "-n <jail name> -t <jail tag> [-d <jail description>] [-u <jail update command|CVSUP|NONE>]",
        },
        "addPortsTree" => {
                func  => \&addPortsTree,
                help  => "Add a portstree to the datastore",
                usage =>
                    "-n <portstree name> [-d <portstree description>] [-u <portstree update command|NONE|CVSUP>]",
        },
        "addPort" => {
                func => \&addPort,
                help =>
                    "Add a port, and optionally, its dependencies, to the datastore",
                usage => "-b <build name> -d <port directory> [-r]",
        },
        "getJailForBuild" => {
                func  => \&getJailForBuild,
                help  => "Get the jail name associated with a given build",
                usage => "-b <build name>",
        },
        "getPortsTreeForBuild" => {
                func  => \&getPortsTreeForBuild,
                help  => "Get the portstree name assoicated with a given build",
                usage => "-b <build name>",
        },
        "getTagForJail" => {
                func  => \&getTagForJail,
                help  => "Get the tag for a given jail",
                usage => "-j <jail name>",
        },
        "getSrcUpdateCmd" => {
                func  => \&getSRcUpdateCmd,
                help  => "Get the update command for the given jail",
                usage => "-j <jail name>",
        },
);

if (!scalar(@ARGV)) {
        usage();
}

my $ds = new TinderboxDS();

my $command = $ARGV[0];
shift;

if (defined($COMMANDS{$command})) {
        &{$COMMANDS{$command}->{'func'}}(@ARGV);
} else {
        usage();
}

cleanup($ds, 0, undef);

sub listJails {
        my @jails = $ds->getAllJails();

        if (defined(@jails)) {
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

        if (defined(@builds)) {
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

        if (defined(@portstrees)) {
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

sub addBuild {
        my $opts = {};

        getopts('n:j:p:d:', $opts);

        if (!$opts->{'n'} || !$opts->{'j'} || !$opts->{'p'}) {
                usage("addBuild");
        }

        my $name      = $opts->{'n'};
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
        my $opts = {};

        getopts('n:t:u:d:', $opts);

        if (!$opts->{'n'} || !$opts->{'t'}) {
                usage("addJail");
        }

        my $name = $opts->{'n'};
        my $tag  = $opts->{'t'};

        if ($ds->isValidJail($name)) {
                cleanup($ds, 1,
                        "A jail named $name is already in the datastore.\n");
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

        my $rc = $ds->addJail($jail);

        if (!$rc) {
                cleanup($ds, 1,
                              "Failed to add jail $name to the datastore: "
                            . $ds->getError()
                            . ".\n");
        }
}

sub addPortsTree {
        my $opts = {};

        getopts('n:u:d:', $opts);

        if (!$opts->{'n'}) {
                usage("addPortsTree");
        }

        my $name = $opts->{'n'};

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

        my $rc = $ds->addPortsTree($portstree);

        if (!$rc) {
                cleanup($ds, 1,
                              "Failed to add portstree $name to the datastore: "
                            . $ds->getError()
                            . ".\n");
        }
}

sub addPort {
        my $opts = {};

        getopts('b:d:r', $opts);

        if (!$opts->{'b'} || !$opts->{'d'}) {
                usage("addPort");
        }

        my $buildname = $opts->{'b'};
        if (!$ds->isValidBuild($buildname)) {
                cleanup($ds, 1, "Unknown build, $buildname\n");
        }

        my $build     = $ds->getBuildByName($buildname);
        my $jail      = $ds->getJailById($build->getJailId());
        my $portstree = $ds->getPortsTreeById($build->getPortsTreeId());
        my $tag       = $jail->getTag();

        if (!$tag) {
                $tag = $jail->getName();
        }

        buildenv($BUILD_ROOT, $buildname, $jail->getName(),
                $portstree->getName());

        if ($opts->{'r'}) {
                my @deps = ();
                addPorts([$opts->{'d'}], $build, \@deps);
                addPorts(\@deps, $build, undef);
        } else {
                addPorts([$opts->{'d'}], $build, undef);
        }
}

sub getJailForBuild {
        my $opts = {};

        getopts('b:', $opts);

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
        my $opts = {};

        getopts('b:', $opts);

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
        my $opts = {};

        getopts('j:', $opts);

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
        my $opts = {};

        getopts('j:', $opts);

        if (!$opts->{'j'}) {
                usage("getSrcUpdateCmd");
        }

        if (!$ds->isValidJail($opts->{'j'})) {
                cleanup($ds, 1, "Unknown jail, " . $opts->{'j'} . "\n");
        }

        my $jail = $ds->getJailByName($opts->{'j'});

        print $jail->getUpdateCmd() . "\n";
}

sub usage {
        my $cmd = shift;

        print STDERR "usage: $0 ";

        if (!defined($cmd)) {
                print STDERR "<command>\n";
                print STDERR "Where <command> is one of:\n";
                foreach my $key (sort keys %COMMANDS) {
                        print STDERR "  $key:\t"
                            . $COMMANDS{$key}->{'help'} . "\n";
                }
        } else {
                print STDERR "$cmd " . $COMMANDS{$cmd}->{'usage'} . "\n";
        }

        cleanup($ds, 1, undef);
}

sub addPorts {
        my $ports = shift;
        my $build = shift;
        my $deps  = shift;

        foreach my $port (@{$ports}) {
                my $portdir = $ENV{'PORTSDIR'} . "/" . $port;
                next if (!-d $portdir);

                my ($portname, $portcomment) =
                    `cd $portdir && make -V PORTNAME -V COMMENT`;
                chomp $portname;
                chomp $portcomment;

                if (defined($deps)) {

                        # We need to add all ports on which this port depends
                        # recursively.

                        my @deplist = `cd $portdir && make all-depends-list`;
                        foreach my $dep (@deplist) {
                                chomp $dep;
                                $dep =~ s|^$ENV{'PORTSDIR'}/||;
                                push @{$deps}, $dep;
                        }
                }

                $portdir =~ s|^$ENV{'PORTSDIR'}/||;

                my $pCls = new Port();

                $pCls->setDirectory($portdir);
                $pCls->setName($portname);
                $pCls->setComment($portcomment);

                # Only add the port if it isn't already in the datastore.
                my $rc;
                if (!$ds->isPortInDS($pCls)) {
                        $rc = $ds->addPort(\$pCls);
                        if (!$rc) {
                                warn "WARN: Failed to add port "
                                    . $pCls->getDirectory() . ": "
                                    . $ds->getError() . "\n";
                        }
                }

                $rc = $ds->addPortForBuild($pCls, $build);
                if (!$rc) {
                        warn "WARN: Failed to add port for build, "
                            . $build->getName() . ": "
                            . $ds->getError() . "\n";
                }
        }
}
