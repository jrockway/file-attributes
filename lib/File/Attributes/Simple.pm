#!/usr/bin/perl
# Simple.pm 
# Copyright (c) 2006 Jonathan Rockway <jrockway@cpan.org>

# see POD after __END__

package File::Attributes::Simple;
use strict;
use warnings;
use base qw(File::Attributes::Base);
use Best [ [ qw/YAML::Syck YAML/ ], qw/DumpFile LoadFile/ ];
use File::Spec;

our $VERSION = '0.02';

sub applicable {
    return 1; # this module Works Everywhere, hopefully.
}

sub _load {
    my $self = shift;
    my $file = shift;
    my $attrfile = $self->_attribute_file($file);
    
    # throws an exception if attrfile ain't YAML (or doesn't exist, etc.)
    my $data = LoadFile($attrfile);
    return $data;
}

sub _save {
    my $self = shift;
    my $file = shift;
    my $data = shift;
    my $attrfile = $self->_attribute_file($file);

    DumpFile($attrfile, $data);
}

sub list {
    my $self = shift;
    my $file = shift;
    my $data = {};

    eval {
	$data = $self->_load($file);
    };
    
    return keys %{$data};
}

sub get {
    my $self = shift;
    my $file = shift;
    my $attr = shift;
    my $data = $self->_load($file);
    
    return $data->{$attr};
}

sub set {
    my $self  = shift;
    my $file  = shift;
    my $key   = shift;
    my $value = shift;

    my $data = {};
    
    eval {
	$data = $self->_load($file);
    };
    
    $data->{$key} = $value;
    $self->_save($file, $data);
}

sub unset {
    my $self = shift;
    my $file = shift;
    my $key  = shift;
    
    my $data = {};
    eval {
	$data = $self->_load($file);
    };
    
    delete $data->{$key};
    $self->_save($file, $data);
}

sub _attribute_file {
    my $self = shift;
    my $file = shift;

    my $max = 10;
    while($max-- && -l $file){
	$file = readlink $file;
    }
    
    my ($volume,$dirs,$filename) = File::Spec->splitpath($file);
    return File::Spec->catpath($volume, $dirs, ".$filename.attributes");
}

__END__

=head1 NAME

File::Attributes::Simple - the simplest implementation of File::Attributes

=head1 SYNOPSIS

This is the fallback for File::Attributes if it can't find anything
better.  It stores attributes as YAML files (named
.filename.attributes) containing key/value pairs.

You probably shouldn't use this class directly, see
L<File::Attributes> instead.

=head1 METHODS

All the standard ones, namely:

=head2 get

=head2 set

=head2 unset

=head2 list

=head2 applicable

=head1 EXTENDING

If you want to implement a file attribute scheme, and can do so doing
hashrefs, this class might make your life easier.  Simply subclass
C<File::Attributes::Simple> (this class), and override the following
(private) methods:

=over 4

=item _attribute_file($filename)

If you just want the attributes to be stored somewhere else, override
this method.  It takes a filename and returns the filename that stores
the attributes.  If you override _load and _save, you don't need to
worry about this method; it isn't called from anywhere else.

=item _load($filename)

This method takes a filename and returns the hash(ref) of attributes.

=item _save($filename, \%attributes)

This method takes a filename and the attributes hashref and stores it
to disk (or wherever, the method doesn't care if it's a disk or not).

=back

I think OS X uses a format for storing filesystem attributes that
could be implemented by overriding this class, but I don't have a Mac
and couldn't find any documentation.

=cut

=head1 BUGS

See bug reporting instructions in L<File::Attributes/BUGS>.

=head1 AUTHOR

Jonathan Rockway C<< <jrockway at cpan.org> >>
