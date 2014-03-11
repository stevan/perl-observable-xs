package Observable;
use v5.18;
use warnings;

use Scalar::Util qw[ refaddr ];

our $VERSION   = '0.01';
our $AUTHORITY = 'cpan:STEVAN';

require XSLoader;
XSLoader::load('Observable', $VERSION);

sub unbind {
    my ($self, $event_name, $callback) = @_;
    $self->{callbacks} = {} unless exists $self->{callbacks};
    return $self unless $self->{callbacks}->{ $event_name };
    @{ $self->{callbacks}->{ $event_name } } = grep {
        refaddr($_) != refaddr($callback)
    } @{ $self->{callbacks}->{ $event_name } };
    delete $self->{callbacks}->{ $event_name }
        unless scalar @{ $self->{callbacks}->{ $event_name } };
    $self;
}

sub fire {
    my ($self, $event_name, @args) = @_;
    return $self unless exists $self->{callbacks};
    return $self unless $self->{callbacks}->{ $event_name };
    $self->$_( @args ) foreach @{ $self->{callbacks}->{ $event_name } };
    return $self;
}

1;

__END__
