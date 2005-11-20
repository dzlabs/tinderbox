#!/usr/bin/perl

use strict;
use vars qw($INFILE);

$INFILE = $ARGV[0];

if (!defined($INFILE)) {
        print "usage: $0 <input file>\n";
        exit(1);
}

unless (open(IN, $INFILE)) {
        print "ERROR: Failed to open $INFILE for reading: $!\n";
        exit(1);
}

my @rawpats = <IN>;

close(IN);

my $i        = 0;
my %parents  = ();
my @patterns = ();

foreach my $line (@rawpats) {
        my ($name, $parent);
        my $pattern = {};
        chomp $line;

        $line =~ s/^([^,]+),\s*//;
        $name = $1;

        $line =~ s/,\s*([^,]+)$//;
        $parent = $1;

        $pattern->{'body'} = $line;
        $pattern->{'id'}   = $i;
        if ($parent != 0) {
                $pattern->{'parent'} = $parents{$parent};
        } else {
                $pattern->{'parent'} = 0;
        }

        $parents{$name} = $i;
        push @patterns, $pattern;
        $i += 100;
}

foreach my $pat (@patterns) {
        print "INSERT INTO port_fail_patterns VALUES (";
        print $pat->{'id'} . ", ";
        print $pat->{'body'} . ", ";
        print $pat->{'parent'};
        print ");\n";
}
print "INSERT INTO port_fail_patterns VALUES (2147483647, '.*', '???', 0);\n";

