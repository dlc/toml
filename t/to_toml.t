use strict;
use warnings;
use utf8;
use Test::More;

use TOML;

is(to_toml(
    +{
        foo => 'bar',
    }
), <<'...', 'str');
foo = "bar"
...

is(to_toml(
    +{
        foo => 3,
    }
), <<'...', 'int');
foo = 3
...

is(to_toml(
    +{
        foo => {
            bar => 'baz',
            iya => 'aan',
        },
    }
), <<'...', 'nest');
[foo]
bar = "baz"
iya = "aan"
...

is(to_toml(
    +{
        foo => {
            bar => 'baz',
            iya => 'aan',
        },
        ya => [1,2,'3'],
    }
), <<'...', 'array');
ya = [1, 2, "3"]
[foo]
bar = "baz"
iya = "aan"
...

done_testing;

