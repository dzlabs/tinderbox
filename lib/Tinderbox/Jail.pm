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
# $MCom: portstools/tinderbox/lib/Tinderbox/Jail.pm,v 1.8 2005/07/20 03:19:03 marcus Exp $
#

package Jail;

use strict;
use TinderObject;
use vars qw(@ISA);
@ISA = qw(TinderObject);

sub new {
        my $that        = shift;
        my $object_hash = {
                Jail_Id          => "",
                Jail_Name        => "",
                Jail_Tag         => "",
                Jail_Last_Built  => "",
                Jail_Update_Cmd  => "",
                Jail_Description => "",
                Jail_Src_Mount   => "",
        };

        my @args = ();
        push @args, $object_hash, @_;

        $that->SUPER::new(@args);
}

sub getId {
        my $self = shift;

        return $self->{Jail_Id};
}

sub getName {
        my $self = shift;

        return $self->{Jail_Name};
}

sub getTag {
        my $self = shift;

        return $self->{Jail_Tag};
}

sub getLastBuilt {
        my $self = shift;

        return $self->{Jail_Last_Built};
}

sub getUpdateCmd {
        my $self = shift;

        return $self->{Jail_Update_Cmd};
}

sub getDescription {
        my $self = shift;

        return $self->{Jail_Description};
}

sub getSrcMount {
        my $self = shift;

        return $self->{Jail_Src_Mount};
}

sub setName {
        my $self = shift;
        my $name = shift;

        $self->{Jail_Name} = $name;
}

sub setTag {
        my $self = shift;
        my $tag  = shift;

        $self->{Jail_Tag} = $tag;
}

sub setLastBuilt {
        my $self       = shift;
        my $updateTime = shift;

        $self->{Jail_Last_Built} = $updateTime;
}

sub setUpdateCmd {
        my $self      = shift;
        my $updateCmd = shift;

        $self->{Jail_Update_Cmd} = $updateCmd;
}

sub setDescription {
        my $self  = shift;
        my $descr = shift;

        $self->{Jail_Description} = $descr;
}

sub setSrcMount {
        my $self  = shift;
        my $mount = shift;

        $self->{Jail_Src_Mount} = $mount;
}

1;
