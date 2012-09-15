use Test::Most;

use Business::BalancedPayments;
use HTTP::Response;
use Test::Mock::LWP::Dispatch;

my $ua = LWP::UserAgent->new();
my $bp = Business::BalancedPayments->new(secret => 9, retries => 2, ua => $ua);

my $num_tries = 0;
my $url = $bp->base_url . '/v1/marketplaces';
$ua->map($url => sub { $num_tries++; return HTTP::Response->new(500) });

dies_ok { $bp->marketplace };
is $num_tries => 3, 'Tried 3 times';

done_testing;
