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

1;
