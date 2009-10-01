#!/usr/bin/env perl

use File::Copy;

use strict;
use warnings FATAL => qw(all);

my $NAME = 'Nikolas Coukouma';
my $EMAIL = 'atrus@zmanda.com';

my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time());

my $OCL_NAME = 'ChangeLog';
my $NCL_NAME = 'ChangeLog~';

open my $DS, '-|', 'diffstat -l -p 1' or die 'failed to run diffstat';
open my $OCL, '<', $OCL_NAME or die "failed to open $OCL_NAME";
-f $NCL_NAME and die "$NCL_NAME already exists";
open my $NCL, '>', $NCL_NAME or die "failed to open $NCL_NAME";

my @files = ();
my $fn;
while ($fn = <$DS>) {
    chomp $fn;
    push @files, $fn;
}

printf $NCL "%04d-%02d-%02d  %s <%s>\n", $year+1900, $mon+1, $mday, $NAME, $EMAIL;

my $c_line = "\t* ";
my $some_files = 0;
while (@files) {
    $fn = shift @files;
    # start a new line before appending?
    if ($some_files and
        # +7 for tab, possible +2 for ", "
        (length($c_line)+7+length($fn)+($some_files? 2 : 0)) > 79) {
        print $NCL $c_line . ",\n";
        $c_line = "\t  ";
        $some_files = 0;
    }
    $c_line .= ($some_files? ", " : "") . $fn;
    $some_files = 1;
}
print $NCL "$c_line:\n\n";

close $DS;

while (my $l = <$OCL>) {
    print $NCL $l;
}

close $OCL;
close $NCL;

move($NCL_NAME, $OCL_NAME);
