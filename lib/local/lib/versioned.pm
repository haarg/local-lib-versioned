package local::lib::versioned;
use strict;
use warnings;

use Config;
use local::lib ();
our @ISA = qw(local::lib);

our $VERSION = '0.001000';
$VERSION = eval $VERSION;

sub install_base_bin_path {
  my ($class, $path) = @_;
  File::Spec->catdir($path, 'bin', $Config{version});
}

# make this accurate-ish, even though local::lib itself doesn't use it
sub install_base_arch_path {
  my ($class, $path) = @_;
  File::Spec->catdir($class->install_base_perl_path($path), $Config{version}, $Config{archname});
}

sub installer_options_for {
  my ($class, $path) = @_;
  if (!defined $path) {
    return (
      PERL_MM_OPT => undef,
      PERL_MB_OPT => undef,
    );
  }
  my $lib = File::Spec->catdir(
    $class->install_base_perl_path($path),
    $Config{version}
  );
  my %mm;
  my %mb;
  $mm{PRIVLIB} = $mb{lib}    = $lib;
  $mm{ARCHLIB} = $mb{arch}   = File::Spec->catdir($lib, $Config{archname});
  $mm{BIN}     = $mb{bin}    =
  $mm{SCRIPT}  = $mb{script} = $class->install_base_bin_path($path);
  $mm{MAN1DIR} = $mm{MAN3DIR} = 'none';
  $mb{bindoc}  = $mb{libdoc} = '';

  return (
    PERL_MM_OPT => join(' ',
      map { "INSTALL$_=".local::lib::_mm_escape_path($mm{$_}) }
      sort keys %mm
    ),
    PERL_MB_OPT => join(' ',
      map { "--install_path $_=".local::lib::_mb_escape_path($mb{$_}) }
      sort keys %mb
    ),
  );
}

1;

__END__

=head1 NAME

local::lib::versioned - install local::lib files into versioned directories

=head1 SYNOPSIS

 $ eval $(perl -Mlocal::lib::versioned)

=head1 DESCRIPTION

Works like L<local::lib>, except files are installed into a subdirectory based
on the perl version.  The PERL5LIB environment variable however is generated
just like L<local::lib> does.  C<perl> will automatically pick up the versioned
directories.

=head1 AUTHOR

haarg - Graham Knop (cpan:HAARG) <haarg@haarg.org>

=head1 CONTRIBUTORS

None yet.

=head1 COPYRIGHT

Copyright (c) 2013 the Moo L</AUTHOR> and L</CONTRIBUTORS>
as listed above.

=head1 LICENSE

This library is free software and may be distributed under the same terms
as perl itself. See L<http://dev.perl.org/licenses/>.

=cut
