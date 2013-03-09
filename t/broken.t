#!/usr/bin/perl

use strict;
use Test::More tests => 3;

use_ok("TOML");

# Syntactically invalid example, originally from https://rt.cpan.org/Ticket/Display.html?id=83836
my $toml = q{foo = "bar'};
my $new;
my $err;
my $serr = $TOML::SYNTAX_ERROR = $TOML::SYNTAX_ERROR ;

$new = from_toml($toml);
is($new, undef, "Invalid syntax returns <undef> in scalar context");

($new, $err) = from_toml($toml);
like($err, qr/^$serr/, 'Invalid syntx returns <undef>, $err in list context');
