#!/usr/bin/env perl

# Copyright (c) 2009, Nikolas Coukouma. All rights reserved.
# Distributed under the terms of a BSD-style license. See COPYING for details.

use File::Copy;
use IO::File;

use strict;
use warnings FATAL => qw(all);

my $SUFFIX = ".diff";

unless (@ARGV) {
    print STDERR <<XXX;
gen-patch.pl REVISION-SPEC [PATH1 [PATH2 ...]]
XXX
    exit 1;
}

my ($rev, @paths) = @ARGV;
# try to make a range if we didn't get one...
$rev .= '..HEAD' unless $rev =~ /\.\./;

my $with_git = sub {
    my @git_args = @_;
    die "nothing passed to with_git" unless @git_args;
    my $cb = pop @git_args;
    open(my $git, '-|', 'git', @git_args) or
        die("failed to run git" . join(' ', @git_args));
    $cb->($git);
    close($git) or
        die("command returned non-zero status: git" . join(' ', @git_args));
};

my @rev_names = ();

$with_git->('log', $rev, '--', @paths, sub {
    my ($git) = @_;
    while (my $l = <$git>) {
        if ($l =~ /^commit ([0-9a-f]{7})/) {
            push @rev_names, $1;
        }
    }
});

my $p_fn = join('-', @rev_names) . "$SUFFIX";
die "patch file $p_fn already exists, not clobbering" if -f $p_fn;
my $p_fh = IO::File->new($p_fn, "w") or
    die "failed to open $p_fn for writing";
$SIG{__DIE__} = sub {
    unlink $p_fn;
};

$with_git->('log', $rev, '--', @paths, sub {
    my ($git) = @_;
    while (my $l = <$git>) {
        print $p_fh $l;
    }
});

print $p_fh "\n\n";

$with_git->('diff', '-p', '--stat', $rev, '--', @paths, sub {
    my ($git) = @_;
    while (my $l = <$git>) {
        print $p_fh $l;
    }
});

print "wrote $p_fn\n";
