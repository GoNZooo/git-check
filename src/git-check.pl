#!/home/gonz/.rakudobrew/bin/perl6

use v6;

# TODO: Replace with filter function
sub dirs-in-dir($path) {
    my @dirs;
    for dir($path) -> $d {
        $d.d ?? @dirs.push: $d !! next;
    }
    @dirs;
}

# TODO: Use dirs-in-dir() and something like a `in` operator
sub has-git-dir($path) {
    for dir($path) -> $d {
        $d.d && $d.Str ~~ /".git"/ ?? return True !! next;
    };
    False;
}

sub get-git-status($path) {
    my $curdir = $*CWD;
    chdir($path);
    my $git-output = run("git", "status", :out).out.slurp-rest;
    chdir($curdir);
    $git-output;
}

sub git-not-changed($git-output) {
    so $git-output ~~ /"nothing to commit, working directory clean"/;
}

sub check-dir($path) {
    if has-git-dir($path) {
        if !git-not-changed get-git-status($path) {
            say $path.Str, " should be checked."; 
        }
    } else {
        for dirs-in-dir($path) -> $d {
            check-dir($d);
        }
    }
}

check-dir(".");
