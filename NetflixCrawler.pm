package NetflixCrawler;

use strict;
use warnings;

use base qw(WWW::Mechanize);

sub new {
  my ($class, %args) = @_;

  my $self = $class->SUPER::new(%args);
}

sub login {
  my ($self, %args) = @_;

  die "Must pass email and password\n" unless ($args{email} && $args{password});

  # Get enter password page.
  $self->get('https://www.netflix.com/Login?locale=en-US');

  # Submit our form.
  $self->form_id('login-form');
  $self->field (email => $args{email});
  $self->field (password => $args{password});
  $self->click;

  # Go to the homepage.
  $self->get('http://www.netflix.com/WiHome');
}

1;

