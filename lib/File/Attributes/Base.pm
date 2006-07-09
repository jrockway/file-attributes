#!/usr/bin/perl
# Base.pm 
# Copyright (c) 2006 Jonathan Rockway <jrockway@cpan.org>

# see POD after __END__

package File::Attributes::Base;
use strict;
use warnings;
use Carp;

sub new {
    my $class = shift;
    my $self = \my $foo;
    bless $self, $class;
    return $self;
}

sub applicable {
    my $self = shift;
    return 0;
} 

1;
__END__

=head1 NAME

File::Attributes::Base - Base class for File::Attributes

=head1 SYNOPSIS

Currently, this class works like a pragma.  If something inherits from
it, File::Attributes will assume it is trying to implement some sort of
file attribute accessor.

=head1 METHODS

=head2 new

Creates an instance.  You probably don't need to override this in your
subclass.

=head2 applicable

Return true if this attribute class will work on this system.  False
by default.

=head1 METHODS THAT SUBCLASSES SHOULD IMPLEMENT

... but aren't required to, because C<< $instance->can('method') >> will tell
whoever's using the module that you're not implementing that method.

=head2 get($file, $attribute)

Return the value of $attribute on C<$file>.  Throw an exception if
something bad happens, like C<$file> doesn't exist, or the filesystem
doesn't support your type of attribute.

=head2 set($file, $key, $value)

Set the attribute C<$key> to C<$value> on C<$file>.  Again, if
something bad happpens, C<croak>; don't return undef!

=head2 unset($file, $attribute)

Unset the attribute called C<$attribute>.  You probably shouldn't
throw an exception if C<$attribute> is already undefined, but if it
makes sense in your context, feel free to.

=head2 list($file)

Return a list of all attributes that C<$file> has.

=head2 applicable

Override this so you can return true, otherwise your module will be
useless.

=head1 AUTHOR

Jonathan Rockway C<< <jrockway@cpan.org> >>.

=head1 BUGS

Report to RT; see L<File::Attributes/BUGS>.
