use strict;
use warnings;
use utf8;
use Test::More tests => 4;

use_ok("TOML");

my ($dat, $err) = from_toml(<<'...');
all="\b\t\n\f\r\"\/\\"
unichar="\u0022"
...
ok(!$err) or diag $err;

is($dat->{all}, "\x08\x09\x0A\x0C\x0D\x22\x2F\x5C");
is($dat->{unichar}, q{"});

