package Build;

use strict;
use TinderObject;
use vars qw(@ISA %STATUS_HASH);
@ISA = qw(TinderObject);

%STATUS_HASH = (
        IDLE      => 0,
        PORTBUILD => 1,
);

sub new {
        my $that        = shift;
        my $object_hash = {
                Build_Id          => "",
                Build_Name        => "",
                Jail_Id           => "",
                Ports_Tree_Id     => "",
                Build_Status      => "",
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

sub getStatus {
        my $self = shift;

        return $self->{Build_Status};
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

sub setStatus {
        my $self   = shift;
        my $status = shift;

        if (defined($STATUS_HASH{$status})) {
                $self->{Build_Status} = $status;
        }
}

sub setDescription {
        my $self  = shift;
        my $descr = shift;

        $self->{Build_Description} = $descr;
}

1;
