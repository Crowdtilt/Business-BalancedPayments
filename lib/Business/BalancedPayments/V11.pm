package Business::BalancedPayments::V11;
use Moo;
with 'Business::BalancedPayments::Base';

# VERSION

use Carp qw(croak);
use Method::Signatures;
use Scalar::Util qw(blessed);

has marketplaces_uri => ( is => 'ro', default => '/marketplaces' );

has marketplaces => ( is => 'ro', lazy => 1, builder => '_build_marketplaces' );

sub BUILD {
    my ($self) = @_;
    $self->ua->default_header(
        accept => 'application/vnd.api+json;revision=1.1');
}

around get_card => _unpack_response('cards');

around create_card => _unpack_response('cards');

method add_card(HashRef $card, HashRef :$customer!) {
    my $card_href = $card->{href} or croak 'The card href is missing';
    my $cust_href = $customer->{href} or croak 'The customer href is missing';
    return $self->put($card->{href}, { customer => $cust_href })->{cards}[0];
}

around get_customer => _unpack_response('customers');

around create_customer => _unpack_response('customers');

method update_customer(HashRef $customer) {
    my $cust_href = $customer->{href} or croak 'The customer href is missing';
    return $self->put($cust_href, $customer)->{customers}[0];
}

method get_hold(Str $id) {
    my $res = $self->get($self->_uri('card_holds', $id));
    return $res ? $res->{card_holds}[0] : undef;
}

method create_hold(HashRef $hold, HashRef :$card!) {
    croak 'The hold amount is missing' unless $hold->{amount};
    my $card_href = $card->{href} or croak 'The card href is missing';
    return $self->post("$card_href/card_holds", $hold)->{card_holds}[0];
}

method capture_hold(HashRef $hold, HashRef :$debit={}) {
    my $hold_href = $hold->{href} or croak 'The hold href is missing';
    return $self->post("$hold_href/debits", $debit)->{debits}[0];
}

method void_hold(HashRef $hold) {
    my $hold_href = $hold->{href} or croak 'The hold href is missing';
    return $self->put($hold_href, { is_void => 'true' })->{card_holds}[0];
}

method create_debit(HashRef $debit, HashRef :$card!) {
    croak 'The debit amount is missing' unless $debit->{amount};
    my $card_href = $card->{href} or croak 'The card href is missing';
    return $self->post("$card_href/debits", $debit)->{debits}[0];
}

around get_debit => _unpack_response('debits');

method refund_debit(HashRef $debit) {
    my $debit_href = $debit->{href} or croak 'The debit href is missing';
    return $self->post("$debit_href/refunds", $debit)->{refunds}[0];
}

around get_bank_account => _unpack_response('bank_accounts');

around create_bank_account => _unpack_response('bank_accounts');

method add_bank_account(HashRef $bank, HashRef :$customer!) {
    my $bank_href = $bank->{href} or croak 'The bank href is missing';
    my $cust_href = $customer->{href} or croak 'The customer href is missing';
    my $res = $self->put($bank->{href}, { customer => $cust_href });
    return $res->{bank_accounts}[0];
}

method create_credit(HashRef $credit, HashRef :$bank_account, HashRef :$card) {
    croak 'The credit amount is missing' unless $credit->{amount};
    if ($bank_account) {
        my $bank_href = $bank_account->{href}
            or croak 'The bank_account href is missing';
        return $self->post("$bank_href/credits", $credit)->{credits}[0];
    } elsif ($card) {
        my $card_href = $card->{href} or croak 'The card href is missing';
        return $self->post("$card_href/credits", $credit)->{credits}[0];
    } else {
        croak 'A bank or card param is required';
    }
}

around get_credit => _unpack_response('credits');

method update_bank_account(HashRef $bank) {
    my $bank_href = $bank->{href} or croak 'The bank_account href is missing';
    return $self->put($bank_href, $bank)->{bank_accounts}[0];
}

method create_bank_verification(HashRef :$bank_account!) {
    my $bank_href = $bank_account->{href}
        or croak 'The bank_account href is missing';
    return $self->post("$bank_href/verifications", {})
        ->{bank_account_verifications}[0];
}

method get_bank_verification(Str $id) {
    my $res = $self->get("/verifications/$id");
    return $res ? $res->{bank_account_verifications}[0] : undef;
}

method confirm_bank_verification(HashRef $verification, Int :$amount_1!, Int :$amount_2!) {
    my $ver_href = $verification->{href}
        or croak 'The verification href is missing';
    return $self->put($ver_href, {amount_1 => $amount_1, amount_2 => $amount_2})
        ->{bank_account_verifications}[0];
}

method create_check_recipient(HashRef $rec) {
    croak 'The recipient name is missing' unless defined $rec->{name};
    croak 'The recipient address line1 is missing'
        unless $rec->{address}{line1};
    croak 'The recipient address postal_code is missing'
        unless $rec->{address}{postal_code};
    my $res = $self->post('/check_recipients', $rec);
    return $res->{check_recipients}[0];
}

method get_dispute(Str $id) {
    my $res = $self->get($self->_uri('disputes', $id));
    return $res ? $res->{disputes}[0] : undef;
}

method get_disputes(HashRef $query = {}) {
    return $self->get($self->_uri('disputes'), $query);
}

method create_check_recipient_credit(HashRef $credit, HashRef :$check_recipient!) {
    my $rec_id = $check_recipient->{id}
        or croak 'The check_recipient hashref needs an id';
    croak 'The credit must contain an amount' unless $credit->{amount};
    my $res = $self->post("/check_recipients/$rec_id/credits", $credit);
    return $res->{credits}[0];
}

method get_all(HashRef $data) {
    my ($key) = grep !/^(links|meta)$/, keys %$data;
    croak "Could not find the top level resource" unless $key;
    my $result = $data->{$key};
    while ( my $next = $data->{meta}{next} ) {
        $data = $self->get($next);
        push @$result, @{ $data->{$key} };
    }
    return $result;
}

method _build_marketplaces { $self->get($self->marketplaces_uri) }

method _build_marketplace { $self->marketplaces->{marketplaces}[0] }

method _build_uris {
    my $links = $self->marketplaces->{links};
    return { map { (split /^marketplaces./)[1] => $links->{$_} } keys %$links };
}

sub _unpack_response {
    my ($name) = @_;
    return sub {
        my ($orig, $self, @args) = @_;
        my $res = $self->$orig(@args);
        return $res->{$name}[0] if $res;
        return $res;
    }
};

1;
