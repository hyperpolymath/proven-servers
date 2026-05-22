# SPDX-License-Identifier: MPL-2.0
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# Julia bindings for the proven-smtp protocol (SMTP server).
#
# Wraps the C-ABI functions from protocols/proven-smtp/ffi/zig/src/smtp.zig
# via ccall into libproven_smtp.so.

module Smtp

using ..ProvenServers: check_status, check_slot, SlotId

export SmtpState, AuthMechanism,
       abi_version, create_context, destroy_context, get_state,
       greet, authenticate, auth_complete, set_sender, add_recipient,
       start_data, append_data, finish_data, reset, quit, enable_tls,
       is_authenticated, is_tls_active, can_transition

const LIB = "libproven_smtp"

# --------------------------------------------------------------------------
# Enumeration types matching Idris2 ABI
# --------------------------------------------------------------------------

"""SMTP session lifecycle states."""
@enum SmtpState::UInt8 begin
    STATE_CONNECTED     = 0
    STATE_GREETED       = 1
    STATE_AUTH_STARTED  = 2
    STATE_AUTHENTICATED = 3
    STATE_MAIL_FROM     = 4
    STATE_RCPT_TO       = 5
    STATE_DATA          = 6
    STATE_DATA_DONE     = 7
    STATE_QUIT          = 8
end

"""SMTP authentication mechanisms."""
@enum AuthMechanism::UInt8 begin
    AUTH_NONE     = 0
    AUTH_PLAIN    = 1
    AUTH_LOGIN    = 2
    AUTH_CRAM_MD5 = 3
    AUTH_XOAUTH2  = 4
end

# --------------------------------------------------------------------------
# ccall declarations
# --------------------------------------------------------------------------

"""Return the ABI version of the linked libproven_smtp."""
function abi_version()::UInt32
    ccall((:smtp_abi_version, LIB), UInt32, ())
end

"""
    create_context() -> SlotId

Create a new SMTP session context. Throws on pool exhaustion.
"""
function create_context()::SlotId
    check_slot(ccall((:smtp_create_context, LIB), Cint, ()))
end

"""
    destroy_context(slot::SlotId)

Release the given SMTP context slot.
"""
function destroy_context(slot::SlotId)::Nothing
    ccall((:smtp_destroy_context, LIB), Cvoid, (Cint,), slot)
    nothing
end

"""
    get_state(slot::SlotId) -> SmtpState

Get the current SMTP session state.
"""
function get_state(slot::SlotId)::SmtpState
    SmtpState(ccall((:smtp_get_state, LIB), UInt8, (Cint,), slot))
end

"""
    greet(slot::SlotId; ehlo::Bool=true)

Send HELO/EHLO greeting. Throws on invalid state.
"""
function greet(slot::SlotId; ehlo::Bool=true)::Nothing
    flag = ehlo ? UInt8(1) : UInt8(0)
    check_status(ccall((:smtp_greet, LIB), UInt8, (Cint, UInt8), slot, flag))
end

"""
    authenticate(slot::SlotId, mech::AuthMechanism)

Begin authentication with the given mechanism. Throws on invalid state.
"""
function authenticate(slot::SlotId, mech::AuthMechanism)::Nothing
    check_status(ccall((:smtp_authenticate, LIB), UInt8,
                       (Cint, UInt8), slot, UInt8(mech)))
end

"""
    auth_complete(slot::SlotId, success::Bool)

Complete authentication. Throws on invalid state.
"""
function auth_complete(slot::SlotId, success::Bool)::Nothing
    flag = success ? UInt8(1) : UInt8(0)
    check_status(ccall((:smtp_auth_complete, LIB), UInt8,
                       (Cint, UInt8), slot, flag))
end

"""
    set_sender(slot::SlotId)

Set the MAIL FROM sender. Throws on invalid state.
"""
function set_sender(slot::SlotId)::Nothing
    check_status(ccall((:smtp_set_sender, LIB), UInt8, (Cint,), slot))
end

"""
    add_recipient(slot::SlotId)

Add a RCPT TO recipient. Throws on invalid state.
"""
function add_recipient(slot::SlotId)::Nothing
    check_status(ccall((:smtp_add_recipient, LIB), UInt8, (Cint,), slot))
end

"""
    start_data(slot::SlotId)

Begin DATA transfer. Throws on invalid state.
"""
function start_data(slot::SlotId)::Nothing
    check_status(ccall((:smtp_start_data, LIB), UInt8, (Cint,), slot))
end

"""
    append_data(slot::SlotId, len::UInt32)

Append data bytes. Throws on invalid state.
"""
function append_data(slot::SlotId, len::UInt32)::Nothing
    check_status(ccall((:smtp_append_data, LIB), UInt8,
                       (Cint, UInt32), slot, len))
end

"""
    finish_data(slot::SlotId)

Finish DATA transfer. Throws on invalid state.
"""
function finish_data(slot::SlotId)::Nothing
    check_status(ccall((:smtp_finish_data, LIB), UInt8, (Cint,), slot))
end

"""
    reset(slot::SlotId)

Reset the SMTP session (RSET). Throws on invalid state.
"""
function reset(slot::SlotId)::Nothing
    check_status(ccall((:smtp_reset, LIB), UInt8, (Cint,), slot))
end

"""
    quit(slot::SlotId)

Send QUIT command. Throws on invalid state.
"""
function quit(slot::SlotId)::Nothing
    check_status(ccall((:smtp_quit, LIB), UInt8, (Cint,), slot))
end

"""
    enable_tls(slot::SlotId)

Enable STARTTLS. Throws on invalid state.
"""
function enable_tls(slot::SlotId)::Nothing
    check_status(ccall((:smtp_enable_tls, LIB), UInt8, (Cint,), slot))
end

"""
    is_authenticated(slot::SlotId) -> Bool

Check if the session is authenticated.
"""
function is_authenticated(slot::SlotId)::Bool
    ccall((:smtp_is_authenticated, LIB), UInt8, (Cint,), slot) == 0x01
end

"""
    is_tls_active(slot::SlotId) -> Bool

Check if TLS is active on the session.
"""
function is_tls_active(slot::SlotId)::Bool
    ccall((:smtp_is_tls_active, LIB), UInt8, (Cint,), slot) == 0x01
end

"""
    can_transition(from::SmtpState, to::SmtpState) -> Bool

Check whether an SMTP state transition is valid.
"""
function can_transition(from::SmtpState, to::SmtpState)::Bool
    ccall((:smtp_can_transition, LIB), UInt8,
          (UInt8, UInt8), UInt8(from), UInt8(to)) == 0x01
end

end # module Smtp
