#define PERL_NO_GET_CONTEXT
#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include "ppport.h"

/*
void callperlsub (void * codeRef) {
    SV* code = (SV*) codeRef;
    dSP;
    PUSHMARK(SP);
    count = perl_call_sv(code, G_DISCARD|G_NOARGS ) ;
}
*/

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
    CODE:
        if ( !sv_isobject(self) ) {
            croak("Self is not an object");
        }

        obj = (HV*) SvRV(self);

        if ( !(SvTYPE(obj) == SVt_PVHV) ) {
            croak("Reference is not a hashref");
        }

        HV *callbacks;
        SV **callbacks_ptr = hv_fetch( obj, "callbacks", 9, 0 );
        if ( callbacks_ptr == NULL ) {
            callbacks = newHV();
            (void)hv_store( obj, "callbacks", 9, newRV_noinc((SV*) callbacks), 0);
        } else {
            callbacks = (HV*) SvRV( *callbacks_ptr );
            if ( !(SvTYPE(callbacks) == SVt_PVHV) ) {
                croak("callbacks is not a hashref");
            }
        }

        STRLEN event_name_string_len;
        char* event_name_string = SvPV( event_name, event_name_string_len );

        AV *events;
        SV **events_ptr = hv_fetch( callbacks, event_name_string, event_name_string_len, 0 );
        if ( events_ptr == NULL ) {
            events = newAV();
            (void)hv_store( callbacks, event_name_string, event_name_string_len, newRV_noinc((SV*) events), 0);
        } else {
            events = (AV*) SvRV( *events_ptr );
            if ( !(SvTYPE(events) == SVt_PVAV) ) {
                croak("events is not an arrayref");
            }
        }


        av_push( events, SvREFCNT_inc(callback) );

        XSRETURN(1);

void
unbind(self, event_name, callback)
    SV *self
    SV *event_name
    SV *callback
    PREINIT:
        HV *obj;
    CODE:
        if ( !sv_isobject(self) ) {
            croak("Self is not an object");
        }

        obj = (HV*) SvRV(self);

        if ( !(SvTYPE(obj) == SVt_PVHV) ) {
            croak("Reference is not a hashref");
        }

        SV **callbacks_ptr = hv_fetch( obj, "callbacks", 9, 0 );

        if ( callbacks_ptr != NULL ) {

            HV *callbacks = (HV*) SvRV( *callbacks_ptr );
            if ( !(SvTYPE(callbacks) == SVt_PVHV) ) {
                croak("callbacks is not a hashref");
            }

            STRLEN event_name_string_len;
            char* event_name_string = SvPV( event_name, event_name_string_len );

            SV **events_ptr = hv_fetch( callbacks, event_name_string, event_name_string_len, 0 );

            if ( events_ptr != NULL ) {

                AV *events;
                AV *new_events;
                I32 event_array_length;

                events = (AV*) SvRV( *events_ptr );
                if ( !(SvTYPE(events) == SVt_PVAV) ) {
                    croak("events is not an arrayref");
                }

                event_array_length = av_top_index(events);

                if (event_array_length != -1) {
                    new_events = newAV();
                }

                for (int i = 0; i <= event_array_length; i++) {
                    SV* event_cb;

                    event_cb = (SV*) *av_fetch( events, i, 0 );
                    if ( SvRV(event_cb) == SvRV(callback) ) {
                        (void)av_delete( events, i, 0 );
                    } else {
                        av_push( new_events, event_cb );
                    }
                }

                if (event_array_length != -1) {
                    (void)hv_delete( callbacks, event_name_string, event_name_string_len, 0);
                    av_undef( events );
                    if ( av_top_index( new_events ) == -1 ) {
                        av_undef( new_events );
                    } else {
                        (void)hv_store( callbacks, event_name_string, event_name_string_len, newRV_noinc((SV*) new_events), 0);
                    }
                }
            }
        }

        XSRETURN(1);

SV *
has_events(self)
    SV *self
    PREINIT:
        HV *obj;
        SV *check;
    CODE:
        if ( !sv_isobject(self) ) {
            croak("Self is not an object");
        }

        obj = (HV*) SvRV(self);

        if ( !(SvTYPE(obj) == SVt_PVHV) ) {
            croak("Reference is not a hashref");
        }

        SV **callbacks_ptr = hv_fetch( obj, "callbacks", 9, 0 );

        if ( callbacks_ptr == NULL ) {
            check = newSViv(0);
        }
        else {

            HV *callbacks = (HV*) SvRV( *callbacks_ptr );

            if ( !(SvTYPE(callbacks) == SVt_PVHV) ) {
                croak("callbacks is not a hashref");
            }

            check = newSViv( HvKEYS( callbacks ) );
        }

        RETVAL = check;
    OUTPUT:
        RETVAL

















