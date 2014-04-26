package IMDBData;

use strict;
use warnings;

use base qw(WWW::Mechanize);

use JSON;
use Encode;

sub new {
  my ($class, %args) = @_;

  my $self = $class->SUPER::new(%args);
}

sub add_imdb_data {
  my ($self, $movie) = @_;
  my $title = $movie->title;
  my $year = $movie->year;

  die "Must provide title and year" unless ($title && $year);

  my $url = "http://www.omdbapi.com/?t=$title&y=$year";
  $self->get($url);

  my $data_bytes = encode('UTF-8', $self->content);
  my $data = JSON->new->utf8->decode($data_bytes);

  return if ($data->{Error});

  $movie->set_imdb_rating($data->{imdbRating});
  $movie->set_imdb_id($data->{imdbID});
  $movie->set_plot($data->{Plot});
  $movie->set_genre($data->{Genre});
}

1;

