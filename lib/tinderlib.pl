sub cleanup {
        my ($ds, $code, $msg) = @_;

        if ($code && defined($msg)) {
                $msg = "ERROR: " . $msg;
        } elsif (defined($msg)) {
                $msg = "INFO: " . $msg;
        }

        $ds->destroy()    if (defined($ds));
        print STDERR $msg if (defined($msg));

        exit($code);
}

sub buildenv {
        my $pb        = shift;
        my $build     = shift;
	my $jail      = shift;
        my $portstree = shift;

        my ($major_version) = ($jail =~ /(^\d)/);

        open(RAWENV, "$pb/scripts/rawenv")
            or die "ERROR: Cannot open $pb/scripts/rawenv for reading: $!\n";

        while (<RAWENV>) {
                chomp;
                s/^#$major_version//;
                next if /^#/;
                s|##PB##|$pb|g;
                s|##BUILD##|$build|g;
		s|##JAIL##|$jail|g;
                s|##PORTSTREE##|$portstree|g;
                s|\^\^([^\^]+)\^\^|$ENV{$1}|g;
                my ($var, $expr) = split(/=/, $_, 2);
                my @words = split(/\s+/, $expr);
                my @cmd = (), @value = ();
                my $exec = 0;
            WORD: foreach my $word (@words) {

                        if ($word !~ /^`/ && !$exec) {
                                push @value, $word;
                        } else {
                                $exec = 1;
                                $word =~ s/^`//;
                                if ($word !~ /`$/) {
                                        push @cmd, $word;
                                        next WORD;
                                }
                                $word =~ s/`$//;
                                push @cmd, $word;
                                my $cmd_string = join(" ", @cmd);
                                my $eval = `$cmd_string`;
                                chomp $eval;
                                push @value, $eval;
                                $exec = 0;
                                @cmd  = ();
                        }
                }
                $ENV{$var} = join(" ", @value);
        }

        close(RAWENV);
}

1;
