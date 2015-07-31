#!./perl

BEGIN {
    unless ($] >= 5.008 and find PerlIO::Layer 'perlio') {
	print "1..0 # Skip: not perlio\n";
	exit 0;
    }
}

require($ENV{PERL_CORE} ? "../../t/test.pl" : "./t/test.pl");

# Win32 below perl 5.18 seems to have an issue with EOF and large buffers. Perl #125723
my $is_broken_win32 = ($^O eq 'MSWin32' && $] < 5.018) ? 1 : 0;

# Above default buffer size of 8192 except on windows below 5.18 which can't handle it.
my $buf_size_count = $is_broken_win32 ? 3455 : 8200;

plan(tests => 6 + 2 * $buf_size_count);

my $io;

use_ok('IO::File');

$io = IO::File->new;

ok($io->open("io_utf8", ">:utf8"), "open >:utf8");
ok((print $io chr(256)), "print chr(256)");
undef $io;

$io = IO::File->new;
ok($io->open("io_utf8", "<:utf8"), "open <:utf8");
is(ord(<$io>), 256, "readline chr(256)");
undef $io;

$io = IO::File->new;
ok($io->open("io_utf8", "<:utf8"), "open <:utf8");
for my $i (0 .. $buf_size_count - 1) {
    is($io->ungetc($i), $i, "ungetc of $i returns itself");
}

for (my $i = $buf_size_count - 1; $i >= 0; $i--) {
    is(ord($io->getc()), $i, "getc gets back $i");
}

undef $io;

END {
  1 while unlink "io_utf8";
}
