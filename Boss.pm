package Boss;

use strict;
use warnings;

sub new {
  my $class = shift;

  my %self;
  $self{detail_work} = [];
  $self{list_work} = [];
  $self{seen} = {};

  return bless \%self, $class;
}

sub get_work {
  my $self = shift;

  if (!$self->detail_work_left && $self->list_work_left) {
    return $self->get_list_work;
  } else {
    return $self->get_detail_work;
  }
}

sub get_detail_work { 
  my $self = shift; 
  return shift @{$self->{detail_work}};
}

sub get_list_work { 
  my $self = shift;
  return shift @{$self->{list_work}};
}

sub add_work {
  my ($self, $link) = @_;
  return if ($self->{seen}{$link->url});

  if ($link->type eq 'list') {
    $self->_add_list_work($link);
  } else {
    $self->_add_detail_work($link);
  }

  $self->{seen}{$link->url} = 1;
}

sub _add_detail_work { push @{$_[0]->{detail_work}}, $_[1] }
sub _add_list_work { push @{$_[0]->{list_work}}, $_[1] }


sub detail_work_left { scalar(@{shift->{detail_work}}) }
sub list_work_left { scalar(@{shift->{list_work}}) }

1;

