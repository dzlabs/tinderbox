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
# $MCom: portstools/tinderbox/lib/Tinderbox/Build.pm,v 1.8 2005/07/20 03:19:03 marcus Exp $
#

package Build;

use strict;
use TinderObject;
use vars qw(@ISA %STATUS_HASH);
@ISA = qw(TinderObject);

%STATUS_HASH = (
        IDLE      => 0,
        PREPARE   => 1,
        PORTBUILD => 2,
);

sub new {
        my $that        = shift;
        my $object_hash = {
                Build_Id           => "",
                Build_Name         => "",
                Jail_Id            => "",
                Ports_Tree_Id      => "",
                Build_Status       => "",
                Build_Description  => "",
                Build_Current_Port => "",
        };

        my @args = ();
        push @args, $object_hash, @_;

        $that->SUPER::new(@args);
}

sub getId {
        my $self = shift;

        return $self->{Build_Id};
}

sub getName {
        my $self = shift;

        return $self->{Build_Name};
}

sub getJailId {
        my $self = shift;

        return $self->{Jail_Id};
}

sub getPortsTreeId {
        my $self = shift;

        return $self->{Ports_Tree_Id};
}

sub getStatus {
        my $self = shift;

        return $self->{Build_Status};
}

sub getDescription {
        my $self = shift;

        return $self->{Build_Description};
}

sub getCurrentPort {
        my $self = shift;

        return $self->{Build_Current_Port};
}

sub setName {
        my $self = shift;
        my $name = shift;

        $self->{Build_Name} = $name;
}

sub setJailId {
        my $self = shift;
        my $id   = shift;

        $self->{Jail_Id} = $id;
}

sub setPortsTreeId {
        my $self = shift;
        my $id   = shift;

        $self->{Ports_Tree_Id} = $id;
}

sub setStatus {
        my $self   = shift;
        my $status = shift;

        if (defined($STATUS_HASH{$status})) {
                $self->{Build_Status} = $status;
        }
}

sub setDescription {
        my $self  = shift;
        my $descr = shift;

        $self->{Build_Description} = $descr;
}

sub setCurrentPort {
        my $self = shift;
        my $port = shift;

        $self->{Build_Current_Port} = $port;
}

1;
