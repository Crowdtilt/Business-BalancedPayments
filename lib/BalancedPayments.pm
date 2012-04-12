package BalancedPayments;

use Modern::Perl;
use Moose;
use namespace::autoclean;
use LWP::UserAgent;
use HTTP::Request;
use JSON qw(from_json);
use Data::Dumper;

use BalancedPayments::APIKey;
use BalancedPayments::Common;
use balancedpayments::Merchant;

# ABSTRACT: BalancedPayments Perl Module

has base_uri => (is => 'rw', default => 'https://api.balancedpayments.com');
has api_version => (is => 'rw', default => 'v1');
has common => (
    is => 'ro',
    lazy => 1,
    default => sub {
        my ($self) = @_;
        return BalancedPayments::Common->new({
            base_uri    => $self->base_url,
            api_version => $self->api_version
        });
    }
);
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
has key => ( is => 'rw', lazy => 1, default => sub {} );
has merchant => (is => 'rw', lazy => 1, default => sub {} );

sub BUILD {
    my ($self, $args) = @_;

    if ($args->{secret}) {
        $self->_configure_processor($args->{secret});
        return 1;
    } else {
        return $self->_create_api_key;
    }
}

sub _configure_processor{
    my ($self, $secret) = @_;
    $self->_get_api_key_details($secret);
    $self->_get_merchant_details($secret);
}

sub _get_merchant_details{
    my ($self, $secret) = @_;

    my $req = HTTP::Request->new;
    $req->method("GET");
    $req->uri($self->base_uri . '/' . $self->api_version . '/merchants');
    $req->authorization_basic($secret, '');
    my $response = $self->ua->request($req);

    if ($response->is_success){
        my $content = from_json($response->content);
        if ($content->{total} == 1){
            $self->merchant(
                BalancedPayments::Merchant->new($content->{items}[0]));
        } else {
            #TODO: Handle multiple keys. I am not sure that this case actually
            #exists. BalancedPayments documentation is not explicit about it
            #yet.
        }
    } else {
        #TODO: We need better error messages.
        confess $response->content;
        return 0;
    }
}


sub _get_api_key_details{
    my ($self, $secret) = @_;

    my $req = HTTP::Request->new;
    $req->method("GET");
    $req->uri($self->base_uri . '/' . $self->api_version . '/api_keys');
    $req->authorization_basic($secret, '');
    my $response = $self->ua->request($req);

    if ($response->is_success){
        my $content = from_json($response->content);
        if ($content->{total} == 1){
            $content->{items}[0]->{secret} = $secret;
            $self->key(BalancedPayments::APIKey->new($content->{items}[0]));
        } else {
            #TODO: Handle multiple keys. I am not sure that this case actually
            #exists. BalancedPayments documentation is not explicit about it
            #yet.
        }
    } else {
        #TODO: We need better error messages.
        confess $response->content;
        return 0;
    }
}

sub _create_api_key {
    my ($self) = @_;
    my $url = $self->base_uri . '/' . $self->api_version . '/api_keys';
    my $response = $self->ua->post($url);
    if ($response->is_success){
        #Prepare the data from the response.
        my $key_data = from_json($response->content);
        $key_data->{meta_data} = $key_data->{meta};
        delete $key_data->{meta};

        my $merchant_data = $key_data->{merchant};
        delete $key_data->{merchant};
        $merchant_data->{meta_data} = $merchant_data->{meta};
        delete $merchant_data->{meta};

        # Create and return the approperiate objects.
        $self->key(BalancedPayments::APIKey->new($key_data));
        #TODO: Accept merchant parameters when creating a new key.
        $self->merchant(BalancedPayments::Merchant->new($merchant_data));
        return 1;
    } else {
        #TODO: We need better error messages.
        confess $response->message;
        return 0;
    }
}

__PACKAGE__->meta->make_immutable;
return 1;

__END__

