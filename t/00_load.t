use Test::More tests => 13;
BEGIN { use_ok('Colloquy::Push') };

use Colloquy::Push;
our $SERVER = 'colloquy.mobi';
our $PORT   = 7906;

my $cp = Colloquy::Push->new('abcd', debug => 1, server => 'test', port => 100, timeout => 100);

ok(defined $cp,                "instantiation");
ok($cp->isa('Colloquy::Push'), "class match");
ok($cp->{device}  eq 'abcd',   "parameter: device");
ok($cp->{debug}   == 1,        "parameter: debug");
ok($cp->{server}  eq 'test',   "parameter: server");
ok($cp->{port}    == 100,      "parameter: port");
ok($cp->{timeout} == 100,      "parameter: timeout");

undef($cp);
$cp = Colloquy::Push->new('abcd');

ok($cp->{device}  eq 'abcd',   "reverifying parameter: device");
ok($cp->{debug}   == 0,        "default: debug");
ok($cp->{server}  eq $SERVER,  "default: debug");
ok($cp->{port}    == $PORT,    "default: debug");
ok($cp->{timeout} == 10,       "default: debug");

