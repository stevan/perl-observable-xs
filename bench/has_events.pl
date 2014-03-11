#!/usr/bin/env perl

use Observable;
use Observable::PP;

use Benchmark qw[ cmpthese ];

my $XS = Observable->new;
my $PP = Observable::PP->new;

cmpthese(
    5_000_000 => {
        'XS' => sub { $XS->has_events },
        'PP' => sub { $PP->has_events },
    }
);

$XS->bind('test' => sub {});
$PP->bind('test' => sub {});

cmpthese(
    5_000_000 => {
        'XS' => sub { $XS->has_events },
        'PP' => sub { $PP->has_events },
    }
);

1;