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
# $MCom: portstools/tinderbox/PortsTree.pm,v 1.5 2005/06/28 05:47:55 adamw Exp $
#

package PortsTree;

use strict;
use TinderObject;
use vars qw(@ISA);
@ISA = qw(TinderObject);

sub new {
        my $that        = shift;
        my $object_hash = {
                Ports_Tree_Id          => "",
                Ports_Tree_Name        => "",
                Ports_Tree_Description => "",
                Ports_Tree_Last_Built  => "",
                Ports_Tree_Update_Cmd  => "",
                Ports_Tree_CVSweb_URL  => "",
        };

        my @args = ();
        push @args, $object_hash, @_;

        $that->SUPER::new(@args);
}

sub getId {
        my $self = shift;

        return $self->{Ports_Tree_Id};
}

sub getName {
        my $self = shift;

        return $self->{Ports_Tree_Name};
}

sub getDescription {
        my $self = shift;

        return $self->{Ports_Tree_Description};
}

sub getTag {
        my $self = shift;

        return $self->{Ports_Tree_Tag};
}

sub getLastBuilt {
        my $self = shift;

        return $self->{Ports_Tree_Last_Built};
}

sub getUpdateCmd {
        my $self = shift;

        return $self->{Ports_Tree_Update_Cmd};
}

sub getCVSwebURL {
        my $self = shift;

        return $self->{Ports_Tree_CVSweb_URL};
}

sub setName {
        my $self = shift;
        my $name = shift;

        $self->{Ports_Tree_Name} = $name;
}

sub setDescription {
        my $self  = shift;
        my $descr = shift;

        $self->{Ports_Tree_Description} = $descr;
}

sub setLastBuilt {
        my $self       = shift;
        my $updateTime = shift;

        $self->{Ports_Tree_Last_Built} = $updateTime;
}

sub setUpdateCmd {
        my $self      = shift;
        my $updateCmd = shift;

        $self->{Ports_Tree_Update_Cmd} = $updateCmd;
}

sub setCVSwebURL {
        my $self = shift;
        my $url  = shift;

        $self->{Ports_Tree_CVSweb_URL} = $url;
}

1;
