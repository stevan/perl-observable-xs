package Observable;
use v5.18;
use warnings;

use Scalar::Util qw[ refaddr ];

our $VERSION   = '0.01';
our $AUTHORITY = 'cpan:STEVAN';

require XSLoader;
XSLoader::load('Observable', $VERSION);

1;

__END__
