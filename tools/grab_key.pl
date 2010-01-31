#!/usr/bin/perl

use IO::Socket::INET;
use strict;

my $s = IO::Socket::INET->new(
  Proto     => 'tcp',
  LocalPort => 6667
);

$s->listen();
print "*** Listening on port 6667\n";

CLIENT: while (my $c = $s->accept()) {
  print "*** Got connection from " . $c->peerhost . "\n";
  
  while (my $i = $c->getline()) {
    if ($i =~ m/^NICK (.+)$/) {
      $c->print(":grab_key 001 $1 :hello\n");
    } elsif ($i =~ m/^PUSH add-device ([0-9a-f]+) :(.+)$/) {
      chomp(my ($token, $name) = ($1, $2));
      
      print "*** Found device\n";
      print "\n\t NAME: $name";
      print "\n\tTOKEN: $token\n\n";

      $c->close();
      last CLIENT;
    }
  }
}

$s->close();