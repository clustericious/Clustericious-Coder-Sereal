use strict;
use warnings;
use 5.010001;
use Test::More;
use Sereal qw( decode_sereal );

BEGIN {

  plan skip_all => 'Test requires HTTP::Tiny, Test::Clustericious::Blocking, URI '
    unless eval q{ use HTTP::Tiny; use Test::Clustericious::Blocking; use URI; 1 }
}

use Test::Clustericious::Cluster;

plan tests => 2;

my $mytest = {
  foo => 1,
  bar => [qw( once more )],
  baz => {
    a => 1,
  }
};

my $cluster = Test::Clustericious::Cluster->new;
$cluster->create_cluster_ok('MyApp');
my $url = $cluster->urls->[0];

my $response = blocking {
  my $http = HTTP::Tiny->new;
  $url = URI->new($url);
  $url->path('/mytest.srl');
  $http->get("$url");
};

use YAML::XS ();
note YAML::XS::Dump($response);

is_deeply decode_sereal($response->{content}), $mytest, 'structure good';

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

1;
