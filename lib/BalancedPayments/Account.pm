package BalancedPayments::Account;

use Modern::Perl;
use Moose;

#"uri": "/v1/marketplaces/TEST-MP583-712-2756/accounts/AC769-541-1361",
has uri => (is => 'rw');
#"created_at": "2012-03-26T18:44:16.530331Z",
has created_at => (is => 'rw');
#"name": null,
has name => (is => 'rw');
#"email_address": "support@example.com",
has email_address => (is => 'rw');
#"authorizations_uri": "/v1/marketplaces/TEST-MP583-712-2756/accounts/AC769-541-1361/authorizations",
has authorizations_uri => (is => 'rw');
#"debits_uri": "/v1/marketplaces/TEST-MP583-712-2756/accounts/AC769-541-1361/debits",
has debits_uri => (is => 'rw');
#"refunds_uri": "/v1/marketplaces/TEST-MP583-712-2756/accounts/AC769-541-1361/refunds",
has refunds_uri => (is => 'rw');
#"credits_uri": "/v1/marketplaces/TEST-MP583-712-2756/accounts/AC769-541-1361/credits",
has credits_uri => (is => 'rw');
#"roles": ["merchant"],
has roles => (is => 'rw');
#"meta": {}
has meta_data => (is => 'rw');

return 1;
