#!/home/gonz/.rakudobrew/bin/perl6

use v6;

sub dirs($path) {
    # Perl6 filter function
    dir($path).grep( { $_.d } );
}

sub has-git-dir($path) {
    # Perl6 `in` operator, sort of. Do any elements in array match the regex?
    any(dirs($path)) ~~ /".git"/;
}

sub get-git-status($path) {
    my $curdir = $*CWD;
    chdir($path);
    my $git-output = run("git", "status", :out).out.slurp-rest;
    chdir($curdir);
    $git-output;
}

sub git-changed($path) {
    not get-git-status($path) ~~ /"nothing to commit, working directory clean"/;
}

sub announce($path) {
    say($path.Str, " should be checked.");
}

sub git-dirs(@dirs) {
    if not @dirs {
        ();
    } else {
        my ($head, *@tail) = @dirs;
        has-git-dir($head)
            ?? [$head, |git-dirs(@tail)]
            !! [|git-dirs(dirs($head)), |git-dirs(@tail)];
    }
}
sub check-dir($path) {
    for git-dirs(dirs($path)).grep( { git-changed($_) } ) {
        announce($_);
    }
}

check-dir(".");
