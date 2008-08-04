#-
# Copyright (c) 2004-2008 FreeBSD GNOME Team <freebsd-gnome@FreeBSD.org>
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
# $MCom: portstools/tinderbox/lib/Tinderbox/Build.pm,v 1.13 2008/08/04 23:18:09 marcus Exp $
#

package Tinderbox::Build;

use strict;
use Tinderbox::TinderObject;
use vars qw(@ISA %STATUS_HASH);
@ISA = qw(Tinderbox::TinderObject);

%STATUS_HASH = (
        IDLE      => 0,
        PREPARE   => 1,
        PORTBUILD => 2,
);

use constant BUILD_ID_FIELD => 'build_id';

sub new {
        my $that        = shift;
        my $object_hash = {
                build_id           => "",
                build_name         => "",
                jail_id            => "",
                ports_tree_id      => "",
                build_status       => "",
                build_description  => "",
                build_current_port => "",
                build_last_updated => "",
                build_remake_count => "",
        };

        my @args = ();
        push @args, $object_hash, @_;

        my $self = $that->SUPER::new(@args);
        $self->{'_id_field'} = BUILD_ID_FIELD;

        return $self;
}

sub getId {
        my $self = shift;

        return $self->{build_id};
}

sub getName {
        my $self = shift;

        return $self->{build_name};
}

sub getJailId {
        my $self = shift;

        return $self->{jail_id};
}

sub getPortsTreeId {
        my $self = shift;

        return $self->{ports_tree_id};
}

sub getStatus {
        my $self = shift;

        return $self->{build_status};
}

sub getDescription {
        my $self = shift;

        return $self->{build_description};
}

sub getCurrentPort {
        my $self = shift;

        return $self->{build_current_port};
}

sub getLastUpdated {
        my $self = shift;

        return $self->{build_last_updated};
}

sub getRemakeCount {
        my $self = shift;

        return $self->{build_remake_count};
}

sub setName {
        my $self = shift;
        my $name = shift;

        $self->{build_name} = $name;
}

sub setJailId {
        my $self = shift;
        my $id   = shift;

        $self->{jail_id} = $id;
}

sub setPortsTreeId {
        my $self = shift;
        my $id   = shift;

        $self->{ports_tree_id} = $id;
}

sub setStatus {
        my $self   = shift;
        my $status = shift;

        if (defined($STATUS_HASH{$status})) {
                $self->{build_status} = $status;
        }
}

sub setDescription {
        my $self  = shift;
        my $descr = shift;

        $self->{build_description} = $descr;
}

sub setCurrentPort {
        my $self = shift;
        my $port = shift;

        $self->{build_current_port} = $port;
}

sub setRemakeCount {
        my $self = shift;
        my $cnt  = shift;

        if ($cnt =~ /^\d+$/) {
                $self->{build_remake_count} = $cnt;
        }
}

1;
