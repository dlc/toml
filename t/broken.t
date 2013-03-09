#!/usr/bin/perl

use strict;
use Test::More tests => 3;

use_ok("TOML");

# Syntactically invalid example, originally from https://rt.cpan.org/Ticket/Display.html?id=83836
my $toml = q{foo = "bar'};
my $new;
my $err;

$new = from_toml($toml);
is($new, undef, "Invalid syntax returns <undef> in scalar context");

($new, $err) = from_toml($toml);
is($err, $TOML::SYNTAX_ERROR, 'Invalid syntx returns <undef>, $err in list context');
