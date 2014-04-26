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

sub get_detail_work { shift @{shift->{detail_work}} }
sub get_list_work { shift @{shift->{list_work}} }

sub add_work {
  my ($self, $link) = @_;
  return if ($self->{seen}{$link->link});

  if ($link->type eq 'list') {
    $self->add_list_work($link);
  } else {
    $self->add_detail_work($link);
  }

  $self->{seen}{$link->link} = 1;
}

sub _add_detail_work { push @{$_[0]->{detail_work}}, $_[1] }
sub _add_list_work { push @{$_[0]->{list_work}}, $_[1] }


sub detail_work_left { scalar(@{shift->{detail_work}}) }
sub list_work_left { scalar(@{shift->{detail_work}}) }

1;

