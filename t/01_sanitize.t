use Test::More tests => 6;
use Colloquy::Push;

my $test = {
	one   => "test\x{0}one",
	two   => "test\x{FF}two",
	three => 'test "four"',
	four  => 'x' x 500,
	###
	badge  => 3,
	action => 'false',
};

Colloquy::Push::_sanitize($_, $test);

ok($test->{one}   eq '"test?one"',          'low-char replacement');
ok($test->{two}   eq '"test?two"',          'high-char replacement');
ok($test->{three} eq '"test \\"four\\""',   'escape quotes');
ok(length($test->{four}) == 257,            'argument truncation');
ok($test->{badge} eq '3',                   'badge-count quote exemption');
ok($test->{action} eq 'false',              'action bool quote exemption');