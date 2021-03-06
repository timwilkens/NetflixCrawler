package Spider;

use strict;
use warnings;

use NetflixCrawler;
use NetflixExtractor;
use NetflixURL;
use IMDBData;
use Store;
use Boss;
use RTData;

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
  $self{rt} = RTData->new;

  bless \%self, $class;
}

sub run {
  my $self = shift;
  my $added = 0;

  $self->{netflix}->login(email    => $self->{email},
                          password => $self->{password}
                         );

  $self->{boss}->add_work(NetflixURL->new(url => 'http://www.netflix.com/WiHome', type => 'list'));

  # Start from genre pages on Homepage.
  my @list_links = $self->{netflix}->get_movie_list_links;
  $self->give_list_to_boss(@list_links);

  while (my $link = $self->{boss}->get_work) {
    next if $self->{storage}->movie_url_exists($link->url);
    print "Getting: " . $link->url . "\n";
    print "Added: $added\t" 
          . $self->{boss}->detail_work_left 
          . " detail links left\t" 
          . $self->{boss}->list_work_left
          . " list links left\n";
    my @to_add = $self->{netflix}->get_all_links($link->url);
    $self->give_list_to_boss(@to_add);

    if ($link->type eq 'detail') {
      $self->{netflix}->get($link->url);
      my $movie = $self->{extractor}->make_movie(link    => $link->url,
                                                 content => $self->{netflix}->content,
                                                );
      next unless $movie;
      # Don't do imdb and RT if we already have this.
      next if $self->{storage}->movie_id_exists($movie->netflix_id);
      next if $self->{storage}->movie_title_exists($movie->title);

      $self->{imdb}->add_imdb_data($movie);
      $self->{rt}->add_tomato_rating($movie);
      $self->{storage}->store_movie($movie);
      $added++;
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

