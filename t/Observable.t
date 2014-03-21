#!/usr/bin/env perl

use strict;
use warnings;

use Test::More;
use Data::Dumper qw[ Dumper ];

BEGIN {
    use_ok('Observable')
};

{
    my $o = Observable->new;
    isa_ok($o, 'Observable');

    can_ok($o, 'bind');
    can_ok($o, 'unbind');
    can_ok($o, 'fire');
    can_ok($o, 'has_events');

    ok(!$o->has_events, '... no events yet');

    my $test       = 0;
    my $test_event = sub { $test++ };

    $o->bind('test', $test_event);

    ok($o->has_events, '... have events now');
    is($test, 0, '... test event has not been fired');

    $o->fire('test');

    is($test, 1, '... test event has been fired');

    $o->unbind('test', $test_event);

    ok(!$o->has_events, '... no events anymore');

    $o->fire('test');
    is($test, 1, '... test event was not fired again');
}

{
    my $o = Observable->new;
    isa_ok($o, 'Observable');

    can_ok($o, 'bind');
    can_ok($o, 'unbind');
    can_ok($o, 'fire');
    can_ok($o, 'has_events');

    ok(!$o->has_events, '... no events yet');

    my @tests;
    my @events;
    foreach my $i (0 .. 10) {
        $tests[$i]  = 0;
        $events[$i] = sub { $tests[$i]++ };

        $o->bind('test', $events[$i]);
    }

    ok($o->has_events, '... have events now');
    is($tests[$_], 0, '... test ('.$_.') event has not been fired')
        foreach 0 .. 10;

    $o->fire('test');
    $o->fire('test');
    $o->fire('test');

    is($tests[$_], 3, '... test ('.$_.') event has not been fired')
        foreach 0 .. 10;
}


done_testing;

