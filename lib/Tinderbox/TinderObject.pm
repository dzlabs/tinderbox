#-
# Copyright (c) 2004-2008 FreeBSD GNOME Team <freebsd-gnome@FreeBSD.org>
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
# $MCom: portstools/tinderbox/lib/Tinderbox/TinderObject.pm,v 1.18 2008/08/07 04:27:49 marcus Exp $
#

package Tinderbox::TinderObject;

use strict;
use vars qw(@ISA);
@ISA = qw(Exporter);

sub new {
        my ($that, @args) = @_;
        my $class = ref($that) || $that;

        my $attrs        = $args[1];
        my $_truth_array = {
                'f' => '0',
                't' => '1',
                '0' => '0',
                '1' => '1',
        };

        my $self = {
                _object_hash => $args[0],
                _id_field    => undef,
                _truth_array => $_truth_array,
        };
        foreach my $key (keys %{$attrs}) {
                $self->{$key} = $attrs->{$key}
                    if (defined($self->{'_object_hash'}->{$key}));
        }
        bless($self, $class);
        $self;
}

sub getIdField() {
        my $self = shift;

        return $self->{'_id_field'};
}

sub toHashRef {
        my $self    = shift;
        my $hashRef = {};

        foreach (keys %{$self->{'_object_hash'}}) {
                if (
                        defined($self->{$_})
                        && (
                                $_ ne $self->{'_id_field'}
                                || (       $_ eq $self->{'_id_field'}
                                        && $self->{$_} ne "")
                        )
                    )
                {
                        $hashRef->{$_} = $self->{$_};
                }
        }

        return $hashRef;
}

sub toString {
        my $self   = shift;
        my $string = "";

        my $hRef = $self->toHashRef();

        $string = "TinderObject Type : " . (ref($self)) . "\n";
        $string .= "ID : " . $self->getId() . "\n";
        foreach my $field (keys %{$hRef}) {
                $string .= "$field : " . $hRef->{$field} . "\n";
        }

        return $string;
}

sub toXMLString {
        my $self = shift;
        my $xml  = "";

        my $hRef = $self->toHashRef();

        $xml = "<?xml version=\"1.0\"?>\n";
        $xml .= "<TinderObject class=\"" . (ref($self)) . "\">\n";
        $xml .= "  <ID>" . $self->getId() . "</ID>\n";
        foreach my $field (keys %{$hRef}) {
                my $value = $hRef->{$field};
                $value =~ s/\</\&lt;/g;
                $value =~ s/\>/\&gt;/g;
                $value =~ s/\&/\&amp;/g;
                $value =~ s/\t/    /g;
                $xml .= "  <$field>$value</$field>\n";
        }

        $xml .= "</TinderObject>\n";

        return $xml;
}

1;
