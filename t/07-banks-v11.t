use Test::Modern;
use t::lib::Common qw(bp_v11 skip_unless_has_secret);

skip_unless_has_secret;

my $bp = bp_v11;

subtest 'create a bank account' => sub {

    my $bank_data = {
        account_number => '000123456789',
        acount_type    => 'checking',
        name           => 'Banker Name',
        routing_number => '110000000',
        address => {
            line1       => '123 Abc St',
            postal_code => '94103',
        },
    };

    my $bank1 = $bp->create_bank_account( $bank_data );
    ok $bank1->{id} or diag explain $bank1;

    my $bank2 = $bp->get_bank_account( $bank1->{id} );
    is $bank2->{id} => $bank1->{id}, 'got correct bank';
};

done_testing;
