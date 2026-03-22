# SPDX-License-Identifier: PMPL-1.0-or-later
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# Julia bindings for the proven-doq protocol (DNS over QUIC (RFC 9250)).
#
# Wraps the C-ABI functions from protocols/proven-doq/ffi/zig/src/doq.zig
# via ccall into libproven_doq.so.

module Doq

using ..ProvenServers: check_status, check_slot, SlotId

export StreamType, ErrorCode, SessionState, ServerState,
       abi_version, create_context, destroy_context, get_state, can_transition

const LIB = "libproven_doq"

# --------------------------------------------------------------------------
# Enumeration types matching Idris2 ABI
# --------------------------------------------------------------------------

"""QUIC stream types.  Matches `StreamType` in `DoqABI.Types`."""
@enum StreamType::UInt8 begin
    UNIDIRECTIONAL = 0
    BIDIRECTIONAL = 1
end


"""DoQ error codes.  Matches `ErrorCode` in `DoqABI.Types`."""
@enum ErrorCode::UInt8 begin
    NO_ERROR = 0
    INTERNAL_ERROR = 1
    EXCESSIVE_LOAD = 2
    PROTOCOL_ERROR = 3
end


"""DoQ session lifecycle states.  Matches `SessionState` in `DoqABI.Types`."""
@enum SessionState::UInt8 begin
    INITIAL = 0
    HANDSHAKING = 1
    READY = 2
    DRAINING = 3
    CLOSED = 4
end


"""DoQ server lifecycle states.  Matches `ServerState` in `DoqABI.Types`."""
@enum ServerState::UInt8 begin
    IDLE = 0
    BOUND = 1
    LISTENING = 2
    PROCESSING = 3
    SHUTDOWN = 4
end

# --------------------------------------------------------------------------
# ccall declarations
# --------------------------------------------------------------------------

"""Return the ABI version of the linked libproven_doq."""
function abi_version()::UInt32
    ccall((:doq_abi_version, LIB), UInt32, ())
end

"""
    create_context() -> SlotId

Create a new DNS over QUIC (RFC 9250) context. Throws on pool exhaustion.
"""
function create_context()::SlotId
    check_slot(ccall((:doq_create_context, LIB), Cint, ()))
end

"""
    destroy_context(slot::SlotId)

Release the given DNS over QUIC (RFC 9250) context slot.
"""
function destroy_context(slot::SlotId)::Nothing
    ccall((:doq_destroy_context, LIB), Cvoid, (Cint,), slot)
    nothing
end

"""
    get_state(slot::SlotId) -> ServerState

Get the current DNS over QUIC (RFC 9250) lifecycle state.
"""
function get_state(slot::SlotId)::ServerState
    ServerState(ccall((:doq_state, LIB), UInt8, (Cint,), slot))
end

"""
    can_transition(from::ServerState, to::ServerState) -> Bool

Check whether a DNS over QUIC (RFC 9250) state transition is valid.
"""
function can_transition(from::ServerState, to::ServerState)::Bool
    ccall((:doq_can_transition, LIB), UInt8,
          (UInt8, UInt8), UInt8(from), UInt8(to)) == 0x01
end

end # module Doq
