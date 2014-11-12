package Business::BalancedPayments::Base;
use Moo;
with 'WebService::Client';

# VERSION

use Carp qw(croak);
use HTTP::Request::Common qw(GET POST);
use JSON qw(encode_json);

has '+base_url' => (is => 'ro', default => 'https://api.balancedpayments.com');

has secret => (is => 'ro', required => 1);

has uris => (is => 'ro', lazy => 1, builder => '_build_uris' );

has marketplace => (is => 'ro', lazy => 1, builder => '_build_marketplace');

sub BUILD {
    my ($self) = @_;
    $self->ua->default_headers->authorization_basic($self->secret, '');
}

sub get_card {
    my ($self, $id) = @_;
    croak 'The id param is missing' unless defined $id;
    return $self->get($self->_uri('cards', $id));
}

sub create_card {
    my ($self, $card) = @_;
    croak 'The card param must be a hashref' unless ref $card eq 'HASH';
    return $self->post($self->_uri('cards'), $card);
}

sub get_customer {
    my ($self, $id) = @_;
    croak 'The id param is missing' unless defined $id;
    return $self->get($self->_uri('customers', $id));
}

sub create_customer {
    my ($self, $customer) = @_;
    $customer ||= {};
    croak 'The customer param must be a hashref' unless ref $customer eq 'HASH';
    return $self->post($self->_uri('customers'), $customer);
}

sub get_debit {
    my ($self, $id) = @_;
    croak 'The id param is missing' unless defined $id;
    return $self->get($self->_uri('debits', $id));
}

sub get_bank_account {
    my ($self, $id) = @_;
    croak 'The id param is missing' unless defined $id;
    return $self->get($self->_uri('bank_accounts', $id));
}

sub create_bank_account {
    my ($self, $bank) = @_;
    croak 'The bank account must be a hashref' unless ref $bank eq 'HASH';
    return $self->post($self->_uri('bank_accounts'), $bank);
}

sub get_credit {
    my ($self, $id) = @_;
    croak 'The id param is missing' unless defined $id;
    return $self->get($self->_uri('credits', $id));
}

sub log {
    my ($self, $msg) = @_;
    return unless $self->logger;
    $self->logger->DEBUG("BP: $msg");
}

sub next {
    my ($self, $thing) = @_;
    return $self->get( $thing->{meta}{next} );
}

sub _uri {
    my ($self, $key, $id) = @_;
    return $id if $id and $id =~ /\//; # in case a uri was passed in
    return $self->uris->{$key} . ( defined $id ? "/$id" : '' );
}

1;
