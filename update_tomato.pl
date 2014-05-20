#!/usr/bin/perl

use strict;
use warnings;

use List::Util qw(shuffle);

use Store;
use RTData;

my $storage = Store->new('movie_store');
my $tomato = RTData->new;
my @movies = $storage->no_tomato;

for my $movie (shuffle(@movies)) {
  $tomato->add_tomato_rating($movie);

  if ($movie->rt_rating) {
    print "Updated rt_rating to: " . $movie->rt_rating . " for movie: " . $movie->title . "\n";
    $storage->update_tomato($movie);
  }
}
