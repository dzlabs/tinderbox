package TinderboxDS;

use strict;
use Port;
use Jail;
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

sub getAllPorts {
        my $self  = shift;
        my @ports = ();

        my @result;

        my $rc = $self->_doQueryHashRef("SELECT * FROM ports", \@result);

        if (!$rc) {
                return undef;
        }

        foreach (@result) {
                my $port = new Port(
                        {
                                Id        => $_->{'Port_Id'},
                                Name      => $_->{'Port_Name'},
                                Directory => $_->{'Port_Directory'},
                                Comment   => $_->{'Port_Comment'}
                        }
                );
                push @ports, $port;
        }

        return @ports;
}

sub getPortById {
        my $self = shift;
        my $id   = shift;

        my @results = $self->getPorts({Id => $id});

        if (!defined(@results)) {
                return undef;
        }

        return $results[0];
}

sub getPortByDirectory {
        my $self = shift;
        my $dir  = shift;

        my @results = $self->getPorts({Directory => $dir});

        if (!defined(@results)) {
                return undef;
        }

        return $results[0];
}

sub getPorts {
        my $self      = shift;
        my @params    = @_;
        my $condition = "";
        my @ports     = ();

        my @values = ();
        my @conds  = ();
        foreach my $param (@params) {

                # Each parameter makes up and OR portion of a query.  Within
                # each parameter is a hash reference that make up the AND
                # portion of the query.
                my @ands = ();
                foreach my $andcond (keys %{$param}) {
                        push @ands,   "Port_$andcond=?";
                        push @values, $param->{$andcond};
                }
                push @conds, "(" . (join(" AND ", @ands)) . ")";
        }

        $condition = join(" OR ", @conds);

        my @results;
        my $query;
        if ($condition ne "") {
                $query = "SELECT * FROM ports WHERE $condition";
        } else {
                $query = "SELECT * FROM ports";
        }

        my $rc = $self->_doQueryHashRef($query, \@results, @values);

        if (!$rc) {
                return undef;
        }

        foreach (@results) {
                my $port = new Port(
                        {
                                Id        => $_->{'Port_Id'},
                                Name      => $_->{'Port_Name'},
                                Directory => $_->{'Port_Directory'},
                                Comment   => $_->{'Port_Comment'}
                        }
                );
                push @ports, $port;
        }

        return @ports;
}

sub getJails {
        my $self      = shift;
        my @params    = @_;
        my $condition = "";
        my @jails     = ();

        my @values = ();
        my @conds  = ();
        foreach my $param (@params) {

                # Each parameter makes up and OR portion of a query.  Within
                # each parameter is a hash reference that make up the AND
                # portion of the query.
                my @ands = ();
                foreach my $andcond (keys %{$param}) {
                        push @ands,   "Port_$andcond=?";
                        push @values, $param->{$andcond};
                }
                push @conds, "(" . (join(" AND ", @ands)) . ")";
        }

        $condition = join(" OR ", @conds);

        my @results;
        my $query;
        if ($condition ne "") {
                $query = "SELECT * FROM jails WHERE $condition";
        } else {
                $query = "SELECT * FROM jails";
        }

        my $rc = $self->_doQueryHashRef($query, \@results, @values);

        if (!$rc) {
                return undef;
        }

        foreach (@results) {
                my $jail = new Port(
                        {
                                Id   => $_->{'Jail_Id'},
                                Name => $_->{'Jail_Name'},
                                Tag  => $_->{'Jail_Tag'}
                        }
                );
                push @jails, $jail;
        }

        return @jails;
}

sub addPort {
        my $self = shift;
        my $port = shift;
        my $pCls = ref($port) ? $$port : $port;

        my $rc = $self->_doQuery(
                "INSERT INTO ports (Port_Directory, Port_Name, Port_Comment) VALUES (?, ?, ?)",
                [$pCls->getDirectory(), $pCls->getName(), $pCls->getComment()]
        );

        if (ref($port)) {
                $$port = $self->getPortByDirectory($pCls->getDirectory());
        }

        return $rc;
}

sub addPortForJail {
        my $self = shift;
        my $port = shift;
        my $jail = shift;

        my $rc =
            $self->_doQuery(
                "INSERT INTO jail_ports (Jail_Id, Port_Id) VALUES (?, ?)",
                [$jail->getId(), $port->getId()]);

        return $rc;
}

sub isPortInDS {
        my $self = shift;
        my $port = shift;

        my $rc =
            $self->_doQueryNumRows(
                "SELECT Port_Id FROM ports WHERE Port_Directory=?",
                $port->getDirectory());

        return ($rc > 0) ? 1 : 0;
}

sub isValidJail {
        my $self     = shift;
        my $jailName = shift;

        my @results = $self->getJails({Name => $jailName});

        if (!defined(@results)) {
                return 0;
        }

        if (scalar(@results)) {
                return 1;
        }

        return 0;
}

sub isPortForJail {
        my $self  = shift;
        my $port  = shift;
        my $jail  = shift;
        my $valid = 1;

        my @result;
        my $rc = $self->_doQueryHashRef(
                "SELECT Jail_Name FROM jails WHERE Jail_Id IN (SELECT Jail_Id FROM jail_ports WHERE Port_Id=?)",
                \@result, $port->getId()
        );

        foreach (@result) {
                if ($jail->getName() eq $_->{'Jail_Name'}) {
                        $valid = 1;
                        last;
                }
                $valid = 0;
        }

        return $valid;
}

sub getAllJails {
        my $self = shift;
        my (@jails);

        my @result;
        my $rc = $self->_doQueryHashRef("SELECT * FROM jails", \@result);

        if (!$rc) {
                return undef;
        }

        foreach (@result) {
                my $jail = new Jail(
                        {
                                Id   => $_->{'Id'},
                                Name => $_->{'Name'},
                                Tag  => $_->{'Tag'}
                        }
                );
                push @jails, $jail;
        }

        return @jails;
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
