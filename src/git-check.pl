#!/home/gonz/.rakudobrew/bin/perl6

use v6;

sub dirs-in-dir($path) {
    # Perl6 filter function
    dir($path).grep( { $_.d } );
}

sub has-git-dir($path) {
    # Perl6 `in` operator, sort of.
    any(dirs-in-dir($path)) ~~ /".git"/;
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
