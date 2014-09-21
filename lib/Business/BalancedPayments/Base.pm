package Business::BalancedPayments::Base;
use Moo::Role;
with 'WebService::Client';

use Carp qw(croak);
use HTTP::Request::Common qw(GET POST);
use JSON qw(encode_json);

requires qw(_build_marketplace _build_uris);

has '+base_url' => (is => 'ro', default => 'https://api.balancedpayments.com');

has secret => (is => 'ro', required => 1);

has uris => (is => 'ro', lazy => 1, builder => '_build_uris' );

has marketplace => (is => 'ro', lazy => 1, builder => '_build_marketplace');

around req => sub {
    my ($orig, $self, $req, @rest) = @_;
    $req->authorization_basic($self->secret);
    return $self->$orig($req, @rest);
};

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

sub log {
    my ($self, $msg) = @_;
    return unless $self->logger;
    $self->logger->DEBUG("BP: $msg");
}

sub _uri {
    my ($self, $key, $id) = @_;
    return $id if $id and $id =~ /\//; # in case a uri was passed in
    return $self->uris->{$key} . ( defined $id ? "/$id" : '' );
}

1;
