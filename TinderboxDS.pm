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
# $MCom: portstools/tinderbox/TinderboxDS.pm,v 1.38 2005/07/19 07:08:54 marcus Exp $
#

package TinderboxDS;

use strict;
use Port;
use Jail;
use PortsTree;
use BuildPortsQueue;
use Build;
use User;
use Host;
use TBConfig;
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
        "Port"            => "ports",
        "Jail"            => "jails",
        "BuildPortsQueue" => "build_ports_queue",
        "Build"           => "builds",
        "PortsTree"       => "ports_trees",
        "User"            => "users",
        "Host"            => "hosts",
        "TBConfig"        => "config",
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

        $self->{'dbh'} =
               DBI->connect($dsn, $DB_USER, $DB_PASS, {PrintError => 0})
            or croak "ERROR: Tinderbox DS: Unable to initialize datasource.";

        bless($self, $class);
        $self;
}

sub getDSVersion {
        my $self = shift;
        my $version;
        my $config;

        my @results;
        my $rc = $self->_doQuery("DESCRIBE config", []);

        if (!$rc) {
                return "1.X";
        }

        @results =
            $self->getObjects("TBConfig",
                {Config_Option_Name => '__DSVERSION__'});

        if (!@results) {
                return undef;
        }

        $config  = $results[0];
        $version = $config->getOptionValue();

        return $version;
}

sub defaultConfig {
        my $self      = shift;
        my $configlet = shift;
        my $host      = shift;
        croak "ERROR: Argument 2 not of type Host\n" if (ref($host) ne "Host");

        my $rc = $self->_doQuery(
                "DELETE FROM config WHERE Config_Option_Name LIKE ? AND Host_Id=?",
                [$configlet . '%', $host->getId()]
        );

        return $rc;
}

sub getConfig {
        my $self      = shift;
        my $configlet = shift;
        my $host      = shift;
        croak "ERROR: Argument 2 not of type Host\n"
            if (defined($host) && ref($host) ne "Host");
        my @config = ();
        my $hostid;

        if (defined($host)) {
                $hostid = $host->getHostId();
        } else {
                $hostid = -1;
        }

        if (defined($configlet)) {
                $configlet = uc $configlet;
                $configlet .= '_%';

                @config = $self->getObjects("TBConfig",
                        {Config_Option_Name => $configlet, Host_Id => $hostid});
        } else {
                @config = $self->getObjects("TBConfig", {Host_Id => $hostid});
        }

        return @config;
}

sub updateConfig {
        my $self      = shift;
        my $configlet = shift;
        my $host      = shift;
        croak "Argument 2 not of type Host\n"
            if (defined($host) && ref($host) ne "Host");
        my @config = @_;
        my $hostid;

        if (defined($host)) {
                $hostid = $host->getHostId();
        } else {
                $hostid = -1;
        }

        foreach my $conf (@config) {
                my $oname  = uc($configlet . '_' . $conf->getOptionName());
                my $ovalue = $conf->getOptionValue();
                my $rc;
                if (!defined($ovalue)) {
                        $ovalue = "";
                }

                if ($hostid > -1) {
                        $rc = $self->_doQuery(
                                "INSERT INTO config VALUES(?, ?, ?) ON DUPLICATE KEY UPDATE Config_Option_Value=?",
                                [$oname, $ovalue, $hostid, $ovalue]
                        );
                } else {
                        $rc = $self->_doQuery(
                                "UPDATE config SET Config_Option_Value=? WHERE Config_Option_Name=?",
                                [$ovalue, $oname]
                        );
                }

                if (!$rc) {
                        return $rc;
                }
        }

        return 1;
}

sub getAllPorts {
        my $self  = shift;
        my @ports = ();

        @ports = $self->getObjects("Port");

        return @ports;
}

sub isValidBuildPortsQueueId {
        my $self = shift;
        my $id   = shift;

        my $rc = $self->_doQueryNumRows(
                "SELECT Build_Ports_Queue_Id FROM build_ports_queue WHERE Build_Ports_Queue_Id=?",
                $id
        );

        return ($rc > 0) ? 1 : 0;
}

sub updateBuildPortsQueueEntryCompletionDate {
        my $self  = shift;
        my $entry = shift;
        croak "ERROR: Argument not of type BuildPortsQueue\n"
            if (ref($entry) ne "BuildPortsQueue");

        my $rc;

        if (!defined($entry->getCompletionDate())) {
                $rc = $self->_doQuery(
                        "UPDATE build_ports_queue SET Completion_Date=NOW() WHERE Build_Ports_Queue_Id=?",
                        [$entry->getId()]
                );
        } else {
                $rc = $self->_doQuery(
                        "UPDATE build_ports_queue SET Completion_Date=? WHERE Build_Ports_Queue_Id=?",
                        [$entry->getCompletionDate(), $entry->getId()]
                );
        }

        return $rc;
}

sub updateBuildPortsQueueEntryStatus {
        my $self   = shift;
        my $id     = shift;
        my $status = shift;

        my %status_hash = (
                ENQUEUED   => 1,
                PROCESSING => 1,
                SUCCESS    => 1,
                FAIL       => 1,
        );

        if (!defined($status_hash{$status})) {
                croak "ERROR: invalid status\n";
        }

        my $rc = $self->_doQuery(
                "UPDATE build_ports_queue SET Status=? WHERE Build_Ports_Queue_Id=?",
                [$status, $id]
        );

        return $rc;
}

sub moveBuildPortsQueueFromUserToUser {
        my $self   = shift;
        my $old_id = shift;
        my $new_id = shift;

        my $rc = $self->_doQuery(
                "UPDATE build_ports_queue
                    SET User_Id=?
                  WHERE User_Id=?",
                [$new_id, $old_id]
        );

        return $rc;

}

sub getBuildPortsQueueById {
        my $self = shift;
        my $id   = shift;

        my @results =
            $self->getObjects("BuildPortsQueue", {Build_Ports_Queue_Id => $id});

        if (!@results) {
                return undef;
        }

        return $results[0];
}

sub getBuildPortsQueueByKeys {
        my $self      = shift;
        my $build     = shift;
        my $directory = shift;
        my $host      = shift;
        croak "ERROR: Argument 1 not of type Host\n" if (ref($host) ne "Host");
        croak "ERROR: Argument 2 not of type Build\n"
            if (ref($build) ne "Build");

        my @results = $self->getObjects(
                "BuildPortsQueue",
                {
                        Build_Id       => $build->getId(),
                        Port_Directory => $directory,
                        Host_Id        => $host->getId()
                }
        );

        if (!@results) {
                return undef;
        }

        return $results[0];
}

sub getBuildPortsQueueByHost {
        my $self   = shift;
        my $host   = shift;
        my $status = shift;
        my @results;

        if ($status) {
                @results = $self->getObjects(
                        "BuildPortsQueue",
                        {
                                Host_Id => $host->getId(),
                                Status  => $status,
                                _ORDER_ =>
                                    "Priority ASC, Build_Ports_Queue_Id ASC"
                        }
                );
        } else {
                @results = $self->getObjects(
                        "BuildPortsQueue",
                        {
                                Host_Id => $host->getId(),
                                _ORDER_ =>
                                    "Priority ASC, Build_Ports_Queue_Id ASC"
                        }
                );
        }

        if (!@results) {
                return undef;
        }

        return @results;
}

sub reorgBuildPortsQueue {
        my $self = shift;
        my $host = shift;

        my $rc = $self->_doQuery(
                "DELETE FROM build_ports_queue WHERE Host_Id=? AND Enqueue_Date<=NOW()-25200 AND Status != 'ENQUEUED'",
                [$host->getId()]
        );

        return $rc;
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

        my @results = $self->getObjects("Port", {Port_Id => $id});

        if (!@results) {
                return undef;
        }

        return $results[0];
}

sub getPortByDirectory {
        my $self = shift;
        my $dir  = shift;

        my @results = $self->getObjects("Port", {Port_Directory => $dir});

        if (!@results) {
                return undef;
        }

        return $results[0];
}

sub getJailByName {
        my $self = shift;
        my $name = shift;

        my @results = $self->getObjects("Jail", {Jail_Name => $name});

        if (!@results) {
                return undef;
        }

        return $results[0];
}

sub getBuildById {
        my $self = shift;
        my $id   = shift;

        my @results = $self->getObjects("Build", {Build_Id => $id});

        if (!@results) {
                return undef;
        }

        return $results[0];
}

sub getHostByName {
        my $self = shift;
        my $name = shift;

        my @results = $self->getObjects("Host", {Host_Name => $name});

        if (!@results) {
                return undef;
        }

        return $results[0];
}

sub getBuildByName {
        my $self = shift;
        my $name = shift;

        my @results = $self->getObjects("Build", {Build_Name => $name});

        if (!@results) {
                return undef;
        }

        return $results[0];
}

sub getJailById {
        my $self = shift;
        my $id   = shift;

        my @results = $self->getObjects("Jail", {Jail_Id => $id});

        if (!@results) {
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

        my @results = $self->getObjects("PortsTree", {Ports_Tree_Id => $id});

        if (!@results) {
                return undef;
        }

        return $results[0];
}

sub getPortsTreeByName {
        my $self = shift;
        my $name = shift;

        my @results =
            $self->getObjects("PortsTree", {Ports_Tree_Name => $name});

        if (!@results) {
                return undef;
        }

        return $results[0];
}

sub getObjects {
        my $self      = shift;
        my $type      = shift;
        my @params    = @_;
        my $condition = "";
        my @objects   = ();
        my $order     = "";
        my $orderseen = 0;

        my @values = ();
        my @conds  = ();

        my $table = $OBJECT_MAP{$type};

        croak "ERROR: Unknown object type, $type\n"
            unless defined($table);
        foreach my $param (@params) {

                # Each parameter makes up and OR portion of a query.  Within
                # each parameter is a hash reference that make up the AND
                # portion of the query.
                my @ands = ();
                foreach my $andcond (keys %{$param}) {
                        if ($andcond eq "_ORDER_" && !$orderseen) {
                                $order = "ORDER BY " . $param->{$andcond};
                                $orderseen++;
                        } elsif ($andcond eq "_ORDER_" && $orderseen) {
                                carp
                                    "WARN: _ORDER_ can only be specified once\n";
                        } else {
                                if ($param->{$andcond} =~ /[^\\]%/) {
                                        push @ands, "$andcond LIKE ?";
                                } else {
                                        push @ands, "$andcond=?";
                                }
                                push @values, $param->{$andcond};
                        }
                }
                push @conds, "(" . (join(" AND ", @ands)) . ")";
        }

        $condition = join(" OR ", @conds);

        my @results;
        my $query;
        if ($condition ne "") {
                $query = "SELECT * FROM $table WHERE $condition";
        } else {
                $query = "SELECT * FROM $table";
        }

        $query .= $order;

        my $rc = $self->_doQueryHashRef($query, \@results, @values);

        if (!$rc) {
                return undef;
        }

        @objects = $self->_newFromArray($type, @results);

        return @objects;
}

sub addBuildPortsQueueEntry {
        my $self      = shift;
        my $build     = shift;
        my $directory = shift;
        my $host      = shift;
        my $priority  = shift;
        my $user      = shift;
        croak "ERROR: Argument 1 not of type Host\n" if (ref($host) ne "Host");
        croak "ERROR: Argument 2 not of type Build\n"
            if (ref($build) ne "Build");

        my $rc = $self->_doQuery(
                "INSERT INTO build_ports_queue
                    ( Build_Id, User_Id, Port_Directory, Priority, Host_Id )
                 VALUES
                     ( ?, ?, ?, ?, ? )",
                [$build->getId(), $user, $directory, $priority, $host->getId()]
        );

        return $rc;
}

sub addHost {
        my $self = shift;
        my $host = shift;
        my $bCls = (ref($host) eq "REF") ? $$host : $host;

        my $rc = $self->_addObject($bCls);

        if (ref($host) eq "REF") {
                $$host = $self->getHostByName($bCls->getName());
        }

        return $rc;
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

sub updateBuildUser {
        my $self         = shift;
        my $build        = shift;
        my $user         = shift;
        my $onCompletion = shift;
        my $onError      = shift;
        croak "ERROR: Argument 1 is not of type build\n"
            if (ref($build) ne "Build");
        croak "ERROR: Argument 2 is not of type user\n"
            if (ref($user) ne "User");

        if (!defined($onCompletion)) {
                $onCompletion = 0;
        }

        if (!defined($onError)) {
                $onError = 0;
        }

        my $rc = $self->_doQuery(
                "UPDATE build_users SET Email_On_Completion=?, Email_On_Error=? WHERE Build_Id=? AND User_Id=?",
                [$onCompletion, $onError, $build->getId(), $user->getId()]
        );

        return $rc;
}

sub updateUser {
        my $self = shift;
        my $user = shift;
        my $uCls = (ref($user) eq "REF") ? $$user : $user;

        my $rc = $self->_doQuery(
                "UPDATE users set User_Email=?, User_Password=PASSWORD(?), User_Www_Enabled=? WHERE User_Id=?",
                [
                        $uCls->getEmail(),      $uCls->getPassword(),
                        $uCls->getWwwEnabled(), $uCls->getId()
                ]
        );

        if (ref($user) eq "REF") {
                $$user = $self->getUserByName($uCls->getName());
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

sub updateJail {
        my $self = shift;
        my $jail = shift;
        croak "ERROR: Argument not of type Jail\n" if (ref($jail) ne "Jail");

        my $rc = $self->_doQuery(
                "UPDATE jails SET Jail_Name=?, Jail_Tag=?, Jail_Update_Cmd=?, Jail_Description=?, Jail_Src_Mount=? WHERE Jail_Id=?",
                [
                        $jail->getName(),      $jail->getTag(),
                        $jail->getUpdateCmd(), $jail->getDescription(),
                        $jail->getSrcMount(),  $jail->getId()
                ]
        );

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
                UNKNOWN   => 0,
                SUCCESS   => 1,
                BROKEN    => 1,
                LEFTOVERS => 1,
                FAIL      => 1,
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

sub updatePortsTree {
        my $self      = shift;
        my $portstree = shift;
        croak "ERROR: Argument not of type PortsTree\n"
            if (ref($portstree) ne "PortsTree");

        my $rc = $self->_doQuery(
                "UPDATE ports_trees SET Ports_Tree_Name=?, Ports_Tree_Description=?, Ports_Tree_Update_Cmd=?, Ports_Tree_CVSweb_URL=?, Ports_Tree_Ports_Mount=? WHERE Ports_Tree_Id=?",
                [
                        $portstree->getName(),
                        $portstree->getDescription(),
                        $portstree->getUpdateCmd(),
                        $portstree->getCVSwebURL(),
                        $portstree->getPortsMount(),
                        $portstree->getId()
                ]
        );

        return $rc;
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

sub getBuildCompletionUsers {
        my $self  = shift;
        my $build = shift;
        croak "ERROR: Argument not of type build\n" if (ref($build) ne "Build");

        my @users = $self->_getBuildUsers($build, "Email_On_Completion");

        return @users;
}

sub getBuildErrorUsers {
        my $self  = shift;
        my $build = shift;
        croak "ERROR: Argument not of type build\n" if (ref($build) ne "Build");

        my @addrs = $self->_getBuildUsers($build, "Email_On_Error");

        return @addrs;
}

sub _getBuildUsers {
        my $self  = shift;
        my $build = shift;
        my $field = shift;
        my @users;

        my @results = ();
        my $rc;
        if (defined($field)) {
                $rc = $self->_doQueryHashRef(
                        "SELECT * FROM  users WHERE User_Id IN (SELECT User_Id FROM build_users WHERE Build_Id=? AND $field=1)",
                        \@results, $build->getId()
                );
        } else {
                $rc = $self->_doQueryHashRef(
                        "SELECT * FROM  users WHERE User_Id IN (SELECT User_Id FROM build_users WHERE Build_Id=?)",
                        \@results, $build->getId()
                );
        }

        if (!$rc) {
                return undef;
        }

        @users = $self->_newFromArray("User", @results);

        return @users;

}

sub isValidUser {
        my $self     = shift;
        my $username = shift;

        my $rc =
            $self->_doQueryNumRows(
                "SELECT User_Id FROM users WHERE User_Name=?", $username);

        return ($rc > 0) ? 1 : 0;
}

sub isUserForBuild {
        my $self  = shift;
        my $user  = shift;
        my $build = shift;
        croak "ERROR: Argument 1 is not of type user\n"
            if (ref($user) ne "User");
        croak "ERROR: Argument 2 is not of type build\n"
            if (ref($build) ne "Build");

        my $rc = $self->_doQueryNumRows(
                "SELECT Build_User_Id FROM build_users WHERE Build_Id=? AND User_Id=?",
                $build->getId(), $user->getId()
        );

        return ($rc > 0) ? 1 : 0;
}

sub getUserById {
        my $self   = shift;
        my $userid = shift;

        my @results = $self->getObjects("User", {User_Id => $userid});

        if (!@results) {
                return undef;
        }

        return $results[0];
}

sub getUserByName {
        my $self     = shift;
        my $username = shift;

        my @results = $self->getObjects("User", {User_Name => $username});

        if (!@results) {
                return undef;
        }

        return $results[0];
}

sub getAllUsers {
        my $self  = shift;
        my @users = ();

        @users = $self->getObjects("User");

        return @users;
}

sub getUsersForBuild {
        my $self  = shift;
        my $build = shift;
        croak "Argument is not of type build\n" if (ref($build) ne "Build");
        my @users = ();

        @users = $self->_getBuildUsers($build, undef);

        return @users;
}

sub getWwwAdmin {
        my $self = shift;

        my @results;
        my $rc = $self->_doQueryHashRef(
                "SELECT users.* FROM users,user_permissions WHERE users.User_Id=user_permissions.User_Id AND user_permissions.User_Permission_Object_Type='users' AND user_permissions.User_Permission_Object_Id=users.User_Id AND user_permissions.User_Permission=?",
                \@results, 1
        );

        if (!$rc) {
                return undef;
        }

        my @user = $self->_newFromArray("User", @results);

        return $user[0];

}

sub setWwwAdmin {
        my $self = shift;
        my $user = shift;

        my $rc = $self->_doQueryNumRows(
                'SELECT User_Id FROM user_permissions where User_Permission=?',
                1
        );

        if (!$rc) {
                $rc = $self->_doQuery(
                        'INSERT INTO user_permissions (User_Id,Host_Id,User_Permission_Object_Type,User_Permission_Object_Id,User_Permission) VALUES (?, ? , ?, ?, ?)',
                        [$user->getId(), '0', 'users', $user->getId(), 1]
                );
        } else {
                $rc = $self->_doQuery(
                        'UPDATE user_permissions SET User_Id=?, User_Permission_Object_Id=? WHERE User_Permission=1',
                        [$user->getId(), $user->getId()]
                );
        }

        return $rc;
}

sub addUser {
        my $self = shift;
        my $user = shift;
        my $uCls = (ref($user) eq "REF") ? $$user : $user;

        my $rc = $self->_doQuery(
                "INSERT INTO users (User_Name,User_Email,User_Password,User_Www_Enabled) VALUES (?, ?, PASSWORD(?), ?)",
                [
                        $uCls->getName(),     $uCls->getEmail(),
                        $uCls->getPassword(), $uCls->getWwwEnabled()
                ]
        );

        if (ref($user) eq "REF") {
                $$user = $self->getUserByName($uCls->getName());
        }

        return $rc;
}

sub addUserForBuild {
        my $self         = shift;
        my $user         = shift;
        my $build        = shift;
        my $onCompletion = shift;
        my $onError      = shift;
        croak "ERROR: Argument 1 is not of type user\n"
            if (ref($user) ne "User");
        croak "ERROR: Argument 2 is not of type build\n"
            if (ref($build) ne "Build");

        if (!defined($onCompletion)) {
                $onCompletion = 0;
        }

        if (!defined($onError)) {
                $onError = 0;
        }

        my $rc = $self->_doQuery(
                "INSERT into build_users (Build_Id, User_Id, Email_On_Completion, Email_On_Error) VALUES (?, ?, ?, ?)",
                [$build->getId(), $user->getId(), $onCompletion, $onError]
        );

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

sub removeHost {
        my $self = shift;
        my $host = shift;

        my $rc;
        $rc = $self->_doQuery("DELETE FROM hosts WHERE Host_Id=?",
                [$host->getId()]);

        return $rc;
}

sub removeBuildPortsQueue {
        my $self = shift;
        my $host = shift;
        croak "ERROR: Argument not of type Host\n" if (ref($host) ne "Host");

        my $rc;
        $rc = $self->_doQuery("DELETE FROM build_ports_queue WHERE Host_Id=?",
                [$host->getId()]);

        return $rc;
}

sub removeBuildPortsQueueEntry {
        my $self  = shift;
        my $entry = shift;

        my $rc;
        $rc =
            $self->_doQuery(
                "DELETE FROM build_ports_queue WHERE Build_Ports_Queue_Id=?",
                [$entry->getId()]);

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

sub removeUser {
        my $self = shift;
        my $user = shift;
        croak "ERROR: Argument 1 is not of type user\n"
            if (ref($user) ne "User");

        my $rc = $self->_doQuery("DELETE FROM build_users WHERE User_Id=?",
                [$user->getId()]);

        if (!$rc) {
                return $rc;
        }

        $rc = $self->_doQuery("DELETE FROM users WHERE User_Id=?",
                [$user->getId()]);

        return $rc;
}

sub removeUserForBuild {
        my $self  = shift;
        my $user  = shift;
        my $build = shift;
        croak "ERROR: Argument 1 is not of type user\n"
            if (ref($user) ne "User");
        croak "ERROR: Argument 2 is not nof type build\n"
            if (ref($build) ne "Build");

        my $rc =
            $self->_doQuery(
                "DELETE FROM build_users WHERE Build_Id=? AND User_Id=?",
                [$build->getId(), $user->getId()]);

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

        my $rc =
            $self->_doQuery("DELETE FROM ports_trees WHERE Ports_Tree_Id=?",
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

        $rc = $self->_doQuery("DELETE FROM build_users WHERE Build_Id=?",
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

sub isValidHost {
        my $self     = shift;
        my $hostname = shift;

        my @results = $self->getObjects("Host", {Host_Name => $hostname});

        if (!@results) {
                return 0;
        }

        if (scalar(@results)) {
                return 1;
        }

        return 0;
}

sub isValidBuild {
        my $self      = shift;
        my $buildName = shift;

        my @results = $self->getObjects("Build", {Build_Name => $buildName});

        if (!@results) {
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

        my @results = $self->getObjects("Jail", {Jail_Name => $jailName});

        if (!@results) {
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

        my @results =
            $self->getObjects("PortsTree", {Ports_Tree_Name => $portsTreeName});

        if (!@results) {
                return 0;
        }

        if (scalar(@results)) {
                return 1;
        }

        return 0;
}

sub isPortInBuild {
        my $self  = shift;
        my $port  = shift;
        my $build = shift;

        my $rc = $self->_doQueryNumRows(
                "SELECT Port_Id FROM build_ports WHERE Port_Id=? AND Build_Id=?",
                $port->getId(), $build->getId()
        );

        return (($rc > 0) ? 1 : 0);
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

sub getAllBuilds {
        my $self   = shift;
        my @builds = ();

        @builds = $self->getObjects("Build");

        return @builds;
}

sub getAllJails {
        my $self  = shift;
        my @jails = ();

        @jails = $self->getObjects("Jail");

        return @jails;
}

sub getAllPortsTrees {
        my $self       = shift;
        my @portstrees = ();

        @portstrees = $self->getObjects("PortsTree");

        return @portstrees;
}

sub getError {
        my $self = shift;

        return $self->{error};
}

sub _doQueryNumRows {
        my $self  = shift;
        my $class = ref $self;
        croak "ERROR: Attempt to call private method"
            if ($class ne __PACKAGE__);
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
        croak "ERROR: Attempt to call private method"
            if ($class ne __PACKAGE__);
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
        croak "ERROR: Attempt to call private method"
            if ($class ne __PACKAGE__);
        my $query  = shift;
        my $params = shift;
        my $sth    = shift;    # Optional
        my $rc;

        my $_sth;              # This is the real statement handler.

        #print STDERR "XXX: query = $query\n";
        #print STDERR "XXX: values = " . (join(", ", @{$params})) . "\n";

        $_sth = $self->{'dbh'}->prepare($query);

        if (!$_sth) {
                $self->{'error'} = $self->{'dbh'}->errstr;
                return 0;
        }

        if (scalar(@{$params})) {
                $rc = $_sth->execute(@{$params});
        } else {
                $rc = $_sth->execute;
        }

        if (!$rc) {
                $self->{'error'} = $_sth->errstr;
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
        croak "ERROR: Attempt to call private method"
            if ($class ne __PACKAGE__);
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

        croak "ERROR: Unknown object type, $objectRef\n"
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

sub getTime {
        my $self      = shift;
        my $localtime = shift;

        my @time = ();
        if (!defined($localtime)) {
                @time = localtime;
        } else {
                @time = localtime($localtime);
        }

        my $year = $time[5] + 1900;
        my $mon  = $time[4] + 1;

        return "$year-$mon-$time[3] $time[2]:$time[1]:$time[0]";
}

sub getPackageSuffix {
        my $self = shift;
        my $jail = shift;
        croak "ERROR: Argument not of type Jail\n" if (ref($jail) ne "Jail");

        if (substr($jail->getName(), 0, 1) == "4") {
                return ".tgz";
        }

        return ".tbz";
}

sub isLogCurrent {
        my $self  = shift;
        my $build = shift;
        my $log   = shift;
        croak "ERROR: Argument not of type Build\n" if (ref($build) ne "Build");

        my $rc = $self->_doQueryNumRows(
                "SELECT Build_Port_Id FROM build_ports WHERE Build_Id=? AND Last_Built_Version=?",
                $build->getId(),
                substr($log, 0, -4)
        );

        return ($rc > 0) ? 1 : 0;
}

1;
