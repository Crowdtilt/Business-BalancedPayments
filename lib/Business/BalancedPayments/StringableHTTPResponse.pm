package Business::BalancedPayments::StringableHTTPResponse;
use Moo::Role;
# VERSION
use overload '""' => sub { $_[0]->status_line . "\n" . $_[0]->content };
1;
