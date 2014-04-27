package Spider;

use strict;
use warnings;

use NetflixCrawler;
use NetflixExtractor;
use IMDBData;
use Store;
use Boss;

sub new {
  my ($class, %args) = @_;
  die "Need email and password" unless ($args{email} && $args{password});

  my %self;
  $self{password} = $args{password};
  $self{email} = $args{email};
  $self{boss} = Boss->new;
  $self{storage} = Store->new('movie_store');
  $self{imdb} = IMDBData->new;
  $self{netflix} = NetflixCrawler->new;
  $self{extractor} = NetflixExtractor->new;

  bless \%self, $class;
}

sub run {
  my $self = shift;

  $self->{netflix}->login(email    => $self->{email},
                          password => $self->{password}
                         );

  # Start from genre pages on Homepage.
  my @list_links = $self->{netflix}->get_movie_list_links;
  $self->give_list_to_boss(@list_links);

  while (my $link = $self->{boss}->get_work) {
    print "Getting: " . $link->url . "\n";
    print $self->{boss}->detail_work_left . " detail links left\n";
    my @to_add = $self->{netflix}->get_all_links($link->url);
    $self->give_list_to_boss(@to_add);

    if ($link->type eq 'detail') {
      $self->{netflix}->get($link->url);
      my $movie = $self->{extractor}->make_movie(link    => $link->url,
                                                 content => $self->{netflix}->content,
                                                );
      next unless $movie;
      $self->{imdb}->add_imdb_data($movie);
      $self->{storage}->store_movie($movie);
    }
  }
}

sub give_list_to_boss {
  my ($self, @links) = @_;

  for my $link (@links) {
    $self->{boss}->add_work($link) unless $self->{storage}->movie_url_exists($link);
  }

}

1;

