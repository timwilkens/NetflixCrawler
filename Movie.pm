package Movie;

use strict;
use warnings;

my %NEW_PARAMS = (title          => undef,
                  netflix_rating => undef,
                  netflix_id     => undef,
                  year           => undef,
                  imdb_rating    => undef,
                  imdb_id        => undef,
                  url            => undef,
                  plot           => undef,
                  genre          => undef,
                  netflix_genre  => undef,
                  rt_rating      => undef,
                 );

sub new {
  my ($class, %args) = @_;
  my $self = bless {%NEW_PARAMS}, $class;

  while (my ($param, $value) = each(%args)) {
    die "'$param' not a valid argument to $class constructor"
      unless (exists $NEW_PARAMS{$param});
    $self->{$param} = $value;
  }
  return $self;
}

sub title { shift->{title} }
sub netflix_rating { shift->{netflix_rating} }
sub netflix_id { shift->{netflix_id} }
sub year { shift->{year} }
sub imdb_rating { shift->{imdb_rating} }
sub imdb_id { shift->{imdb_id} }
sub url { shift->{url} }
sub plot { shift->{plot} }
sub genre { shift->{genre} }
sub netflix_genre { shift->{netflix_genre} }
sub rt_rating { shift->{rt_rating} }

sub set_title { $_[0]->{title} = $_[1] }
sub set_netflix_rating { $_[0]->{netflix_rating} = $_[1] }
sub set_netflix_id { $_[0]->{netflix_id} = $_[1] }
sub set_year { $_[0]->{year} = $_[1] }
sub set_imdb_rating { $_[0]->{imdb_rating} = $_[1] }
sub set_imdb_id { $_[0]->{imdb_id} = $_[1] }
sub set_url { $_[0]->{url} = $_[1] }
sub set_plot { $_[0]->{plot} = $_[1] }
sub set_genre { $_[0]->{genre} = $_[1] }
sub set_netflix_genre { $_[0]->{netflix_genre} = $_[1] }
sub set_rt_rating { $_[0]->{rt_rating} = $_[1] }

sub is_tv_show {
  my $self = shift;
  return ($self->netflix_genre =~ /\sTV|TV\s/) ? 1 : 0;
}

1;

