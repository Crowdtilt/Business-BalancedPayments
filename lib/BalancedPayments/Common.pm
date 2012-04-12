package BalancedPayments::Common;

use Modern::Perl;
use Moose;
use LWP::UserAgent;
use HTTP::Request;

has base_uri => (is => 'rw', required => 1);
has api_version => (is => 'rw', default => 'v1');
has ua => (
    is => 'ro',
    lazy => 1,
    default => sub {
        my $ua = LWP::UserAgent->new;
        $ua->default_header(content_type => 'application/json');
        $ua->timeout(5);
        return $ua;
    },
);

sub make_request {
    my ($self, $method, $path, $headers, $content) = @_;
    my $ua = $self->ua;
    my $req_url = $self->base_uri . $self->api_version . $path;

    my $req = HTTP::Request->new($method => $req_url, $headers, $content);
    #TODO: Fix the authorization below to use an API key.
    $req->authorization_basic($self->developer_sid, $self->auth_token);
    my $res = $ua->request($req);

    my $result = from_json($res->content);
    if($res->is_success) {
        $result->{success} = $res->is_success;
    }
    return $result;
}

return 1;
