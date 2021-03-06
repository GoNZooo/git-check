#!/home/gonz/.rakudobrew/bin/perl6

use v6;

sub get-git-status($path) {
    my $curdir = $*CWD;
    chdir($path);
    my $git-output = run("git", "status", "-s", :out).out.slurp-rest;
    chdir($curdir);
    $git-output;
}

sub git-changed($path) {
    so get-git-status($path);
}

sub announce($path) {
    say($path.Str, " should be checked.");
}

# Determines if two paths share the same root
sub same-root($path1, $path2) {
    $path2.starts-with($path1) || $path1.starts-with($path2);
}

# For a given path, filters out sub-paths from a sorted list of paths
sub filter-same-root($path, @dirs) {
    @dirs.grep({ not (same-root($path, $_)) });
}

# Filters out top-directories, so sub-directiores are not included
sub top-dirs(@dirs) {
    if (not @dirs) {
        ();
    } else {
        my $first = @dirs[0];
        my @unique-rest = filter-same-root($first, @dirs[1 .. @dirs.end]);
        [$first, |top-dirs(@unique-rest)];
    }
}

sub find-git-dirs($path) {
    my $find-output = run("find", $path, "-wholename", "*/.git", :out).out.slurp-rest;
    my @git-dirs = $find-output.lines.map({ $_.substr(0, *-4) }).sort;

    top-dirs(@git-dirs);
}

sub MAIN(Str $root-dir = ".") {
    for find-git-dirs($root-dir).grep({ git-changed $_ }) {
        announce($_);
    }
}

