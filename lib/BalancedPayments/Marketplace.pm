package BalancedPayments::Marketplace;

use Modern::Perl;
use Moose;

# ABSTRACT: BalancedPayments Perl Module

#"uri": "/v1/marketplaces/TEST-MP583-712-2756",
has uri => (is => 'rw', required => 1);
#"name": "Test Marketplace",
has name => (is => 'rw');
#"domain_url": "example.com",
has domain_url => (is => 'rw');
#"support_email_address": "support@example.com",
has support_email_address => (is => 'rw');
# "escrow_balance": 0,
has escrow_balance => (is => 'rw');
#"support_phone_number": "+16505551234",
has support_phone_number => (is => 'rw');
#"accountunts_uri": "/v1/marketplaces/TEST-MP583-712-2756/accounts",
has accountunts_uri => (is => 'rw');
#"authorizations_uri": "/v1/marketplaces/TEST-MP583-712-2756/authorizations",
has authorizations_uri => (is => 'rw');
#"debits_uri": "/v1/marketplaces/TEST-MP583-712-2756/debits",
has debits_uri => (is => 'rw');
#"refunds_uri": "/v1/marketplaces/TEST-MP583-712-2756/refunds",
has refunds_uri => (is => 'rw');
#"credits_uri": "/v1/marketplaces/TEST-MP583-712-2756/credits",
has credits_uri => (is => 'rw');
# "meta": {},
has meta_data => (is => 'rw');
# "owner_account":
has owner_account => (is => 'rw');


return 1;
