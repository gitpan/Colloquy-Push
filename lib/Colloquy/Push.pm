package Colloquy::Push;

=head1 NAME

Colloquy::Push - APNS messaging for Mobile Colloquy

=head1 SYNOPSIS

  use Colloquy::Push;
  my $id = 'ce7098848342d16da...';

  my $iphone = Colloquy::Push->new($id, timeout => 5);
  $iphone->push( message => 'hello world!',
                 room    => '#perl',
                 server  => 'irc.freenode.net',
                 sender  => 'bg' );

=head1 DESCRIPTION

  C<Colloquy::Push> can be used to dispatch iPhone "Push" notifications to
  devices running B<Mobile Colloquy> that are registered to accept these
  notifications.
  
  As a prerequisite for using this module, you must have the device ID of the
  recipient. This is admittedly tricky because the ID is generated and managed
  by the APNS servers, so there is a mock server included in the distribution
  that can be used for exactly this purpose.

=cut

use Carp;
use IO::Socket::SSL;
use strict;
our $VERSION = '0.01';


###
### PRIVATE METHODS
###

sub _connect {
  my ($self) = @_;
  
  if ($self->{persistent} and exists($self->{_sock})) {
    if ($self->{_sock}->connected()) {
      return $self->{_sock};
    } else {
      print "*** closing stale connection\n"
        if $self->{debug};
      $self->{_sock}->close();
    }
  }
  
  $self->{_sock} = IO::Socket::SSL->new(
    PeerHost => $self->{server},
    PeerPort => $self->{port},
    Timeout  => $self->{timeout},
  ) or croak("failed to connect to server: $@");
  
  printf(STDERR "*** connected to %s:%s\n", $self->{server}, $self->{port})
    if $self->{debug};
  
  return $self->{_sock};
}

sub _sanitize {
  my ($self, $args) = @_;
  
  foreach (keys %{$args}) {
    # truncate long parameters
    if (length($args->{$_}) > 255) {
      $args->{$_} = substr($args->{$_}, 0, 255);
    }
    
    # reduce to printable ASCII
    $args->{$_} =~ s/[^\x{20}-\x{7E}]/?/g;
    
    unless (($_ eq 'action') or ($_ eq 'badge')) {
      # add slashes
      $args->{$_} =~ s/"/\\"/g;
      # encapsulate in quotes
      $args->{$_} = '"' . $args->{$_} . '"';
    }
    
  }
}


###
### PUBLIC METHODS
###

=head1 METHODS

=over 4

=item C<new( $device, ... )>

This method constructs a new C<Colloquy::Push> instance. It takes the
device-token of the iPhone that will receive the APNS notifications as its
only required argument. Optionally, these additional keyword arguments are
accepted:

   KEY                     DEFAULT
   -----------             --------------------
   server                  "colloquy.mobi"
   port                     7906
   timeout                  10
   debug                    0
   persistent               0

=cut

sub new {
  my ($class, $device, %args) = @_;
  my $self = bless(\%args, $class);

  $self->{device} = $device
    or croak('No device ID passed to ' . __PACKAGE__ . '->new()');

  # default settings
  $self->{server}  ||= 'colloquy.mobi';
  $self->{port}    ||= 7906;
  $self->{timeout} ||= 10;
  ($self->{debug} = 0) unless exists($self->{debug});
  ($self->{persistent} = 0) unless exists($self->{persistent});

  return $self;
}

=item C<push( ... )>

This method takes a number of keyword arguments needed to build and dispatch
a push notification. Keywords marked with an asterisk are required:

   KEY                     VALUE
   -----------             --------------------
   action                  boolean: event was an action (default: 'false')
   badge                   amount to increment icon badge
 * message                 body of the message or action
   room                    originating IRC channel (optional if privmsg)
 * sender                  originating IRC nick
 * server                  originating IRC server
   sound                   alert sound (see app prefs for available sounds)

=cut

sub push {
  my ($self, %args) = @_;
  
  $args{'device-token'} = $self->{device};
  $self->_sanitize(\%args);
  my $msg = '{' . join(",", map { "\"$_\":$args{$_}" } keys %args) . '}';
  
  my $sock = $self->_connect();
  print STDERR ">>> $msg\n" if $self->{debug};
  $sock->print($msg);
  
  ### this functionality disappeared from the push proxy in Jan2010?
  # my $res = $sock->getline();
  # print STDERR "<<< $res\n" if ($self->{debug});
  # croak("push() failed") unless ($res eq 'DONE');
  
  $sock->close() unless $self->{persistent};
}


1;

__END__

=back

=head1 SEE ALSO

=over 4

=item * Mobile Colloquy (http://colloquy.mobi/)

=back

=head1 AUTHOR

Brandon Gilmore, E<lt>brandon@mg2.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2010 Brandon Gilmore

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.10.0 or,
at your option, any later version of Perl 5 you may have available.

=cut