#!/usr/bin/env perl

use strict;
use warnings FATAL => qw(all);

my %all_files = ();

my $cmd = 'git ls-files';
open(GIT, '-|', $cmd) or
    die "failed to run \"$cmd\"";
while (my $l = <GIT>) {
    chomp($l);
    $all_files{$l} = {};
}
close(GIT);

my $cur_year;
{
    my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time());
    $cur_year = 1900 + $year;
}

$cmd = 'git log \'--pretty=format:commit %H at %ai\' --name-only';
open(GIT, '-|', $cmd) or
    die "failed to run \"$cmd\"";
my $year;
while (my $l = <GIT>) {
    chomp($l);
    if ($l =~ /^commit [0-9a-f]{40} at (\d{4})-\d{2}-\d{2} \d{1,2}:\d{1,2}:\d{1,2} [+-]\d{4}$/) {
        $year = $1+0;
    } else {
        # ignore files that don't currently exist
        $all_files{$l}->{$year} = 1 if $all_files{$l};
    }
}
close(GIT);

foreach my $fn (keys %all_files) {
    print($fn . " " . join(', ', sort(keys(%{$all_files{$fn}}))) . "\n");
}
