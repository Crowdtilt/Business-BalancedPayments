package BalancedPayments;
use Moo;

use HTTP::Request::Common qw(GET POST);
use JSON qw(from_json);
use LWP::UserAgent;

has secret      => (is => 'ro', required => 1);
has merchant    => (is => 'rw', lazy => 1, builder => '_build_merchant');
has marketplace => (is => 'rw', lazy => 1, builder => '_build_marketplace');
has base_url => (
    is => 'ro',
    default => sub { return 'https://api.balancedpayments.com' }
);
has ua => (
    is => 'ro',
    lazy => 1,
    default => sub {
        my $ua = LWP::UserAgent->new;
        $ua->timeout(10);
        return $ua;
    },
);
has api_keys_uri     => (is => 'ro', default => sub { '/v1/api_keys' });
has merchants_uri    => (is => 'ro', default => sub { '/v1/merchants' });
has marketplaces_uri => (is => 'ro', default => sub { '/v1/marketplaces' });
has cards_uri => (
    is => 'ro',
    lazy => 1,
    default => sub { shift->marketplace->{cards_uri} }
);

sub get_card {
    my ($self, $id) = @_;
    return $self->_get($self->cards_uri . "/$id");
}

sub create_card {
    my ($self, $args) = @_;
    return $self->_post($self->cards_uri, $args);
}

sub _url { $_[0]->base_url . $_[1] }

sub _build_merchant {
    my ($self) = @_;
    my $data = $self->_get($self->merchants_uri);
    return $data->{items}[0];
}

sub _build_marketplace {
    my ($self) = @_;
    my $data = $self->_get($self->marketplaces_uri);
    return $data->{items}[0];
}

sub _get {
    my ($self, $path) = @_;
    return $self->_req(GET $path);
}

sub _post {
    my ($self, $path, $params) = @_;
    return $self->_req(POST $path, content => $params);
}

sub _req {
    my ($self, $req) = @_;
    $req->authorization_basic($self->secret);
    return $self->ua->request($req);
}

sub _check_res {
    my ($res) = @_;
    my ($url, $method) = ($res->request->uri, $res->request->method);
    die sprintf "Error attempting %s => %s:\n%s\n%s",
        $method, $url, $res->status_line, $res->content
        unless $res->is_success;
}

around qw(_get _post) => sub {
    my $orig = shift;
    my $self = shift;
    my $path = shift;
    my $url = $self->_url($path);
    my $res = $self->$orig($url, @_);
    _check_res($res);
    return from_json($res->content);
};

# ABSTRACT: BalancedPayments API bindings

=head1 SYNOPSIS

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

=head1 DESCRIPTION

This module provides bindings for the
L<BalancedPayments|https://www.balancedpayments.com> API.

=head1 METHODS

=head2 get_card

    get_card($id)

Returns a credit card hashref for the given id.
Here is an example response:

    { 
        account          => '123',
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

Creates a credit card and returns the corresponding hashref.
See L</get_card> for an example response.

=cut

1;
