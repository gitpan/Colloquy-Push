use Module::Build;
use strict;
use warnings;

Module::Build->new(
  module_name    => 'Colloquy::Push',
  license        => 'perl',
  dist_author    => 'Brandon Gilmore <brandon@mg2.org>',

  build_requires => {
    'Test::More'      => 0
  },

  requires       => {
    'perl'            => '5.8.0',
    'Carp'            => 0,
    'IO::Socket::SSL' => '>= 0.93',
  }
)->create_build_script;
