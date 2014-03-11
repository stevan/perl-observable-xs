#!/usr/bin/env perl

use Observable;
use Observable::PP;

use Benchmark qw[ cmpthese ];

cmpthese(
    1_000_000 => {
        'XS' => sub { Observable->new     },
        'PP' => sub { Observable::PP->new },
    }
);

1;