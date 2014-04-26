package NetflixCrawler;

use strict;
use warnings;

use base qw(WWW::Mechanize);

sub new {
  my ($class, %args) = @_;

  my $self = $class->SUPER::new(%args);
}

sub login {
  my ($self, %args) = @_;

  die "Must pass email and password\n" unless ($args{email} && $args{password});

  # Get enter password page.
  $self->get('https://www.netflix.com/Login?locale=en-US');

  # Submit our form.
  $self->form_id('login-form');
  $self->field (email => $args{email});
  $self->field (password => $args{password});
  $self->click;

  # Go to the homepage.
  $self->get('http://www.netflix.com/WiHome');
}

my %GENRE_IDS = (action   => 1365,
                 comedy   => 6548,
                 thriller => 8933,
                );

sub get_movie_links_by_genre {
  my ($self, $genre) = @_;

  die "Must provide genre 'action', 'comedy', or 'thriller'" unless ($genre && $GENRE_IDS{$genre});

  my $url = 'http://www.netflix.com/WiGenre?agid=' . $GENRE_IDS{$genre} . '&orderBy=rt';
  $self->get($url);

  my @movie_links = $self->find_all_links(tag       => 'a',
                                          url_regex => qr/WiPlayer\?movieid=/
                                         );

  my @links;

  # Go from play link to info link.
  for my $link (@movie_links) {
    $link = $link->url_abs;
    $link =~ s/&trkid=\d+$//;
    $link =~ s/Player\?movieid=/Movie\//;
    push @links, $link;
  }
  @links;
}

sub make_movie {
  my ($self, $link) = @_;
  $self->get($link);

  my ($netflix_id) = $link =~ /WiMovie\/(\d+)/;

  my $movie = Movie->new(netflix_id => $netflix_id);
  my $content = $self->content;

  if ($content =~ /<h1\s*class="title"\s*>\s*(.*?)\s*<\/h1>/) {
    $movie->set_title($1);
  }

  if ($content =~ /<div\s+class="starbar\s+starbar-avg\s+stbrWrapStc\s+clearfix">\s*(.*?)\s*<\/div>/s) {
    $content = $1;
    if ($content =~ /<\/p>\s*<meta\s+content="\d+"\s*\/>\s*<span\s+class="rating"\s*>\s*(\d+\.?\d*)\s+stars/) {
      $movie->set_rating($1);
    }
  }

  $movie;
}

1;

