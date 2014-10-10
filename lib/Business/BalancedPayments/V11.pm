package Business::BalancedPayments::V11;
use Moo;
with 'Business::BalancedPayments::Base';

use Carp qw(croak);
use Method::Signatures;

has marketplaces_uri => ( is => 'ro', default => '/marketplaces' );

has marketplaces => ( is => 'ro', lazy => 1, builder => '_build_marketplaces' );

sub BUILD {
    my ($self) = @_;
    $self->ua->default_header(
        accept => 'application/vnd.api+json;revision=1.1');
}

around get_card => _unpack_response('cards');

around create_card => _unpack_response('cards');

method add_card(HashRef $card, HashRef :$customer!) {
    my $card_href = $card->{href} or croak 'The card href is missing';
    my $cust_href = $customer->{href} or croak 'The customer href is missing';
    return $self->put($card->{href}, { customer => $cust_href })->{cards}[0];
}

around get_customer => _unpack_response('customers');

around create_customer => _unpack_response('customers');

method get_hold(Str $id) {
    my $res = $self->get($self->_uri('card_holds', $id));
    return $res ? $res->{card_holds}[0] : undef;
}

method create_hold(HashRef $hold, HashRef :$card!) {
    croak 'The hold amount is missing' unless $hold->{amount};
    my $card_href = $card->{href} or croak 'The card href is missing';
    return $self->post("$card_href/card_holds", $hold)->{card_holds}[0];
}

method capture_hold(HashRef $hold, HashRef :$debit={}) {
    my $hold_href = $hold->{href} or croak 'The hold href is missing';
    return $self->post("$hold_href/debits", $debit)->{debits}[0];
}

method void_hold(HashRef $hold) {
    my $hold_href = $hold->{href} or croak 'The hold href is missing';
    return $self->put($hold_href, { is_void => 'true' })->{card_holds}[0];
}

method create_debit(HashRef $debit, HashRef :$card!) {
    croak 'The debit amount is missing' unless $debit->{amount};
    my $card_href = $card->{href} or croak 'The card href is missing';
    return $self->post("$card_href/debits", $debit)->{debits}[0];
}

around get_debit => _unpack_response('debits');

method refund_debit(HashRef $debit) {
    my $debit_href = $debit->{href} or croak 'The debit href is missing';
    return $self->post("$debit_href/refunds", $debit)->{refunds}[0];
}

around get_bank_account => _unpack_response('bank_accounts');

around create_bank_account => _unpack_response('bank_accounts');

method add_bank_account(HashRef $bank, HashRef :$customer!) {
    my $bank_href = $bank->{href} or croak 'The bank href is missing';
    my $cust_href = $customer->{href} or croak 'The customer href is missing';
    my $res = $self->put($bank->{href}, { customer => $cust_href });
    return $res->{bank_accounts}[0];
}

method create_credit(HashRef $credit, HashRef :$bank_account, HashRef :$card) {
    croak 'The credit amount is missing' unless $credit->{amount};
    if ($bank_account) {
        my $bank_href = $bank_account->{href}
            or croak 'The bank_account href is missing';
        return $self->post("$bank_href/credits", $credit)->{credits}[0];
    } elsif ($card) {
        my $card_href = $card->{href} or croak 'The card href is missing';
        return $self->post("$card_href/credits", $credit)->{credits}[0];
    } else {
        croak 'A bank or card param is required';
    }
}

around get_credit => _unpack_response('credits');

method update_bank_account(HashRef $bank) {
    my $bank_href = $bank->{href} or croak 'The bank_account href is missing';
    return $self->put($bank_href, $bank)->{bank_accounts}[0];
}

method create_bank_verification(HashRef :$bank_account!) {
    my $bank_href = $bank_account->{href}
        or croak 'The bank_account href is missing';
    return $self->post("$bank_href/verifications", {})
        ->{bank_account_verifications}[0];
}

method get_bank_verification(Str $id) {
    my $res = $self->get("/verifications/$id");
    return $res ? $res->{bank_account_verifications}[0] : undef;
}

method confirm_bank_verification(HashRef $verification, Int :$amount_1!, Int :$amount_2!) {
    my $ver_href = $verification->{href}
        or croak 'The verification href is missing';
    return $self->put($ver_href, {amount_1 => $amount_1, amount_2 => $amount_2})
        ->{bank_account_verifications}[0];
}

method create_check_recipient(HashRef $rec) {
    croak 'The recipient name is missing' unless defined $rec->{name};
    croak 'The recipient address line1 is missing'
        unless $rec->{address}{line1};
    croak 'The recipient address postal_code is missing'
        unless $rec->{address}{postal_code};
    my $res = $self->post('/check_recipients', $rec);
    return $res->{check_recipients}[0];
}

method create_check_recipient_credit(HashRef $credit, HashRef :$check_recipient!) {
    my $rec_id = $check_recipient->{id}
        or croak 'The check_recipient hashref needs an id';
    croak 'The credit must contain an amount' unless $credit->{amount};
    my $res = $self->post("/check_recipients/$rec_id/credits", $credit);
    return $res->{credits}[0];
}

method _build_marketplaces { $self->get($self->marketplaces_uri) }

method _build_marketplace { $self->marketplaces->{marketplaces}[0] }

method _build_uris {
    my $links = $self->marketplaces->{links};
    return { map { (split /^marketplaces./)[1] => $links->{$_} } keys %$links };
}

sub _unpack_response {
    my ($name) = @_;
    return sub {
        my ($orig, $self, @args) = @_;
        my $res = $self->$orig(@args);
        return $res->{$name}[0] if $res;
        return $res;
    }
};

=head1 METHODS

These methods are for version 1.1 of the Balanced API
L<https://docs.balancedpayments.com/1.1/api>.

For the C<get_*> methods, the C<$id> param can be the id of the resource or
a uri. For example, the following two lines are equivalent:

    $bp->get_card('CC6J123');
    $bp->get_card('/cards/CC6J123');

=head2 get_card

    get_card($id)

Returns the card for the given id.

Example response:

    {
      'id' => 'CC6J',
      'href' => '/cards/CC6J',
      'address' => {
        'city' => undef,
        'country_code' => undef,
        'line1' => undef,
        'line2' => undef,
        'postal_code' => undef,
        'state' => undef
      },
      'avs_postal_match' => undef,
      'avs_result' => undef,
      'avs_street_match' => undef,
      'bank_name' => 'BANK OF HAWAII',
      'brand' => 'MasterCard',
      'can_credit' => 0,
      'can_debit' => 1,
      'category' => 'other',
      'created_at' => '2014-09-21T05:55:17.564617Z',
      'cvv' => undef,
      'cvv_match' => undef,
      'cvv_result' => undef,
      'expiration_month' => 12,
      'expiration_year' => 2020,
      'fingerprint' => 'fc4c',
      'is_verified' => $VAR1->{'cards'}[0]{'can_debit'},
      'links' => { 'customer' => undef },
      'meta' => {},
      'name' => undef,
      'number' => 'xxxxxxxxxxxx5100',
      'type' => 'credit',
      'updated_at' => '2014-09-21T05:55:17.564619Z'
    }

=head2 create_card

    create_card($card)

Creates a card.
Returns the card card that was created.

Example:

    my $card = $bp->create_card({
        number           => '5105105105105100',
        expiration_month => 12,
        expiration_year  => 2020,
    });

=head2 add_card

    add_card($card, customer => $customer);

Associates a card with a customer.
It expects a card hashref, such as one returned by L</get_card>,
and a customer hashref, such as one returned by L</get_customer>.
Returns the card.

Example:

    my $customer = $bp->create_customer;
    my $card = $bp->get_card($card_id);
    $bp->add_card($card, customer => $customer);

=head2 get_customer

    get_customer($id)

Returns the customer for the given id.

Example response:

    {
      'address' => {
        'city' => undef,
        'country_code' => undef,
        'line1' => undef,
        'line2' => undef,
        'postal_code' => undef,
        'state' => undef
      },
      'business_name' => undef,
      'created_at' => '2014-10-02T07:59:26.311760Z',
      'dob_month' => undef,
      'dob_year' => undef,
      'ein' => undef,
      'email' => 'foo@bar.com',
      'href' => '/customers/CUe3pf7nX93sMvrd9qcC29W',
      'id' => 'CUe3pf7nX93sMvrd9qcC29W',
      'links' => {
        'destination' => undef,
        'source' => undef
      },
      'merchant_status' => 'no-match',
      'meta' => {},
      'name' => undef,
      'phone' => undef,
      'ssn_last4' => undef,
      'updated_at' => '2014-10-02T07:59:26.405946Z'
    }

=head2 create_customer

    create_customer($customer)

Creates a customer.
A customer hashref is optional.
Returns the customer.

Example:

    $bp->create_customer({ name => 'Bob', email => 'bob@foo.com' });

=head2 get_hold

    get_hold($id)

Returns the card hold for the given id.

Example response:

    {
      'amount' => 123,
      'created_at' => '2014-10-03T03:39:46.933465Z',
      'currency' => 'USD',
      'description' => undef,
      'expires_at' => '2014-10-10T03:39:47.051257Z',
      'failure_reason' => undef,
      'failure_reason_code' => undef,
      'href' => '/card_holds/HL7b0bw2Ooe6G3yad7dR1rRr',
      'id' => 'HL7b0bw2Ooe6G3yad7dR1rRr',
      'links' => {
        'card' => 'CC7af3NesZk2bYR5GxqLLmfe',
        'debit' => undef,
        'order' => undef
      },
      'meta' => {},
      'status' => 'succeeded',
      'transaction_number' => 'HL7JT-EWF-5CQ6',
      'updated_at' => '2014-10-03T03:39:47.094448Z',
      'voided_at' => undef
    }

=head2 create_hold

    create_hold($hold_data, card => $card)

Creates a card hold.
The C<$hold_data> hashref must contain an amount.
The card param is a hashref such as one returned from L</get_card>.
Returns the created hold.

=head2 capture_hold

    capture_hold($hold, debit => $debit)

Captures a previously created card hold.
This creates a debit.
The C<$debit> hashref is optional and can contain an amount.
Any amount up to the amount of the hold may be captured.
Returns the created debit.

Example:

    my $hold = $bp->get_hold($hold_id);
    my $debit = $bp->capture_hold(
        $hold,
        debit => {
            amount                  => 1000,
            description             => 'money for stuffs',
            appears_on_statement_as => 'ACME 123',
        }
    );

=head2 void_hold

    void_hold($hold)

Cancels the hold.
Once voided, the hold can no longer be captured.
Returns the voided hold.

Example:

    my $hold = $bp->get_hold($hold_id);
    my $voided_hold = $bp->void_hold($hold);

=head2 get_debit

    get_debit($id)

Returns the debit for the given id.

Example response:

    {
      'amount' => 123,
      'appears_on_statement_as' => 'BAL*Tilt.com',
      'created_at' => '2014-10-06T05:01:39.045336Z',
      'currency' => 'USD',
      'description' => undef,
      'failure_reason' => undef,
      'failure_reason_code' => undef,
      'href' => '/debits/WD6F5x4VpYx4hfB02tGIqNU1',
      'id' => 'WD6F5x4VpYx4hfB02tGIqNU1',
      'links' => {
        'card_hold' => 'HL6F4q5kJGxt1ftH8vgZZJkh',
        'customer' => undef,
        'dispute' => undef,
        'order' => undef,
        'source' => 'CC6DFWepK7eeL03cZ06Sb9Xf'
      },
      'meta' => {},
      'status' => 'succeeded',
      'transaction_number' => 'WAVD-B0K-R7TX',
      'updated_at' => '2014-10-06T05:01:39.542306Z'
    }

=head2 create_debit

    create_debit($debit, card => $card)

Debits a card.
The C<$debit> hashref must contain an amount.
The card param is a hashref such as one returned from L</get_card>.
Returns the created debit.

Example:

    my $card = $bp->get_card($card_id);
    my $debit = $bp->create_debit({ amount => 123 }, card => $card);

=head2 refund_debit

    refund_debit($debit)

Refunds a debit.
Returnds the refund.

Example:

    my $debit = $bp->get_debit($debit_id);
    my $refund = $bp->refund_debit($debit);

Example response:

    {
      'amount' => 123,
      'created_at' => '2014-10-06T04:57:44.959806Z',
      'currency' => 'USD',
      'description' => undef,
      'href' => '/refunds/RF2pO6Fz8breGs2TAIpfE2nr',
      'id' => 'RF2pO6Fz8breGs2TAIpfE2nr',
      'links' => {
        'debit' => 'WD2hQV9COFX0aPMSIzyeAuAg',
        'dispute' => undef,
        'order' => undef
      },
      'meta' => {},
      'status' => 'succeeded',
      'transaction_number' => 'RFRGL-EU1-A39B',
      'updated_at' => '2014-10-06T04:57:48.161218Z'
    }

=head2 get_bank_account

    get_bank_account($id)

Returns the bank account for the given id.

Example response:

    {
      'account_number' => 'xxxxxxxx6789',
      'account_type' => 'checking',
      'address' => {
        'city' => undef,
        'country_code' => 'USA',
        'line1' => '123 Abc St',
        'line2' => undef,
        'postal_code' => '94103',
        'state' => undef
      },
      'bank_name' => '',
      'can_credit' => bless( do{\(my $o = 1)}, 'JSON::XS::Boolean' ),
      'can_debit' => bless( do{\(my $o = 0)}, 'JSON::XS::Boolean' ),
      'created_at' => '2014-10-06T06:40:14.649386Z',
      'fingerprint' => 'cc552495fc90556293db500b985bacc918d9fb4d37b42052adf64',
      'href' => '/bank_accounts/BA4TAWvO3d3J14i6BdjJUZsp',
      'id' => 'BA4TAWvO3d3J14i6BdjJUZsp',
      'links' => {
        'bank_account_verification' => undef,
        'customer' => undef
      },
      'meta' => {},
      'name' => 'Bob Smith',
      'routing_number' => '110000000',
      'updated_at' => '2014-10-06T06:40:14.649388Z'
    }

=head2 create_bank_account

    create_bank_account($bank)

Creates a bank account.
Returns the bank account that was created.

Example:

    my $bank = $bp->create_bank_account({
        account_number => '000123456789',
        acount_type    => 'checking',
        name           => 'Bob Smith',
        routing_number => '110000000',
        address => {
            line1       => '123 Abc St',
            postal_code => '94103',
        },
    });

=head2 add_bank_account

    add_bank_account($bank, customer => $customer)

Associates a bank account to the given customer.
Returns the bank account.

Example:

    my $bank = $bp->add_bank_account($bank_id);
    my $customer = $bp->get_customer($customer_id);
    $bank = $bp->add_bank_account($bank, customer => $customer);

=head2 get_credit

    get_credit($id)

Returns the credit for the given id.

Example response:

    {
      'amount' => 123,
      'appears_on_statement_as' => 'Tilt.com',
      'created_at' => '2014-10-06T06:52:00.522212Z',
      'currency' => 'USD',
      'description' => undef,
      'failure_reason' => undef,
      'failure_reason_code' => undef,
      'href' => '/credits/CR27ns5sg1FFgHsGy5VEhowd',
      'id' => 'CR27ns5sg1FFgHsGy5VEhowd',
      'links' => {
        'customer' => undef,
        'destination' => 'BA26JfFfg1vqrCoXPzSSxtKg',
        'order' => undef
      },
      'meta' => {},
      'status' => 'succeeded',
      'transaction_number' => 'CR4F7-4XQ-JLDG',
      'updated_at' => '2014-10-06T06:52:03.558485Z'
    }

=head2 create_credit

    create_credit($credit, bank_account => $bank)
    create_credit($credit, card => $card)

Sends money to a bank account or a credit card.
The C<$credit> hashref must contain an amount.
A bank_account or card param is required.
Returns the created credit.

Example:

    my $bank = $bp->get_bank_account($bank_account_id);
    my $credit = $bp->create_credit({ amount => 123 }, bank_account => $bank);

=head2 get_bank_verification

    get_bank_verification($id)

Gets a bank account verification.

Example response:

    {
      'attempts' => 0,
      'attempts_remaining' => 3,
      'created_at' => '2014-10-06T08:01:59.972034Z',
      'deposit_status' => 'succeeded',
      'href' => '/verifications/BZnWun9Itq7FVtj1nludGjC',
      'id' => 'BZnWun9Itq7FVtj1nludGjC',
      'links' => {
        'bank_account' => 'BAdFCPv3GkIlXEWQrdTyIW9'
      },
      'meta' => {},
      'updated_at' => '2014-10-06T08:02:00.268756Z',
      'verification_status' => 'pending'
    }

=head2 create_bank_verification

    create_bank_verification(bank_account => $bank)

Create a new bank account verification.
This initiates the process of sending micro deposits to the bank account which
will be used to verify bank account ownership.
A bank_account param is required.
Returns the created bank account verification.

Example:

    my $bank = $bp->get_bank_account($bank_account_id);
    my $verification = $bp->create_bank_verification(bank_account => $bank);

=head2 confirm_bank_verification

    confirm_bank_verification($verification,
        amount_1 => $amount_1, amount_2 => $amount_2);

Confirm the trial deposit amounts that were sent to the bank account.
Returns the bank account verification.

Example:

    my $ver = $bp->get_bank_account($bank_account_id);
    $verification =
        $bp->confirm_bank_verification($ver, amount_1 => 1, amount_2 => 2);

=cut

1;
