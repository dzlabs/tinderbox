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
# $MCom: portstools/tinderbox/lib/BuildPortsQueue.pm,v 1.4 2005/08/22 00:53:00 marcus Exp $
#

package BuildPortsQueue;

use strict;
use TinderObject;
use vars qw(@ISA);
@ISA = qw(TinderObject);

use constants BUILD_PORTS_QUEUE_ID_FIELD => 'Build_Ports_Queue_Id';

sub new {
        my $that        = shift;
        my $object_hash = {
                Build_Ports_Queue_Id => "",
                Enqueue_Date         => "",
                Completion_Date      => "",
                Build_Id             => "",
                User_Id              => "",
                Port_Directory       => "",
                Priority             => "",
                Host_Id              => "",
                Email_On_Completion  => "",
                Status               => "",
        };

        my @args = ();
        push @args, $object_hash, @_;

        my $self = $that->SUPER::new(@args);
        $self->{'_id_field'} = BUILD_PORTS_QUEUE_ID_FIELD;

        return $self;
}

sub getId {
        my $self = shift;

        return $self->{Build_Ports_Queue_Id};
}

sub getBuildId {
        my $self = shift;

        return $self->{Build_Id};
}

sub getCompletionDate {
        my $self = shift;

        return $self->{Completion_Date};
}

sub getEmailOnCompletion {
        my $self = shift;

        return $self->{Email_On_Completion};
}

sub getPortDirectory {
        my $self = shift;

        return $self->{Port_Directory};
}

sub getPriority {
        my $self = shift;

        return $self->{Priority};
}

sub getUserId {
        my $self = shift;

        return $self->{User_Id};
}

sub setCompletionDate {
        my $self = shift;
        my $date = shift;

        $self->{Completion_Date} = $date;
}

1;
