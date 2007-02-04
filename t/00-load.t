#!perl -T

use Test::More tests => 1;

BEGIN {
	use_ok( 'File::Attributes' );
}

diag( "Testing File::Attributes $File::Attributes::VERSION, Perl $], $^X" );
my @backends = File::Attributes::_modules;
@backends = map { $_. ' ('.$_->VERSION.')' } @backends;
my $backends = join ', ', @backends;
diag( "Available backends: $backends." );
