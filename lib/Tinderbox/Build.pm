package Build;

use strict;
use TinderObject;
use vars qw(@ISA);
@ISA = qw(TinderObject);

sub new {
        my $that        = shift;
        my $object_hash = {
                Build_Id          => "",
                Build_Name        => "",
                Jail_Id           => "",
                Ports_Tree_Id     => "",
                Build_Description => "",
        };

        my @args = ();
        push @args, $object_hash, @_;

        $that->SUPER::new(@args);
}

sub getId {
        my $self = shift;

        return $self->{Build_Id};
}

sub getName {
        my $self = shift;

        return $self->{Build_Name};
}

sub getJailId {
        my $self = shift;

        return $self->{Jail_Id};
}

sub getPortsTreeId {
        my $self = shift;

        return $self->{Ports_Tree_Id};
}

sub getDescription {
        my $self = shift;

        return $self->{Build_Description};
}

sub setName {
        my $self = shift;
        my $name = shift;

        $self->{Build_Name} = $name;
}

sub setJailId {
        my $self = shift;
        my $id   = shift;

        $self->{Jail_Id} = $id;
}

sub setPortsTreeId {
        my $self = shift;
        my $id   = shift;

        $self->{Ports_Tree_Id} = $id;
}

sub setDescription {
        my $self  = shift;
        my $descr = shift;

        $self->{Build_Description} = $descr;
}

1;
