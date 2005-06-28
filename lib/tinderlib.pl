#-
# Copyright (c) 2004-2005 FreeBSD GNOME Team <freebsd-gnome@FreeBSD.org>
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
# 1. Redistributions of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in the
#    documentation and/or other materials provided with the distribution.
#
# THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ``AS IS'' AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
# OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
# HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
# LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
# OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
# SUCH DAMAGE.
#
# $MCom: portstools/tinderbox/lib/tinderlib.pl,v 1.6 2005/06/28 05:47:55 adamw Exp $
#

use strict;
use Net::SMTP;

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
                my @cmd = (), my @value = ();
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

# This function sends email based on the given parameters.
#   $from should be one valid email address
#   $to should be a reference to an array of addresses
#   $subject should be a valid email subject line
#   $data should be a string representing the body of the email
#   $host should be the SMTP host through which the mail will be relayed
sub sendMail {
        my ($from, $to, $subject, $data, $host) = @_;
        my ($smtp, $header);
        my $rc = 1;

        $smtp = Net::SMTP->new($host);
        $smtp->mail($from);
        $smtp->to(@{$to});

        $header = "From: $from\n";
        $header .= "To: " . (join(",", @{$to}));
        $header .= "\n";
        $header .= "Subject: $subject\n";
        $header .= "\n";

        $data = $header . $data;

        $rc = $smtp->data($data);

        $smtp->quit;

        return $rc;
}

1;
