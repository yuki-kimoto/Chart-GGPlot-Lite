#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

plan tests => 1;

BEGIN {
    use_ok( 'Chart::GGPlot::Lite' ) || print "Bail out!\n";
}

diag( "Testing Chart::GGPlot::Lite $Chart::GGPlot::Lite::VERSION, Perl $], $^X" );
