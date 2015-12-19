package Clustericious::Coder::Sereal;

use strict;
use warnings;
use Sereal::Encoder qw( sereal_encode_with_object );
use Sereal::Decoder qw( sereal_decode_with_object );
use 5.010001;

# ABSTRACT: Sereal encoder for AutodataHandler
# VERSION

=head1 SYNOPSIS

 % cpanm Clustericious::Coder::Sereal

=head1 DESCRIPTION

Simply install this module and any L<Clustericious> 1.12 applications
will automatically handle L<Sereal> encoded requests and responses.

=head1 SEE ALSO

L<Clustericious>

=cut

sub coder
{
  my $encoder = Sereal::Encoder->new;
  my $decoder = Sereal::Decoder->new;

  my %coder = (
    type   => 'application/sereal',
    format => 'srl',
    encode => sub { sereal_encode_with_object($encoder, $_[0]) },
    decode => sub { sereal_decode_with_object($decoder, $_[0]) },
  );
  
  \%coder;
}

1;
