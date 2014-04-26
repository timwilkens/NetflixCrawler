package NetflixExtractor;

use strict;
use warnings;

use Movie;

sub new {
  my $class = shift;
  bless {}, $class;
}

sub make_movie {
  my ($self, %args) = @_;
  my $link = $args{link};
  my $content = $args{content};

  my ($netflix_id) = $link =~ /WiMovie\/(\d+)/;
  my $movie = Movie->new(netflix_id => $netflix_id,
                         url        => $link
                        );

  my $title = _extract_title($content);
  return unless $title;
  $movie->set_title($title);

  my $year = _extract_year($content);
  return unless $year;
  $movie->set_year($year);

  my $rating = _extract_rating($content);
  $movie->set_netflix_rating($rating);

  return $movie;
}

sub _extract_title {
  my $content = shift;

  my $title;
  if ($content =~ /<h1\s*class="title"\s*>\s*(.*?)\s*<\/h1>/s) {
    $title = $1;
    $title =~ s/\\//;
  } else {
    die "$content";
  }
  return $title;
}

sub _extract_year {
  my $content = shift;

  my $year;
  if ($content =~ /<\/h1>\s*(?:<span\s+class="origTitle">.*?<\/span>)?\s*<\/div>\s*<span\s+class="year"\s*>\s*(\d{4})/s) {
    $year = $1;
  } else {
    die "$content - YEAR\n";
  }
  return $year;
}

sub _extract_rating {
  my $content = shift;

  my $rating;
  if ($content =~ /<div\s+class="starbar\s+starbar-avg\s+stbrWrapStc\s+clearfix">\s*(.*?)\s*<\/div>/s) {
    $content = $1;
    if ($content =~ /<\/p>\s*<meta\s+content="\d+"\s*\/>\s*<span\s+class="rating"\s*>\s*(\d+\.?\d*)\s+stars/s) {
      $rating = $1;
    }
  }
  return $rating;
}

1;

