package TinderObject;

use strict;
use vars qw(@ISA);
@ISA = qw(Exporter);

sub new {
        my ($that, @args) = @_;
        my $class = ref($that) || $that;

        my $attrs = $args[1];

        my $self = {_object_hash => $args[0],};
        foreach my $key (keys %{$attrs}) {
                $self->{$key} = $attrs->{$key}
                    if (defined($self->{_object_hash}->{$key}));
        }
        bless($self, $class);
        $self;
}

sub toHashRef {
        my $self    = shift;
        my $hashRef = {};

        foreach (keys %{$self->{_object_hash}}) {
                $hashRef->{$_} = $self->{$_};
        }

        return $hashRef;
}

1;
