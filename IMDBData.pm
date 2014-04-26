package IMDBData;

use strict;
use warnings;

use base qw(WWW::Mechanize);

use JSON qw(decode_json);

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

  my $data = decode_json($self->content);
  return if ($data->{Error});

  $movie->set_imdb_rating($data->{imdbRating});
  $movie->set_imdb_id($data->{imdbID});
}

1;

