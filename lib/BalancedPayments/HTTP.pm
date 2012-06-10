package BalancedPayments::HTTP;
use Moo::Role;

use HTTP::Request::Common qw(GET POST PUT);
use JSON qw(from_json to_json);
use LWP::UserAgent;

has base_url => (
    is      => 'ro',
    default => sub { 'https://api.balancedpayments.com' }
);
has ua => (
    is      => 'ro',
    lazy    => 1,
    default => sub {
        my $ua = LWP::UserAgent->new();
        $ua->timeout(10);
        return $ua;
    },
);

sub get {
    my ($self, $path) = @_;
    return $self->_req(GET $path);
}

sub post {
    my ($self, $path, $params) = @_;
    return $self->_req(POST $path, content => to_json $params);
}

sub put {
    my ($self, $path, $params) = @_;
    return $self->_req(PUT $path, content => to_json $params);
}

# Prefix the path param of the http methods with the base_url
around qw(get post put) => sub {
    my $orig = shift;
    my $self = shift;
    my $path = shift;
    die 'Path is missing' unless $path;
    my $url = $self->_url($path);
    return $self->$orig($url, @_);
};

sub _req {
    my ($self, $req) = @_;
    $req->authorization_basic($self->secret);
    $req->header(content_type => 'application/json');
    my $res = $self->ua->request($req);
    _check_res($res);
    return $res->content ? from_json($res->content) : 1;
}

sub _url {
    my ($self, $path) = @_;
    return $path =~ /^http/ ? $path : $self->base_url . $path;
}

sub _check_res {
    my ($res) = @_;
    my ($url, $method) = ($res->request->uri, $res->request->method);
    die sprintf "Error attempting %s => %s:\n%s\n%s",
        $method, $url, $res->status_line, $res->content
        unless $res->is_success;
}

1;
