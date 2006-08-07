package File::Attributes;

# please see POD after __END__

use warnings;
use strict;
use Carp;
our $VERSION = '0.02';

# modules that we require
use Module::Pluggable ( search_path => 'File::Attributes',
		        instantiate => 'new' );

# exporting business
require Exporter;
our @ISA = qw(Exporter);
our @EXPORT = ();
our @EXPORT_OK   = qw(set_attribute   set_attributes
		      get_attribute   get_attributes
		      unset_attribute unset_attributes
		      list_attributes);
our %EXPORT_TAGS = (all => [@EXPORT_OK]);

# internal variables
my @modules; # the modules to call, in order


sub _do_each {
    my $what = shift;
    my @args = @_;
    my $file = $args[0];
    croak "$file does not exist" if !-e $file;
    
    #print {*STDERR} "_do_each called with $what (@_)\n";

    my @ERRORS;
    my $result;
    my @result;
    
    foreach my $plugin (@modules){
	if(wantarray){
	    eval {
		@result = $plugin->$what(@_);
	    };
	}
	else {
	    eval {
		$result = $plugin->$what(@_);
	    };
	}
	
	if($@){
	    push @ERRORS, $@;
	}
	else {
	    # success!, so return
	    return wantarray ? @result : $result;
	}
    }
    
    # if we get here, everything failed
    my $caller = (caller(1))[3];
    croak "$caller failed: @ERRORS";
}

sub set_attribute {
    _do_each('set', @_);
    return;
}

sub set_attributes {
    my $file  = shift;
    my $first = shift;

    # if someone passes a hashref instead, handle that nicely
    my %attributes;
    if(ref $first){
	%attributes = %{$first};
    }
    else {
	%attributes = ($first, @_);
    }    


    foreach my $key (keys %attributes){
	set_attribute($file, $key, $attributes{$key});
    }
}

sub get_attribute {
    return _do_each('get', @_);
}

sub get_attributes {
    my $file = shift;
    my @attributes = list_attributes($file);
    my %result;
    foreach my $attribute (@attributes){
	$result{$attribute} = get_attribute($file, $attribute);
    }
    return %result;
}

sub unset_attribute {
    return _do_each('unset', @_);
}

sub unset_attributes {
    my $file = shift;
    my @attributes = @_;
    foreach my $attribute (@attributes){
	unset_attribute($file, $attribute);
    }
    return;
}

sub list_attributes {
    my @result = _do_each('list', @_);
    return @result;
}

sub _init {
    my $simple;
    foreach my $plugin (plugins()){
	eval {
	    if($plugin->isa('File::Attributes::Base') && $plugin->applicable){
		if($plugin =~ /^File::Attributes::Simple[^:]/){
		    # we want File::Attributes::Simple to be last, always.
		    $simple = $plugin;
		}
		else {
		    push @modules, $plugin;
		}
	    }
	};
    }

    @modules = (@modules, $simple) if $simple;
    return scalar @modules;
}

sub _modules {
    return map {/(.+)=[A-Z]+/; $1;} @modules;
}

return _init(); # returns true if the module can be used
__END__

=head1 NAME

File::Attributes - Manipulate file metadata

=head1 VERSION

Version 0.02

=cut

=head1 SYNOPSIS

    use File::Attributes qw(set_attribute list_attributes get_all_attributes);

    my $file = 'foo.txt';
    set_attribute($file, type     => 'text/plain');
    set_attribute($file, encoding => 'utf8');
    
    my @attributes = list_attributes($file);
    #  @attributes = qw(type encoding)
 
    %attributes = get_attributes($file);
    #  $attributes{type} will be 'text/plain'
    #  $attributes{foo}  will be undefined.

=head1 DETAILS

C<File::Attributes> is a wrapper around modules in the
L<File::Attributes|http://search.cpan.org/search?query=File%3A%3AAttributes>
hierarchy.  If you use this module directly (instead of one of the
aforementioned decendants), then your attribute manipulations will
Just Work, regardless of the underlying filesystem.

Module::Pluggable is used to find all C<File::Attributes::> modules
that inherit from C<File::Attributes::Base> and that are applicable on
your system.  If it finds one, it uses that.  If not, it uses
C<File::Attributes::Simple>, which is bundled with this module and
works everywhere.

=head1 EXPORT

None, by default.  Specify the functions that you'd like to use as
arguments to the module.

=head1 FUNCTIONS

All functions throw an exception on error.

=head2 get_attribute($file, $attribute)

Returns the value of attribute C<$attribute> on file C<$file>.  If
C<$attribute> doesn't exist, returns undefined.

=head2 set_attribute($file, $attribute => $value)

Sets attribute $<attribute> on file C<$file> to C<$value>.

=head2 get_attributes($file)

Returns a hash of all attributes on C<$file>.

=head2 set_attributes($file, %hash)

Sets the attributes named by the keys of C<%hash> to the value
contained in C<%hash>.  Note that this operation is not atomic -- if
setting an individual attribute fails, the attributes on C<$file> may
not be the same as before C<set_attributes> was called!

=head2 unset_attribute($file, $attribute)

Removes the attribute C<$attribute> from C<$file>.

=head2 unset_attributes($file, $attribute0, [$attribute1, ...])

Removes each attribute (C<$attribute0>, C<$attribute1>, C<...>) from
C<$file>.

=head2 list_attributes($file)

Returns a list of the attributes on C<$file>.  Equivalent to (but
faster than) C<keys get_attributes($file)>.

=cut

=head1 AUTHOR

Jonathan Rockway, C<< <jrockway at cpan.org> >>

=head1 BUGS

Please report any bugs or feature requests to RT at
L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=File-Attributes>.

=head1 COPYRIGHT & LICENSE

Copyright 2006 Jonathan Rockway, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

1; # End of File::Attributes
