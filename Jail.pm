package Jail;

use strict;
use TinderObject;
use vars qw(@ISA);
@ISA = qw(TinderObject);

sub new {
        my $that        = shift;
        my $object_hash = {
                Jail_Id          => "",
                Jail_Name        => "",
                Jail_Tag         => "",
                Jail_Last_Built  => "",
                Jail_Update_Cmd  => "",
                Jail_Description => "",
        };

        my @args = ();
        push @args, $object_hash, @_;

        $that->SUPER::new(@args);
}

sub getId {
        my $self = shift;

        return $self->{Jail_Id};
}

sub getName {
        my $self = shift;

        return $self->{Jail_Name};
}

sub getTag {
        my $self = shift;

        return $self->{Jail_Tag};
}

sub getLastBuilt {
        my $self = shift;

        return $self->{Jail_Last_Built};
}

sub getUpdateCmd {
        my $self = shift;

        return $self->{Jail_Update_Cmd};
}

sub getDescription {
        my $self = shift;

        return $self->{Jail_Description};
}

sub setName {
        my $self = shift;
        my $name = shift;

        $self->{Jail_Name} = $name;
}

sub setTag {
        my $self = shift;
        my $tag  = shift;

        $self->{Jail_Tag} = $tag;
}

sub setLastBuilt {
        my $self       = shift;
        my $updateTime = shift;

        $self->{Jail_Last_Built} = $updateTime;
}

sub setUpdateCmd {
        my $self      = shift;
        my $updateCmd = shift;

        $self->{Jail_Update_Cmd} = $updateCmd;
}

sub setDescription {
        my $self  = shift;
        my $descr = shift;

        $self->{Description} = $descr;
}

1;
