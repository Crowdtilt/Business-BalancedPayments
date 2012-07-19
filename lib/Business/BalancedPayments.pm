package Business::BalancedPayments;
use Moo;
with 'Business::BalancedPayments::HTTP';

use Carp qw(croak);

has secret      => (is => 'ro', required => 1                             );
has merchant    => (is => 'rw', lazy => 1, builder => '_build_merchant'   );
has marketplace => (is => 'rw', lazy => 1, builder => '_build_marketplace');

has api_keys_uri     => (is => 'ro', default => sub { '/v1/api_keys'     });
has merchants_uri    => (is => 'ro', default => sub { '/v1/merchants'    });
has marketplaces_uri => (is => 'ro', default => sub { '/v1/marketplaces' });

sub _build_merchant {
    my ($self) = @_;
    my $data = $self->get($self->merchants_uri);
    return $data->{items}[0];
}

sub _build_marketplace {
    my ($self) = @_;
    my $data = $self->get($self->marketplaces_uri);
    return $data->{items}[0];
}

sub get_card {
    my ($self, $id) = @_;
    croak 'The id param is missing' unless defined $id;
    return $self->get($self->marketplace->{cards_uri} . "/$id");
}

sub create_card {
    my ($self, $card) = @_;
    croak 'The card param must be a hashref' unless ref $card eq 'HASH';
    return $self->post($self->marketplace->{cards_uri}, $card);
}

sub get_account {
    my ($self, $id) = @_;
    croak 'The id param is missing' unless defined $id;
    return $self->get($self->marketplace->{accounts_uri} . "/$id");
}

sub get_account_by_email {
    my ($self, $email) = @_;
    croak 'The email param is missing' unless $email;
    return $self->get(
        $self->marketplace->{accounts_uri} . "?email_address=$email");
}

sub create_account {
    my ($self, $account, %args) = @_;
    my $card = $args{card};
    croak 'The account param must be a hashref' unless ref $account eq 'HASH';
    croak 'The account requires an email_address field'
        unless $account->{email_address};
    my $existing_acct = $self->get_account_by_email($account->{email_address});
    $existing_acct = $existing_acct->{items}[0];
    return $existing_acct if $existing_acct;
    if ($card) {
        croak 'The card param must be a hashref' unless ref $card eq 'HASH';
        croak 'The card is missing a uri' unless $card->{uri};
        $account->{card_uri} = $card->{uri};
    }
    return $self->post($self->marketplace->{accounts_uri}, $account);
}

sub update_account {
    my ($self, $account) = @_;
    croak 'The account param must be a hashref' unless ref $account eq 'HASH';
    return $self->put($account->{uri}, $account);
}

sub add_card {
    my ($self, $card, %args) = @_;
    my $account = $args{account};
    croak 'The card param must be a hashref' unless ref $card eq 'HASH';
    croak 'The account param must be a hashref' unless ref $account eq 'HASH';
    croak 'The account requires a cards_uri field' unless $account->{cards_uri};
    return $self->post($account->{cards_uri}, $card);
}

sub add_bank_account {
    my ($self, $bank_account, %args) = @_;
    my $account = $args{account};
    croak 'The bank_account param must be a hashref'
        unless ref $bank_account eq 'HASH';
    croak 'The account param must be a hashref' unless ref $account eq 'HASH';
    croak 'The bank_accounts_uri field is missing from the account object'
        unless $account->{bank_accounts_uri};
    return $self->post($account->{bank_accounts_uri}, $bank_account);
}

sub create_hold {
    my ($self, $hold, %args) = @_;
    croak 'The hold param must be a hashref' unless ref $hold eq 'HASH';
    croak 'The hold is missing an amount field' unless $hold->{amount};
    my $card = $args{card};
    my $account = $args{account};
    croak 'An account or card must be provided' unless $account or $card;
    my $holds_uri;
    if ($account) {
        croak 'The account must be a hashref' unless ref $account eq 'HASH';
        $holds_uri = $account->{holds_uri};
    }
    if ($card) {
        croak 'The card param must be a hashref' unless ref $card eq 'HASH';
        croak 'The card is missing a uri' unless $card->{uri};
        $holds_uri ||= $card->{account}{holds_uri};
    }
    croak 'No holds_uri found' unless $holds_uri;
    $hold->{source_uri} = $card->{uri} if $card;
    return $self->post($holds_uri, $hold);
}

sub capture_hold {
    my ($self, $hold) = @_;
    croak 'The hold param must be a hashref' unless ref $hold eq 'HASH';
    croak 'No hold uri found' unless $hold->{uri};
    return $self->post(
        $self->marketplace->{debits_uri}, { hold_uri => $hold->{uri} });
}

sub get_hold {
    my ($self, $id) = @_;
    croak 'The id param is missing' unless defined $id;
    return $self->get($self->marketplace->{holds_uri} . "/$id");
}

sub void_hold {
    my ($self, $hold) = @_;
    croak 'The hold param must be a hashref' unless ref $hold eq 'HASH';
    croak 'No hold uri found' unless $hold->{uri};
    return $self->put($hold->{uri}, { is_void => 'True' });
}

sub refund_debit {
    my ($self, $debit) = @_;
    croak 'The debit param must be a hashref' unless ref $debit eq 'HASH';
    croak 'No amount found' unless $debit->{amount};
    croak 'No debit uri found' unless $debit->{uri} || $debit->{debit_uri};
    $debit->{debit_uri} ||= $debit->{uri};
    return $self->post($self->marketplace->{refunds_uri}, $debit);
}

sub get_bank_account {
    my ($self, $id) = @_;
    croak 'The id param is missing' unless defined $id;
    return $self->get($self->marketplace->{bank_accounts_uri} . "/$id");
}

sub create_bank_account {
    my ($self, $bank_account) = @_;
    croak 'The bank_account must be a hashref'
        unless ref $bank_account eq 'HASH';
    return $self->post($self->marketplace->{bank_accounts_uri}, $bank_account);
}

sub create_credit {
    my ($self, $credit, %args) = @_;
    my $account = $args{account};
    my $bank_account = $args{bank_account};
    croak 'The credit param must be a hashref' unless ref $credit eq 'HASH';
    croak 'The credit must contain an amount' unless exists $credit->{amount};
    croak 'An account or bank_account params is required'
        unless $account or $bank_account;
    my $credits_uri;
    if ($account) {
        croak 'The account param must be a hashref'
            unless ref $account eq 'HASH';
        $credits_uri = $account->{credits_uri};
    }
    if ($bank_account) {
        croak 'The bank_account param must be a hashref'
            unless ref $bank_account eq 'HASH';
        croak 'The bank_account is a uri' unless$bank_account->{uri};
        croak 'The bank_account is missing an credits_uri'
            unless$bank_account->{account}{credits_uri};
        $credits_uri = $bank_account->{account}{credits_uri};
        $credit->{bank_account_uri} = $bank_account->{uri};
    }
    croak 'No credits_uri found' unless $credits_uri;
    return $self->post($credits_uri, $credit);
}

# ABSTRACT: BalancedPayments API bindings

=head1 SYNOPSIS

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

=head1 DESCRIPTION

This module provides bindings for the
L<BalancedPayments|https://www.balancedpayments.com> API.

=head1 METHODS

=head2 get_card

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

=head2 create_card

    create_card({
        card_number      => "5105105105105100",
        expiration_month => 12,
        expiration_year  => 2020,
        security_code    => 123,
    })

Creates a credit card.
See L</get_card> for an example response.

=head2 get_account

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

=head2 get_account_by_email

    get_account_by_email($email)

Returns the account for the given email address.
See L</get_account> for an example response.

=head2 create_account

    create_account($account)
    create_account($account, card => $card)

Creates an account.
An account hashref is required.
The account hashref must have an email_address field:

    $bp->create_account({ email_address => 'bob@crowdtilt.com' });

It is possible to create an account and associate it with a credit card at the
same time.
You can do this in 2 ways.
You can provide a card such as one returned by calling L</get_card>:

    my $card = $bp->get_card($card_id);
    $bp->create_account({ email_address => 'bob@crowdtilt.com' }, card => $card)

Alternatively, you can provide a card_uri inside the account hashref:

    my $card = $bp->get_card($card_id);
    $bp->create_account({
        email_address => 'bob@crowdtilt.com',
        card_uri      => $card->{uri},
    });

Returns an account hashref.
See L</get_account> for an example response.

=head2 update_account

    update_account($account)

Updates an account.
it expects an account hashref, such as one returned by L</get_account>

=head2 add_card

    add_card($card, account => $account)

Adds a card to an account.
It expects a card hashref, such as one returned by L</get_card>,
and an account hashref, such as one returned by L</get_account>.

Returns an account hashref.
See L</get_account> for an example response.

=head2 get_hold

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

=head2 create_hold

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

See L</get_hold> for an example response.

=head2 capture_hold

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

=head2 void_hold

    void_hold($hold)

Voids a hold.

    my $hold = $bp->get_hold($hold_id);
    $bp->void_hold($hold);

Returns a hold hashref.
See L</get_hold> for an example response.

=head2 refund_debit

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

=head2 get_bank_account

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

=head2 create_bank_account

    create_bank_account($bank_account)

Creates a bank account.
A bank account hashref is required:

    $bp->create_bank_account({
        name           => "WHC III Checking",
        account_number => "12341234",
        bank_code      => "321174851",
    });

See L</get_bank_account> for an example response.


=head2 add_bank_account

    add_bank_account($bank_account, account => $account)

Adds a bank account to an account.
It expects a bank account hashref and an account hashref:

    my $account = $bp->get_account($account_id);
    $bp->add_bank_accounti(
        {
            name           => "WHC III Checking",
            account_number => "12341234",
            bank_code      => "321174851",
        },
        account => $account
    );

This operation implicitly adds the "merchant" role to the account.

Returns an bank_account hashref.
See L</get_bank_account> for an example response.

=head2 create_credit

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

=cut

1;
