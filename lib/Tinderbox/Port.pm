package Port;

use strict;
use TinderObject;
use vars qw(@ISA);
@ISA = qw(TinderObject);

sub new {
        my $that        = shift;
        my $object_hash = {
                Port_Id        => "",
                Port_Name      => "",
                Port_Directory => "",
                Port_Comment   => "",
        };

        my @args = ();
        push @args, $object_hash, @_;

        $that->SUPER::new(@args);
}

sub getId {
        my $self = shift;

        return $self->{Port_Id};
}

sub getName {
        my $self = shift;

        return $self->{Port_Name};
}

sub getDirectory {
        my $self = shift;

        return $self->{Port_Directory};
}

sub getComment {
        my $self = shift;

        return $self->{Port_Comment};
}

sub setName {
        my $self = shift;
        my $name = shift;

        $self->{Port_Name} = $name;
}

sub setDirectory {
        my $self = shift;
        my $dir  = shift;

        $self->{Port_Directory} = $dir;
}

sub setComment {
        my $self    = shift;
        my $comment = shift;

        $self->{Port_Comment} = $comment;
}

1;
