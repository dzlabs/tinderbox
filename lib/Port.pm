package Port;

use strict;

sub new {
        my ($that, @args) = @_;
        my $class = ref($that) || $that;

        my $attrs = $args[0];

        my $self = {
                Id        => $attrs->{'Id'},
                Name      => $attrs->{'Name'},
                Directory => $attrs->{'Directory'},
                Comment   => $attrs->{'Comment'},
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

sub getDirectory {
        my $self = shift;

        return $self->{Directory};
}

sub getComment {
        my $self = shift;

        return $self->{Comment};
}

sub setName {
        my $self = shift;
        my $name = shift;

        $self->{Name} = $name;
}

sub setDirectory {
        my $self = shift;
        my $dir  = shift;

        $self->{Directory} = $dir;
}

sub setComment {
        my $self    = shift;
        my $comment = shift;

        $self->{Comment} = $comment;
}

sub toString {
        my $self   = shift;
        my $string = "";

        $string = join("|",
                $self->{Id},        $self->{Name},
                $self->{Directory}, $self->{Comment});

        return $string;
}

1;
