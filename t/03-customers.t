use Test::Most;
use Business::BalancedPayments;

unless ($ENV{BALANCED_SECRET}) {
    plan skip_all => 'BALANCED_SECRET not set for testing';
}

my $bp = Business::BalancedPayments->new(secret => $ENV{BALANCED_SECRET});

my $cust = $bp->create_customer;
ok ref $cust eq 'HASH', 'Created a customer object';
ok $cust->{id}, 'Created customer has id';

my $get_cust = $bp->get_customer( $cust->{id} );
ok ref $get_cust eq 'HASH', 'Got the customer';
is $get_cust->{id} => $cust->{id}, 'Got correct customer';

done_testing;
