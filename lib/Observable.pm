package Observable;
use v5.18;
use warnings;

use Scalar::Util qw[ refaddr ];

our $VERSION   = '0.01';
our $AUTHORITY = 'cpan:STEVAN';

require XSLoader;
XSLoader::load('Observable', $VERSION);

sub fire {
    my ($self, $event_name, @args) = @_;
    return $self unless exists $self->{callbacks};
    return $self unless $self->{callbacks}->{ $event_name };
    $self->$_( @args ) foreach @{ $self->{callbacks}->{ $event_name } };
    return $self;
}

1;

__END__
