# SPDX-License-Identifier: MPL-2.0
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# Julia bindings for the proven-netconf protocol (NETCONF (RFC 6241) server).
#
# Wraps the C-ABI functions from protocols/proven-netconf/ffi/zig/src/netconf.zig
# via ccall into libproven_netconf.so.

module Netconf

using ..ProvenServers: check_status, check_slot, SlotId

export NETCONF_PORT,
       NetconfOperation,
       Datastore,
       EditOperation,
       NetconfErrorType,
       ErrorSeverity,
       NetconfState,
       abi_version,
       create_context,
       destroy_context,
       get_state,
       can_transition

const LIB = "libproven_netconf"

# --------------------------------------------------------------------------
# Constants
# --------------------------------------------------------------------------

"""NETCONF_PORT: protocol constant."""
const NETCONF_PORT = UInt16(830)

# --------------------------------------------------------------------------
# Enumeration types matching Idris2 ABI
# --------------------------------------------------------------------------

"""NETCONF operations."""
@enum NetconfOperation::UInt8 begin
    OP_GET = 0
    OP_GET_CONFIG = 1
    OP_EDIT_CONFIG = 2
    OP_COPY_CONFIG = 3
    OP_DELETE_CONFIG = 4
    OP_LOCK = 5
    OP_UNLOCK = 6
    OP_CLOSE_SESSION = 7
    OP_KILL_SESSION = 8
    OP_COMMIT = 9
    OP_VALIDATE = 10
    OP_DISCARD_CHANGES = 11
end

"""NETCONF datastores."""
@enum Datastore::UInt8 begin
    DS_RUNNING = 0
    DS_STARTUP = 1
    DS_CANDIDATE = 2
end

"""NETCONF edit operations."""
@enum EditOperation::UInt8 begin
    EDIT_MERGE = 0
    EDIT_REPLACE = 1
    EDIT_CREATE = 2
    EDIT_DELETE = 3
    EDIT_REMOVE = 4
end

"""NETCONF error types."""
@enum NetconfErrorType::UInt8 begin
    ERR_TRANSPORT = 0
    ERR_RPC = 1
    ERR_PROTOCOL = 2
    ERR_APPLICATION = 3
end

"""NETCONF error severity."""
@enum ErrorSeverity::UInt8 begin
    SEV_ERROR = 0
    SEV_WARNING = 1
end

"""NETCONF session states."""
@enum NetconfState::UInt8 begin
    STATE_IDLE = 0
    STATE_CONNECTED = 1
    STATE_LOCKED = 2
    STATE_EDITING = 3
    STATE_CLOSING = 4
    STATE_TERMINATED = 5
end

# --------------------------------------------------------------------------
# ccall declarations
# --------------------------------------------------------------------------

"""Return the ABI version of the linked libproven_netconf."""
function abi_version()::UInt32
    ccall((:netconf_abi_version, LIB), UInt32, ())
end

"""
    create_context() -> SlotId

Create a new Netconf context. Throws on pool exhaustion.
"""
function create_context()::SlotId
    check_slot(ccall((:netconf_create_context, LIB), Cint, ()))
end

"""
    destroy_context(slot::SlotId)

Release the given Netconf context slot.
"""
function destroy_context(slot::SlotId)::Nothing
    ccall((:netconf_destroy_context, LIB), Cvoid, (Cint,), slot)
    nothing
end

"""
    get_state(slot::SlotId) -> NetconfState

Get the current Netconf lifecycle state.
"""
function get_state(slot::SlotId)::NetconfState
    NetconfState(ccall((:netconf_state, LIB), UInt8, (Cint,), slot))
end

"""
    can_transition(from::NetconfState, to::NetconfState) -> Bool

Check whether a Netconf state transition is valid.
"""
function can_transition(from::NetconfState, to::NetconfState)::Bool
    ccall((:netconf_can_transition, LIB), UInt8,
          (UInt8, UInt8), UInt8(from), UInt8(to)) == 0x01
end

end # module Netconf
