use Test::Modern;
use t::lib::Common qw(bp_v11 skip_unless_has_secret);

skip_unless_has_secret;

my $bp = bp_v11;

my $cust1 = $bp->create_customer;
ok ref $cust1 eq 'HASH', 'created a customer with no params';
$cust1 = $bp->create_customer({ email => 'foo@bar.com' });
ok ref $cust1 eq 'HASH', 'created a customer with email';
ok $cust1->{id};

my $cust2 = $bp->get_customer( $cust1->{id} );
ok ref $cust2 eq 'HASH', 'got the customer';
is $cust2->{id} => $cust1->{id}, 'got correct customer';
is $cust2->{email} => 'foo@bar.com', 'got correct email';

done_testing;
