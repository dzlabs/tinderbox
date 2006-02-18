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
# $MCom: portstools/tinderbox/lib/Tinderbox/Jail.pm,v 1.12 2006/02/18 19:57:21 marcus Exp $
#

package Tinderbox::Jail;

use strict;
use Tinderbox::TinderObject;
use POSIX;
use vars qw(@ISA);
@ISA = qw(Tinderbox::TinderObject);

use constant JAIL_ID_FIELD => 'jail_id';

sub new {
        my $that        = shift;
        my $object_hash = {
                jail_id          => "",
                jail_name        => "",
		jail_arch	 => "",
                jail_tag         => "",
                jail_last_built  => "",
                jail_update_cmd  => "",
                jail_description => "",
                jail_src_mount   => "",
        };

        my @args = ();
        push @args, $object_hash, @_;

        my $self = $that->SUPER::new(@args);
        $self->{'_id_field'} = JAIL_ID_FIELD;

        return $self;
}

sub getId {
        my $self = shift;

        return $self->{jail_id};
}

sub getName {
        my $self = shift;

        return $self->{jail_name};
}

sub getArch {
	my $self = shift;

	my $arch = $self->{jail_arch};
	if (!defined($arch) || $arch eq '') {
		my @uname = POSIX::uname();
		$arch = $uname[4];
	}
	return $arch;
}

sub getTag {
        my $self = shift;

        return $self->{jail_tag};
}

sub getLastBuilt {
        my $self = shift;

        return $self->{jail_last_built};
}

sub getUpdateCmd {
        my $self = shift;

        return $self->{jail_update_cmd};
}

sub getDescription {
        my $self = shift;

        return $self->{jail_description};
}

sub getSrcMount {
        my $self = shift;

        return $self->{jail_src_mount};
}

sub setName {
        my $self = shift;
        my $name = shift;

        $self->{jail_name} = $name;
}

sub setArch {
	my $self = shift;
	my $name = shift;

	$self->{jail_arch} = $name;
}

sub setTag {
        my $self = shift;
        my $tag  = shift;

        $self->{jail_tag} = $tag;
}

sub setLastBuilt {
        my $self       = shift;
        my $updateTime = shift;

        $self->{jail_last_built} = $updateTime;
}

sub setUpdateCmd {
        my $self      = shift;
        my $updateCmd = shift;

        $self->{jail_update_cmd} = $updateCmd;
}

sub setDescription {
        my $self  = shift;
        my $descr = shift;

        $self->{jail_description} = $descr;
}

sub setSrcMount {
        my $self  = shift;
        my $mount = shift;

        $self->{jail_src_mount} = $mount;
}

1;
