package NetflixCrawler;

use strict;
use warnings;

use base qw(WWW::Mechanize);

use NetflixLink;

my $NETFLIX_HOME = 'http://www.netflix.com/WiHome';

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
  $self->get($NETFLIX_HOME);
}

my %GENRE_IDS = (action   => 1365,
                 comedy   => 6548,
                 thriller => 8933,
                );

sub get_movie_links_by_genre {
  my ($self, $genre) = @_;

  die "Must provide genre 'action', 'comedy', or 'thriller'" unless ($genre && $GENRE_IDS{$genre});

  my $url = 'http://www.netflix.com/WiGenre?agid=' . $GENRE_IDS{$genre} . '&orderBy=rt';
  $self->get_movie_detail_links;
}

sub get_movie_detail_links {
  my ($self, $url) = @_;

  $self->get($url);
  my @movie_links = $self->find_all_links(tag       => 'a',
                                          url_regex => qr/WiPlayer\?movieid=/
                                         );

  return $self->_transform_movie_detail_links(@movie_links);
}

sub _transform_movie_detail_links {
 my ($self, @movie_links) = @_;

  my @links;
  # Go from play link to info link.
  for my $link (@movie_links) {
    $link = $link->url_abs;
    $link =~ s/&trkid=\d+.+$//;
    $link =~ s/Player\?movieid=/Movie\//;
    push @links, NetflixLink->new(link => $link, type => 'detail');
  }
  return @links;
}

sub get_movie_list_links {
  my ($self, $url) = @_;

  $url //= $NETFLIX_HOME;

  $self->get($url);
  my @movie_links = $self->find_all_links(tag       => 'a',
                                          url_regex => qr/WiAltGenre\?agid=/
                                         );
  my @links;
  for my $link (@movie_links) {
    $link = $link->url_abs;
    push @links, NetflixLink->new(link => $link, type => 'list');
  }

  return @links;
}

sub get_all_links {
  my ($self, $link) = @_;

  my @detail_links = $self->get_movie_detail_links($link->link);
  my @list_links = $self->get_movie_list_links($link->link);

  return (@detail_links, @list_links);
}

1;

