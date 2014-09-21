use Test::Modern;
use t::lib::Common qw(bp_v11 skip_unless_has_secret);

skip_unless_has_secret;

my $bp = bp_v11;

my $card_data = {
    number           => "5105105105105100",
    expiration_month => 12,
    expiration_year  => 2020,
};

subtest 'create a card' => sub {
    my $bp = Business::BalancedPayments->new(
        secret  => $ENV{PERL_BALANCED_TEST_SECRET},
        version => 1.1,
    );

    my $res = $bp->create_card( $card_data );
    ok $res->{cards} or diag explain $res;
    my $card1 = $res->{cards}[0];
    ok $card1->{id} or diag explain $card1;

    $res = $bp->get_card( $card1->{id} );
    my $card2 = $res->{cards}[0];
    is $card2->{id} => $card1->{id}, 'got correct card';
};

done_testing;
