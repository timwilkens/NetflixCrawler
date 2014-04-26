package Movie;

use strict;
use warnings;

my %NEW_PARAMS = (title      => undef,
                  rating     => undef,
                  netflix_id => undef,
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

sub set_title { $_[0]->{title} = $_[1] }
sub set_rating { $_[0]->{rating} = $_[1] }
