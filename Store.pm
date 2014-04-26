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
    title CHAR NOT NULL,
    plot CHAR,
    genre CHAR,
    url CHAR,
    imdb_rating FLOAT,
    netflix_rating FLOAT,
    year INTEGER,
    netflix_id INTEGER UNIQUE,
    imdb_id CHAR)");
  }
  
  $self{dbh} = $dbh;
  return bless \%self, $class;
}

sub store_movie {
  my ($self, $movie) = @_;

  return if ($self->movie_exists($movie));

  my $sql = 'INSERT INTO movies (title, netflix_rating, netflix_id, plot, 
                                genre, url, imdb_rating, year, imdb_id
                                ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)';
  $self->{dbh}->do($sql, undef, $movie->title, $movie->netflix_rating, $movie->netflix_id, $movie->plot,
                   $movie->genre, $movie->url, $movie->imdb_rating, $movie->year, $movie->imdb_id);
}

sub close {
  my $self = shift;
  $self->{dbh}->disconnect;
}

sub movie_exists {
  my ($self, $movie) = @_;
  return $self->{dbh}->selectrow_array('SELECT COUNT(*) FROM movies WHERE netflix_id = ?',
                                        undef, $movie->netflix_id
                                      );
}

sub search_netflix_rating {
  my ($self, $rating) = @_;

  my $sql = "SELECT * from movies WHERE netflix_rating >= ?";
  my $sth = $self->{dbh}->prepare($sql);
  $sth->execute($rating)
    or die $self->{dbh}->errstr;

  my @movies;
  while (my $row = $sth->fetchrow_hashref) {
    my $movie = Movie->new();
    for my $field ( qw(title netflix_rating netflix_id plot genre url imdb_rating year imdb_id) ) {
      my $method = "set_" . $field;
      $movie->$method($row->{$field});
    }
    push @movies, $movie;
  }
  return @movies;
}

1;

