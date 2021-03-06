package NetflixURL;

use strict;
use warnings;

my %NEW_PARAMS = (url => undef,
                  type => undef,
                 );

my %VALID_TYPES = (list   => 1,
                   detail => 1,
                  );

sub new {
  my ($class, %args) = @_;

  my $self = bless {%NEW_PARAMS}, $class;

  while (my ($param, $value) = each (%args)) {
    die "'$param' not a valid argument to $class constructor"
      unless (exists $NEW_PARAMS{$param});
    die "Invalid type '$value'" 
      unless (($param ne 'type') || $VALID_TYPES{$value});
    $self->{$param} = $value;
  }
  return $self;
}

sub url { shift->{url} }
sub type { shift->{type} }

sub set_url { $_[0]->{url} = $_[1] }
sub set_type { $_[0]->{type} = $_[1] }

1;

