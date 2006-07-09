#!perl -T

use Test::More tests => 1;

BEGIN {
	use_ok( 'File::Attributes' );
}

diag( "Testing File::Attributes $File::Attributes::VERSION, Perl $], $^X" );
my @backends = File::Attributes::_modules;
diag( "Available backends: @backends." );
