use Test::Modern;
use t::lib::Common qw(bp_v11 skip_unless_has_secret create_card);

skip_unless_has_secret;

my $bp = bp_v11;
my $card = create_card;

subtest 'create and refund debit' => sub {
    my $debit = $bp->create_debit({ amount => 123 }, card => $card);
    is $debit->{amount} => 123;

    $debit = $bp->get_debit($debit->{id});
    is $debit->{amount} => 123;

    my $refund = $bp->refund_debit($debit);
    is $refund->{amount} => 123;
};

done_testing;
