# Copyright (c) 2004-2005 Ade Lovett <ade@FreeBSD.org>
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
# $MCom: portstools/tinderbox/lib/Tinderbox/MakeCache.pm,v 1.1 2005/07/19 07:18:20 marcus Exp $
#

package MakeCache;

use strict;

# a list of variables that we pull from the port Makefile
our @makeTargets = (
    'PKGNAME',
    'IGNORE',
    'NO_PACKAGE',
    'FORBIDDEN',
    'EXTRACT_DEPENDS',
    'PATCH_DEPENDS',
    'FETCH_DEPENDS',
    'BUILD_DEPENDS',
    'LIB_DEPENDS',
    'RUN_DEPENDS',
    'DEPENDS',
    'MAINTAINER',
    'COMMENT',
);

# Create a new cache object
sub new {
    my $name = shift;
    my $self = bless {
	CACHE   => undef,
	SEEN    => undef,
	BASEDIR => shift,
    }, $name;

    $self;
}

# A wrapper around make(1) in the port directory, if the cache object
# is present, simply return, otherwise pull all the requested variables
# into the cache
sub _execMake {
    my $self = shift;
    my $port = shift;
    my @ret;
    my $tmp;

    return if ($self->{SEEN}->{$port} eq 1);

    $tmp = '-V ' . join(' -V ', @makeTargets);
    my $dir = $self->{BASEDIR} . '/' . $port;
    @ret = split("\n", `cd $dir && make $tmp`);

    foreach $tmp (@makeTargets) {
	$self->{CACHE}->{$port}{$tmp} = shift @ret;
    }
    $self->{SEEN}->{$port} = 1;
}

# Internal function for returning a port variable
sub _getVariable {
    my $self = shift;
    my $port = shift;
    my $var  = shift;

    $self->_execMake($port);
    return $self->{CACHE}->{$port}{$var};
}

# Internal function for returning a port dependency list
sub _getList {
    my $self = shift;
    my $port = shift;
    my $item = shift;
    my @deps;

    $self->_execMake($port);
    foreach my $dep (split(/\s+/, $self->{CACHE}->{$port}{$item})) {
	my ($d, $ddir) = split(/:/, $dep);
	$ddir =~ s|^$self->{BASEDIR}/||;
	push @deps, $ddir;
    }
    return @deps;
}

# Package name
sub PkgName {
    my $self = shift;
    my $port = shift;
    return $self->_getVariable($port, 'PKGNAME');
}

# Port comment
sub Comment {
    my $self = shift;
    my $port = shift;
    return $self->_getVariable($port, 'COMMENT');
}

# Port maintainer
sub Maintainer {
    my $self = shift;
    my $port = shift;
    return $self->_getVariable($port, 'MAINTAINER');
}

# Extract dependencies
sub ExtractDepends {
    my $self = shift;
    my $port = shift;
    return $self->_getList($port, 'EXTRACT_DEPENDS');
}

# Patch dependencies
sub PatchDepends {
    my $self = shift;
    my $port = shift;
    return $self->_getList($port, 'PATCH_DEPENDS');
}

# Fetch dependencies
sub FetchDepends {
    my $self = shift;
    my $port = shift;
    return $self->_getList($port, 'FETCH_DEPENDS');
}

# Build dependencies
sub BuildDepends {
    my $self = shift;
    my $port = shift;
    return $self->_getList($port, 'BUILD_DEPENDS');
}

# Library dependencies
sub LibDepends {
    my $self = shift;
    my $port = shift;
    return $self->_getList($port, 'LIB_DEPENDS');
}

# Run dependencies
sub RunDepends {
    my $self = shift;
    my $port = shift;
    return $self->_getList($port, 'RUN_DEPENDS');
}

# Other dependencies
sub Depends {
    my $self = shift;
    my $port = shift;
    return $self->_getList($port, 'DEPENDS');
}

# A close approximation to the 'ignore-list' target
sub IgnoreList {
    my $self = shift;
    my $port = shift;

    my $n = 0;
    $self->_execMake($port);
    foreach my $var ('NO_PACKAGE', 'IGNORE', 'FORBIDDEN') {
	$n++ if ($self->{CACHE}->{$port}{$var} ne "");
    }
    return $n eq 0 ? "" : $self->PkgName($port);
}

# A close approximation to the 'build-depends-list' target
sub BuildDependsList {
    my $self = shift;
    my $port = shift;

    my @deps;
    push(@deps, $self->ExtractDepends($port));
    push(@deps, $self->PatchDepends($port));
    push(@deps, $self->FetchDepends($port));
    push(@deps, $self->BuildDepends($port));
    push(@deps, $self->LibDepends($port));
    push(@deps, $self->Depends($port));

    my %uniq;
    return grep { !$uniq{$_}++ } @deps;
}

# A close approximation to the 'run-depends-list' target
sub RunDependsList {
    my $self = shift;
    my $port = shift;

    my @deps;
    push(@deps, $self->LibDepends($port));
    push(@deps, $self->RunDepends($port));
    push(@deps, $self->Depends($port));

    my %uniq;
    return grep { !$uniq{$_}++ } @deps;
}
