use strict;
use warnings;
package Module::Path;
# ABSTRACT: get the full path to a locally installed module

require Exporter;

our @ISA       = qw(Exporter);
our @EXPORT_OK = qw(module_path);

my $SEPARATOR;

BEGIN {
    if ($^O =~ /^(dos|os2)/i) {
        $SEPARATOR = '\\';
    } elsif ($^O =~ /^MacOS/i) {
        $SEPARATOR = ':';
    } else {
        $SEPARATOR = '/';
    }
}

sub module_path
{
    my $module = shift;
    my $relpath;
    my $fullpath;

    ($relpath = $module.'.pm') =~ s/::/$SEPARATOR/g;

    foreach my $dir (@INC) {
        # see 'perldoc -f require' on why you might find
        # a reference in @INC
        next if ref($dir);

        $fullpath = $dir.$SEPARATOR.$relpath;
        return $fullpath if -f $fullpath;
    }

    return undef;
}

1;

=head1 NAME

Module::Path - get the full path to a locally installed module

=head1 SYNOPSIS

 use Module::Path 'module_path';
 
 $path = module_path('Test::More');
 if (defined($path)) {
   print "Test::More found at $path\n";
 } else {
   print "Danger Will Robinson!\n";
 }

=head1 DESCRIPTION

Module::Path provides a single function, C<module_path()>,
which will find where a module is installed locally.

It works by looking in all the directories in C<@INC>
for an appropriately named file:

=over 4

=item

Foo::Bar becomes C<Foo/Bar.pm>, using the correct directory path
separator for your operating system.

=item

Iterate over C<@INC>, ignoring any references
(see L<"perlfunc"/"require"> if you're surprised to hear
that you might find references in C<@INC>).

=item

For each directory in C<@INC>, append the partial path (C<Foo/Bar.pm>),
again using the correct directory path separator.
If the resulting file exists, return this path.

=item

If no file was found, return C<undef>.

=back

I wrote this module because I couldn't find an alternative
which dealt with the points listed above, and didn't pull in
what seemed like too many dependencies to me.

The distribution for C<Module::Path> includes the C<mpath>
script, which lets you get the path for a module from the command-line:

 % mpath Module::Path


=head1 BUGS

Obviously this only works where the module you're after has its own C<.pm>
file. If a file defines multiple packages, this won't work.

This also won't find any modules that are being loaded in some special
way, for example using a code reference in C<@INC>, as described
in L<"perlfunc"/"require">.


=head1 SEE ALSO

There are a number of other modules on CPAN which provide the
same or similar functionality:
L<App::whichpm>,
L<Class::Inspector>,
L<Module::Data>,
L<Module::Filename>,
L<Module::Finder>,
L<Module::Info>,
L<Module::Locate>,
L<Module::Mapper>,
L<Module::Metadata>,
L<Module::Runtime>,
L<Module::Util>,
and L<Path::ScanINC>.

I've written a review of all such modules that I'm aware of:

=over 4

L<http://neilb.org/reviews/module-path.html>

=back

Module::Path was written to be fast, portable, and have a low number of
core-only runtime dependencies. It you only want to look up the path to
a module, it's a good choice.

If you want more information, such as the module's version, what functions
are provided, etc, then start by looking at L<Module::Info>,
L<Module::Metadata>, and L<Class::Inspector>.

The following scripts can also give you the path:
L<perldoc>,
L<whichpm|https://www.metacpan.org/module/whichpm>.


=head1 REPOSITORY

L<https://github.com/neilbowers/Module-Path>

=head1 AUTHOR

Neil Bowers E<lt>neilb@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2012 by Neil Bowers <neilb@cpan.org>.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

