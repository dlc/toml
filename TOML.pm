package TOML;

# -------------------------------------------------------------------
# TOML - Parser for Tom's Obvious, Minimal Language.
#
# Copyright (C) 2013 Darren Chamberlain <darren@cpan.org>
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License as
# published by the Free Software Foundation; version 2.
#
# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
# 02111-1301 USA
# -------------------------------------------------------------------

use strict;
use vars qw($VERSION @EXPORT);
use base qw(Exporter);

use Text::Balanced qw(extract_bracketed);

$VERSION = "0.9";
@EXPORT = qw(from_toml);

sub from_toml {
    my $string = shift;
    my %toml;   # Final data structure
    my $cur;

    # Normalize
    $string =
        join "\n",
        grep !/^$/,
        map { s/^\s*//; s/\s*$//; $_ } 
        map { s/#.*//; $_ }
        split /[\n\r]/, $string;

    while ($string) {
        # strip leading whitespace, including newlines
        $string =~ s/^\s*//s;

        # Strings
        if ($string =~ s/^(\S+)\s*=\s*"([^"]*)"\s*//) {
            my $key = "$1";
            my $val = "$2";
            $val =~ s/^"//;
            $val =~ s/"$//;
            $val =~ s/\\0/\x00/g;
            $val =~ s/\\t/\x09/g;
            $val =~ s/\\n/\x0a/g;
            $val =~ s/\\r/\x0d/g;
            $val =~ s/\\"/\x22/g;
            $val =~ s/\\\\/\x5c/g;

            if ($cur) {
                $cur->{ $key } = $val;
            }
            else {
                $toml{ $key } = $val;
            }
        }

        # Boolean
        if ($string =~ s/^(\S+)\s*=\s*(true|false)//i) {
            my $key = "$1";
            my $num = lc($2) eq "true" ? "true" : "false";
            if ($cur) {
                $cur->{ $key } = $num;
            }
            else {
                $toml{ $key } = $num;
            }
        }

        # Date
        if ($string =~ s/^(\S+)\s*=\s*(\d\d\d\d\-\d\d\-\d\dT\d\d:\d\d:\d\dZ)\s*//) {
            my $key = "$1";
            my $date = "$2";
            if ($cur) {
                $cur->{ $key } = $date;
            }
            else {
                $toml{ $key } = $date;
            }
        }

        # Numbers
        if ($string =~ s/^(\S+)\s*=\s*([+-]?[\d.]+)\n//) {
            my $key = "$1";
            my $num = $2;
            if ($cur) {
                $cur->{ $key } = $num;
            }
            else {
                $toml{ $key } = $num;
            }
        }

        # Arrays
        if ($string =~ s/^(\S+)\s=\s*(\[)/[/) {
            my $key = "$1";
            my $match;
            ($match, $string) = extract_bracketed($string, "[]");
            if ($cur) {
                $cur->{ $key } = eval $match || $match;
            }
            else {
                $toml{ $key } = eval $match || $match;
            }
        }

        # New section
        elsif ($string =~ s/^\[([^]]+)\]\s*//) {
            my $section = "$1";
            $cur = undef;
            my @bits = split /\./, $section;

            for my $bit (@bits) {
                if ($cur) {
                    $cur->{ $bit } ||= { };
                    $cur = $cur->{ $bit };
                }
                else {
                    $toml{ $bit } ||= { };
                    $cur = $toml{ $bit };
                }
            }
        }
    }

    return \%toml;
}

1;

__END__

=head1 NAME

TOML - Parser for Tom's Obvious, Minimal Language.

=head1 SYNOPSIS

    use TOML qw(from_toml);

    my $toml = slurp("~/.foo.toml");
    my $data = from_toml($toml);

=head1 DESCRIPTIOn

C<TOML> implements a parser for Tom's Obvious, Minimal Language, as
defined at L<https://github.com/mojombo/toml>.

C<TOML> exports a single subroutine, C<from_toml>, that transforms a string
containing toml to a perl data structure. This data structure complies
with the tests provided at L<https://github.com/mojombo/toml/tree/master/tests>.



=head1 AUTHOR

Darren Chamberlain <darren@cpan.org>

