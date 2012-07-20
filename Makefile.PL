
use strict;
use warnings;



use ExtUtils::MakeMaker 6.30;



my %WriteMakefileArgs = (
  "ABSTRACT" => "BalancedPayments API bindings",
  "AUTHOR" => "Naveed Massjouni <naveedm9\@gmail.com>, Khaled Hussein <khaled.hussein\@gmail.com>",
  "BUILD_REQUIRES" => {
    "File::Find" => 0,
    "File::Temp" => 0,
    "Test::More" => 0,
    "Test::Most" => 0,
    "strict" => 0,
    "warnings" => 0
  },
  "CONFIGURE_REQUIRES" => {
    "ExtUtils::MakeMaker" => "6.30"
  },
  "DISTNAME" => "Business-BalancedPayments",
  "EXE_FILES" => [],
  "LICENSE" => "perl",
  "NAME" => "Business::BalancedPayments",
  "PREREQ_PM" => {
    "Carp" => 0,
    "HTTP::Request::Common" => 0,
    "JSON" => 0,
    "LWP::UserAgent" => 0,
    "Moose" => 0,
    "Moose::Role" => 0
  },
  "VERSION" => "0.0100",
  "test" => {
    "TESTS" => "t/*.t"
  }
);


unless ( eval { ExtUtils::MakeMaker->VERSION(6.56) } ) {
  my $br = delete $WriteMakefileArgs{BUILD_REQUIRES};
  my $pp = $WriteMakefileArgs{PREREQ_PM};
  for my $mod ( keys %$br ) {
    if ( exists $pp->{$mod} ) {
      $pp->{$mod} = $br->{$mod} if $br->{$mod} > $pp->{$mod};
    }
    else {
      $pp->{$mod} = $br->{$mod};
    }
  }
}

delete $WriteMakefileArgs{CONFIGURE_REQUIRES}
  unless eval { ExtUtils::MakeMaker->VERSION(6.52) };

WriteMakefile(%WriteMakefileArgs);



