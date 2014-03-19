#!/usr/bin/env perl

use Observable;
use Observable::PP;

use Benchmark qw[ cmpthese ];

my $XS = Observable->new;
my $PP = Observable::PP->new;

my ($XS_count, $PP_count) = (0, 0);

$XS->bind('test' => sub { $XS_count++ });
$PP->bind('test' => sub { $PP_count++ });

cmpthese(
    5_000_000 => {
        'XS' => sub { $XS->fire('test') },
        'PP' => sub { $PP->fire('test') },
    }
);

cmpthese(
    5_000_000 => {
        'XS' => sub { $XS->fire('test', 1 .. 10) },
        'PP' => sub { $PP->fire('test', 1 .. 10) },
    }
);

1;