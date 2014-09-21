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

sub create_check_recipient {
    my ($self, %params) = @_;
    my $name        = $params{name};
    my $address1    = $params{address1};
    my $address2    = $params{address2};
    my $postal_code = $params{postal_code};
    croak "The name param is required" unless $name;
    croak "The address1 param is required" unless $address1;
    croak "The postal_code param is required" unless $postal_code;

    my $res = $self->post('/check_recipients', {
        name => $name,
        address => {
            line1 => $address1,
            line2 => $address2,
            postal_code => $postal_code,
        },
    });
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

sub _build_merchant {
    my ($self) = @_;
    my $data = $self->get($self->merchants_uri);
    return $data->{merchants}[0];
}

sub _build_uris {
    my ($self) = @_;
    my $links = $self->marketplaces->{links};
    return { map { (split /^marketplaces./)[1] => $links->{$_} } keys %$links };
}

1;
