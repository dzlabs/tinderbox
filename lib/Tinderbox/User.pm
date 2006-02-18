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
# $MCom: portstools/tinderbox/lib/Tinderbox/User.pm,v 1.9 2006/02/18 19:57:21 marcus Exp $
#

package Tinderbox::User;

use strict;
use Tinderbox::TinderObject;
use vars qw(@ISA);
@ISA = qw(Tinderbox::TinderObject);

use constant USER_ID_FIELD => 'user_id';

sub new {
        my $that        = shift;
        my $object_hash = {
                user_id          => "",
                user_name        => "",
                user_email       => "",
                user_password    => "",
                user_www_enabled => "",
        };

        my @args = ();
        push @args, $object_hash, @_;

        my $self = $that->SUPER::new(@args);
        $self->{'_id_field'} = USER_ID_FIELD;

        return $self;
}

sub getId {
        my $self = shift;

        return $self->{user_id};
}

sub getName {
        my $self = shift;

        return $self->{user_name};
}

sub getEmail {
        my $self = shift;

        return $self->{user_email};
}

sub getPassword {
        my $self = shift;

        return $self->{user_password};
}

sub getWwwEnabled {
        my $self = shift;

        return $self->{'_truth_array'}->{$self->{user_www_enabled}};
}

sub setName {
        my $self = shift;
        my $name = shift;

        $self->{user_name} = $name;
}

sub setEmail {
        my $self  = shift;
        my $email = shift;

        $self->{user_email} = $email;
}

sub setPassword {
        my $self     = shift;
        my $password = shift;

        $self->{user_password} = $password;
}

sub setWwwEnabled {
        my $self       = shift;
        my $wwwenabled = shift;

        $self->{user_www_enabled} = $wwwenabled;
}

1;
