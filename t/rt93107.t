#!/usr/bin/perl

# Regression test for https://rt.cpan.org/Ticket/Display.html?id=93107

use strict;
use warnings;

use Test::More tests => 6;

use IO::Poll;

use IO::Handle;

package NewIOHandle;
use base qw( IO::Handle );

package main;

pipe( my $rd, my $wr ) or die "Cannot pipe() - $!";
$wr->syswrite("data\n");

# $rd should now be readable

my $poll = IO::Poll->new;
$poll->mask( $rd, POLLIN );

my $ret = $poll->poll(0);
is( $ret,               1,      'poll() indicates 1 filehandle is ready' );
is( $poll->events($rd), POLLIN, 'poll() indicates $rd has POLLIN' );

bless $rd, "NewIOHandle";

is( $poll->mask($rd), POLLIN, '$poll still has POLLIN mask for reblessed handle' );
$ret = $poll->poll(0);
is( $ret,               1,      'poll() indicates 1 filehandle is ready after rebless' );
is( $poll->events($rd), POLLIN, 'poll() indicates reblessed $rd still has POLLIN' );

$poll->remove($rd);
$rd->close;

$ret = $poll->poll(0);
is( $ret, 0, 'poll() times out after remove' );

