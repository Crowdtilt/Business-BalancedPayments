package BalancedPayments::APIKey;

use Modern::Perl;
use Moose;

# ABSTRACT: API Key for BalancedPayments APIs.

#"uri": "/v1/api_keys/AK205-426-6793"
has uri => (is => 'rw');
#"created_at": "2012-03-26T18:05:52.389153Z",
has created_at => (is => 'rw');
#"secret": "5334a8d4776e11e19b55024f5cb9b783",
has secret => (is => 'rw');
#"meta": {},
has meta_data => (is => 'rw');


return 1;

