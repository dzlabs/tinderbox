package TinderboxDS;

use strict;
use DBI;
use Carp;
use vars qw(
    $DB_DRIVER
    $DB_HOST
    $DB_NAME
    $DB_USER
    $DB_PASS
);

require "ds.ph";

sub new {
        my ($that, @args) = @_;
        my $class = ref($that) || $that;

        my $self = {
                dbh   => undef,
                error => undef,
        };

        my $dsn = "DBI:$DB_DRIVER:database=$DB_NAME;host=$DB_HOST";

        $self->{'dbh'} = DBI->connect($dsn, $DB_USER, $DB_PASS)
            or croak "Tinderbox DS: Unable to initialize datasource.";

        bless($self, $class);
        $self;
}

sub getPorts {
        my $self   = shift;
        my @fields = @_;

        my $fieldString = "*";
        my @result;
        if (defined(@fields)) {
                $fieldString = join(",", @fields);
        }

        my $rc =
            $self->_doQueryHashRef("SELECT $fieldString FROM ports", \@result);

        if (!$rc) {
                return undef;
        }

        return @result;
}

sub addPort {
        my $self        = shift;
        my $portdir     = shift;
        my $portname    = shift;
        my $portcomment = shift;

        my $rc =
            $self->_doQuery(
                "INSERT INTO ports (Port_Directory, Port_Name, Port_Comment) VALUES (?, ?, ?)",
                $portdir, $portname, $portcomment);

        return $rc;
}

sub isPortInDS {
        my $self    = shift;
        my $portdir = shift;

        my $rc =
            $self->_doQueryNumRows(
                "SELECT Port_Id FROM ports WHERE Port_Directory=?", $portdir);

        return ($rc > 0) ? 1 : 0;
}

sub isPortForJail {
        my $self     = shift;
        my $portId   = shift;
        my $jailType = shift;
        my $valid    = 1;

        my @result;
        my $rc = $self->_doQueryHashRef(
                "SELECT Jail_Type FROM jails WHERE Jail_Id IN (SELECT Jail_Id FROM jail_ports WHERE Port_Id=?)",
                \@result, $portId
        );

        foreach (@result) {
                if ($jailType eq $_->{'Jail_Type'}) {
                        $valid = 1;
                        last;
                }
                $valid = 0;
        }

        return $valid;
}

sub getJailTypes {
        my $self = shift;
        my (@jailTypes);

        my @result;
        my $rc =
            $self->_doQueryHashRef("SELECT Jail_Type FROM jails", \@result);

        if (!$rc) {
                return undef;
        }

        foreach (@result) {
                push @jailTypes, $_->{'Jail_Type'};
        }

        return @jailTypes;
}

sub getError {
        my $self = shift;

        return $self->{error};
}

sub _doQueryNumRows {
        my $self  = shift;
        my $class = ref $self;
        croak "Attempt to call private method" if ($class ne __PACKAGE__);
        my $query  = shift;
        my @params = @_;
        my $rows;

        my $sth;
        my $rc = $self->_doQuery($query, \@params, \$sth);

        if (!$rc) {
                return -1;
        }

        if ($sth->rows > -1) {
                $rows = $sth->rows;
        } else {
                my $all = $sth->fetchall_arrayref;
                $rows = scalar(@{$all});
        }

        $sth->finish;

        return $rows;
}

sub _doQueryHashRef {
        my $self  = shift;
        my $class = ref $self;
        croak "Attempt to call private method" if ($class ne __PACKAGE__);
        my $query  = shift;
        my $result = shift;
        my @params = @_;

        my $sth;
        my $rc = $self->_doQuery($query, \@params, \$sth);

        if (!$rc) {
                $result = undef;
                return 0;
        }

        my $hash_ref;
        while ($hash_ref = $sth->fetchrow_hashref) {
                push @{$result}, $hash_ref;
        }

        $sth->finish;

        1;
}

sub _doQuery {
        my $self  = shift;
        my $class = ref $self;
        croak "Attempt to call private method" if ($class ne __PACKAGE__);
        my $query  = shift;
        my $params = shift;
        my $sth    = shift;    # Optional

        my $_sth;              # This is the real statement handler.

        $_sth = $self->{'dbh'}->prepare($query);

        if (!$_sth) {
                $self->{'error'} = $_sth->error;
                return 0;
        }

        if (scalar(@{$params})) {
                $_sth->execute(@{$params});
        } else {
                $_sth->execute;
        }

        if (!$_sth) {
                $self->{'error'} = $_sth->error;
                return 0;
        }

        if (defined($sth)) {
                $$sth = $_sth;
        } else {
                $_sth->finish;
        }

        1;
}

sub destroy {
        my $self = shift;

        $self->{error} = undef;
        $self->{dbh}->disconnect;
}

1;
