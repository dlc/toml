#!/usr/bin/perl

use strict;
use Test::More tests => 2;

use_ok("TOML");

# Original structre
my $toml = q{# This is a TOML document. Boom.

title = "TOML Example"

[owner]
name = "Tom Preston-Werner"
organization = "GitHub"
bio = "GitHub Cofounder & CEO\nLikes tater tots and beer."
dob = 1979-05-27T07:32:00Z # First class dates? Why not?

[database]
server = "192.168.1.1"
ports = [ 8001, 8001, 8002 ]
connection_max = 5000
enabled = true

[servers]

  # You can indent as you please. Tabs or spaces. TOML don't care.
  [servers.alpha]
  ip = "10.0.0.1"
  dc = "eqdc10"

  [servers.beta]
  ip = "10.0.0.2"
  dc = "eqdc10"

[clients]
data = [ ["gamma", "delta"], [1, 2] ] # just an update to make sure parsers support it
};

# Expected structure
my $yaml = {
          'database' => {
                        'ports' => [
                                   '8001',
                                   '8001',
                                   '8002'
                                 ],
                        'connection_max' => '5000',
                        'server' => '192.168.1.1',
                        'enabled' => 'true'
                      },
          'owner' => {
                     'dob' => '1979-05-27T07:32:00Z',
                     'name' => 'Tom Preston-Werner',
                     'bio' => 'GitHub Cofounder & CEO
Likes tater tots and beer.',
                     'organization' => 'GitHub'
                   },
          'clients' => {
                       'data' => [
                                 [
                                   'gamma',
                                   'delta'
                                 ],
                                 [
                                   '1',
                                   '2'
                                 ]
                               ]
                     },
          'servers' => {
                       'alpha' => {
                                  'dc' => 'eqdc10',
                                  'ip' => '10.0.0.1'
                                },
                       'beta' => {
                                 'dc' => 'eqdc10',
                                 'ip' => '10.0.0.2'
                               }
                     },
          'title' => 'TOML Example'
        };



my $new = from_toml($toml);
is_deeply($yaml, $new, "Structure matches example YAML");
