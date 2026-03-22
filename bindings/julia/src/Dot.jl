# SPDX-License-Identifier: PMPL-1.0-or-later
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# Julia bindings for the proven-dot protocol (DNS over TLS (RFC 7858)).
#
# Wraps the C-ABI functions from protocols/proven-dot/ffi/zig/src/dot.zig
# via ccall into libproven_dot.so.

module Dot

using ..ProvenServers: check_status, check_slot, SlotId

export SessionState, PaddingStrategy, ErrorReason, ServerState,
       abi_version, create_context, destroy_context, get_state, can_transition

const LIB = "libproven_dot"

# --------------------------------------------------------------------------
# Enumeration types matching Idris2 ABI
# --------------------------------------------------------------------------

"""DoT session lifecycle states.  Matches `SessionState` in `DotABI.Types`."""
@enum SessionState::UInt8 begin
    CONNECTING = 0
    HANDSHAKING = 1
    ESTABLISHED = 2
    CLOSING = 3
    CLOSED = 4
end


"""DoT padding strategies (RFC 7830).  Matches `PaddingStrategy` in `DotABI.Types`."""
@enum PaddingStrategy::UInt8 begin
    NO_PADDING = 0
    BLOCK_PADDING = 1
    RANDOM_PADDING = 2
end


"""DoT error reasons.  Matches `ErrorReason` in `DotABI.Types`."""
@enum ErrorReason::UInt8 begin
    HANDSHAKE_FAILED = 0
    CERTIFICATE_INVALID = 1
    TIMEOUT = 2
    UPSTREAM_ERROR = 3
end


"""DoT server lifecycle states.  Matches `ServerState` in `DotABI.Types`."""
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

"""Return the ABI version of the linked libproven_dot."""
function abi_version()::UInt32
    ccall((:dot_abi_version, LIB), UInt32, ())
end

"""
    create_context() -> SlotId

Create a new DNS over TLS (RFC 7858) context. Throws on pool exhaustion.
"""
function create_context()::SlotId
    check_slot(ccall((:dot_create_context, LIB), Cint, ()))
end

"""
    destroy_context(slot::SlotId)

Release the given DNS over TLS (RFC 7858) context slot.
"""
function destroy_context(slot::SlotId)::Nothing
    ccall((:dot_destroy_context, LIB), Cvoid, (Cint,), slot)
    nothing
end

"""
    get_state(slot::SlotId) -> ServerState

Get the current DNS over TLS (RFC 7858) lifecycle state.
"""
function get_state(slot::SlotId)::ServerState
    ServerState(ccall((:dot_state, LIB), UInt8, (Cint,), slot))
end

"""
    can_transition(from::ServerState, to::ServerState) -> Bool

Check whether a DNS over TLS (RFC 7858) state transition is valid.
"""
function can_transition(from::ServerState, to::ServerState)::Bool
    ccall((:dot_can_transition, LIB), UInt8,
          (UInt8, UInt8), UInt8(from), UInt8(to)) == 0x01
end

end # module Dot
