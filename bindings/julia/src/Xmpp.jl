# SPDX-License-Identifier: PMPL-1.0-or-later
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# Julia bindings for the proven-xmpp protocol (XMPP (RFC 6120) server).
#
# Wraps the C-ABI functions from protocols/proven-xmpp/ffi/zig/src/xmpp.zig
# via ccall into libproven_xmpp.so.

module Xmpp

using ..ProvenServers: check_status, check_slot, SlotId

export XMPP_CLIENT_PORT,
       XMPP_SERVER_PORT,
       StanzaType,
       XmppMessageType,
       PresenceType,
       IqType,
       StreamError,
       abi_version,
       create_context,
       destroy_context,
       get_state,
       can_transition

const LIB = "libproven_xmpp"

# --------------------------------------------------------------------------
# Constants
# --------------------------------------------------------------------------

"""XMPP_CLIENT_PORT: protocol constant."""
const XMPP_CLIENT_PORT = UInt16(5222)

"""XMPP_SERVER_PORT: protocol constant."""
const XMPP_SERVER_PORT = UInt16(5269)

# --------------------------------------------------------------------------
# Enumeration types matching Idris2 ABI
# --------------------------------------------------------------------------

"""XMPP stanza types."""
@enum StanzaType::UInt8 begin
    STANZA_MESSAGE = 0
    STANZA_PRESENCE = 1
    STANZA_IQ = 2
end

"""XMPP message types."""
@enum XmppMessageType::UInt8 begin
    MSG_CHAT = 0
    MSG_ERROR = 1
    MSG_GROUPCHAT = 2
    MSG_HEADLINE = 3
    MSG_NORMAL = 4
end

"""XMPP presence types."""
@enum PresenceType::UInt8 begin
    PRES_AVAILABLE = 0
    PRES_AWAY = 1
    PRES_DND = 2
    PRES_XA = 3
    PRES_UNAVAILABLE = 4
end

"""XMPP IQ types."""
@enum IqType::UInt8 begin
    IQ_GET = 0
    IQ_SET = 1
    IQ_RESULT = 2
    IQ_ERROR = 3
end

"""XMPP stream errors."""
@enum StreamError::UInt8 begin
    STREAM_BAD_FORMAT = 0
    STREAM_CONFLICT = 1
    STREAM_CONNECTION_TIMEOUT = 2
    STREAM_HOST_GONE = 3
    STREAM_HOST_UNKNOWN = 4
    STREAM_NOT_AUTHORIZED = 5
    STREAM_POLICY_VIOLATION = 6
    STREAM_RESOURCE_CONSTRAINT = 7
    STREAM_SYSTEM_SHUTDOWN = 8
end

# --------------------------------------------------------------------------
# ccall declarations
# --------------------------------------------------------------------------

"""Return the ABI version of the linked libproven_xmpp."""
function abi_version()::UInt32
    ccall((:xmpp_abi_version, LIB), UInt32, ())
end

"""
    create_context() -> SlotId

Create a new Xmpp context. Throws on pool exhaustion.
"""
function create_context()::SlotId
    check_slot(ccall((:xmpp_create_context, LIB), Cint, ()))
end

"""
    destroy_context(slot::SlotId)

Release the given Xmpp context slot.
"""
function destroy_context(slot::SlotId)::Nothing
    ccall((:xmpp_destroy_context, LIB), Cvoid, (Cint,), slot)
    nothing
end

"""
    get_state(slot::SlotId) -> StanzaType

Get the current Xmpp lifecycle state.
"""
function get_state(slot::SlotId)::StanzaType
    StanzaType(ccall((:xmpp_state, LIB), UInt8, (Cint,), slot))
end

"""
    can_transition(from::StanzaType, to::StanzaType) -> Bool

Check whether a Xmpp state transition is valid.
"""
function can_transition(from::StanzaType, to::StanzaType)::Bool
    ccall((:xmpp_can_transition, LIB), UInt8,
          (UInt8, UInt8), UInt8(from), UInt8(to)) == 0x01
end

end # module Xmpp
