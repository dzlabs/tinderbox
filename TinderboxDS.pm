#-
# Copyright (c) 2004 FreeBSD GNOME Team <freebsd-gnome@FreeBSD.org>
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
# $Id$
#

package TinderboxDS;

use strict;
use Port;
use Jail;
use PortsTree;
use Build;
use DBI;
use Carp;
use vars qw(
    $DB_DRIVER
    $DB_HOST
    $DB_NAME
    $DB_USER
    $DB_PASS
    %OBJECT_MAP
);

%OBJECT_MAP = (
        "Port"      => "ports",
        "Jail"      => "jails",
        "Build"     => "builds",
        "PortsTree" => "ports_trees",
);

require "ds.ph";

sub new {
        my ($that, @args) = @_;
        my $class = ref($that) || $that;

        my $self = {
                dbh   => undef,
                error => undef,
        };

        my $dsn = "DBI:$DB_DRIVER:database=$DB_NAME;host=$DB_HOST";

        $self->{'dbh'} = DBI->connect($dsn, $DB_USER, $DB_PASS)
            or croak "Tinderbox DS: Unable to initialize datasource.";

        bless($self, $class);
        $self;
}

sub getAllPorts {
        my $self  = shift;
        my @ports = ();

        @ports = $self->getPorts();

        return @ports;
}

sub getPortsForBuild {
        my $self  = shift;
        my $build = shift;
        my @ports;

        my @results;
        my $rc = $self->_doQueryHashRef(
                "SELECT * FROM ports WHERE Port_Id IN (SELECT Port_Id FROM build_ports WHERE Build_Id=?)",
                \@results, $build->getId()
        );

        if (!$rc) {
                return undef;
        }

        @ports = $self->_newFromArray("Port", @results);

        return @ports;
}

sub getPortById {
        my $self = shift;
        my $id   = shift;

        my @results = $self->getPorts({Port_Id => $id});

        if (!defined(@results)) {
                return undef;
        }

        return $results[0];
}

sub getPortByDirectory {
        my $self = shift;
        my $dir  = shift;

        my @results = $self->getPorts({Port_Directory => $dir});

        if (!defined(@results)) {
                return undef;
        }

        return $results[0];
}

sub getPorts {
        my $self      = shift;
        my @params    = @_;
        my $condition = "";
        my @ports     = ();

        my @values = ();
        my @conds  = ();
        foreach my $param (@params) {

                # Each parameter makes up and OR portion of a query.  Within
                # each parameter is a hash reference that make up the AND
                # portion of the query.
                my @ands = ();
                foreach my $andcond (keys %{$param}) {
                        push @ands,   "$andcond=?";
                        push @values, $param->{$andcond};
                }
                push @conds, "(" . (join(" AND ", @ands)) . ")";
        }

        $condition = join(" OR ", @conds);

        my @results;
        my $query;
        if ($condition ne "") {
                $query = "SELECT * FROM ports WHERE $condition";
        } else {
                $query = "SELECT * FROM ports";
        }

        my $rc = $self->_doQueryHashRef($query, \@results, @values);

        if (!$rc) {
                return undef;
        }

        @ports = $self->_newFromArray("Port", @results);

        return @ports;
}

sub getJailByName {
        my $self = shift;
        my $name = shift;

        my @results = $self->getJails({Jail_Name => $name});

        if (!defined(@results)) {
                return undef;
        }

        return $results[0];
}

sub getBuildById {
        my $self = shift;
        my $id   = shift;

        my @results = $self->getBuilds({Build_Id => $id});

        if (!defined(@results)) {
                return undef;
        }

        return $results[0];
}

sub getBuildByName {
        my $self = shift;
        my $name = shift;

        my @results = $self->getBuilds({Build_Name => $name});

        if (!defined(@results)) {
                return undef;
        }

        return $results[0];
}

sub getJailById {
        my $self = shift;
        my $id   = shift;

        my @results = $self->getJails({Jail_Id => $id});

        if (!defined(@results)) {
                return undef;
        }

        return $results[0];
}

sub getJailForBuild {
        my $self  = shift;
        my $build = shift;
        my $jail;

        $jail = $self->getJailById($build->getJailId());

        return $jail;
}

sub getPortsTreeForBuild {
        my $self  = shift;
        my $build = shift;

        my $portstree;
        $portstree = $self->getPortsTreeById($build->getPortsTreeId());
        return $portstree;
}

sub getPortsTreeById {
        my $self = shift;
        my $id   = shift;

        my @results = $self->getPortsTrees({Ports_Tree_Id => $id});

        if (!defined(@results)) {
                return undef;
        }

        return $results[0];
}

sub getPortsTreeByName {
        my $self = shift;
        my $name = shift;

        my @results = $self->getPortsTrees({Ports_Tree_Name => $name});

        if (!defined(@results)) {
                return undef;
        }

        return $results[0];
}

sub getBuilds {
        my $self      = shift;
        my @params    = @_;
        my $condition = "";
        my @builds    = ();

        my @values = ();
        my @conds  = ();
        foreach my $param (@params) {

                # Each parameter makes up and OR portion of a query.  Within
                # each parameter is a hash reference that make up the AND
                # portion of the query.
                my @ands = ();
                foreach my $andcond (keys %{$param}) {
                        push @ands,   "$andcond=?";
                        push @values, $param->{$andcond};
                }
                push @conds, "(" . (join(" AND ", @ands)) . ")";
        }

        $condition = join(" OR ", @conds);

        my @results;
        my $query;
        if ($condition ne "") {
                $query = "SELECT * FROM builds WHERE $condition";
        } else {
                $query = "SELECT * FROM builds";
        }

        my $rc = $self->_doQueryHashRef($query, \@results, @values);

        if (!$rc) {
                return undef;
        }

        @builds = $self->_newFromArray("Build", @results);

        return @builds;
}

sub getJails {
        my $self      = shift;
        my @params    = @_;
        my $condition = "";
        my @jails     = ();

        my @values = ();
        my @conds  = ();
        foreach my $param (@params) {

                # Each parameter makes up and OR portion of a query.  Within
                # each parameter is a hash reference that make up the AND
                # portion of the query.
                my @ands = ();
                foreach my $andcond (keys %{$param}) {
                        push @ands,   "$andcond=?";
                        push @values, $param->{$andcond};
                }
                push @conds, "(" . (join(" AND ", @ands)) . ")";
        }

        $condition = join(" OR ", @conds);

        my @results;
        my $query;
        if ($condition ne "") {
                $query = "SELECT * FROM jails WHERE $condition";
        } else {
                $query = "SELECT * FROM jails";
        }

        my $rc = $self->_doQueryHashRef($query, \@results, @values);

        if (!$rc) {
                return undef;
        }

        @jails = $self->_newFromArray("Jail", @results);

        return @jails;
}

sub addBuild {
        my $self  = shift;
        my $build = shift;
        my $bCls  = (ref($build) eq "REF") ? $$build : $build;

        my $rc = $self->_addObject($bCls);

        if (ref($build) eq "REF") {
                $$build = $self->getBuildByName($bCls->getName());
        }

        return $rc;
}

sub addJail {
        my $self = shift;
        my $jail = shift;
        my $jCls = (ref($jail) eq "REF") ? $$jail : $jail;

        my $rc = $self->_addObject($jCls);

        if (ref($jail) eq "REF") {
                $$jail = $self->getJailByName($jCls->getName());
        }

        return $rc;
}

sub addPort {
        my $self = shift;
        my $port = shift;
        my $pCls = (ref($port) eq "REF") ? $$port : $port;

        my $rc = $self->_addObject($pCls);

        if (ref($port) eq "REF") {
                $$port = $self->getPortByDirectory($pCls->getDirectory());
        }

        return $rc;
}

sub updatePort {
        my $self = shift;
        my $port = shift;
        my $pCls = (ref($port) eq "REF") ? $$port : $port;

        my $rc = $self->_doQuery(
                "UPDATE ports SET Port_Name=?, Port_Comment=?, Port_Maintainer=? WHERE Port_Id=?",
                [
                        $pCls->getName(),       $pCls->getComment(),
                        $pCls->getMaintainer(), $pCls->getId()
                ]
        );

        if (ref($port) eq "REF") {
                $$port = $self->getPortByDirectory($pCls->getDirectory());
        }

        return $rc;
}

sub addPortsTree {
        my $self      = shift;
        my $portstree = shift;
        my $pCls      = (ref($portstree) eq "REF") ? $$portstree : $portstree;

        my $rc = $self->_addObject($pCls);

        if (ref($portstree) eq "REF") {
                $$portstree = $self->getPortsTreeByName($pCls->getName());
        }

        return $rc;
}

sub updateJailLastBuilt {
        my $self = shift;
        my $jail = shift;
        croak "ERROR: Argument not of type Jail\n" if (ref($jail) ne "Jail");

        my $rc;
        if ($jail->getLastBuilt()) {
                my $last_built = $jail->getLastBuilt();
                $rc =
                    $self->_doQuery(
                        "UPDATE jails SET Jail_Last_Built=? WHERE Jail_Id=?",
                        [$last_built, $jail->getId()]);
        } else {
                $rc = $self->_doQuery(
                        "UPDATE jails SET Jail_Last_Built=NOW() WHERE Jail_Id=?",
                        [$jail->getId()]
                );
        }

        return $rc;
}

sub updatePortLastBuilt {
        my $self = shift;
        return $self->updatePortLastBuilts(@_, "Last_Built");
}

sub updatePortLastSuccessfulBuilt {
        my $self = shift;
        return $self->updatePortLastBuilts(@_, "Last_Successful_Built");
}

sub updatePortLastBuilts {
        my $self       = shift;
        my $port       = shift;
        my $build      = shift;
        my $last_built = shift;
        my $column     = shift;
        croak "ERROR: Argument 1 not of type Port\n" if (ref($port) ne "Port");
        croak "ERROR: Argument 2 not of type Build\n"
            if (ref($build) ne "Build");

        my $rc;
        if (!defined($last_built) || $last_built eq "") {
                $rc = $self->_doQuery(
                        "UPDATE build_ports SET $column=NOW() WHERE Port_Id=? AND Build_Id=?",
                        [$port->getId(), $build->getId()]
                );
        } else {
                $rc = $self->_doQuery(
                        "UPDATE build_ports SET $column=? WHERE Port_Id=? AND Build_Id=?",
                        [$last_built, $port->getId(), $build->getId()]
                );
        }

        return $rc;
}

sub updatePortLastStatus {
        my $self   = shift;
        my $port   = shift;
        my $build  = shift;
        my $status = shift;
        croak "ERROR: Argument 1 not of type Port\n" if (ref($port) ne "Port");
        croak "ERROR: Argument 2 not of type Build\n"
            if (ref($build) ne "Build");

        my %status_hash = (
                UNKNOWN => 0,
                SUCCESS => 1,
                FAIL    => 1,
        );

        if (!defined($status_hash{$status})) {
                $status = "UNKNOWN";
        }

        my $rc = $self->_doQuery(
                "UPDATE build_ports SET Last_Status=? WHERE Port_Id=? AND Build_Id=?",
                [$status, $port->getId(), $build->getId()]
        );

        return $rc;
}

sub updatePortLastBuiltVersion {
        my $self    = shift;
        my $port    = shift;
        my $build   = shift;
        my $version = shift;
        croak "ERROR: Argument 1 not of type Port\n" if (ref($port) ne "Port");
        croak "ERROR: Argument 2 not of type Build\n"
            if (ref($build) ne "Build");

        my $rc = $self->_doQuery(
                "UPDATE build_ports SET Last_Built_Version=? WHERE Port_Id=? AND Build_Id=?",
                [$version, $port->getId(), $build->getId()]
        );

        return $rc;
}

sub getPortLastBuiltVersion {
        my $self  = shift;
        my $port  = shift;
        my $build = shift;
        croak "ERROR: Argument 1 not of type Port\n" if (ref($port) ne "Port");
        croak "ERROR: Argument 2 not of type Build\n"
            if (ref($build) ne "Build");

        my @results;
        my $rc = $self->_doQueryHashRef(
                "SELECT Last_Built_Version FROM build_ports WHERE Port_Id=? AND Build_Id=?",
                \@results, $port->getId(), $build->getId()
        );

        if (!$rc) {
                return undef;
        }

        return $results[0]->{Last_Built_Version};
}

sub updatePortsTreeLastBuilt {
        my $self      = shift;
        my $portstree = shift;
        croak "ERROR: Argument not of type PortsTree\n"
            if (ref($portstree) ne "PortsTree");

        my $rc;
        if ($portstree->getLastBuilt()) {
                my $last_built = $portstree->getLastBuilt();
                $rc = $self->_doQuery(
                        "UPDATE ports_trees SET Ports_Tree_Last_Built=? WHERE Ports_Tree_Id=?",
                        [$last_built, $portstree->getId()]
                );
        } else {
                $rc = $self->_doQuery(
                        "UPDATE ports_trees SET Ports_Tree_Last_Built=NOW() WHERE Ports_Tree_Id=?",
                        [$portstree->getId()]
                );
        }

        return $rc;
}

sub updateBuildStatus {
        my $self  = shift;
        my $build = shift;
        croak "ERROR: Argument not of type build\n" if (ref($build) ne "Build");

        my $rc =
            $self->_doQuery("UPDATE builds SET Build_Status=? WHERE Build_Id=?",
                [$build->getStatus(), $build->getId()]);

        return $rc;
}

sub updateBuildCurrentPort {
        my $self    = shift;
        my $build   = shift;
        my $pkgname = shift;
        croak "ERROR: Argument 1 not of type build\n"
            if (ref($build) ne "Build");

        my $rc;
        if (!defined($pkgname)) {
                $rc = $self->_doQuery(
                        "UPDATE builds SET Build_Current_Port=NULL WHERE Build_Id=?",
                        [$build->getId()]
                );
        } else {
                $rc = $self->_doQuery(
                        "UPDATE builds SET Build_Current_Port=? WHERE Build_Id=?",
                        [$pkgname, $build->getId()]
                );
        }

        return $rc;
}

sub addPortForBuild {
        my $self  = shift;
        my $port  = shift;
        my $build = shift;

        my $rc =
            $self->_doQuery(
                "INSERT INTO build_ports (Build_Id, Port_Id) VALUES (?, ?)",
                [$build->getId(), $port->getId()]);

        return $rc;
}

sub removePort {
        my $self = shift;
        my $port = shift;

        my $rc;
        $rc = $self->_doQuery("DELETE FROM build_ports WHERE Port_Id=?",
                [$port->getId()]);

        if (!$rc) {
                return $rc;
        }

        $rc = $self->_doQuery("DELETE FROM ports WHERE Port_Id=?",
                [$port->getId()]);

        return $rc;
}

sub removePortForBuild {
        my $self  = shift;
        my $port  = shift;
        my $build = shift;

        my $rc =
            $self->_doQuery(
                "DELETE FROM build_ports WHERE Port_Id=? AND Build_Id=?",
                [$port->getId(), $build->getId()]);

        return $rc;
}

sub removeJail {
        my $self = shift;
        my $jail = shift;

        my $rc = $self->_doQuery("DELETE FROM jails WHERE Jail_Id=?",
                [$jail->getId()]);

        return $rc;
}

sub removePortsTree {
        my $self      = shift;
        my $portstree = shift;

        my $rc = $self->_doQuery("DELETE FROM portstrees WHERE Ports_Tree_Id=?",
                [$portstree->getId()]);

        return $rc;
}

sub removeBuild {
        my $self  = shift;
        my $build = shift;

        my $rc;
        $rc = $self->_doQuery("DELETE FROM build_ports WHERE Build_Id=?",
                [$build->getId()]);

        if (!$rc) {
                return $rc;
        }

        $rc = $self->_doQuery("DELETE FROM builds WHERE Build_Id=?",
                [$build->getId()]);

        return $rc;
}

sub findBuildsForJail {
        my $self  = shift;
        my $jail  = shift;
        my @jails = ();

        my @results;
        my $rc = $self->_doQueryHashRef("SELECT * FROM builds WHERE Jail_Id=?",
                \@results, $jail->getId());

        if (!$rc) {
                return undef;
        }

        @jails = $self->_newFromArray("Jail", @results);

        return @jails;
}

sub findBuildsForPortsTree {
        my $self       = shift;
        my $portstree  = shift;
        my @portstrees = ();

        my @results;
        my $rc =
            $self->_doQueryHashRef("SELECT * FROM builds WHERE Ports_Tree_Id=?",
                \@results, $portstree->getId());

        if (!$rc) {
                return undef;
        }

        @portstrees = $self->_newFromArray("PortsTree", @results);

        return @portstrees;
}

sub isPortInDS {
        my $self = shift;
        my $port = shift;

        my $rc =
            $self->_doQueryNumRows(
                "SELECT Port_Id FROM ports WHERE Port_Directory=?",
                $port->getDirectory());

        return (($rc > 0) ? 1 : 0);
}

sub isValidBuild {
        my $self      = shift;
        my $buildName = shift;

        my @results = $self->getBuilds({Build_Name => $buildName});

        if (!defined(@results)) {
                return 0;
        }

        if (scalar(@results)) {
                return 1;
        }

        return 0;
}

sub isValidJail {
        my $self     = shift;
        my $jailName = shift;

        my @results = $self->getJails({Jail_Name => $jailName});

        if (!defined(@results)) {
                return 0;
        }

        if (scalar(@results)) {
                return 1;
        }

        return 0;
}

sub isValidPortsTree {
        my $self          = shift;
        my $portsTreeName = shift;

        my @results = $self->getPortsTrees({Ports_Tree_Name => $portsTreeName});

        if (!defined(@results)) {
                return 0;
        }

        if (scalar(@results)) {
                return 1;
        }

        return 0;
}

sub isPortForBuild {
        my $self  = shift;
        my $port  = shift;
        my $build = shift;
        my $valid = 1;

        my @result;
        my $rc = $self->_doQueryHashRef(
                "SELECT Build_Name FROM builds WHERE Build_Id IN (SELECT Build_Id FROM build_ports WHERE Port_Id=?)",
                \@result, $port->getId()
        );

        foreach (@result) {
                if ($build->getName() eq $_->{'Build_Name'}) {
                        $valid = 1;
                        last;
                }
                $valid = 0;
        }

        return $valid;
}

sub getPortsTrees {
        my $self       = shift;
        my @params     = @_;
        my $condition  = "";
        my @portstrees = ();

        my @values = ();
        my @conds  = ();
        foreach my $param (@params) {

                # Each parameter makes up and OR portion of a query.  Within
                # each parameter is a hash reference that make up the AND
                # portion of the query.
                my @ands = ();
                foreach my $andcond (keys %{$param}) {
                        push @ands,   "$andcond=?";
                        push @values, $param->{$andcond};
                }
                push @conds, "(" . (join(" AND ", @ands)) . ")";
        }

        $condition = join(" OR ", @conds);

        my @results;
        my $query;
        if ($condition ne "") {
                $query = "SELECT * FROM ports_trees WHERE $condition";
        } else {
                $query = "SELECT * FROM ports_trees";
        }

        my $rc = $self->_doQueryHashRef($query, \@results, @values);

        if (!$rc) {
                return undef;
        }

        @portstrees = $self->_newFromArray("PortsTree", @results);

        return @portstrees;
}

sub getAllBuilds {
        my $self   = shift;
        my @builds = ();

        @builds = $self->getBuilds();

        return @builds;
}

sub getAllJails {
        my $self  = shift;
        my @jails = ();

        @jails = $self->getJails();

        return @jails;
}

sub getAllPortsTrees {
        my $self       = shift;
        my @portstrees = ();

        @portstrees = $self->getPortsTrees();

        return @portstrees;
}

sub getError {
        my $self = shift;

        return $self->{error};
}

sub _doQueryNumRows {
        my $self  = shift;
        my $class = ref $self;
        croak "Attempt to call private method" if ($class ne __PACKAGE__);
        my $query  = shift;
        my @params = @_;
        my $rows;

        my $sth;
        my $rc = $self->_doQuery($query, \@params, \$sth);

        if (!$rc) {
                return -1;
        }

        if ($sth->rows > -1) {
                $rows = $sth->rows;
        } else {
                my $all = $sth->fetchall_arrayref;
                $rows = scalar(@{$all});
        }

        $sth->finish;

        return $rows;
}

sub _doQueryHashRef {
        my $self  = shift;
        my $class = ref $self;
        croak "Attempt to call private method" if ($class ne __PACKAGE__);
        my $query  = shift;
        my $result = shift;
        my @params = @_;

        my $sth;
        my $rc = $self->_doQuery($query, \@params, \$sth);

        if (!$rc) {
                $result = undef;
                return 0;
        }

        my $hash_ref;
        while ($hash_ref = $sth->fetchrow_hashref) {
                push @{$result}, $hash_ref;
        }

        $sth->finish;

        1;
}

sub _doQuery {
        my $self  = shift;
        my $class = ref $self;
        croak "Attempt to call private method" if ($class ne __PACKAGE__);
        my $query  = shift;
        my $params = shift;
        my $sth    = shift;    # Optional

        my $_sth;              # This is the real statement handler.

        #print STDERR "XXX: query = $query\n";
        #print STDERR "XXX: values = " . (join(", ", @{$params})) . "\n";

        $_sth = $self->{'dbh'}->prepare($query);

        if (!$_sth) {
                $self->{'error'} = $_sth->error;
                return 0;
        }

        if (scalar(@{$params})) {
                $_sth->execute(@{$params});
        } else {
                $_sth->execute;
        }

        if (!$_sth) {
                $self->{'error'} = $_sth->error;
                return 0;
        }

        if (defined($sth)) {
                $$sth = $_sth;
        } else {
                $_sth->finish;
        }

        $self->{'error'} = undef;

        1;
}

sub _newFromArray {
        my $self  = shift;
        my $class = ref $self;
        croak "Attempt to call private method" if ($class ne __PACKAGE__);
        my $type    = shift;
        my @array   = @_;
        my @objects = ();

        foreach (@array) {
                my $obj = eval "new $type(\$_)";
                if (ref($obj) ne $type) {
                        return undef;
                }
                push @objects, $obj;
        }

        return @objects;
}

sub _addObject {
        my $self      = shift;
        my $object    = shift;
        my $objectRef = ref($object);

        croak "Unknown object type, $objectRef\n"
            unless defined($OBJECT_MAP{$objectRef});

        my $table      = $OBJECT_MAP{$objectRef};
        my $objectHash = $object->toHashRef();

        my $names    = join(",", keys(%{$objectHash}));
        my @values   = values(%{$objectHash});
        my $valueStr = join(",", (map { '?' } @values));

        my $rc =
            $self->_doQuery("INSERT INTO $table ($names) VALUES ($valueStr)",
                \@values);

        return $rc;
}

sub destroy {
        my $self = shift;

        $self->{error} = undef;
        $self->{dbh}->disconnect;
}

1;
