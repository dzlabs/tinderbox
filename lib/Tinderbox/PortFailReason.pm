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
# $MCom: portstools/tinderbox/lib/Tinderbox/PortFailReason.pm,v 1.2 2006/02/18 19:57:21 marcus Exp $
#

package Tinderbox::PortFailReason;

use strict;
use Tinderbox::TinderObject;
use vars qw(@ISA %TYPE_HASH);
@ISA = qw(Tinderbox::TinderObject);

%TYPE_HASH = (
        COMMON    => 0,
        RARE      => 1,
        TRANSIENT => 2,
);

sub new {
        my $that        = shift;
        my $object_hash = {
                port_fail_reason_tag   => "",
                port_fail_reason_descr => "",
                port_fail_reason_type  => "",
        };

        my @args = ();
        push @args, $object_hash, @_;

        my $self = $that->SUPER::new(@args);

        return $self;
}

sub getTag {
        my $self = shift;

        return $self->{port_fail_reason_tag};
}

sub getDescr {
        my $self = shift;

        return $self->{port_fail_reason_descr};
}

sub getType {
        my $self = shift;

        return $self->{port_fail_reason_type};
}

sub setTag {
        my $self = shift;
        my $tag  = shift;

        $self->{port_fail_reason_tag} = $tag;
}

sub setDescr {
        my $self  = shift;
        my $descr = shift;

        $self->{port_fail_reason_descr} = $descr;
}

sub setType {
        my $self = shift;
        my $type = shift;

        if (defined($TYPE_HASH{$type})) {
                $self->{port_fail_reason_type} = $type;
        }
}

1;
