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
use base qw(Exporter);

our ($VERSION, @EXPORT, $SYNTAX_ERROR);

use Text::Balanced qw(extract_bracketed);

$VERSION = "0.9";
@EXPORT = qw(from_toml);
$SYNTAX_ERROR = q(Syntax error);

sub from_toml {
    my $string = shift;
    my %toml;   # Final data structure
    my $cur;
    my $err;    # Error

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

        # Store current value, to check for invalid syntax
        my $string_start = $string;

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

        if ($string eq $string_start) {
            # If $string hasn't been modified by this point, then
            # it contains invalid syntax.
            return wantarray ? (undef, $SYNTAX_ERROR) : undef;
        }
    }

    return wantarray ? (\%toml, $err) : \%toml;
}

1;

__END__

=head1 NAME

TOML - Parser for Tom's Obvious, Minimal Language.

=head1 SYNOPSIS

    use TOML qw(from_toml);

    my $toml = slurp("~/.foo.toml");
    my $data = from_toml($toml);

    # With error checking
    my ($data, $err) = from_toml($toml);
    unless ($data) {
        die "Error parsing toml: $err";
    }

=head1 DESCRIPTION

C<TOML> implements a parser for Tom's Obvious, Minimal Language, as
defined at L<https://github.com/mojombo/toml>.

C<TOML> exports a single subroutine, C<from_toml>, that transforms a string
containing toml to a perl data structure. This data structure complies
with the tests provided at L<https://github.com/mojombo/toml/tree/master/tests>.

If called in list context, C<from_toml> produces a (C<hash>, C<error_string>) tuple,
where C<error_string> is C<undef> on non-errors. If there is an error, then
C<hash> will be undefined and C<error_string> will contains (scant) details about
said error.

=head1 AUTHOR

Darren Chamberlain <darren@cpan.org>

