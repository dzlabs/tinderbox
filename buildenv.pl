#!/usr/bin/perl

sub buildenv {
        my $pb   = shift;
        my $jail = shift;

        my ($major_version) = ($jail =~ /(^\d)/);

        open(RAWENV, "$pb/scripts/rawenv")
            or die "Cannot open $pb/scripts/rawenv for reading: $!\n";

        while (<RAWENV>) {
                chomp;
                s/^#$major_version//;
                next if /^#/;
                s|##PB##|$pb|g;
                s|##JAIL##|$jail|g;
                s|##MAKE##|$pb/make.conf|g;
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
