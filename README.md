# NAME

Business::BalancedPayments - Balanced Payments API bindings

# VERSION

version 1.0300

# SYNOPSIS

    use Business::BalancedPayments;

    my $bp = Business::BalancedPayments->client(secret => 'abc123');

    my $customer = $bp->create_customer;

    my $card = $bp->create_card({
        card_number      => '5105105105105100',
        expiration_month => 12,
        expiration_year  => 2020,
        security_code    => 123,
    });

    $bp->add_card($card, customer => $customer);

# DESCRIPTION

This module provides bindings for the
[Balanced](https://www.balancedpayments.com) API.

# METHODS

The client methods documented here are for v1.1 of the Balanced API
[https://docs.balancedpayments.com/1.1/api](https://docs.balancedpayments.com/1.1/api).
See [Business::BalancedPayments::V10](http://search.cpan.org/perldoc?Business::BalancedPayments::V10) for the v1.0 methods.

For the `get_*` methods, the `$id` param can be the id of the resource or
a uri. For example, the following two lines are equivalent:

    $bp->get_card('CC6J123');
    $bp->get_card('/cards/CC6J123');

## client

    my $bp = Business::BalancedPayments->client(
        secret  => $secret,
        version => 1.1,     # optional, defaults to 1.1
        logger  => $logger, # optional
        retries => 3,       # optional
    );

Returns a new Balanced client object.
Parameters:

- secret

    Required. The Balanced Payments secret key for your account.

- version

    Optional. Defaults to `'1.1'`.
    The only supported versions currently are `'1.0'` and `'1.1'`.
    Note that version `'1.0'` was officially deprecated March 2014. 

See [WebService::Client](http://search.cpan.org/perldoc?WebService::Client) for other supported parameters such as `logger`,
`retries`, and `timeout`.

## get\_card

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

## create\_card

    create_card($card)

Creates a card.
Returns the card card that was created.

Example:

    my $card = $bp->create_card({
        number           => '5105105105105100',
        expiration_month => 12,
        expiration_year  => 2020,
    });

## add\_card

    add_card($card, customer => $customer);

Associates a card with a customer.
It expects a card hashref, such as one returned by ["get\_card"](#get\_card),
and a customer hashref, such as one returned by ["get\_customer"](#get\_customer).
Returns the card.

Example:

    my $customer = $bp->create_customer;
    my $card = $bp->get_card($card_id);
    $bp->add_card($card, customer => $customer);

## get\_customer

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

## create\_customer

    create_customer($customer)

Creates a customer.
A customer hashref is optional.
Returns the customer.

Example:

    $bp->create_customer({ name => 'Bob', email => 'bob@foo.com' });

## update\_customer

    update_customer($customer)

Updates a customer.
Returns the updated customer.

Example:

    my $customer = $bp->get_customer($customer_id);
    $customer->{email} = 'sue@foo.com';
    $bp->update_customer($customer);

## get\_hold

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

## create\_hold

    create_hold($hold_data, card => $card)

Creates a card hold.
The `$hold_data` hashref must contain an amount.
The card param is a hashref such as one returned from ["get\_card"](#get\_card).
Returns the created hold.

## capture\_hold

    capture_hold($hold, debit => $debit)

Captures a previously created card hold.
This creates a debit.
The `$debit` hashref is optional and can contain an amount.
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

## void\_hold

    void_hold($hold)

Cancels the hold.
Once voided, the hold can no longer be captured.
Returns the voided hold.

Example:

    my $hold = $bp->get_hold($hold_id);
    my $voided_hold = $bp->void_hold($hold);

## get\_debit

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

## create\_debit

    create_debit($debit, card => $card)

Debits a card.
The `$debit` hashref must contain an amount.
The card param is a hashref such as one returned from ["get\_card"](#get\_card).
Returns the created debit.

Example:

    my $card = $bp->get_card($card_id);
    my $debit = $bp->create_debit({ amount => 123 }, card => $card);

## refund\_debit

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

## get\_bank\_account

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

## create\_bank\_account

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

## add\_bank\_account

    add_bank_account($bank, customer => $customer)

Associates a bank account to the given customer.
Returns the bank account.

Example:

    my $bank = $bp->add_bank_account($bank_id);
    my $customer = $bp->get_customer($customer_id);
    $bank = $bp->add_bank_account($bank, customer => $customer);

## get\_credit

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

## create\_credit

    create_credit($credit, bank_account => $bank)
    create_credit($credit, card => $card)

Sends money to a bank account or a credit card.
The `$credit` hashref must contain an amount.
A bank\_account or card param is required.
Returns the created credit.

Example:

    my $bank = $bp->get_bank_account($bank_account_id);
    my $credit = $bp->create_credit({ amount => 123 }, bank_account => $bank);

## get\_bank\_verification

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

## create\_bank\_verification

    create_bank_verification(bank_account => $bank)

Create a new bank account verification.
This initiates the process of sending micro deposits to the bank account which
will be used to verify bank account ownership.
A bank\_account param is required.
Returns the created bank account verification.

Example:

    my $bank = $bp->get_bank_account($bank_account_id);
    my $verification = $bp->create_bank_verification(bank_account => $bank);

## confirm\_bank\_verification

    confirm_bank_verification($verification,
        amount_1 => $amount_1, amount_2 => $amount_2);

Confirm the trial deposit amounts that were sent to the bank account.
Returns the bank account verification.

Example:

    my $ver = $bp->get_bank_account($bank_account_id);
    $verification =
        $bp->confirm_bank_verification($ver, amount_1 => 1, amount_2 => 2);

# AUTHORS

- Ali Anari <ali@tilt.com>
- Khaled Hussein <khaled@tilt.com>
- Naveed Massjouni <naveed@tilt.com>
- Al Newkirk <al@tilt.com>
- Will Wolf <will@tilt.com>

# COPYRIGHT AND LICENSE

This software is copyright (c) 2012 by Crowdtilt, Inc..

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.
