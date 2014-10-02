package Business::BalancedPayments::V11;
use Moo;
with 'Business::BalancedPayments::Base';

use Carp qw(croak);

has marketplaces_uri => ( is => 'ro', default => '/marketplaces' );

has marketplaces => ( is => 'ro', lazy => 1, builder => '_build_marketplaces' );

sub BUILD {
    my ($self) = @_;
    $self->ua->default_header(
        accept => 'application/vnd.api+json;revision=1.1');
}

around get_card => _wrapper('cards');

around create_card => _wrapper('cards');

sub add_card {
    my ($self, $card, %args) = @_;
    my $customer = $args{customer};
    croak 'The card param must be a hashref' unless ref $card eq 'HASH';
    my $card_href = $card->{href} or croak 'The card href is missing';
    croak 'The customer param must be a hashref' unless ref $customer eq 'HASH';
    my $cust_href = $customer->{href} or croak 'The customer href is missing';
    return $self->put($card->{href}, { customer => $cust_href })->{cards}[0];
}

around get_customer => _wrapper('customers');

around create_customer => _wrapper('customers');

sub create_check_recipient {
    my ($self, $rec) = @_;
    croak 'The recipient param must be a hashref' unless ref $rec eq 'HASH';
    croak 'The recipient name is missing' unless defined $rec->{name};
    croak 'The recipient address line1 is missing'
        unless $rec->{address}{line1};
    croak 'The recipient address postal_code is missing'
        unless $rec->{address}{postal_code};
    my $res = $self->post('/check_recipients', $rec);
    return $res->{check_recipients}[0];
}

sub create_check_recipient_credit {
    my ($self, $credit, %args) = @_;
    my $check_recipient = $args{check_recipient};
    croak 'The check_recipient param must be a hashref'
        unless ref $check_recipient eq 'HASH';
    croak 'The check_recipient hashref needs an id'
        unless $check_recipient->{id};
    croak 'The credit param must be a hashref' unless ref $credit eq 'HASH';
    croak 'The credit must contain an amount' unless $credit->{amount};

    my $res = $self->post(
        "/check_recipients/$check_recipient->{id}/credits", $credit);
    return $res->{credits}[0];
}

sub _build_marketplaces {
    my ($self) = @_;
    return $self->get($self->marketplaces_uri);
}

sub _build_marketplace {
    my ($self) = @_;
    return $self->marketplaces->{marketplaces}[0];
}

sub _build_uris {
    my ($self) = @_;
    my $links = $self->marketplaces->{links};
    return { map { (split /^marketplaces./)[1] => $links->{$_} } keys %$links };
}

sub _wrapper {
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
      'cards' => [
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
      ],
      'links' => {
        'cards.card_holds' => '/cards/{cards.id}/card_holds',
        'cards.customer' => '/customers/{cards.customer}',
        'cards.debits' => '/cards/{cards.id}/debits',
        'cards.disputes' => '/cards/{cards.id}/disputes'
      }
    }

=head2 create_card

Creates a card.
Returns the card card that was created.

    create_card({
        number           => '5105105105105100',
        expiration_month => 12,
        expiration_year  => 2020,
    })

=head2 add_card

    add_card($card, customer => $customer);

Associates a card with a customer.
It expects a card hashref, such as one returned by L</get_card>,
and a customer hashref, such as one returned by L</get_customer>.
Returns the card.

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

    create_customer()
    create_customer({ name => 'Bob', email => 'bob@foo.com' })

Creates a customer.
A customer hashref is optional.
Returns the customer object.

=cut

1;
