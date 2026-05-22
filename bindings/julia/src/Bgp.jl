# SPDX-License-Identifier: MPL-2.0
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# Julia bindings for the proven-bgp protocol (BGP (Border Gateway Protocol, RFC 4271)).
#
# Wraps the C-ABI functions from protocols/proven-bgp/ffi/zig/src/bgp.zig
# via ccall into libproven_bgp.so.

module Bgp

using ..ProvenServers: check_status, check_slot, SlotId

export BgpState, BgpEvent, MessageType, ErrorCode, Origin, AsPathSegmentType, PathAttrType,
       abi_version, create_context, destroy_context, get_state, can_transition

const LIB = "libproven_bgp"

# --------------------------------------------------------------------------
# Enumeration types matching Idris2 ABI
# --------------------------------------------------------------------------

"""BGP finite state machine states (RFC 4271 Section 8.2.2).  Matches `BGPState` in `BgpABI.Types`."""
@enum BgpState::UInt8 begin
    IDLE = 0
    CONNECT = 1
    ACTIVE = 2
    OPEN_SENT = 3
    OPEN_CONFIRM = 4
    ESTABLISHED = 5
end


"""BGP FSM events (RFC 4271 Section 8.1).  Matches `BGPEvent` in `BgpABI.Types`."""
@enum BgpEvent::UInt8 begin
    MANUAL_START = 0
    MANUAL_STOP = 1
    AUTOMATIC_START = 2
    CONNECT_RETRY_TIMER_EXPIRES = 3
    HOLD_TIMER_EXPIRES = 4
    KEEPALIVE_TIMER_EXPIRES = 5
    DELAY_OPEN_TIMER_EXPIRES = 6
    TCP_CONNECTION_VALID = 7
    TCP_CR_ACKED = 8
    TCP_CONNECTION_CONFIRMED = 9
    TCP_CONNECTION_FAILS = 10
    BGP_OPEN_RECEIVED = 11
    BGP_HEADER_ERR = 12
    BGP_OPEN_MSG_ERR = 13
    NOTIF_MSG_VER_ERR = 14
    NOTIF_MSG = 15
    KEEPALIVE_MSG = 16
    UPDATE_MSG = 17
    UPDATE_MSG_ERR = 18
end


"""BGP message types (RFC 4271 Section 4).  Matches `MessageType` in `BgpABI.Types`."""
@enum MessageType::UInt8 begin
    OPEN = 0
    UPDATE = 1
    NOTIFICATION = 2
    KEEPALIVE = 3
end


"""BGP NOTIFICATION error codes (RFC 4271 Section 4.5).  Matches `ErrorCode` in `BgpABI.Types`."""
@enum ErrorCode::UInt8 begin
    MESSAGE_HEADER_ERROR = 0
    OPEN_MESSAGE_ERROR = 1
    UPDATE_MESSAGE_ERROR = 2
    HOLD_TIMER_EXPIRED = 3
    FSM_ERROR = 4
    CEASE = 5
end


"""BGP ORIGIN path attribute values (RFC 4271 Section 4.3).  Matches `Origin` in `BgpABI.Types`."""
@enum Origin::UInt8 begin
    IGP = 0
    EGP = 1
    INCOMPLETE = 2
end


"""BGP AS_PATH segment types (RFC 4271 Section 4.3).  Matches `ASPathSegmentType` in `BgpABI.Types`."""
@enum AsPathSegmentType::UInt8 begin
    AS_SET = 0
    AS_SEQUENCE = 1
end


"""BGP path attribute types (RFC 4271 Section 5).  Matches `PathAttrType` in `BgpABI.Types`."""
@enum PathAttrType::UInt8 begin
    ORIGIN = 0
    AS_PATH = 1
    NEXT_HOP = 2
    MED = 3
    LOCAL_PREF = 4
    ATOMIC_AGGR = 5
    AGGREGATOR = 6
    UNKNOWN = 7
end

# --------------------------------------------------------------------------
# ccall declarations
# --------------------------------------------------------------------------

"""Return the ABI version of the linked libproven_bgp."""
function abi_version()::UInt32
    ccall((:bgp_abi_version, LIB), UInt32, ())
end

"""
    create_context() -> SlotId

Create a new BGP (Border Gateway Protocol, RFC 4271) context. Throws on pool exhaustion.
"""
function create_context()::SlotId
    check_slot(ccall((:bgp_create_context, LIB), Cint, ()))
end

"""
    destroy_context(slot::SlotId)

Release the given BGP (Border Gateway Protocol, RFC 4271) context slot.
"""
function destroy_context(slot::SlotId)::Nothing
    ccall((:bgp_destroy_context, LIB), Cvoid, (Cint,), slot)
    nothing
end

"""
    get_state(slot::SlotId) -> BgpState

Get the current BGP (Border Gateway Protocol, RFC 4271) lifecycle state.
"""
function get_state(slot::SlotId)::BgpState
    BgpState(ccall((:bgp_state, LIB), UInt8, (Cint,), slot))
end

"""
    can_transition(from::BgpState, to::BgpState) -> Bool

Check whether a BGP (Border Gateway Protocol, RFC 4271) state transition is valid.
"""
function can_transition(from::BgpState, to::BgpState)::Bool
    ccall((:bgp_can_transition, LIB), UInt8,
          (UInt8, UInt8), UInt8(from), UInt8(to)) == 0x01
end

end # module Bgp
