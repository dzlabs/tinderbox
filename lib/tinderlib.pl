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
# $MCom: portstools/tinderbox/lib/tinderlib.pl,v 1.20 2007/10/13 02:28:46 ade Exp $
#

use strict;
use Net::SMTP;
use Sys::Hostname;

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

sub tinderLoc {
        my $pb   = shift;
        my $type = shift;
        my $what = shift;

        return "$pb/builds/$what"     if ($type eq 'builddata');
        return "$pb/errors/$what"     if ($type eq 'builderrors');
        return "$pb/logs/$what"       if ($type eq 'buildlogs');
        return "$pb/packages/$what"   if ($type eq 'packages');
        return "$pb/scripts/$what"    if ($type eq 'scripts');
        return "$pb/portstrees/$what" if ($type eq 'portstrees');

        return "/nonexistent/tinderbox/$type/$what";
}

1;
