package t::lib::Common;

use Business::BalancedPayments;
use Exporter qw(import);
use Test::More import => [qw(plan)];

our @EXPORT_OK = qw(bp_v10 bp_v11 skip_unless_has_secret);

sub bp_v10 {
    return Business::BalancedPayments->client(
        secret  => secret(),
        version => 1.0,
    );
}

sub bp_v11 {
    return Business::BalancedPayments->client(
        secret  => secret(),
        version => 1.1,
    );
}

sub secret { $ENV{PERL_BALANCED_TEST_SECRET} }

sub skip_unless_has_secret {
    plan skip_all => 'PERL_BALANCED_TEST_SECRET is required' unless secret();
}


1;
