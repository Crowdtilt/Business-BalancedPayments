# NAME

BalancedPayments - BalancedPayments API bindings

# VERSION

version 0.0001

# SYNOPSIS

    use BalancedPayments;

    my $secret = 'abc123';
    my $bp = BalancedPayments->new(secret => $secret);

    my $card = $bp->create_card({
        card_number      => "5105105105105100",
        expiration_month => 12,
        expiration_year  => 2020,
        security_code    => 123,
    });

    $bp->get_card($card->{id});

# DESCRIPTION

This module provides bindings for the
[BalancedPayments](https://www.balancedpayments.com) API.

# METHODS

## get_card

    get_card($id)

Returns the credit card for the given id.

Example response:

    { 
        account          => { ... },
        brand            => "MasterCard",
        card_type        => "mastercard",
        created_at       => "2012-06-07T11:00:40.003671Z",
        expiration_month => 12,
        expiration_year  => 2020,
        id               => "CC92QRQcwUCp5zpzEz7lXKS",
        is_valid         => 1,
        last_four        => 5100,
        name             => undef,
        uri              => "/v1/marketplaces/MK98f1/cards/CC92QRQcwUCp5zpzKS",
    }

## create_card

    create_card({
        card_number      => "5105105105105100",
        expiration_month => 12,
        expiration_year  => 2020,
        security_code    => 123,
    })

Creates a credit card.
See ["get_card"](#get_card) for an example response.

## get_account

    get_account($id)

Returns the account for the given id.

Example response:

    {
        id                => "AC7A",
        uri               => "/v1/marketplaces/MK98/accounts/AC7A",
        email_address     => "naveed\@crowdtilt.com",
        meta              => {},
        name              => undef,
        roles             => [],
        created_at        => "2012-06-07T21:01:38.801460Z",
        bank_accounts_uri => "/v1/marketplaces/MK98/accounts/AC7A/bank_accounts",
        cards_uri         => "/v1/marketplaces/MK98/accounts/AC7A/cards",
        credits_uri       => "/v1/marketplaces/MK98/accounts/AC7A/credits",
        debits_uri        => "/v1/marketplaces/MK98/accounts/AC7A/debits",
        holds_uri         => "/v1/marketplaces/MK98/accounts/AC7A/holds",
        refunds_uri       => "/v1/marketplaces/MK98/accounts/AC7A/refunds",
        transactions_uri  => "/v1/marketplaces/MK98/accounts/AC7A/transactions",
    }

## create_account

    create_account($account)
    create_account($account, card => $card)

Creates an account.
An account hashref is required.
The account hashref must have an email_address field:

    $bp->create_account({ email_address => 'bob@crowdtilt.com' });

It is possible to create an account and associate it with a credit card at the
same time.
You can do this in 2 ways.
You can provide a card such as one returned by calling ["get_card"](#get_card):

    my $card = $bp->get_card($card_id);
    $bp->create_account({ email_address => 'bob@crowdtilt.com' }, card => $card)

Alternatively, you can provide a card_uri inside the account hashref:

    my $card = $bp->get_card($card_id);
    $bp->create_account({
        email_address => 'bob@crowdtilt.com',
        card_uri      => $card->{uri},
    });

Returns an account hashref.
See ["get_account"](#get_account) for an example response.

## add_card

    add_card($card, account => $account)

Adds a card to an account.
It expects a card hashref, such as one returned by ["get_card"](#get_card),
and an account hashref, such as one returned by ["get_account"](#get_account).

Returns an account hashref.
See ["get_account"](#get_account) for an example response.

## get_hold

    get_hold($hold_id)

Returns the hold with the given id.
Example response:

    {
      id          => "HL5byxIzSvf0entZuO9eEsWJ",
      uri         => "/v1/marketplaces/MK98/holds/HL5byxIzSvf0entZuO9eEsWJ",
      amount      => 200,
      account     => { ... },
      created_at  => "2012-06-08T09:23:53.745746Z",
      debit       => undef,
      description => undef,
      expires_at  => "2012-06-15T09:23:53.705009Z",
      fee         => 35,
      is_void     => 0,
      meta        => {},
      source => {
        brand            => "MasterCard",
        card_type        => "mastercard",
        created_at       => "2012-06-07T11:00:40.003671Z",
        expiration_month => 12,
        expiration_year  => 2020,
        id               => "CC92QRQcwUCp5zpzEz7lXKS",
        is_valid         => 1,
        last_four        => 5100,
        name             => undef,
        uri => "/v1/marketplaces/MK98/accounts/AC7A/cards/CC92QRQcwUCp5zpzEz7lXKS",
      },
    }

## create_hold

    create_hold($hold, account => $account)
    create_hold($hold, card => $card)

Creates a hold for the given account.
It expects a hold hashref which at least contains an amount field.
The amount must be an integer value >= 200.

An account or card must be provided.
If an account is provided, Balanced defaults to charging the most recently
added card for the account.

    my $account = $bp->get_account($account_id);
    $bp->create_hold ({ account => 250 }, account => $account);

You can pass in a card if you want to charge a specific card:

    my $card = bp->get_card($card_id);
    $bp->create_hold({ amount => 250 }, card => $card);

See ["get_hold"](#get_hold) for an example response.

## capture_hold

    capture_hold($hold)

Capturing a hold will create a debit representing the flow of funds from the
buyer's account to your marketplace.

    my $hold = $bp->get_hold($hold_id);
    $bp->capture_hold($hold);

Returns a debit hashref.
Example response:

    {
      id                      => "WD2Lpzyz8Okbhx2Nbw7YuTP3",
      uri                     => "/v1/marketplaces/MK98/debits/WD2L",
      amount                  => 50,
      appears_on_statement_as => "example.com",
      available_at            => "2012-06-08T09:57:27.686977Z",
      created_at              => "2012-06-08T09:57:27.750828Z",
      description             => undef,
      fee                     => 1,
      meta                    => {},
      hold                    => { ... },
      account                 => { ... },
      refunds_uri             => "/v1/marketplaces/MK98/debits/WD2L/refunds",
      source => {
        brand            => "MasterCard",
        card_type        => "mastercard",
        created_at       => "2012-06-07T11:00:40.003671Z",
        expiration_month => 12,
        expiration_year  => 2020,
        id               => "CC92QRQcwUCp5zpzEz7lXKS",
        is_valid         => 1,
        last_four        => 5100,
        name             => undef,
        uri => "/v1/marketplaces/MK98/accounts/AC7A/cards/CC92QRQcwUCp5zpzEz7lXKS",
      },
      transaction_number => "W476-365-3767",
    }

## void_hold

    void_hold($hold)

Voids a hold.

    my $hold = $bp->get_hold($hold_id);
    $bp->void_hold($hold);

Returns a hold hashref.
See ["get_hold"](#get_hold) for an example response.

## refund_debit

    refund_debit($debit)

Refunds a debit.
If no amount is found in the debit hashref,
then Balanced refunds the entire amount.

    my $account = $bp->get_account($account_id);
    my $debit = $bp->capture_hold(
        $bp->create_hold({ amount => 305 }, account => $account)
    );
    $bp->refund_debit($debit);

Example response:

    {
        id                      => "RFrFB30adjtze8HSIoghLPr",
        uri                     => "/v1/marketplaces/MK98/refunds/RFrFB30adLPr",
        amount                  => 305,
        created_at              => "2012-06-11T11:31:59.414827Z",
        description             => undef,
        fee                     => -10,
        meta                    => {},
        transaction_number      => "RF536-609-0270",
        appears_on_statement_as => "example.com",
        account                 => { ... },
        debit                   => { ... },
    }

## get_bank_account

    get_bank_account($id)

Returns the bank account for the given id.

Example response:

    {
        id          =>  "BA3gESxjg9yO61fj3CVUhGQm",
        uri         =>  "/v1/marketplaces/MK98/bank_accounts/BA3gES",
        name        =>  "WHC III Checking",
        bank_name   =>  "SAN MATEO CREDIT UNION",
        bank_code   =>  321174851,
        last_four   =>  1234,
        created_at  =>  "2012-06-12T15:00:59.248638Z",
        is_valid    =>  1,
        account     =>  { ... },
    }

## create_bank_account

    create_bank_account($bank_account)

Creates a bank account.
A bank account hashref is required:

    $bp->create_bank_account({
        name           => "WHC III Checking",
        account_number => "12341234",
        bank_code      => "321174851",
    });

See ["get_bank_account"](#get_bank_account) for an example response.

## create_credit

    create_credit($credit, account => $account)
    create_credit($credit, bank_account => $bank_account)

Creates a credit.
This is a way of sending money to merchant accounts.
The credit hashref should at least contain an amount field.
An account or bank account hashref is required.
You may pass in a bank account if you would like to specify a specific bank
account to send money to.

    my $bank_account = $bp->get_bank_account($bank_account_id);
    $bp->create_credit({ amount => 50 }, bank_account => $bank_account);

If an account is provided, Balanced will default to crediting the most recently
added bank account.
The account should have the merchant role.

    my $account = $bp->get_account($account_id);
    $bp->create_credit({ amount => 50 }, account => $account);

Returnds a credit hashref.
Example response:

    {
        id                  => "CR4GkfkOzYNBjFXW5Mxtpn1I",
        uri                 => "/v1/marketplaces/MK98/credits/CR4Gkf",
        amount              => 50,
        created_at          => "2012-06-12T18:51:21.097085Z",
        description         => undef,
        meta                => {},
        transaction_number  => "CR382-740-3389",
        account             => { ... },
        destination         => {
            bank_code  => 321174851,
            bank_name  => "SAN MATEO CREDIT UNION",
            created_at => "2012-06-12T15:00:59.248638Z",
            id         => "BA3gESxjg9yO61fj3CVUhGQm",
            is_valid   => 1,
            last_four  => 1234,
            name       => "WHC III Checking",
            uri => "/v1/marketplaces/MK98/accounts/AC78/bank_accounts/BA3g",
        },
    }

# AUTHORS

- Naveed Massjouni <naveedm9@gmail.com>
- Khaled Hussein <khaled.hussein@gmail.com>

# COPYRIGHT AND LICENSE

This software is copyright (c) 2012 by Crowdtilt, Inc..

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.