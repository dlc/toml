use strict;
use ExtUtils::MakeMaker;

my %clean = (
    'FILES' => '$(DISTVNAME).tar$(SUFFIX) *.ppd'
);

my %dist = (
    PREOP => 'perldoc -t TOML.pm > README',
);

my %prereq = (
    'Text::Balanced' => 0,
    'TOML::Parser'   => 0,
);

WriteMakefile(
    'NAME'          => 'TOML',
    'AUTHOR'        => 'darren chamberlain <darren@cpan.org>',
    'ABSTRACT_FROM' => 'TOML.pm',
    'VERSION_FROM'  => 'TOML.pm',
    'PREREQ_PM'     => \%prereq,
    'clean'         => \%clean,
    'dist'          => \%dist,
);
