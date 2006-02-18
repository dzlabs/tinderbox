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
# $MCom: portstools/tinderbox/lib/Tinderbox/Port.pm,v 1.10 2006/02/18 19:57:21 marcus Exp $
#

package Tinderbox::Port;

use strict;
use Tinderbox::TinderObject;
use vars qw(@ISA);
@ISA = qw(Tinderbox::TinderObject);

use constant PORT_ID_FIELD => 'port_id';

sub new {
        my $that        = shift;
        my $object_hash = {
                port_id         => "",
                port_name       => "",
                port_directory  => "",
                port_maintainer => "",
                port_comment    => "",
        };

        my @args = ();
        push @args, $object_hash, @_;

        my $self = $that->SUPER::new(@args);
        $self->{'_id_field'} = PORT_ID_FIELD;

        return $self;
}

sub getId {
        my $self = shift;

        return $self->{port_id};
}

sub getName {
        my $self = shift;

        return $self->{port_name};
}

sub getDirectory {
        my $self = shift;

        return $self->{port_directory};
}

sub getMaintainer {
        my $self = shift;

        return $self->{port_maintainer};
}

sub getComment {
        my $self = shift;

        return $self->{port_comment};
}

sub setName {
        my $self = shift;
        my $name = shift;

        $self->{port_name} = $name;
}

sub setDirectory {
        my $self = shift;
        my $dir  = shift;

        $self->{port_directory} = $dir;
}

sub setMaintainer {
        my $self  = shift;
        my $maint = shift;

        $self->{port_maintainer} = $maint;
}

sub setComment {
        my $self    = shift;
        my $comment = shift;

        $self->{port_comment} = $comment;
}

1;
