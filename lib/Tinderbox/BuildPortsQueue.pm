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
# $MCom: portstools/tinderbox/lib/Tinderbox/BuildPortsQueue.pm,v 1.11 2007/10/13 02:28:46 ade Exp $
#

package Tinderbox::BuildPortsQueue;

use strict;
use Tinderbox::TinderObject;
use vars qw(@ISA);
@ISA = qw(Tinderbox::TinderObject);

use constant BUILD_PORTS_QUEUE_ID_FIELD => 'build_ports_queue_id';

sub new {
        my $that        = shift;
        my $object_hash = {
                build_ports_queue_id => "",
                enqueue_date         => "",
                completion_date      => "",
                build_id             => "",
                user_id              => "",
                port_directory       => "",
                priority             => "",
                email_on_completion  => "",
                status               => "",
        };

        my @args = ();
        push @args, $object_hash, @_;

        my $self = $that->SUPER::new(@args);
        $self->{'_id_field'} = BUILD_PORTS_QUEUE_ID_FIELD;

        return $self;
}

sub getId {
        my $self = shift;

        return $self->{build_ports_queue_id};
}

sub getBuildId {
        my $self = shift;

        return $self->{build_id};
}

sub getCompletionDate {
        my $self = shift;

        return $self->{completion_date};
}

sub getEmailOnCompletion {
        my $self = shift;

        return $self->{'_truth_array'}->{$self->{email_on_completion}};
}

sub getPortDirectory {
        my $self = shift;

        return $self->{port_directory};
}

sub getPriority {
        my $self = shift;

        return $self->{priority};
}

sub getUserId {
        my $self = shift;

        return $self->{user_id};
}

sub setCompletionDate {
        my $self = shift;
        my $date = shift;

        $self->{completion_date} = $date;
}

1;
