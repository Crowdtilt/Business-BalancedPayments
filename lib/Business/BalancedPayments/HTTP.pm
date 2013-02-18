package Business::BalancedPayments::HTTP;
use Moose::Role;

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
has retries => (is => 'ro', default => 0);

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
    $self->_log_request($req);
    my $res = $self->ua->request($req);
    $self->_log_response($res);
    my $retries = $self->retries;
    while ($res->code =~ /^5/ and $retries--) {
        sleep 1;
        $res = $self->ua->request($req);
        $self->_log_response($res);
    }
    return undef if $res->code =~ /404|410/;
    die $res unless $res->is_success;
    return $res->content ? from_json($res->content) : 1;
}

sub _url {
    my ($self, $path) = @_;
    return $path =~ /^http/ ? $path : $self->base_url . $path;
}

sub _log_request {
    my ($self, $req) = @_;
    $self->log($req->method . ' => ' . $req->uri);
    my $content = $req->content;
    return unless length $content;
    eval { $content = to_json from_json $content };
    $self->log($content);
}

sub _log_response {
    my ($self, $res) = @_;
    $self->log($res->status_line);
    my $content = $res->content;
    eval { $content = to_json from_json $content };
    $self->log($content);
}

1;
