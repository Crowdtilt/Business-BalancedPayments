package BalancedPayments::Merchant;

use Modern::Perl;
use Moose;

#  "uri": "/v1/merchants/TEST-MR222-964-0818",
has uri => (is => 'rw');
#  "created_at": "2012-03-26T18:05:52.390381Z",
has created_at => (is => 'rw');
#  "type": "person",
has type => (is => 'rw');
#  "name": "William Henry Cavendish III",
has name => (is => 'rw');
#  "email_address": "whc@example.org",
has email_address => (is => 'rw');
#  "balance": 0,
has balance => (is => 'rw');
#  "street_address": "123 Fake St",
has street_address => (is => 'rw');
#  "postal_code": "90210",
has postal_code => (is => 'rw');
#  "country_code": "USA",
has country_code => (is => 'rw');
#  "phone_number": "+16505551212",
has phone_number => (is => 'rw');
#  "marketplace": null,
has marketplace => (is => 'rw');
#  "api_keys_uri": "/v1/merchants/TEST-MR222-964-0818/api_keys"
has api_keys_uri => (is => 'rw');
#  "accounts_uri": "/v1/merchants/TEST-MR222-964-0818/accounts",
has accounts_uri => (is => 'rw');
#  "meta": {},
has meta_data => (is => 'rw');



return 1;
