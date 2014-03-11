#define PERL_NO_GET_CONTEXT
#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include "ppport.h"

MODULE = Observable		PACKAGE = Observable

SV *
new(package)
    SV *package
    PREINIT:
        HV *self;
        HV *stash;
        SV *self_ref;
    CODE:
        if (!SvPOK(package)) {
            croak("new() expects a package name");
        }

        self = newHV();

        stash = gv_stashpv(SvPV_nolen(package), 0);
        if (!stash) {
            croak("Failed to find our stash!");
        }

        self_ref = newRV_noinc((SV*) self);

        RETVAL = sv_bless(self_ref, stash);
    OUTPUT:
        RETVAL

void
bind(self, event_name, callback)
    SV *self
    SV *event_name
    SV *callback
    PREINIT:
        HV *obj;

        HV *callbacks;
        SV **callbacks_ptr;

        AV *events;
        SV **events_ptr;

        STRLEN event_name_string_len;
        char* event_name_string;
    CODE:
        if ( !sv_isobject(self) ) {
            croak("Self is not an object");
        }

        obj = (HV*) SvRV(self);

        if ( !(SvTYPE(obj) == SVt_PVHV) ) {
            croak("Reference is not a hashref");
        }

        callbacks_ptr = hv_fetch( obj, "callbacks", 9, 0 );
        if ( callbacks_ptr == NULL ) {
            callbacks = newHV();
            (void)hv_store( obj, "callbacks", 9, newRV_noinc((SV*) callbacks), 0);
        } else {
            callbacks = (HV*) SvRV( *callbacks_ptr );
            if ( !(SvTYPE(callbacks) == SVt_PVHV) ) {
                croak("callbacks is not a hashref");
            }
        }

        event_name_string = SvPV( event_name, event_name_string_len );

        events_ptr = hv_fetch( callbacks, event_name_string, event_name_string_len, 0 );
        if ( events_ptr == NULL ) {
            events = newAV();
            (void)hv_store( callbacks, event_name_string, event_name_string_len, newRV_noinc((SV*) events), 0);
        } else {
            events = (AV*) SvRV( *events_ptr );
            if ( !(SvTYPE(events) == SVt_PVAV) ) {
                croak("events is not an arrayref");
            }
        }

        av_push( events, callback );

        XSRETURN(1);


SV *
has_events(self)
    SV *self
    PREINIT:
        HV *obj;
        SV *check;
        HV *callbacks;
        SV **callbacks_ptr;
    CODE:
        if ( !sv_isobject(self) ) {
            croak("Self is not an object");
        }

        obj = (HV*) SvRV(self);

        if ( !(SvTYPE(obj) == SVt_PVHV) ) {
            croak("Reference is not a hashref");
        }

        callbacks_ptr = hv_fetch( obj, "callbacks", 9, 0 );

        if ( callbacks_ptr == NULL ) {
            check = newSViv(0);
        }
        else {

            callbacks = (HV*) SvRV( *callbacks_ptr );

            if ( !(SvTYPE(callbacks) == SVt_PVHV) ) {
                croak("callbacks is not a hashref");
            }

            check = newSViv( HvKEYS( callbacks ) );
        }

        RETVAL = check;
    OUTPUT:
        RETVAL

















