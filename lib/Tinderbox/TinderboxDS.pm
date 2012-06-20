#-
# Copyright (c) 2004-2010 FreeBSD GNOME Team <freebsd-gnome@FreeBSD.org>
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
# $MCom: portstools/tinderbox/lib/Tinderbox/TinderboxDS.pm,v 1.101 2012/06/20 20:47:42 ade Exp $
#

package Tinderbox::TinderboxDS;

use strict;
use Tinderbox::Port;
use Tinderbox::Jail;
use Tinderbox::PortsTree;
use Tinderbox::Build;
use Tinderbox::BuildPortsQueue;
use Tinderbox::User;
use Tinderbox::Config;
use Tinderbox::PortFailPattern;
use Tinderbox::PortFailReason;
use Tinderbox::Hook;
use DBI;
use Carp;
use Digest::MD5 qw(md5_hex);
use POSIX qw(strftime);
use vars qw(
    $DB_DRIVER
    $DB_HOST
    $DB_NAME
    $DB_USER
    $DB_PASS
    $DBI_TYPE
    $PKG_PREFIX
    %OBJECT_MAP
);

$PKG_PREFIX = 'Tinderbox::';
%OBJECT_MAP = (
        "Port"            => "ports",
        "Jail"            => "jails",
        "Build"           => "builds",
        "BuildPortsQueue" => "build_ports_queue",
        "PortsTree"       => "ports_trees",
        "User"            => "users",
        "Config"          => "config",
        "PortFailReason"  => "port_fail_reasons",
        "PortFailPattern" => "port_fail_patterns",
        "Hook"            => "hooks",
);

require "ds.ph";

sub new {
        my ($that, @args) = @_;
        my $class = ref($that) || $that;

        my $self = {
                dbh   => undef,
                error => undef,
                now_fn => undef,
        };

        if (!$DBI_TYPE) {
                $DBI_TYPE = 'database';
        }

        my $dsn = "";

        if ($DB_DRIVER eq "SQLite") {
                $dsn = "DBI:$DB_DRIVER:$DB_NAME";
                $self->{'now_fn'} = "DATETIME(\'now\',\'localtime\')";
        } else {
                $dsn = "DBI:$DB_DRIVER:$DBI_TYPE=$DB_NAME";
                if ($DB_HOST) {
                        $dsn .= ";host=$DB_HOST";
                }
                $self->{'now_fn'} = "NOW()";
        }

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
        my @tables = map { $_ =~ s/.*\.//; $_ } $self->{'dbh'}->tables();
        my @matches = grep { /\bconfig\b/ } @tables;

        if (!scalar @matches) {
                return "1.X";
        }

        @results =
            $self->getObjects("Config",
                {config_option_name => '__DSVERSION__'});

        if (!@results) {
                return undef;
        }

        $config  = $results[0];
        $version = $config->getOptionValue();

        return $version;
}

sub verifyType {
        my $self = shift;
        my $argn = shift;
        my $what = shift;
        my $type = shift;

        return if (!defined($what));

        my $ref = ref($what);
        return if ($ref eq "Tinderbox::$type");

        croak "ERROR: Argument $argn not of type $what ($ref)\n";
}

sub defaultConfig {
        my $self      = shift;
        my $configlet = shift;

        my $rc = $self->_doQuery(
                "DELETE FROM config WHERE config_option_name LIKE ?",
                $configlet);

        return $rc;
}

sub getConfig {
        my $self      = shift;
        my $configlet = shift;

        my @config = ();
        my @results;
        my $rc;

        if (defined($configlet)) {
                $configlet = uc $configlet;
                $configlet .= '_%';
        } else {
                $configlet = '%';
        }

        $rc = $self->_doQueryHashRef(
                "SELECT * FROM config WHERE config_option_name LIKE ?",
                \@results, $configlet);

        if (!$rc) {
                return ();
        }

        @config = $self->_newFromArray("Config", @results);

        return @config;
}

sub updateConfig {
        my $self      = shift;
        my $configlet = shift;
        my @config    = @_;

        foreach my $conf (@config) {
                my $oname  = uc($configlet . '_' . $conf->getOptionName());
                my $ovalue = $conf->getOptionValue();
                my $rc;
                if (!defined($ovalue)) {
                        $ovalue = "";
                }

                my @results =
                    $self->getObjects("Config", {config_option_name => $oname});

                my ($query, $values);
                if (!@results) {
                        $query = "INSERT INTO config VALUES(?, ?)";
                        $values = [$oname, $ovalue];
                } else {
                        $query =
                            "UPDATE config SET config_option_value=? WHERE config_option_name=?";
                        $values = [$ovalue, $oname];
                }
                $rc = $self->_doQuery($query, $values);

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

sub getAllHooks {
        my $self  = shift;
        my @hooks = ();

        @hooks = $self->getObjects("Hook");

        return @hooks;
}

sub isValidBuildPortsQueueId {
        my $self = shift;
        my $id   = shift;

        my $queue = $self->getBuildPortsQueueById($id);

        return (defined($queue));
}

sub updateBuildPortsQueueEntryCompletionDate {
        my $self  = shift;
        my $entry = shift;
        my $rc;

        $self->verifyType(1, $entry, 'BuildPortsQueue');

        if (!defined($entry->getCompletionDate())) {
                $rc = $self->_doQuery(
                        "UPDATE build_ports_queue SET completion_date=$self->{'now_fn'} WHERE build_ports_queue_id=?",
                        [$entry->getId()]
                );
        } else {
                $rc = $self->_doQuery(
                        "UPDATE build_ports_queue SET completion_date=? WHERE build_ports_queue_id=?",
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
                "UPDATE build_ports_queue SET status=? WHERE build_ports_queue_id=?",
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
                    SET user_id=?
                  WHERE user_id=?",
                [$new_id, $old_id]
        );

        return $rc;

}

sub getBuildPortsQueueById {
        my $self = shift;
        my $id   = shift;

        my @results =
            $self->getObjects("BuildPortsQueue", {build_ports_queue_id => $id});

        if (!@results) {
                return undef;
        }

        return $results[0];
}

sub getBuildPortsQueueByKeys {
        my $self      = shift;
        my $build     = shift;
        my $directory = shift;

        $self->verifyType(1, $build, 'Build');

        my @results = $self->getObjects(
                "BuildPortsQueue",
                {
                        build_id       => $build->getId(),
                        port_directory => $directory
                }
        );

        if (!@results) {
                return undef;
        }

        return $results[0];
}

sub getBuildPortsQueueByStatus {
        my $self   = shift;
        my $status = shift;
        my @results;

        if ($status) {
                @results = $self->getObjects(
                        "BuildPortsQueue",
                        {
                                status => $status,
                                _ORDER_ =>
                                    "priority ASC, build_ports_queue_id ASC"
                        }
                );
        } else {
                @results =
                    $self->getObjects("BuildPortsQueue",
                        {_ORDER_ => "priority ASC, build_ports_queue_id ASC"});
        }

        if (!@results) {
                return ();
        }

        return @results;
}

sub reorgBuildPortsQueue {
        my $self = shift;

        my $enq_time = time - 25200;
        my $enq_sql = strftime("%Y-%m-%d %H:%M:%S", localtime($enq_time));

        my $rc = $self->_doQuery(
                "DELETE FROM build_ports_queue WHERE enqueue_date<=? AND status != 'ENQUEUED'",
                [$enq_sql]
        );

        return $rc;
}

sub getPortsForBuild {
        my $self  = shift;
        my $build = shift;
        my @ports;

        my @results;
        my $rc = $self->_doQueryHashRef(
                "SELECT * FROM ports WHERE port_id IN (SELECT port_id FROM build_ports WHERE build_id=?)",
                \@results, $build->getId()
        );

        if (!$rc) {
                return ();
        }

        @ports = $self->_newFromArray("Port", @results);

        return @ports;
}

sub getPortById {
        my $self = shift;
        my $id   = shift;

        my @results = $self->getObjects("Port", {port_id => $id});

        if (!@results) {
                return undef;
        }

        return $results[0];
}

sub getPortByDirectory {
        my $self = shift;
        my $dir  = shift;

        my @results = $self->getObjects("Port", {port_directory => $dir});

        if (!@results) {
                return undef;
        }

        return $results[0];
}

sub getJailByName {
        my $self = shift;
        my $name = shift;

        my @results = $self->getObjects("Jail", {jail_name => $name});

        if (!@results) {
                return undef;
        }

        return $results[0];
}

sub getHookByName {
        my $self = shift;
        my $name = shift;

        my @results = $self->getObjects("Hook", {hook_name => $name});

        if (!@results) {
                return undef;
        }

        return $results[0];
}

sub getBuildById {
        my $self = shift;
        my $id   = shift;

        my @results = $self->getObjects("Build", {build_id => $id});

        if (!@results) {
                return undef;
        }

        return $results[0];
}

sub getBuildByName {
        my $self = shift;
        my $name = shift;

        my @results = $self->getObjects("Build", {build_name => $name});

        if (!@results) {
                return undef;
        }

        return $results[0];
}

sub getPortFailReasonByTag {
        my $self = shift;
        my $tag  = shift;

        my @results =
            $self->getObjects("PortFailReason", {port_fail_reason_tag => $tag});

        if (!@results) {
                return undef;
        }

        return $results[0];
}

sub getPortFailPatternById {
        my $self = shift;
        my $id   = shift;

        my @results =
            $self->getObjects("PortFailPattern", {port_fail_pattern_id => $id});

        if (!@results) {
                return undef;
        }

        return $results[0];
}

sub getJailById {
        my $self = shift;
        my $id   = shift;

        my @results = $self->getObjects("Jail", {jail_id => $id});

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

        my @results = $self->getObjects("PortsTree", {ports_tree_id => $id});

        if (!@results) {
                return undef;
        }

        return $results[0];
}

sub getPortsTreeByName {
        my $self = shift;
        my $name = shift;

        my @results =
            $self->getObjects("PortsTree", {ports_tree_name => $name});

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
                                $order = " ORDER BY " . $param->{$andcond};
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
                if (@ands) {
                        push @conds, "(" . (join(" AND ", @ands)) . ")";
                }
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
                return ();
        }

        @objects = $self->_newFromArray($type, @results);

        return @objects;
}

sub addBuildPortsQueueEntry {
        my $self      = shift;
        my $build     = shift;
        my $directory = shift;
        my $priority  = shift;
        my $user      = shift;

        $self->verifyType(1, $build, 'Build');

        my $rc = $self->_doQuery(
                "INSERT INTO build_ports_queue
                    ( build_id, user_id, port_directory, priority, email_on_completion, enqueue_date )
                 VALUES
                     ( ?, ?, ?, ?, '0', $self->{'now_fn'} )",
                [$build->getId(), $user, $directory, $priority]
        );

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

sub addDependencyForPort {
        my $self    = shift;
        my $port    = shift;
        my $build   = shift;
        my $deptype = shift;
        my $dep     = shift;

        $self->verifyType(1, $port,  'Port');
        $self->verifyType(2, $build, 'Build');
        $self->verifyType(4, $dep,   'Port');

        my @results;
        my $rc = $self->_doQueryHashRef(
                "SELECT build_port_id FROM build_ports WHERE build_id=? AND port_id=?",
                \@results, $build->getId(), $port->getId()
        );
        if (!$rc) {
                return $rc;
        }

        my $bp_id = $results[0]->{'build_port_id'};

        $rc = $self->_doQuery(
                "INSERT INTO port_dependencies (build_port_id, port_id, dependency_type) VALUES (?, ?, ?)",
                [$bp_id, $dep->getId(), $deptype]
        );

        return $rc;
}

sub clearDependenciesForPort {
        my $self    = shift;
        my $port    = shift;
        my $build   = shift;
        my $deptype = shift;

        $self->verifyType(1, $port,  'Port');
        $self->verifyType(2, $build, 'Build');

        my @results;
        my $rc = $self->_doQueryHashRef(
                "SELECT build_port_id FROM build_ports WHERE build_id=? AND port_id=?",
                \@results, $build->getId(), $port->getId()
        );
        if (!$rc) {
                return $rc;
        }

        my $bp_id = $results[0]->{'build_port_id'};

        my @params = ($bp_id);
        my $query  = "DELETE FROM port_dependencies WHERE build_port_id=?";

        if (defined($deptype)) {
                $query .= " AND dependency_type=?";
                push @params, $deptype;
        }

        $rc = $self->_doQuery($query, \@params);

        return $rc;
}

sub getDependenciesForPort {
        my $self    = shift;
        my $port    = shift;
        my $build   = shift;
        my $deptype = shift;

        $self->verifyType(1, $port,  'Port');
        $self->verifyType(2, $build, 'Build');

        my @results;
        my $rc = $self->_doQueryHashRef(
                "SELECT build_port_id FROM build_ports WHERE build_id=? AND port_id=?",
                \@results, $build->getId(), $port->getId()
        );
        if (!$rc) {
                return undef;
        }

        my $bp_id = $results[0]->{'build_port_id'};

        @results = ();
        my @params = ($bp_id);
        my $query =
            "SELECT port_id FROM port_dependencies WHERE build_port_id=?";

        if (defined($deptype)) {
                $query .= " AND dependency_type=?";
                push @params, $deptype;
        }

        $rc = $self->_doQueryHashRef($query, \@results, @params);
        if (!$rc) {
                return undef;
        }

        my @deps = ();
        foreach my $result (@results) {
                my $pCls = $self->getPortById($result->{'port_id'});
                push @deps, $pCls if (defined($pCls));
        }

        return @deps;
}

sub addPortFailPattern {
        my $self    = shift;
        my $pattern = shift;
        my $pCls    = (ref($pattern) eq "REF") ? $$pattern : $pattern;

        my $rc = $self->_addObject($pCls);

        if (ref($pattern) eq "REF") {
                $$pattern = $self->getPortFailPatternById($pCls->getId());
        }

        return $rc;
}

sub addPortFailReason {
        my $self   = shift;
        my $reason = shift;
        my $rCls   = (ref($reason) eq "REF") ? $$reason : $reason;

        my $rc = $self->_addObject($rCls);

        if (ref($reason) eq "REF") {
                $$reason = $self->getPortFailReasonByTag($rCls->getTag());
        }

        return $rc;
}

sub updateBuildUser {
        my $self         = shift;
        my $build        = shift;
        my $user         = shift;
        my $onCompletion = shift;
        my $onError      = shift;

        $self->verifyType(1, $build, 'Build');
        $self->verifyType(2, $user,  'User');

        if (!defined($onCompletion)) {
                $onCompletion = 0;
        }

        if (!defined($onError)) {
                $onError = 0;
        }

        my $rc = $self->_doQuery(
                "UPDATE build_users SET email_on_completion=?, email_on_error=? WHERE build_id=? AND user_id=?",
                [$onCompletion, $onError, $build->getId(), $user->getId()]
        );

        return $rc;
}

sub updateUser {
        my $self = shift;
        my $user = shift;
        my $uCls = (ref($user) eq "REF") ? $$user : $user;
        my $hashPass;

        $hashPass = md5_hex($uCls->getPassword());

        my $rc = $self->_doQuery(
                "UPDATE users set user_email=?, user_password=?, user_www_enabled=? WHERE user_id=?",
                [
                        $uCls->getEmail(),      $hashPass,
                        $uCls->getWwwEnabled(), $uCls->getId()
                ]
        );

        if (ref($user) eq "REF") {
                $$user = $self->getUserByName($uCls->getName());
        }

        return $rc;
}

sub updatePortFailReason {
        my $self   = shift;
        my $reason = shift;
        my $rCls   = (ref($reason) eq "REF") ? $$reason : $reason;

        my $rc = $self->_doQuery(
                "UPDATE port_fail_reasons SET port_fail_reason_type=?, port_fail_reason_descr=? WHERE port_fail_reason_tag=?",
                [$rCls->getType(), $rCls->getDescr(), $rCls->getTag()]
        );

        if (ref($reason) eq "REF") {
                $$reason = $self->getPortFailReasonByTag($rCls->getTag());
        }

        return $rc;
}

sub updatePort {
        my $self = shift;
        my $port = shift;
        my $pCls = (ref($port) eq "REF") ? $$port : $port;

        my $rc = $self->_doQuery(
                "UPDATE ports SET port_name=?, port_comment=?, port_maintainer=? WHERE port_id=?",
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

        $self->verifyType(1, $jail, 'Jail');

        my $rc = $self->_doQuery(
                "UPDATE jails SET jail_name=?, jail_tag=?, jail_update_cmd=?, jail_description=?, jail_src_mount=? WHERE jail_id=?",
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

        $self->verifyType(1, $jail, 'Jail');

        my $rc;
        if ($jail->getLastBuilt()) {
                my $last_built = $jail->getLastBuilt();
                $rc = $self->_doQuery(
                        "UPDATE jails SET jail_last_built=? WHERE jail_id=?",
                        [$last_built, $jail->getId()]);
        } else {
                $rc = $self->_doQuery(
                        "UPDATE jails SET jail_last_built=$self->{'now_fn'} WHERE jail_id=?",
                        [$jail->getId()]
                );
        }

        return $rc;
}

sub updatePortLastBuilt {
        my $self  = shift;
        my $port  = $_[0];
        my $build = $_[1];
        my $query;
        my $rc;
        my @results;

        $self->verifyType(1, $port,  'Port');
        $self->verifyType(2, $build, 'Build');

        if ($DB_DRIVER eq 'mysql') {
                $query =
                    'SELECT UNIX_TIMESTAMP(NOW()) - UNIX_TIMESTAMP(build_last_updated) AS d FROM builds WHERE build_id=?';
        } elsif ($DB_DRIVER eq 'Pg') {
                $query =
                    "SELECT DATE_PART('EPOCH', NOW()) - DATE_PART('EPOCH', build_last_updated) AS d FROM builds WHERE build_id=?";
        } else {
                $query =
                    "SELECT strftime('%s', 'now', 'localtime') - strftime('%s', build_last_updated) AS d FROM builds WHERE build_id=?";
        }

        $rc = $self->_doQueryHashRef($query, \@results, $build->getId());

        my $d = int($results[0]->{'d'});

        $rc = $self->_doQuery(
                "UPDATE build_ports SET last_run_duration=? WHERE port_id=? AND build_id=?",
                [$d, $port->getId(), $build->getId()]
        );
        if (!$rc) {
                return $rc;
        }

        return $self->updatePortLastBuilts(@_, "last_built");
}

sub updatePortLastSuccessfulBuilt {
        my $self = shift;
        return $self->updatePortLastBuilts(@_, "last_successful_built");
}

sub updatePortLastFailReason {
        my $self = shift;
        return $self->updatePortLastBuilts(@_, "last_fail_reason");
}

sub updatePortLastFailedDep {
        my $self = shift;
        return $self->updatePortLastBuilts(@_, "last_failed_dependency");
}

sub updatePortTotalSize {
        my $self = shift;
        return $self->updatePortLastBuilts(@_, "total_size");
}

sub updatePortLastBuilts {
        my $self       = shift;
        my $port       = shift;
        my $build      = shift;
        my $last_built = shift;
        my $column     = shift;

        $self->verifyType(1, $port,  'Port');
        $self->verifyType(2, $build, 'Build');

        my $rc;
        if ((!defined($last_built) || $last_built eq "")
                && $column ne "last_failed_dependency")
        {
                $rc = $self->_doQuery(
                        "UPDATE build_ports SET $column=$self->{'now_fn'} WHERE port_id=? AND build_id=?",
                        [$port->getId(), $build->getId()]
                );
        } else {
                $rc = $self->_doQuery(
                        "UPDATE build_ports SET $column=? WHERE port_id=? AND build_id=?",
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

        $self->verifyType(1, $port,  'Port');
        $self->verifyType(2, $build, 'Build');

        my %status_hash = (
                UNKNOWN   => 0,
                SUCCESS   => 1,
                BROKEN    => 1,
                LEFTOVERS => 1,
                FAIL      => 1,
                DUD       => 1,
                DEPEND    => 1,
        );

        if (!defined($status_hash{$status})) {
                $status = "UNKNOWN";
        }

        my $rc = $self->_doQuery(
                "UPDATE build_ports SET last_status=? WHERE port_id=? AND build_id=?",
                [$status, $port->getId(), $build->getId()]
        );

        return $rc;
}

sub updatePortLastBuiltVersion {
        my $self    = shift;
        my $port    = shift;
        my $build   = shift;
        my $version = shift;

        $self->verifyType(1, $port,  'Port');
        $self->verifyType(2, $build, 'Build');

        my $rc = $self->_doQuery(
                "UPDATE build_ports SET last_built_version=? WHERE port_id=? AND build_id=?",
                [$version, $port->getId(), $build->getId()]
        );

        return $rc;
}

sub getPortLastBuiltVersion {
        my $self  = shift;
        my $port  = shift;
        my $build = shift;

        $self->verifyType(1, $port,  'Port');
        $self->verifyType(2, $build, 'Build');

        my @results;
        my $rc = $self->_doQueryHashRef(
                "SELECT last_built_version FROM build_ports WHERE port_id=? AND build_id=?",
                \@results, $port->getId(), $build->getId()
        );

        if (!$rc) {
                return undef;
        }

        return $results[0]->{'last_built_version'};
}

sub getPortLastBuiltStatus {
        my $self  = shift;
        my $port  = shift;
        my $build = shift;

        $self->verifyType(1, $port,  'Port');
        $self->verifyType(2, $build, 'Build');

        my @results;
        my $rc = $self->_doQueryHashRef(
                "SELECT last_status FROM build_ports WHERE port_id=? AND build_id=?",
                \@results, $port->getId(), $build->getId()
        );

        if (!$rc) {
                return undef;
        }

        return $results[0]->{'last_status'};
}

sub getPortTotalSize {
        my $self  = shift;
        my $port  = shift;
        my $build = shift;

        $self->verifyType(1, $port,  'Port');
        $self->verifyType(2, $build, 'Build');

        my @results;
        my $rc = $self->_doQueryHashRef(
                "SELECT total_size FROM build_ports WHERE port_id=? AND build_id=?",
                \@results, $port->getId(), $build->getId()
        );

        if (!$rc) {
                return undef;
        }

        return $results[0]->{'total_size'};
}

sub updatePortsTree {
        my $self      = shift;
        my $portstree = shift;

        $self->verifyType(1, $portstree, 'PortsTree');

        my $rc = $self->_doQuery(
                "UPDATE ports_trees SET ports_tree_name=?, ports_tree_description=?, ports_tree_update_cmd=?, ports_tree_cvsweb_url=?, ports_tree_ports_mount=? WHERE ports_tree_id=?",
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

        $self->verifyType(1, $portstree, 'PortsTree');

        my $rc;
        if ($portstree->getLastBuilt()) {
                my $last_built = $portstree->getLastBuilt();
                $rc = $self->_doQuery(
                        "UPDATE ports_trees SET ports_tree_last_built=? WHERE ports_tree_id=?",
                        [$last_built, $portstree->getId()]
                );
        } else {
                $rc = $self->_doQuery(
                        "UPDATE ports_trees SET ports_tree_last_built=$self->{'now_fn'} WHERE ports_tree_id=?",
                        [$portstree->getId()]
                );
        }

        return $rc;
}

sub updateBuildStatus {
        my $self  = shift;
        my $build = shift;

        $self->verifyType(1, $build, 'Build');

        my $rc = $self->_doQuery(
                "UPDATE builds SET build_status=?,build_last_updated=$self->{'now_fn'} WHERE build_id=?",
                [$build->getStatus(), $build->getId()]
        );

        return $rc;
}

sub updateBuildRemakeCount {
        my $self  = shift;
        my $build = shift;
        my $count = shift;

        $self->verifyType(1, $build, 'Build');

        my $query;
        my @params = ();
        if ($count >= 0) {
                $query =
                    "UPDATE builds SET build_remake_count=? WHERE build_id=?";
                push @params, $count, $build->getId();
        } else {
                return 0;
        }

        my $rc = $self->_doQuery($query, \@params);

        return $rc;
}

sub updateBuildCurrentPort {
        my $self    = shift;
        my $build   = shift;
        my $port    = shift;
        my $pkgname = shift;

        $self->verifyType(1, $build, 'Build');

        my $rc = $self->_doQuery(
                "UPDATE build_ports SET currently_building='0' WHERE build_id = ? AND currently_building='1'",
                [$build->getId()]
        );
        if (!$rc) {
                return $rc;
        }

        if (!defined($pkgname)) {
                $rc = $self->_doQuery(
                        "UPDATE builds SET build_current_port=NULL,build_last_updated=$self->{'now_fn'} WHERE build_id=?",
                        [$build->getId()]
                );
        } else {
                $rc = $self->_doQuery(
                        "UPDATE builds SET build_current_port=?,build_last_updated=$self->{'now_fn'} WHERE build_id=?",
                        [$pkgname, $build->getId()]
                );
        }

        if (!$rc) {
                return $rc;
        }

        if (defined($port)) {
                $self->verifyType(2, $port, 'Port');
                $rc = $self->_doQuery(
                        "UPDATE build_ports SET currently_building='1' WHERE build_id=? AND port_id=?",
                        [$build->getId(), $port->getId()]
                );
        }

        return $rc;
}

sub updateHookCmd {
        my $self = shift;
        my $hook = shift;
        my $cmd  = shift;

        $self->verifyType(1, $hook, 'Hook');

        my $rc;
        if (!defined($cmd)) {
                $rc = $self->_doQuery(
                        "UPDATE hooks SET hook_cmd=NULL WHERE hook_name=?",
                        [$hook->getName()]);
        } else {
                $rc = $self->_doQuery(
                        "UPDATE hooks SET hook_cmd=? WHERE hook_name=?",
                        [$cmd, $hook->getName()]);
        }

        return $rc;
}

sub getBuildCompletionUsers {
        my $self  = shift;
        my $build = shift;

        $self->verifyType(1, $build, 'Build');

        my @users = $self->_getBuildUsers($build, "email_on_completion");

        return @users;
}

sub getBuildErrorUsers {
        my $self  = shift;
        my $build = shift;

        $self->verifyType(1, $build, 'Build');

        my @addrs = $self->_getBuildUsers($build, "email_on_error");

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
                        "SELECT * FROM  users WHERE user_id IN (SELECT user_id FROM build_users WHERE build_id=? AND $field='1')",
                        \@results, $build->getId()
                );
        } else {
                $rc = $self->_doQueryHashRef(
                        "SELECT * FROM  users WHERE user_id IN (SELECT user_id FROM build_users WHERE build_id=?)",
                        \@results, $build->getId()
                );
        }

        if (!$rc) {
                return ();
        }

        @users = $self->_newFromArray("User", @results);

        return @users;

}

sub isValidUser {
        my $self     = shift;
        my $username = shift;

        my $user = $self->getUserByName($username);

        return (defined($user));
}

sub isUserForBuild {
        my $self  = shift;
        my $user  = shift;
        my $build = shift;

        $self->verifyType(1, $user,  'User');
        $self->verifyType(2, $build, 'Build');

        my $rc = $self->_doQueryNumRows(
                "SELECT build_user_id FROM build_users WHERE build_id=? AND user_id=?",
                $build->getId(), $user->getId()
        );

        return ($rc > 0) ? 1 : 0;
}

sub getUserById {
        my $self   = shift;
        my $userid = shift;

        my @results = $self->getObjects("User", {user_id => $userid});

        if (!@results) {
                return undef;
        }

        return $results[0];
}

sub getUserByName {
        my $self     = shift;
        my $username = shift;

        my @results = $self->getObjects("User", {user_name => $username});

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

        $self->verifyType(1, $build, 'Build');

        my @users = $self->_getBuildUsers($build, undef);
        return @users;
}

sub getWwwAdmin {
        my $self = shift;

        my @results;
        my $rc = $self->_doQueryHashRef(
                "SELECT users.* FROM users,user_permissions WHERE users.user_id=user_permissions.user_id AND user_permissions.user_permission_object_type='users' AND user_permissions.user_permission_object_id=users.user_id AND user_permissions.user_permission=?",
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
                'SELECT user_id FROM user_permissions where user_permission=?',
                1
        );

        if (!$rc) {
                $rc = $self->_doQuery(
                        'INSERT INTO user_permissions (user_id,user_permission_object_type,user_permission_object_id,user_permission) VALUES (?, ?, ?, ?)',
                        [$user->getId(), 'users', $user->getId(), 1]
                );
        } else {
                $rc = $self->_doQuery(
                        'UPDATE user_permissions SET user_id=?, user_permission_object_id=? WHERE user_permission=1',
                        [$user->getId(), $user->getId()]
                );
        }

        return $rc;
}

sub addUser {
        my $self = shift;
        my $user = shift;
        my $uCls = (ref($user) eq "REF") ? $$user : $user;
        my $hashPass;

        $hashPass = md5_hex($uCls->getPassword());

        my $rc = $self->_doQuery(
                "INSERT INTO users (user_name,user_email,user_password,user_www_enabled) VALUES (?, ?, ?, ?)",
                [
                        $uCls->getName(), $uCls->getEmail(),
                        $hashPass,        $uCls->getWwwEnabled()
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

        $self->verifyType(1, $user,  'User');
        $self->verifyType(2, $build, 'Build');

        if (!defined($onCompletion)) {
                $onCompletion = 0;
        }

        if (!defined($onError)) {
                $onError = 0;
        }

        my $rc = $self->_doQuery(
                "INSERT into build_users (build_id, user_id, email_on_completion, email_on_error) VALUES (?, ?, ?, ?)",
                [$build->getId(), $user->getId(), $onCompletion, $onError]
        );

        return $rc;
}

sub addPortForBuild {
        my $self  = shift;
        my $port  = shift;
        my $build = shift;

        my $rc = $self->_doQuery(
                "INSERT INTO build_ports (build_id, port_id) VALUES (?, ?)",
                [$build->getId(), $port->getId()]);

        return $rc;
}

sub removeBuildPortsQueue {
        my $self = shift;

        my $rc;
        $rc = $self->_doQuery("DELETE FROM build_ports_queue");
        return $rc;
}

sub removeBuildPortsQueueEntry {
        my $self  = shift;
        my $entry = shift;

        my $rc;
        $rc = $self->_doQuery(
                "DELETE FROM build_ports_queue WHERE build_ports_queue_id=?",
                [$entry->getId()]);

        return $rc;
}

sub removePort {
        my $self = shift;
        my $port = shift;

        my $rc;
        $rc = $self->_doQuery("DELETE FROM build_ports WHERE port_id=?",
                [$port->getId()]);

        if (!$rc) {
                return $rc;
        }

        $rc = $self->_doQuery("DELETE FROM ports WHERE port_id=?",
                [$port->getId()]);

        return $rc;
}

sub removePortForBuild {
        my $self  = shift;
        my $port  = shift;
        my $build = shift;

        my $rc = $self->_doQuery(
                "DELETE FROM build_ports WHERE port_id=? AND build_id=?",
                [$port->getId(), $build->getId()]);

        return $rc;
}

sub removeUser {
        my $self = shift;
        my $user = shift;

        $self->verifyType(1, $user, 'User');

        my $rc = $self->_doQuery("DELETE FROM build_users WHERE user_id=?",
                [$user->getId()]);

        if (!$rc) {
                return $rc;
        }

        $rc = $self->_doQuery("DELETE FROM users WHERE user_id=?",
                [$user->getId()]);

        return $rc;
}

sub removeUserForBuild {
        my $self  = shift;
        my $user  = shift;
        my $build = shift;

        $self->verifyType(1, $user,  'User');
        $self->verifyType(2, $build, 'Build');

        my $rc = $self->_doQuery(
                "DELETE FROM build_users WHERE build_id=? AND user_id=?",
                [$build->getId(), $user->getId()]);

        return $rc;
}

sub removeJail {
        my $self = shift;
        my $jail = shift;

        my $rc = $self->_doQuery("DELETE FROM jails WHERE jail_id=?",
                [$jail->getId()]);

        return $rc;
}

sub removePortsTree {
        my $self      = shift;
        my $portstree = shift;

        my $rc =
            $self->_doQuery("DELETE FROM ports_trees WHERE ports_tree_id=?",
                [$portstree->getId()]);

        return $rc;
}

sub removeBuild {
        my $self  = shift;
        my $build = shift;

        my $rc;
        $rc = $self->_doQuery("DELETE FROM build_ports WHERE build_id=?",
                [$build->getId()]);

        if (!$rc) {
                return $rc;
        }

        $rc = $self->_doQuery("DELETE FROM build_users WHERE build_id=?",
                [$build->getId()]);

        if (!$rc) {
                return $rc;
        }

        $rc = $self->_doQuery("DELETE FROM build_ports_queue WHERE build_id=?",
                [$build->getId()]);

        if (!$rc) {
                return $rc;
        }

        $rc = $self->_doQuery("DELETE FROM build_groups WHERE build_id=?",
                [$build->getId()]);

        if (!$rc) {
                return $rc;
        }

        $rc = $self->_doQuery("DELETE FROM builds WHERE build_id=?",
                [$build->getId()]);

        return $rc;
}

sub removePortFailPattern {
        my $self    = shift;
        my $pattern = shift;

        my $rc = $self->_doQuery(
                "DELETE FROM port_fail_patterns WHERE port_fail_pattern_id=?",
                [$pattern->getId()]);

        return $rc;
}

sub removePortFailReason {
        my $self   = shift;
        my $reason = shift;

        my $rc = $self->_doQuery(
                "DELETE FROM port_fail_reasons WHERE port_fail_reason_tag=?",
                [$reason->getTag()]);

        return $rc;
}

sub findBuildsForJail {
        my $self   = shift;
        my $jail   = shift;
        my @builds = ();

        my @results;
        my $rc = $self->_doQueryHashRef("SELECT * FROM builds WHERE jail_id=?",
                \@results, $jail->getId());

        if (!$rc) {
                return ();
        }

        @builds = $self->_newFromArray("Build", @results);

        return @builds;
}

sub findBuildsForPortsTree {
        my $self      = shift;
        my $portstree = shift;
        my @builds    = ();

        my @results;
        my $rc =
            $self->_doQueryHashRef("SELECT * FROM builds WHERE ports_tree_id=?",
                \@results, $portstree->getId());

        if (!$rc) {
                return ();
        }

        @builds = $self->_newFromArray("Build", @results);

        return @builds;
}

sub findPortFailPatternsWithReason {
        my $self     = shift;
        my $reason   = shift;
        my @patterns = ();

        my @results;
        my $rc = $self->_doQueryHashRef(
                "SELECT * FROM port_fail_patterns WHERE port_fail_pattern_reason=?",
                \@results, $reason->getTag()
        );

        if (!$rc) {
                return ();
        }

        @patterns = $self->_newFromArray("PortFailPattern", @results);

        return @patterns;
}

sub isPortInDS {
        my $self = shift;
        my $port = shift;

        my $rc = $self->_doQueryNumRows(
                "SELECT port_id FROM ports WHERE port_directory=?",
                $port->getDirectory());

        return (($rc > 0) ? 1 : 0);
}

sub isValidBuild {
        my $self      = shift;
        my $buildName = shift;

        my $build = $self->getBuildByName($buildName);

        return (defined($build));
}

sub isValidJail {
        my $self     = shift;
        my $jailName = shift;

        my $jail = $self->getJailByName($jailName);

        return (defined($jail));
}

sub isValidPortsTree {
        my $self          = shift;
        my $portsTreeName = shift;

        my $portstree = $self->getPortsTreeByName($portsTreeName);

        return (defined($portstree));
}

sub isValidPortFailReason {
        my $self      = shift;
        my $reasonTag = shift;

        my $portFailReason = $self->getPortFailReasonByTag($reasonTag);

        return (defined($portFailReason));
}

sub isValidPortFailPattern {
        my $self      = shift;
        my $patternId = shift;

        my $portFailPattern = $self->getPortFailPatternById($patternId);

        return (defined($portFailPattern));
}

sub isValidHook {
        my $self     = shift;
        my $hookName = shift;

        my $hook = $self->getHookByName($hookName);

        return (defined($hook));
}

sub isPortInBuild {
        my $self  = shift;
        my $port  = shift;
        my $build = shift;

        my $rc = $self->_doQueryNumRows(
                "SELECT port_id FROM build_ports WHERE port_id=? AND build_id=?",
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
                "SELECT build_name FROM builds WHERE build_id IN (SELECT build_id FROM build_ports WHERE port_id=?)",
                \@result, $port->getId()
        );

        foreach (@result) {
                if ($build->getName() eq $_->{'build_name'}) {
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

sub getAllPortFailReasons {
        my $self            = shift;
        my @portFailReasons = ();

        @portFailReasons =
            $self->getObjects("PortFailReason",
                {_ORDER_ => 'port_fail_reason_tag'});

        return @portFailReasons;
}

sub getAllPortFailPatterns {
        my $self             = shift;
        my @portFailPatterns = ();

        @portFailPatterns =
            $self->getObjects("PortFailPattern",
                {_ORDER_ => 'port_fail_pattern_id'});

        return @portFailPatterns;
}

sub getError {
        my $self = shift;

        return $self->{'error'};
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

        # According to the DBI documentation, $DBI::rows isn't intended to get
        # the row count of a SELECT query; indeed, with SQLite it's always 0.
        if ($sth->rows > -1 && $DB_DRIVER != "SQLite") {
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
        my $params = shift;    # Optional depending on query
        my $sth    = shift;    # Optional
        my $rc;

        my $_sth;              # This is the real statement handler.

        if (defined($ENV{'TINDERBOX_QUERY_DEBUG'})) {
                printf STDERR "TINDERBOX_SQL:\n\tquery = %s\n", $query;
                printf STDERR "\tvalues = %s\n", join(', ', @{$params})
                    if (defined($params));
        }

        $_sth = $self->{'dbh'}->prepare($query);

        if (!$_sth) {
                $self->{'error'} = $self->{'dbh'}->errstr;
                return 0;
        }

        if (defined($params) && scalar(@{$params})) {
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

sub _isA {
        my $type   = shift;
        my $object = shift;

        if ($PKG_PREFIX ne '') {
                $type = $PKG_PREFIX . $type;
        }

        return (ref($object) eq $type);
}

sub _newFromArray {
        my $self  = shift;
        my $class = ref $self;
        croak "ERROR: Attempt to call private method"
            if ($class ne __PACKAGE__);
        my $type    = shift;
        my @array   = @_;
        my @objects = ();

        if ($PKG_PREFIX ne '') {
                $type = $PKG_PREFIX . $type;
        }

        foreach (@array) {
                my $obj = eval "new $type(\$_)";
                if (ref($obj) ne $type) {
                        return ();
                }
                push @objects, $obj;
        }

        return @objects;
}

sub _addObject {
        my $self      = shift;
        my $object    = shift;
        my $objectRef = ref($object);

        if ($PKG_PREFIX ne '') {
                $objectRef =~ s/^$PKG_PREFIX//;
        }

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

sub commitObject {
        my $self      = shift;
        my $object    = shift;
        my $objectRef = ref($object);

        if ($PKG_PREFIX eq '') {
                $objectRef =~ s/^$PKG_PREFIX//;
        }

        croak "ERROR: Unknown object type, $objectRef\n"
            unless defined($OBJECT_MAP{$objectRef});
        croak "ERROR: ID field is undefined\n"
            unless (defined($object->getIdField())
                && $object->getIdField() ne '');

        my $table      = $OBJECT_MAP{$objectRef};
        my $objectHash = $object->toHashRef();

        my $query = "UPDATE $table SET ";

        my @fields = ();
        my @values = ();
        foreach my $key (keys %{$objectHash}) {
                if (defined($objectHash->{$key})) {
                        push @fields, "$key=?";
                        push @values, $objectHash->{$key};
                }
        }

        $query .= join(",", @fields);
        $query .= " WHERE " . $object->getIdField() . "=?";
        push @values, $object->getId();

        my $rc = $self->_doQuery($query, \@values);

        return $rc;
}

sub destroy {
        my $self = shift;

        $self->{'error'} = undef;
        $self->{'dbh'}->disconnect;
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

        $self->verifyType(1, $jail, 'Jail');

        if (substr($jail->getName(), 0, 1) == "4") {
                return ".tgz";
        }

        return ".tbz";
}

sub isLogCurrent {
        my $self  = shift;
        my $build = shift;
        my $log   = shift;
        my $range;

        $self->verifyType(1, $build, 'Build');
        if ($log =~ /\.bz2$/) {
                $range = -8;
        } else {
                $range = -4;
        }

        my $rc = $self->_doQueryNumRows(
                "SELECT build_port_id FROM build_ports WHERE build_id=? AND last_built_version=?",
                $build->getId(),
                substr($log, 0, $range)
        );

        return ($rc > 0) ? 1 : 0;
}

1;
