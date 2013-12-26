use strict;
use warnings FATAL => 'all';
use ExtUtils::MakeMaker;

(do 'maint/Makefile.PL.include' or die $@) unless -f 'META.yml';

my %META = (
  name => 'local::lib::versioned',
  license => 'perl_5',
  prereqs => {
    configure => { requires => {
      'ExtUtils::MakeMaker' => 0,
    } },
    build => { requires => {
    } },
    test => { requires => {
      'Test::More'  => 0.94,
    } },
    runtime => { requires => {
      'local::lib'  => 2,
    } },
  },
  resources => {
    repository => {
      url => 'https://github.com/haarg/local-lib-versioned.git',
      web => 'https://github.com/haarg/local-lib',
      type => 'git',
    },
    x_IRC => 'irc://irc.perl.org/#local-lib',
    bugtracker => {
      web => 'https://rt.cpan.org/Public/Dist/Display.html?Name=local-lib-versioned',
      mailto => 'bug-local-lib-versioned@rt.cpan.org',
    },
    license => [ 'http://dev.perl.org/licenses/' ],
  },
  no_index => {
    directory => [ 't', 'xt' ]
  },
);

my %MM_ARGS = (
);



# have to do this since old EUMM dev releases miss the eval $VERSION line
my $mmver = eval $ExtUtils::MakeMaker::VERSION;
my $mymeta_works      = $mmver >= 6.57_07;
my $mymeta            = $mmver >= 6.57_02;
my $has_test_requires = $mmver >= 6.63_03;

my %configure_deps = %{$META{prereqs}{configure}{requires}};
my %build_deps     = %{$META{prereqs}{build}{requires}};
my %test_deps      = %{$META{prereqs}{test}{requires}};
my %run_deps       = %{$META{prereqs}{runtime}{requires}};

my $min_perl_version = delete $run_deps{perl};

if (not $has_test_requires) {
  %build_deps = (%build_deps, %test_deps);
  %test_deps = ();
}
if (not $mymeta_works) {
  %run_deps = (%run_deps, %build_deps);
  %build_deps = ();
}

(my $name = $META{name}) =~ s/-/::/g;
(my $module = "lib/$name.pm") =~ s{::}{/}g;

WriteMakefile(
  NAME => $META{name},
  VERSION_FROM => $module,
  LICENSE => $META{license},

  $min_perl_version     ? ( MIN_PERL_VERSION    => $min_perl_version ) : (),
  keys %configure_deps  ? ( CONFIGURE_REQUIRES  => \%configure_deps ) : (),
  keys %build_deps      ? ( BUILD_REQUIRES      => \%build_deps ) : (),
  keys %test_deps       ? ( TEST_REQUIRES       => \%test_deps ) : (),
  keys %run_deps        ? ( PREREQ_PM           => \%run_deps ) : (),

  ($mymeta && !$mymeta_works ? (NO_MYMETA => 1) : ()),
  -f 'META.yml' ? () : (META_ADD => { 'meta-spec' => { version => 2 }, %META }),

  %MM_ARGS,
);
