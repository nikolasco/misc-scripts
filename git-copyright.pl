#!/usr/bin/env perl

# Copyright (c) 2009, Nikolas Coukouma. All rights reserved.
# Distributed under the terms of a BSD-style license. See COPYING for details.

use File::Copy;
use File::Temp;
use IO::File;

use strict;
use warnings FATAL => qw(all);

# lines matching PATTERN will be replaced with a notice, built from FORMAT
# format will be used in sprintf(), with %s being replaced by '2001, 2002'
my $COPY_NOTICE_PATTERN =
    qr/Copyright \(c\) (?:[-\d, ]+ )?Zmanda(?:,? Inc\.)? +All Rights Reserved\./;
my $COPY_NOTICE_FORMAT =
    'Copyright (c) %s Zmanda, Inc.  All Rights Reserved.';

my %all_files = ();

my $cmd = 'git ls-files';
open(my $git, '-|', $cmd) or
    die "failed to run \"$cmd\"";
while (my $l = <$git>) {
    chomp($l);
    $all_files{$l} = {};
}
close($git);

my $cur_year;
{
    my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time());
    $cur_year = 1900 + $year;
}

$cmd = 'git log \'--pretty=format:commit %H at %ai\' --name-only';
open($git, '-|', $cmd) or
    die "failed to run \"$cmd\"";
my $year;
while (my $l = <$git>) {
    chomp($l);
    if ($l =~ /^commit [0-9a-f]{40} at (\d{4})-\d{2}-\d{2} \d{1,2}:\d{1,2}:\d{1,2} [+-]\d{4}$/) {
        $year = $1+0;
    } else {
        # ignore files that don't currently exist
        $all_files{$l}->{$year} = 1 if $all_files{$l};
    }
}
close($git);

foreach my $fn (keys %all_files) {
    my $new_notice = sprintf($COPY_NOTICE_FORMAT,
        join(',', sort(keys(%{$all_files{$fn}}))));

    my $tmp = File::Temp->new(UNLINK => 0) or
        die "failed to create temporary file for $fn";
    my $file = IO::File->new($fn, 'r');

    while (my $l = <$file>) {
        $l =~ s/$COPY_NOTICE_PATTERN/$new_notice/;
        print $tmp $l;
    }

    close($tmp);
    close($file);

    copy($tmp->filename, $fn) or
        die "copying $tmp->filename to $fn failed: $!";
}
