#!/usr/bin/perl

# This is a hack to make sure we can always find our modules.
BEGIN {
        my $pb = "/space";
        push @INC, "$pb/scripts";
        use lib "$pb/sctips";
}

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
        "init" => {
                func  => \&init,
                help  => "Initialize a tinderbox environment",
                usage => "[-u <USA_RESIDENT value>] [-c <CPUTYPE value>]",
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
                    "-n <portstree name> [-d <portstree description>] [-u <portstree update command|NONE|CVSUP>] [-w <CVSweb URL>]",
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
                func  => \&getSrcUpdateCmd,
                help  => "Get the update command for the given jail",
                usage => "-j <jail name>",
        },
        "getPortsUpdateCmd" => {
                func  => \&getPortsUpdateCmd,
                help  => "Get the update command for the given portstree",
                usage => "-p <portstree name>",
        },
        "rmPort" => {
                func  => \&rmPort,
                help  => "Remove a port from the datastore",
                usage => "-d <port directory> [-b <build name>] [-f]",
        },
        "rmBuild" => {
                func  => \&rmBuild,
                help  => "Remove a build from the datastore",
                usage => "-b <build name> [-f]",
        },
        "rmPortsTree" => {
                func  => \&rmPortsTree,
                help  => "Remove a portstree from the datastore",
                usage => "-p <portstree name> [-f]",
        },
        "rmJail" => {
                func  => \&rmJail,
                help  => "Remove a jail from the datastore",
                usage => "-j <jail name> [-f]",
        },
        "updatePortsTree" => {
                func => \&updatePortsTree,
                help =>
                    "Run the configured update command on the specified portstree",
                usage => "-p <portstree name> [-l <last built timestamp>]",
        },
        "updateJailLastBuilt" => {
                func  => \&updateJailLastBuilt,
                help  => "Update the specified jail's last built time",
                usage => "-j <jail name> [-l <last built timestamp>]",
        },
        "updatePortLastBuilt" => {
                func => \&updatePortLastBuilt,
                help =>
                    "Update the specified port's last built time for the specified build",
                usage =>
                    "-d <port directory> -b <build name> [-l <last built timestamp>]",
        },
        "updatePortLastSuccessfulBuilt" => {
                func => \&updatePortLastSuccessfulBuilt,
                help =>
                    "Update the specified port's last successful built time for the specified build",
                usage =>
                    "-d <port directory> -b <build name> [-l <last built timestamp>]",
        },
        "updatePortLastStatus" => {
                func => \&updatePortLastStatus,
                help =>
                    "Update the specified port's last build status for the specified build",
                usage =>
                    "-d <port directory> -b <build name> -s <UNKNOWN|SUCCESS|FAIL>",
        },
        "updatePortLastBuiltVersion" => {
                func => \&updatePortLastBuiltVersion,
                help =>
                    "Update the specified port's last built version for the specified build",
                usage =>
                    "-d <port directory> -b <build name> -v <last built version>",
        },
        "updateBuildStatus" => {
                func  => \&updateBuildStatus,
                help  => "Update the current status for the specific build",
                usage => "-b <build name> -s <IDLE|PORTBUILD>",
        },
        "getPortLastBuiltVersion" => {
                func => \&getPortLastBuiltVersion,
                help =>
                    "Get the last built version for the specified port and build",
                usage => "-d <port directory> -b <build name>",
        },
        "updateBuildCurrentPort" => {
                func => \&updateBuildCurrentPort,
                help =>
                    "Update the port currently being built for the specify build",
                usage => "-b <build name> [-n <package name>]",
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

sub init {
        my $usa_resident = "YES";
        my $cputype      = "p3";
        my $opts         = {};

        getopts('u:c:', $opts);

        $usa_resident = $opts->{'u'} if ($opts->{'u'});
        $cputype      = $opts->{'c'} if ($opts->{'c'});

        system("mkdir -p $BUILD_ROOT/jails");
        system("mkdir -p $BUILD_ROOT/builds");
        system("mkdir -p $BUILD_ROOT/portstrees");
        system("mkdir -p $BUILD_ROOT/errors");
        system("mkdir -p $BUILD_ROOT/logs");
        system("mkdir -p $BUILD_ROOT/packages");
        open(MC, ">$BUILD_ROOT/make.conf");

        print MC <<"EOMC";
XFREE86_VERSION?=4
USA_RESIDENT?=$usa_resident
CPUTYPE?=$cputype
NO_LPR=true
NOPROFILE=true
MAKE_KERBEROS5= yes
NO_MODULES=damnit
EOMC
}

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

        getopts('n:u:d:w:', $opts);

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
        $portstree->setCVSwebURL($opts->{'w'})   if ($opts->{'w'});

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

        my $jail_name = $opts->{'j'};

        if (!$ds->isValidJail($jail_name)) {
                cleanup($ds, 1, "Unknown jail, $jail_name\n");
        }

        my $jail = $ds->getJailByName($jail_name);

        my $update_cmd = $jail->getUpdateCmd();

        if ($update_cmd eq "CVSUP") {
                $update_cmd =
                    "/usr/local/bin/cvsup -g $BUILD_ROOT/jails/$jail_name/src-supfile";
        } elsif ($update_cmd eq "NONE") {
                $update_cmd = "";
        } else {
                $update_cmd = "$BUILD_ROOT/scripts/$update_cmd $jail_name";
        }

        print $update_cmd . "\n";
}

sub getPortsUpdateCmd {
        my $opts = {};

        getopts('p:', $opts);

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
                    "/usr/local/bin/cvsup -g $BUILD_ROOT/portstrees/$portstree_name/ports-supfile";
        } elsif ($update_cmd eq "NONE") {
                $update_cmd = "";
        } else {
                $update_cmd = "$BUILD_ROOT/scripts/$update_cmd $portstree_name";
        }

        print $update_cmd . "\n";
}

sub rmPort {
        my $opts = {};

        getopts('fb:d:', $opts);

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
                            . $opts->{'d'} . "? ";
                } else {
                        print "Really remove port " . $opts->{'d'} . "? ";
                }
                my $response = <STDIN>;
                print "\n";
                cleanup($ds, 0, undef) unless ($response =~ /^y/i);
        }

        my $rc;
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
        my $opts = {};

        getopts('b:f', $opts);

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
        my $opts = {};

        getopts('j:f', $opts);

        if (!$opts->{'j'}) {
                usage("rmJail");
        }

        if (!$ds->isValidJail($opts->{'j'})) {
                cleanup($ds, 1, "Unknown jail " . $opts->{'j'} . "\n");
        }

        my $jail   = $ds->getJailByName($opts->{'j'});
        my @builds = $ds->findBuildsForJail($jail);

        unless ($opts->{'f'}) {
                if (defined(@builds)) {
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
                                "Failed to remove build $build as part of removing jail "
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
        my $opts = {};

        getopts('p:f', $opts);

        if (!$opts->{'p'}) {
                usage("rmPortsTree");
        }

        if (!$ds->isValidPortsTree($opts->{'p'})) {
                cleanup($ds, 1, "Unknown portstree " . $opts->{'p'} . "\n");
        }

        my $portstree = $ds->getPortsTreeByName($opts->{'p'});
        my @builds    = $ds->findBuildsForPortsTree($portstree);

        unless ($opts->{'f'}) {
                if (defined(@builds)) {
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
                                "Failed to remove build $build as part of removing portstree "
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

sub updatePortsTree {
        my $opts = {};

        getopts('p:l:', $opts);

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
                $update_cmd =
                    "/usr/local/bin/cvsup -g $BUILD_ROOT/portstrees/$name/ports-supfile";
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

sub updateJailLastBuilt {
        my $opts = {};

        getopts('j:l:', $opts);

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
        my $opts = {};

        getopts('d:b:l:', $opts);

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
        my $opts = {};

        getopts('d:b:l:', $opts);

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
        my $opts = {};

        getopts('d:b:s:', $opts);

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
        my $opts = {};

        getopts('d:b:v:', $opts);

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
        my $opts = {};

        getopts('b:s:', $opts);

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
        my $opts = {};

        getopts('d:b:', $opts);

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
        my $opts = {};

        getopts('b:n:', $opts);

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

                my ($portname, $portmaintainer, $portcomment) =
                    `cd $portdir && make -V PORTNAME -V MAINTAINER -V COMMENT`;
                chomp $portname;
                chomp $portmaintainer;
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
                $pCls->setMaintainer($portmaintainer);
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
                } else {
                        $rc = $ds->updatePort(\$pCls);
                        if (!$rc) {
                                warn "WARN: Failed to update port "
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
