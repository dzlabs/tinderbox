package Jail;

use strict;

sub new {
        my ($that, @args) = @_;
        my $class = ref($that) || $that;

        my $attrs = $args[0];

        my $self = {
                Id   => $attrs->{'Id'},
                Name => $attrs->{'Name'},
                Tag  => $attrs->{'Tag'},
        };

        bless($self, $class);
        $self;
}

sub getId {
        my $self = shift;

        return $self->{Id};
}

sub getName {
        my $self = shift;

        return $self->{Name};
}

sub getTag {
        my $self = shift;

        return $self->{Tag};
}

sub setName {
        my $self = shift;
        my $name = shift;

        $self->{Name} = $name;
}

sub setTag {
        my $self = shift;
        my $tag  = shift;

        $self->{Tag} = $tag;
}

1;
