package Business::BalancedPayments::V10;
use Moo;
with 'Business::BalancedPayments::Base';

use Carp qw(croak);

has marketplaces_uri => ( is => 'ro', default => '/v1/marketplaces' );

sub get_account {
    my ($self, $id) = @_;
    croak 'The id param is missing' unless defined $id;
    return $self->get($self->_uri('accounts', $id));
}

sub get_account_by_email {
    my ($self, $email) = @_;
    croak 'The email param is missing' unless $email;
    return $self->get($self->_uri->('accounts') . "?email_address=$email");
}

sub create_account {
    my ($self, $account, %args) = @_;
    my $card = $args{card};
    $account ||= {};
    croak 'The account param must be a hashref' unless ref $account eq 'HASH';

    if ($card) {
        croak 'The card param must be a hashref' unless ref $card eq 'HASH';
        croak 'The card is missing a uri' unless $card->{uri};
        $account->{card_uri} = $card->{uri};
    }
    return $self->post($self->_uri('accounts'), $account);
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

sub update_account {
    my ($self, $account) = @_;
    croak 'The account param must be a hashref' unless ref $account eq 'HASH';
    croak 'The account must have an id or uri field'
        unless $account->{uri} || $account->{id};
    my $acc_uri = $account->{uri} || $self->_uri('accounts', $account->{id});
    return $self->put($acc_uri, $account);
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
    if ($card) {
        croak 'The card param must be a hashref' unless ref $card eq 'HASH';
        $holds_uri = $card->{account}{holds_uri};
    } elsif ($account) {
        croak 'The account must be a hashref' unless ref $account eq 'HASH';
        $holds_uri = $account->{holds_uri};
    }
    die 'Could not find a holds_uri' unless $holds_uri;
    $hold->{source_uri} ||= $card->{uri} if $card and $card->{uri};
    return $self->post($holds_uri, $hold);
}

sub capture_hold {
    my ($self, $hold, $params) = @_;
    croak 'The hold param is missing' unless $hold;
    croak 'The optional extra params must be a hashref'
        if $params and ref $params ne 'HASH';
    my $hold_uri = ref $hold eq 'HASH' ? $hold->{uri} : $hold;
    my $data = { hold_uri => $hold_uri, %$params };
    return $self->post($self->_uri('debits'), $data);
}

sub get_debit {
    my ($self, $id) = @_;
    croak 'The id param is missing' unless defined $id;
    return $self->get($self->_uri('debits', $id));
}

sub create_debit {
    my ($self, $debit, %args) = @_;
    croak 'The debit param must be a hashref' unless ref $debit eq 'HASH';
    croak 'No amount found' unless $debit->{amount};
    my $card = $args{card};
    my $account = $args{account};
    croak 'An account or card must be provided' unless $account or $card;
    my $debits_uri;
    if ($card) {
        croak 'The card param must be a hashref' unless ref $card eq 'HASH';
        $debits_uri = $card->{account}{debits_uri};
    } elsif ($account) {
        croak 'The account must be a hashref' unless ref $account eq 'HASH';
        $debits_uri = $account->{debits_uri};
    }
    die 'Could not find a debits_uri' unless $debits_uri;
    $debit->{source_uri} ||= $card->{uri} if $card and $card->{uri};
    return $self->post($debits_uri, $debit);
}

sub get_hold {
    my ($self, $id) = @_;
    croak 'The id param is missing' unless defined $id;
    return $self->get($self->_uri('holds', $id));
}

sub get_refund {
    my ($self, $id) = @_;
    croak 'The id param is missing' unless defined $id;
    return $self->get($self->_uri('refunds', $id));
}

sub get_refunds {
    my ($self, $debit) = @_;
    croak 'The debit param is missing' unless defined $debit;
    return $self->get($debit->{refunds_uri});
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
    return $self->post($self->_uri('refunds'), $debit);
}

sub get_bank_account {
    my ($self, $id) = @_;
    croak 'The id param is missing' unless defined $id;
    return $self->get($self->_uri('bank_accounts', $id));
}

sub confirm_bank_verification {
    my ($self, $id, %args) = @_;
    my $verification_id = $args{verification_id};
    croak 'The id param is missing' unless defined $id;
    croak 'The verification_id param is missing' unless defined $verification_id;
    my $uri = join '/',
        $self->_uri('bank_accounts', $id), 'verifications', $verification_id;
    my $amount_1 = $args{amount_1} or croak 'The amount_1 param is missing';
    my $amount_2 = $args{amount_2} or croak 'The amount_2 param is missing';
    return $self->put($uri => {amount_1 => $amount_1, amount_2 => $amount_2});
}

sub create_bank_account {
    my ($self, $bank) = @_;
    croak 'The bank account must be a hashref' unless ref $bank eq 'HASH';
    return $self->post($self->_uri('bank_accounts'), $bank);
}

sub create_bank_verification {
    my ($self, $id) = @_;
    croak 'The id param is missing' unless defined $id;
    my $uri = $self->_uri('bank_accounts', $id) . '/verifications';
    return $self->post($uri => {});
}

sub update_bank_account {
    my ($self, $bank) = @_;
    croak 'The bank account must be a hashref' unless ref $bank eq 'HASH';
    croak 'The bank account must have an id or uri field'
        unless $bank->{uri} || $bank->{id};
    my $bank_uri = $bank->{uri} || $self->_uri('bank_accounts', $bank->{id});
    return $self->put($bank_uri, $bank);
}

sub invalidate_bank_account {
    my ($self, $bank_id) = @_;
    croak 'A bank id is required' unless defined $bank_id;
    return $self->update_bank_account({ id => $bank_id, is_valid => 0 });
}

sub get_credit {
    my ($self, $id) = @_;
    croak 'The id param is missing' unless defined $id;
    return $self->get($self->_uri('credits', $id));
}

sub create_credit {
    my ($self, $credit, %args) = @_;
    my $account = $args{account};
    my $bank_account = $args{bank_account};
    croak 'The credit param must be a hashref' unless ref $credit eq 'HASH';
    croak 'The credit must contain an amount' unless exists $credit->{amount};
    croak 'An account or bank_account param is required'
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
        croak 'The bank_account is a uri' unless $bank_account->{uri};
        croak 'The bank_account is missing an credits_uri'
            unless $bank_account->{account}{credits_uri};
        $credits_uri = $bank_account->{account}{credits_uri};
        $credit->{bank_account_uri} = $bank_account->{uri};
    }
    croak 'No credits_uri found' unless $credits_uri;
    return $self->post($credits_uri, $credit);
}

sub get_transactions {
    my ($self) = @_;
    return $self->get($self->_uri('transactions'));
}

sub _build_marketplace {
    my ($self) = @_;
    my $data = $self->get($self->marketplaces_uri);
    return $data->{items}[0];
}

sub _build_uris {
    my ($self) = @_;
    return {
        map { (split /_uri$/)[0] => $self->marketplace->{$_} }
            grep { /_uri$/ } keys %{ $self->marketplace }
    };
}

1;
