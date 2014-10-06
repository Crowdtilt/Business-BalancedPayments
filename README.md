# NAME

Business::BalancedPayments - Balanced Payments API bindings

# VERSION

version 1.0000

# SYNOPSIS

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

# DESCRIPTION

This module provides bindings for the
[Balanced](https://www.balancedpayments.com) API.

# METHODS

This module provides a single method ["create"](#create) that will return a version
specific client.

See [Business::BalancedPayments::V10](http://search.cpan.org/perldoc?Business::BalancedPayments::V10) for the v1.0 methods.

See [Business::BalancedPayments::V11](http://search.cpan.org/perldoc?Business::BalancedPayments::V11) for the v1.1 methods.

## create

    my $bp = Business::BalancedPayments->client(
        secret  => $secret,
        version => 1.1,     # optional, defaults to 1.1
        logger  => $logger, # optional
        retries => 3,       # optional
    );

Returns a new Balanced client object.
Parameters:

- secret

    Required. The Balanced Payments secret key for your account.

- version

    Optional. Defaults to `'1.1'`.
    The only supported versions currently are `'1.0'` and `'1.1'`.
    Note that version `'1.0'` was officially deprecated March 2014. 

See [WebService::Client](http://search.cpan.org/perldoc?WebService::Client) for other supported parameters such as `logger`,
`retries`, and `timeout`.

# AUTHORS

- Khaled Hussein <khaled@tilt.com>
- Naveed Massjouni <naveed@tilt.com>
- Al Newkirk <al@tilt.com>
- Will Wolf <will@tilt.com>

# COPYRIGHT AND LICENSE

This software is copyright (c) 2012 by Crowdtilt, Inc..

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.
