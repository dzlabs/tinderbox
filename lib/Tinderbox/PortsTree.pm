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
# $MCom: portstools/tinderbox/lib/Tinderbox/PortsTree.pm,v 1.10 2006/02/18 19:57:21 marcus Exp $
#

package Tinderbox::PortsTree;

use strict;
use Tinderbox::TinderObject;
use vars qw(@ISA);
@ISA = qw(Tinderbox::TinderObject);

use constant PORTS_TREE_ID_FIELD => 'ports_tree_id';

sub new {
        my $that        = shift;
        my $object_hash = {
                ports_tree_id          => "",
                ports_tree_name        => "",
                ports_tree_description => "",
                ports_tree_last_built  => "",
                ports_tree_update_cmd  => "",
                ports_tree_cvsweb_url  => "",
                ports_tree_ports_mount => "",
        };

        my @args = ();
        push @args, $object_hash, @_;

        my $self = $that->SUPER::new(@args);
        $self->{'_id_field'} = PORTS_TREE_ID_FIELD;

        return $self;
}

sub getId {
        my $self = shift;

        return $self->{ports_tree_id};
}

sub getName {
        my $self = shift;

        return $self->{ports_tree_name};
}

sub getDescription {
        my $self = shift;

        return $self->{ports_tree_description};
}

sub getLastBuilt {
        my $self = shift;

        return $self->{ports_tree_last_built};
}

sub getUpdateCmd {
        my $self = shift;

        return $self->{ports_tree_update_cmd};
}

sub getCVSwebURL {
        my $self = shift;

        return $self->{ports_tree_cvsweb_url};
}

sub getPortsMount {
        my $self = shift;

        return $self->{ports_tree_ports_mount};
}

sub setName {
        my $self = shift;
        my $name = shift;

        $self->{ports_tree_name} = $name;
}

sub setDescription {
        my $self  = shift;
        my $descr = shift;

        $self->{ports_tree_description} = $descr;
}

sub setLastBuilt {
        my $self       = shift;
        my $updateTime = shift;

        $self->{ports_tree_last_built} = $updateTime;
}

sub setUpdateCmd {
        my $self      = shift;
        my $updateCmd = shift;

        $self->{ports_tree_update_cmd} = $updateCmd;
}

sub setCVSwebURL {
        my $self = shift;
        my $url  = shift;

        $self->{ports_tree_cvsweb_url} = $url;
}

sub setPortsMount {
        my $self  = shift;
        my $mount = shift;

        $self->{ports_tree_ports_mount} = $mount;
}

1;
