package Store;

use strict;
use warnings;

use DBI;
use Movie;

sub new {
  my ($class, $file) = @_;
  die "Must provide a filepath" unless $file;

  my %self;

  # Make the table if we don't have it yet.
  my $make_flag;
  if (! -f $file) {
    $make_flag = 1;
  }

  my $connect = "dbi:SQLite:dbname=$file";
  my $dbh = DBI->connect($connect, '', '', {
   RaiseError       => 1,
   AutoCommit       => 1,
  });

  if ($make_flag) {
    $dbh->do("CREATE TABLE movies (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    title CHAR UNIQUE NOT NULL,
    plot CHAR,
    genre CHAR,
    url CHAR UNIQUE,
    imdb_rating FLOAT,
    netflix_rating FLOAT,
    year INTEGER,
    netflix_id INTEGER UNIQUE,
    imdb_id CHAR,
    netflix_genre CHAR,
    rt_rating INTEGER)");
  }
  
  $self{dbh} = $dbh;
  return bless \%self, $class;
}

sub store_movie {
  my ($self, $movie) = @_;

  return if ($self->movie_id_exists($movie->netflix_id));
  return if ($self->movie_title_exists($movie->title));
  return if ($self->movie_url_exists($movie->url));

  my $sql = 'INSERT INTO movies (title, netflix_rating, netflix_id, plot, 
                                genre, url, imdb_rating, year, imdb_id, netflix_genre, rt_rating
                                ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)';
  $self->{dbh}->do($sql, undef, $movie->title, $movie->netflix_rating, $movie->netflix_id, $movie->plot,
                   $movie->genre, $movie->url, $movie->imdb_rating, $movie->year, $movie->imdb_id, 
                   $movie->netflix_genre, $movie->rt_rating
                  );
}

sub close {
  my $self = shift;
  $self->{dbh}->disconnect;
}

sub movie_id_exists {
  my ($self, $netflix_id) = @_;
  return $self->{dbh}->selectrow_array('SELECT COUNT(*) FROM movies WHERE netflix_id = ?',
                                        undef, $netflix_id
                                      );
}

sub movie_title_exists {
  my ($self, $title) = @_;
  return $self->{dbh}->selectrow_array('SELECT COUNT(*) FROM movies WHERE title = ?',
                                        undef, $title
                                      );
}

sub movie_url_exists {
  my ($self, $url) = @_;
  return $self->{dbh}->selectrow_array('SELECT COUNT(*) FROM movies WHERE url = ?',
                                        undef, $url
                                      );
}

sub netflix_rating_above {
  my ($self, $rating) = @_;

  my $sql = "SELECT * from movies WHERE netflix_rating >= ?";
  return $self->_make_query(sql   => $sql, 
                            value => $rating
                           );
}

sub netflix_genre_contains {
  my ($self, $query, $sort) = @_;

  # Try to speed things up here a bit. Need netflig_genre for 'is_tv_show' method.
  my $sql = "SELECT title, netflix_rating, imdb_rating, rt_rating, plot, url, netflix_genre from movies WHERE netflix_genre LIKE ?";
  return $self->_make_query(sql   => $sql, 
                            value => '%'.$query.'%',
                            sort  => $sort,
                           );

}

sub _make_query {
  my ($self, %args) = @_;
  my $sql = $args{sql};
  my $value = $args{value};
  my $sort = $args{sort};
  $sort //= 'netflix';

  my $sth = $self->{dbh}->prepare($sql);
  $sth->execute($value)
    or die $self->{dbh}->errstr;

  my @movies;
  while (my $row = $sth->fetchrow_hashref) {
    push @movies, $self->_movie_from_data($row);
  }
  return _sort_movies($sort, @movies);
}

sub _sort_movies {
  my ($sort, @movies) = @_;
  my $primary;
  my $aux;
  
  if ($sort eq 'netflix') {
    $primary = 1;
    $aux = 6;
  } elsif ($sort eq 'imdb') {
    $primary = 3;
    $aux = 4;
  } else {
    $primary = 2;
    $aux = 5;
  }
  return map { $_->[0] }
         sort { $b->[$primary] <=> $a->[$primary] || $b->[$aux] <=> $a->[$aux] }
         map { [$_->[0], $_->[1], $_->[2], $_->[3], $_->[1] + ($_->[2] / 20), $_->[1] + ($_->[3] / 2), ($_->[2] / 20) + ($_->[3] / 2)] } 
         map { [$_, $_->netflix_rating, $_->rt_rating, $_->imdb_rating] } @movies;
}

sub _movie_from_data {
  my ($self, $data) = @_;

  my $movie = Movie->new();
  for my $field ( qw(title netflix_rating netflix_id plot genre url imdb_rating year imdb_id netflix_genre rt_rating) ) {
    my $method = "set_" . $field;
    if ($data->{$field}) {
      $movie->$method($data->{$field});
    } else {
      $movie->$method(undef);
    }
  }
  return $movie;
}


1;

