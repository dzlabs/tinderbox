package PortsTree;

use strict;
use TinderObject;
use vars qw(@ISA);
@ISA = qw(TinderObject);

sub new {
        my $that        = shift;
        my $object_hash = {
                Ports_Tree_Id          => "",
                Ports_Tree_Name        => "",
                Ports_Tree_Description => "",
                Ports_Tree_Last_Built  => "",
                Ports_Tree_Update_Cmd  => "",
        };

        my @args = ();
        push @args, $object_hash, @_;

        $that->SUPER::new(@args);
}

sub getId {
        my $self = shift;

        return $self->{Ports_Tree_Id};
}

sub getName {
        my $self = shift;

        return $self->{Ports_Tree_Name};
}

sub getDescription {
        my $self = shift;

        return $self->{Ports_Tree_Description};
}

sub getTag {
        my $self = shift;

        return $self->{Ports_Tree_Tag};
}

sub getLastBuilt {
        my $self = shift;

        return $self->{Ports_Tree_Last_Built};
}

sub getUpdateCmd {
        my $self = shift;

        return $self->{Ports_Tree_Update_Cmd};
}

sub setName {
        my $self = shift;
        my $name = shift;

        $self->{Ports_Tree_Name} = $name;
}

sub setDescription {
        my $self  = shift;
        my $descr = shift;

        $self->{Ports_Tree_Description} = $descr;
}

sub setLastBuilt {
        my $self       = shift;
        my $updateTime = shift;

        $self->{Ports_Tree_Last_Built} = $updateTime;
}

sub setUpdateCmd {
        my $self      = shift;
        my $updateCmd = shift;

        $self->{Ports_Tree_Update_Cmd} = $updateCmd;
}

1;
