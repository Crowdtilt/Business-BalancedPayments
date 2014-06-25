# NAME

Business::BalancedPayments - BalancedPayments API bindings

# VERSION

version 0.1501

# SYNOPSIS

    use Business::BalancedPayments;

    my $secret = 'abc123';
    my $bp = Business::BalancedPayments->new(secret => $secret);

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

For the `get_*` methods, the `$id` param can be the id of the resource or
a uri. For example, the following two lines are equivalent:

    $bp->get_account('AC7A');
    $bp->get_account('/v1/marketplaces/MK98/accounts/AC7A');

## new

    my $bp = Business::BalancedPayments->new(
        secret  => $secret,
        logger  => $logger, # optional
        retries => 3,       # optional
    );

Instantiates a new \`Business::BalancedPayments\` client object.
Parameters:

- secret

    Required. The Balanced Payments secret key for your account.

- logger

    Optional.
    A logger-like object.
    It just needs to have a method named `DEBUG` that takes a single argument,
    the message to be logged.
    A [Log::Tiny](http://search.cpan.org/perldoc?Log::Tiny) object would be a good choice.

- retries

    Optional.
    The number of times to retry requests in cases when Balanced returns a 5xx
    response.
    Defaults to 0.

## get\_transactions

    get_transactions()

Returns the transactions for this marketplace.

## get\_card

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

## create\_card

    create_card({
        card_number      => "5105105105105100",
        expiration_month => 12,
        expiration_year  => 2020,
        security_code    => 123,
    })

Creates a credit card.
See ["get\_card"](#get\_card) for an example response.

## get\_account

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

## get\_account\_by\_email

    get_account_by_email($email)

Returns the account for the given email address.
See ["get\_account"](#get\_account) for an example response.

## create\_account

    create_account()
    create_account($account)
    create_account($account, card => $card)

Creates an account.
An account hashref is optional.
The account hashref, if passed in, must have an email\_address field:

    $bp->create_account({ email_address => 'bob@crowdtilt.com' });

It is possible to create an account and associate it with a credit card at the
same time.
You can do this in 2 ways.
You can provide a card such as one returned by calling ["get\_card"](#get\_card):

    my $card = $bp->get_card($card_id);
    $bp->create_account({ email_address => 'bob@crowdtilt.com' }, card => $card)

Alternatively, you can provide a card\_uri inside the account hashref:

    my $card = $bp->get_card($card_id);
    $bp->create_account({
        email_address => 'bob@crowdtilt.com',
        card_uri      => $card->{uri},
    });

Returns an account hashref.
See ["get\_account"](#get\_account) for an example response.

## update\_account

    update_account($account)

Updates an account.
It expects an account hashref, such as one returned by ["get\_account"](#get\_account).
The account hashref must contain a uri or id field.

## add\_card

    add_card($card, account => $account)

Adds a card to an account.
It expects a card hashref, such as one returned by ["get\_card"](#get\_card),
and an account hashref, such as one returned by ["get\_account"](#get\_account).

Returns an account hashref.
See ["get\_account"](#get\_account) for an example response.

## get\_debit

    get_debit($debit_id)

Returns the debit with the given id.
Example response:

    {
      id                       =>  "WD1xtdUeixQIfJEsg4RwwHjQ",
      transaction_number       =>  "W553-201-5667",
      amount                   =>  50,
      fee                      =>  1,
      description              =>  undef,
      appears_on_statement_as  =>  "example.com",
      available_at             =>  "2012-10-25T04:48:19.337522Z",
      created_at               =>  "2012-10-25T04:48:19.443904Z",
      uri                      =>  "/v1/marketplaces/MK98/debits/WD2L",
      refunds_uri              => "/v1/marketplaces/MK98/debits/WD2L/refunds",
      account                  =>  { ...  },
      hold                     =>  { ...  },
      meta                     =>  { ...  },
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

## create\_debit

    create_debit($debit, account => $account)
    create_debit($debit, card => $card)

Creates a debit.
It expects a debit hashref which at least contains an amount field.
An account or card must be provided.

    my $account = $bp->get_account($account_id);
    $bp->create_debit ({ account => 250 }, account => $account);

    my $card = bp->get_card($card_id);
    $bp->create_debit({ amount => 250 }, card => $card);

Successful creation of a debit will return an associated hold as part of the
response.
This hold was created and captured behind the scenes automatically.
See ["get\_debit"](#get\_debit) for an example response.

## get\_hold

    get_hold($hold_id)

Returns the hold with the given id.
Example response:

    {
      id          => "HL5byxIzSvf0entZuO9eEsWJ",
      uri         => "/v1/marketplaces/MK98/holds/HL5byxIzSvf0entZuO9eEsWJ",
      amount      => 200,
      description => undef,
      created_at  => "2012-06-08T09:23:53.745746Z",
      expires_at  => "2012-06-15T09:23:53.705009Z",
      fee         => 35,
      is_void     => 0,
      account     => { ... },
      debit       => { ... },
      meta        => { ... },
      source      => { ... },
    }

## create\_hold

    create_hold($hold, account => $account)
    create_hold($hold, card => $card)

Creates a hold for the given account.
It expects a hold hashref which at least contains an amount field.

An account or card must be provided.
If an account is provided, Balanced defaults to charging the most recently
added card for the account.

    my $account = $bp->get_account($account_id);
    $bp->create_hold ({ account => 250 }, account => $account);

You can pass in a card if you want to charge a specific card:

    my $card = bp->get_card($card_id);
    $bp->create_hold({ amount => 250 }, card => $card);

See ["get\_hold"](#get\_hold) for an example response.

## capture\_hold

    capture_hold($hold)
    capture_hold($hold, {
        amount                  => ...,
        appears_on_statement_as => ...,
        meta                    => ...,
        description             => ...,
        on_behalf_of_uri        => ...,
        source_uri              => ...,
        bank_account_uri        => ...,
    })

Capturing a hold will create a debit representing the flow of funds from the
buyer's account to your marketplace.
The `hold` param is required and may be a hold object or a hold uri.
A an optional hashref of extra parameters may be provided.
They will be passed on to Balanced.

    my $hold = $bp->get_hold($hold_id);
    my $merchant_account = $bp->get_account($merchant_id);
    $bp->capture_hold($hold, { on_behalf_of_uri => $merchant_account->{uri} });

Returns a debit hashref.
Example response:

    {
      id                      => "WD2Lpzyz8Okbhx2Nbw7YuTP3",
      transaction_number      => "W476-365-3767",
      uri                     => "/v1/marketplaces/MK98/debits/WD2L",
      amount                  => 50,
      appears_on_statement_as => "example.com",
      available_at            => "2012-06-08T09:57:27.686977Z",
      created_at              => "2012-06-08T09:57:27.750828Z",
      description             => undef,
      fee                     => 1,
      meta                    => { ... },
      hold                    => { ... },
      account                 => { ... },
      source                  => { ... },
      refunds_uri             => "/v1/marketplaces/MK98/debits/WD2L/refunds",
    }

    =head2 get_refund

     get_refund($id)

    Gets a refund by id.

     $bp->get_refund($id);

    Returns a refund hashref.
    Example response.
      {
        id                       =>  'RF74',
        transaction_number       =>  'RF966-744-5492',
        amount                   =>  323,
        fee                      =>  -10,
        description              =>  '',
        appears_on_statement_as  =>  'example.com',
        created_at               =>  '2012-08-27T16:54:46.595330Z',
        debit                    =>  { ... },
        meta                     =>  { ... },
        account                  =>  { ... },
        uri                      =>  '/v1/marketplaces/MP35/refunds/RF74',
      }

## get\_refunds

    get_refunds($debit)

Gets the refunds associated with a specific debit.

    my $debit = $bp->get_debit($debit_id);
    $bp->get_refunds($debit);

Returns a refunds hashref.
Example response.
  {
    items => \[
      {
        id                       =>  'RF74',
        transaction\_number       =>  'RF966-744-5492',
        amount                   =>  323,
        fee                      =>  -10,
        description              =>  '',
        appears\_on\_statement\_as  =>  'example.com',
        created\_at               =>  '2012-08-27T16:54:46.595330Z',
        debit                    =>  { ... },
        meta                     =>  { ... },
        account                  =>  { ... },
        uri                      =>  '/v1/marketplaces/MP35/refunds/RF74',
      }
    \],
    offset    => 0,
    limit     => 10,
    next\_uri  => undef,
    total     => 1,
    uri       => '/v1/marketplaces/MP35/debits/WD2L/refunds?limit=10&offset=0',
    first\_uri => '/v1/marketplaces/MP35/debits/WD2L/refunds?limit=10&offset=0',
    last\_uri  => '/v1/marketplaces/MP35/debits/WD2L/refunds?limit=10&offset=0',
    previous\_uri => undef,
  }

## void\_hold

    void_hold($hold)

Voids a hold.

    my $hold = $bp->get_hold($hold_id);
    $bp->void_hold($hold);

Returns a hold hashref.
See ["get\_hold"](#get\_hold) for an example response.

## refund\_debit

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

## get\_bank\_account

    get_bank_account($id)

Returns the bank account for the given id.

Example response:

    {
        id          =>  "BA3gES",
        uri         =>  "/v1/marketplaces/MK98/bank_accounts/BA3gES",
        name        =>  "WHC III Checking",
        bank_name   =>  "SAN MATEO CREDIT UNION",
        bank_code   =>  321174851,
        last_four   =>  1234,
        created_at  =>  "2012-06-12T15:00:59.248638Z",
        is_valid    =>  1,
        account     =>  { ... },
    }

## confirm\_bank\_verification

    confirm_bank_verification($bank_id, verification_id => $verification_id,
        amount_1 => $x, amount_2 => $y)

Returns the bank account verification status for the given ids.

Example response:

    {
        _type              => "bank_account_authentication",
        _uris              => {},
        attempts           => 0,
        created_at         => "2014-01-09T03:11:11.080804Z",
        id                 => "BZ5nDyPcUn2QNkgQn4o62gjM",
        remaining_attempts => 3,
        state              => "deposit_succeeded",
        updated_at         => "2014-01-09T03:11:11.490600Z",
        uri                => "/v1/bank_accounts/BA5lj/verifications/BZ5nD"
    }

## create\_bank\_account

    create_bank_account($bank_account)

Creates a bank account.
A bank account hashref is required:

    $bp->create_bank_account({
        name           => "WHC III Checking",
        account_number => "12341234",
        bank_code      => "321174851",
    });

Returns a bank account hashref.
See ["get\_bank\_account"](#get\_bank\_account) for an example response.

## create\_bank\_verification

    create_bank_verification($bank_id)

Returns the bank account verification receipt for the request.

Example response:

    {
        _type              => "bank_account_authentication",
        _uris              => {},
        attempts           => 1,
        created_at         => "2014-01-09T03:11:20.160110Z",
        id                 => "BZ5xQsMUtax4itwPTPM2Ducu",
        remaining_attempts => 2,
        state              => "verified",
        updated_at         => "2014-01-09T03:11:21.482255Z",
        uri                => "/v1/bank_accounts/BA5vJy/verifications/BZ5xQs"
    }

## add\_bank\_account

    add_bank_account($bank_account, account => $account)

Adds a bank account to an account.
It expects a bank account hashref and an account hashref:

    my $account = $bp->get_account($account_id);
    $bp->add_bank_account(
        {
            name           => "WHC III Checking",
            account_number => "12341234",
            bank_code      => "321174851",
        },
        account => $account
    );

This operation implicitly adds the "merchant" role to the account.

Returns a bank account hashref.
See ["get\_bank\_account"](#get\_bank\_account) for an example response.

## update\_bank\_account

    update_bank_account($bank_account)

Updates a bank account.
A bank account hashref must be provided which must contain an id or uri for
the bank account.
Balanced only allows you to update the is\_valid and meta fields.
You may invalidate a bank account by passing is\_valid with a false value.
Once a bank account has been invalidated it cannot be re-activated.

    $bp->update_bank_account({
        id       => 'BA3gES',
        is_valid => 0,
        meta     => { foo => 'bar' },
    });

Returns a bank account hashref.
See ["get\_bank\_account"](#get\_bank\_account) for an example response.

## invalidate\_bank\_account

    invalidate_bank_account($bank_account_id);

Invalidates a bank account.
A bank account id is required.
This is a convenience method that does the equivalent of:

    update_bank_account({ id => $bank_id, is_valid => 0 });

Returns a bank account hashref.
See ["get\_bank\_account"](#get\_bank\_account) for an example response.

## get\_credit

    get_credit($credit_id);

Gets a credit.
This is a way to get information about a specific credit, which can be useful
to check its status or get fee information about it.

## create\_credit

    create_credit($credit, account => $account);
    create_credit($credit, bank_account => $bank_account);

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

- Al Newkirk <al@crowdtilt.com>
- Khaled Hussein <khaled@crowdtilt.com>
- Naveed Massjouni <naveed@crowdtilt.com>
- Will Wolf <will@crowdtilt.com>

# COPYRIGHT AND LICENSE

This software is copyright (c) 2012 by Crowdtilt, Inc..

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.
