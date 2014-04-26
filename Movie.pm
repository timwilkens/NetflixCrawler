package Movie;

use strict;
use warnings;

my %NEW_PARAMS = (title      => undef,
                  rating     => undef,
                  netflix_id => undef,
                  year       => undef,
                 );

sub new {
  my ($class, %args) = @_;
  my $self = bless \%NEW_PARAMS, $class;

  while (my ($param, $value) = each(%args)) {
    die "'$param' not a valid argument to $class constructor"
      unless (exists $NEW_PARAMS{$param});
    $self->{$param} = $value;
  }
  $self;
}

sub title { shift->{title} }
sub rating { shift->{rating} }
sub netflix_id { shift->{netflix_id} }
sub year { shift->{year} }

sub set_title { $_[0]->{title} = $_[1] }
sub set_rating { $_[0]->{rating} = $_[1] }
sub set_netflix_id { $_[0]->{netflix_id} = $_[1] }
sub set_year { $_[0]->{year} = $_[1] }

1;

