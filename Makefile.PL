use strict;
use ExtUtils::MakeMaker;

my %clean = (
    'FILES' => '$(DISTVNAME).tar$(SUFFIX) *.ppd'
);

my %dist = (
    PREOP => 'perldoc -t TOML.pm > README',
);

WriteMakefile(
    'NAME'          => 'TOML',
    'AUTHOR'        => 'darren chamberlain <darren@cpan.org>',
    'ABSTRACT_FROM' => 'TOML.pm',
    'VERSION_FROM'  => 'TOML.pm',
    'clean'         => \%clean,
    'dist'          => \%dist,
);
