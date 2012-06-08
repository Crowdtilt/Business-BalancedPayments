package BalancedPayments::HTTP;
use Moo::Role;

use HTTP::Request::Common qw(GET POST PUT);
use JSON qw(from_json to_json);
use LWP::UserAgent;

requires 'base_url';

has ua => (
    is => 'ro',
    lazy => 1,
    default => sub {
        my $ua = LWP::UserAgent->new;
        $ua->timeout(10);
        return $ua;
    },
);

sub _url { $_[0]->base_url . $_[1] }

sub _build_merchant {
    my ($self) = @_;
    my $data = $self->_get($self->merchants_uri);
    return $data->{items}[0];
}

sub _build_marketplace {
    my ($self) = @_;
    my $data = $self->_get($self->marketplaces_uri);
    return $data->{items}[0];
}

sub _get {
    my ($self, $path) = @_;
    return $self->_req(GET $path);
}

sub _post {
    my ($self, $path, $params) = @_;
    return $self->_req(POST $path, content => to_json $params);
}

sub _put {
    my ($self, $path, $params) = @_;
    return $self->_req(PUT $path, content => to_json $params);
}

sub _req {
    my ($self, $req) = @_;
    $req->authorization_basic($self->secret);
    $req->header(content_type => 'application/json');
    return $self->ua->request($req);
}

sub _check_res {
    my ($res) = @_;
    my ($url, $method) = ($res->request->uri, $res->request->method);
    die sprintf "Error attempting %s => %s:\n%s\n%s",
        $method, $url, $res->status_line, $res->content
        unless $res->is_success;
}

around qw(_get _post _put) => sub {
    my $orig = shift;
    my $self = shift;
    my $path = shift;
    my $url = $self->_url($path);
    my $res = $self->$orig($url, @_);
    _check_res($res);
    return $res->content ? from_json($res->content) : 1;
};

1;
