package RTData;

use strict;
use warnings;

use base qw(WWW::Mechanize);

my $TOMATO_BASE = 'http://www.rottentomatoes.com/m/';

sub new {
  my ($class, %args) = @_;

  my $self = $class->SUPER::new(%args);
}

sub add_tomato_rating {
  my ($self, $movie) = @_;
  my $title = $movie->title;
  my $year = $movie->year;

  die "Must provide title and year" unless ($title && $year);

  my $url_title = $title;
  $url_title =~ s/[-:]/ /g;
  $url_title =~ s/\s+/_/g;
  my $url = $TOMATO_BASE . $url_title . "/";

  $self->get($url);
  return unless ($self->status == 200);

  my $content = $self->content;

  if ($content =~ /<h1\s+class="movie_title">\s*(.*?)\s*<\/h1>/) {
    my $title_string = $1;
    if ($title_string =~ /<span\s+itemprop="name">.*?\((\d{4})\)\s*</) {
      return unless ($year == $1); # Try to check that we have the right movie.
    }
  }

  if ($content =~ /<span\s+itemprop="ratingValue"\s+id="all-critics-meter"\s*class="meter\s+\w+\s+numeric\s+">\s*(\d+)\s*<\/span>/) {
    $movie->set_rt_rating($1);
  }
}

1;

