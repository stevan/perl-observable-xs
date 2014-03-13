#!/usr/bin/env perl

use Observable;
use Observable::PP;

use Benchmark qw[ cmpthese ];

my $XS = Observable->new;
my $PP = Observable::PP->new;

my $test = sub { 1 };

my $i = 0;
cmpthese(
    1_000_000 => {
        'XS' => sub { $XS->bind( ('test' . $i++) => $test ) },
        'PP' => sub { $PP->bind( ('test' . $i++) => $test ) },
    }
);

1;