use strict;
use warnings;
use Test::More tests => 4;
use Test::Clustericious::Cluster;
use Sereal::Encoder qw( encode_sereal );
use Sereal::Decoder qw( decode_sereal );

my $cluster = Test::Clustericious::Cluster->new;
$cluster->create_cluster_ok('MyApp');
my $t = $cluster->t;

my $mytest = {
  foo => 1,
  bar => [qw( once more )],
  baz => {
    a => 1,
  }
};

subtest 'get with extension' => sub {
  $t->get_ok('/mytest.srl')
    ->status_is(200)
    ->header_is('Content-Type' => 'application/sereal');
  is_deeply(decode_sereal($t->tx->res->body), $mytest, 'structure is good');
};

subtest 'get with accept' => sub {
  $t->get_ok('/mytest', { Accept => 'application/sereal' })
    ->status_is(200)
    ->header_is('Content-Type' => 'application/sereal');
  is_deeply(decode_sereal($t->tx->res->body), $mytest, 'structure is good');
};

subtest 'post' => sub {
  $t->post_ok('/mytest', { 'Content-Type' => 'application/sereal', Accept => 'application/json' }, encode_sereal({a => 1, b => 2}))
    ->status_is(200)
    ->json_is('/answer', 3);
  note $t->tx->res->to_string;
};

__DATA__

@@ lib/MyApp.pm
package MyApp;

use strict;
use warnings;
use base qw( Clustericious::App );
use Clustericious::RouteBuilder;

get '/mytest' => sub {
  shift->stash->{autodata} = 
  {
    foo => 1,
    bar => [qw( once more )],
    baz => {
      a => 1,
    }
  };
};

post '/mytest' => sub {
  my($c) = @_;
  my $data = $c->parse_autodata;
  $c->stash->{autodata} = { answer => $data->{a} + $data->{b} };
};

1;
