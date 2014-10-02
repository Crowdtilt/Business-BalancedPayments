package Business::BalancedPayments;

# VERSION

use Business::BalancedPayments::V10;
use Business::BalancedPayments::V11;
use Carp qw(croak);

sub client {
    my ($class, %args) = @_;
    $args{version} ||= 1.1;
    croak "only versions 1.0 and 1.1 are supported"
        unless $args{version} == 1 or $args{version} == 1.1;
    return $args{version} == 1
        ? Business::BalancedPayments::V10->new(%args)
        : Business::BalancedPayments::V11->new(%args);
}

# ABSTRACT: Balanced Payments API bindings

=head1 SYNOPSIS

    use Business::BalancedPayments;

    my $bp = Business::BalancedPayments->client(secret => 'abc123');

    my $customer = $bp->create_customer;

    my $card = $bp->create_card({
        card_number      => '5105105105105100',
        expiration_month => 12,
        expiration_year  => 2020,
        security_code    => 123,
    });

    $bp->add_card($card, customer => $customer);

=head1 DESCRIPTION

This module provides bindings for the
L<Balanced|https://www.balancedpayments.com> API.

=head1 METHODS

This module provides a single method L</create> that will return a version
specific client.

See L<Business::BalancedPayments::V10> for the v1.0 methods.

See L<Business::BalancedPayments::V11> for the v1.1 methods.

=head2 create

    my $bp = Business::BalancedPayments->client(
        secret  => $secret,
        version => 1.1,     # optional, defaults to 1.1
        logger  => $logger, # optional
        retries => 3,       # optional
    );

Returns a new Balanced client object.
Parameters:

=over 4

=item secret

Required. The Balanced Payments secret key for your account.

=item version

Optional. Defaults to C<'1.1'>.
The only supported versions currently are C<'1.0'> and C<'1.1'>.
Note that version C<'1.0'> was officially deprecated March 2014. 

=back

See L<WebService::Client> for other supported parameters such as C<logger>,
C<retries>, and C<timeout>.

=cut

1;
