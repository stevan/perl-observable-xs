#define PERL_NO_GET_CONTEXT
#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include "ppport.h"

HV* self_to_obj (SV* self) {
    HV* obj;

    if (!sv_isobject(self)) {
        croak("Self is not an object");
    }
    if (!(SvTYPE(SvRV(self)) == SVt_PVHV)) {
        croak("Reference is not a hashref");
    }
    return (HV*) SvRV(self);
}

HV* get_callbacks (HV* obj) {
    HV*  callbacks;
    SV** callbacks_ptr;

    callbacks_ptr = hv_fetch(obj, "callbacks", 9, 0);
    if (callbacks_ptr != NULL) {
        callbacks = (HV*) SvRV(*callbacks_ptr);
        if (!(SvTYPE(callbacks) == SVt_PVHV)) {
            croak("callbacks is not a hashref");
        }
        return callbacks;
    } else {
        return NULL;
    }
}

AV* get_events (HV* callbacks, SV* event_name) {
    AV* events;

    HE* events_entry = hv_fetch_ent(callbacks, event_name, 0, 0);
    if (events_entry != NULL) {
        events = (AV*) SvRV(HeVAL(events_entry));
        if (!(SvTYPE(events) == SVt_PVAV) ) {
            croak("events is not an arrayref");
        }
        return events;
    } else {
        return NULL;
    }
}

SV* bless_new_hashref(SV* package) {
    HV* stash;
    SV* self;

    if (!SvPOK(package)) {
        croak("new() expects a package name");
    }

    stash = gv_stashpv(SvPV_nolen(package), 0);
    if (!stash) {
        croak("Failed to find our stash!");
    }

    self = newRV_noinc((SV*) newHV());

    return sv_bless(self, stash);
}

MODULE = Observable		PACKAGE = Observable

SV*
new(package)
    SV* package
    CODE:
        RETVAL = bless_new_hashref(package);
    OUTPUT:
        RETVAL

void
fire(self, event_name, ...)
    SV* self
    SV* event_name
    PREINIT:
        HV* obj;
        HV* callbacks;
        AV* events;
    CODE:
        obj       = self_to_obj(self);
        callbacks = get_callbacks(obj);

        if (callbacks != NULL) {

            events = get_events(callbacks, event_name);
            if (events != NULL) {

                I32 event_array_length, i, j;

                event_array_length = av_len(events);

                if (event_array_length != -1) {

                    dSP;

                    for (i = 0; i <= event_array_length; i++) {
                        SV* code;
                        code = (SV*) *av_fetch(events, i, 0);

                        ENTER;
                        SAVETMPS;
                        PUSHMARK(SP);
                        XPUSHs(self);
                        for (j = 0; j <= items; j++) {
                            XPUSHs(ST(j));
                        }
                        PUTBACK;
                        (void)call_sv(code, G_VOID|G_DISCARD);
                        SPAGAIN;
                        FREETMPS;
                        LEAVE;
                    }
                }
            }

        }

        XSRETURN(1);


void
bind(self, event_name, callback)
    SV *self
    SV *event_name
    SV *callback
    PREINIT:
        HV* obj;
        HV* callbacks;
        AV* events;
    CODE:
        obj       = self_to_obj(self);
        callbacks = get_callbacks(obj);

        if (callbacks == NULL) {
            callbacks = newHV();
            (void)hv_store(obj, "callbacks", 9, newRV_noinc((SV*) callbacks), 0);
        }

        events = get_events(callbacks, event_name);
        if (events == NULL) {
            events = newAV();
            (void)hv_store_ent(callbacks, event_name, newRV_noinc((SV*) events), 0);
        }

        av_push(events, SvREFCNT_inc(callback));

        XSRETURN(1);

void
unbind(self, event_name, callback)
    SV *self
    SV *event_name
    SV *callback
    PREINIT:
        HV* obj;
        HV* callbacks;
        AV* events;
    CODE:
        obj       = self_to_obj(self);
        callbacks = get_callbacks(obj);

        if (callbacks != NULL) {

            events = get_events(callbacks, event_name);

            if (events != NULL) {

                AV* new_events;
                I32 event_array_length, i;

                event_array_length = av_top_index(events);

                if (event_array_length != -1) {
                    new_events = newAV();
                }

                for (i = 0; i <= event_array_length; i++) {
                    SV* event_cb;

                    event_cb = (SV*) *av_fetch(events, i, 0);
                    if (SvRV(event_cb) == SvRV(callback)) {
                        (void)av_delete(events, i, 0);
                    } else {
                        av_push(new_events, event_cb);
                    }
                }

                if (event_array_length != -1) {
                    (void)hv_delete_ent(callbacks, event_name, G_DISCARD, 0);
                    if (av_top_index(new_events) == -1) {
                        av_undef(new_events);
                    } else {
                        (void)hv_store_ent(callbacks, event_name, newRV_noinc((SV*) new_events), 0);
                    }
                }

            }
        }

        XSRETURN(1);

SV *
has_events(self)
    SV *self
    PREINIT:
        HV* obj;
        HV* callbacks;
    CODE:
        obj       = self_to_obj(self);
        callbacks = get_callbacks(obj);
        RETVAL    = callbacks == NULL ? newSViv(0) : newSViv(HvKEYS(callbacks));
    OUTPUT:
        RETVAL

