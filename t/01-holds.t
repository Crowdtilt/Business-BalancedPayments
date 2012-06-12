use Test::Most;
use Business::BalancedPayments;

my $bp = Business::BalancedPayments->new(secret => 'secret');

my $hold = {};
throws_ok { $bp->create_hold($hold) } qr/amount/, 'No ammount';

$hold = {amount => 500};
throws_ok { $bp->create_hold($hold) } qr/account or card/, 'No account or card';

done_testing;
