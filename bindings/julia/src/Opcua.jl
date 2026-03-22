# SPDX-License-Identifier: PMPL-1.0-or-later
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# Julia bindings for the proven-opcua protocol (OPC UA (OPC Unified Architecture) server).
#
# Wraps the C-ABI functions from protocols/proven-opcua/ffi/zig/src/opcua.zig
# via ccall into libproven_opcua.so.

module Opcua

using ..ProvenServers: check_status, check_slot, SlotId

export OPCUA_PORT,
       OPCUA_TLS_PORT,
       OpcuaServiceType,
       NodeClass,
       OpcuaStatusCode,
       SecurityMode,
       OpcuaSessionState,
       abi_version,
       create_context,
       destroy_context,
       get_state,
       can_transition

const LIB = "libproven_opcua"

# --------------------------------------------------------------------------
# Constants
# --------------------------------------------------------------------------

"""OPCUA_PORT: protocol constant."""
const OPCUA_PORT = UInt16(4840)

"""OPCUA_TLS_PORT: protocol constant."""
const OPCUA_TLS_PORT = UInt16(4843)

# --------------------------------------------------------------------------
# Enumeration types matching Idris2 ABI
# --------------------------------------------------------------------------

"""OPC UA service types."""
@enum OpcuaServiceType::UInt8 begin
    SVC_READ = 0
    SVC_WRITE = 1
    SVC_BROWSE = 2
    SVC_SUBSCRIBE = 3
    SVC_PUBLISH = 4
    SVC_CALL = 5
    SVC_CREATE_SESSION = 6
    SVC_ACTIVATE_SESSION = 7
    SVC_CLOSE_SESSION = 8
    SVC_CREATE_SUBSCRIPTION = 9
    SVC_DELETE_SUBSCRIPTION = 10
end

"""OPC UA node classes."""
@enum NodeClass::UInt8 begin
    NC_OBJECT = 0
    NC_VARIABLE = 1
    NC_METHOD = 2
    NC_OBJECT_TYPE = 3
    NC_VARIABLE_TYPE = 4
    NC_REFERENCE_TYPE = 5
    NC_DATA_TYPE = 6
    NC_VIEW = 7
end

"""OPC UA status codes."""
@enum OpcuaStatusCode::UInt8 begin
    SC_GOOD = 0
    SC_UNCERTAIN = 1
    SC_BAD = 2
    SC_BAD_NODE_ID_UNKNOWN = 3
    SC_BAD_ATTRIBUTE_ID_INVALID = 4
    SC_BAD_NOT_READABLE = 5
    SC_BAD_NOT_WRITABLE = 6
    SC_BAD_OUT_OF_RANGE = 7
    SC_BAD_TYPE_MISMATCH = 8
    SC_BAD_SESSION_ID_INVALID = 9
    SC_BAD_SUBSCRIPTION_ID_INVALID = 10
    SC_BAD_TIMEOUT = 11
end

"""OPC UA message security modes."""
@enum SecurityMode::UInt8 begin
    SEC_NONE = 0
    SEC_SIGN = 1
    SEC_SIGN_AND_ENCRYPT = 2
end

"""OPC UA session lifecycle states."""
@enum OpcuaSessionState::UInt8 begin
    STATE_IDLE = 0
    STATE_CONNECTED = 1
    STATE_CREATED = 2
    STATE_ACTIVATED = 3
    STATE_MONITORING = 4
    STATE_CLOSING = 5
end

# --------------------------------------------------------------------------
# ccall declarations
# --------------------------------------------------------------------------

"""Return the ABI version of the linked libproven_opcua."""
function abi_version()::UInt32
    ccall((:opcua_abi_version, LIB), UInt32, ())
end

"""
    create_context() -> SlotId

Create a new Opcua context. Throws on pool exhaustion.
"""
function create_context()::SlotId
    check_slot(ccall((:opcua_create_context, LIB), Cint, ()))
end

"""
    destroy_context(slot::SlotId)

Release the given Opcua context slot.
"""
function destroy_context(slot::SlotId)::Nothing
    ccall((:opcua_destroy_context, LIB), Cvoid, (Cint,), slot)
    nothing
end

"""
    get_state(slot::SlotId) -> OpcuaSessionState

Get the current Opcua lifecycle state.
"""
function get_state(slot::SlotId)::OpcuaSessionState
    OpcuaSessionState(ccall((:opcua_state, LIB), UInt8, (Cint,), slot))
end

"""
    can_transition(from::OpcuaSessionState, to::OpcuaSessionState) -> Bool

Check whether a Opcua state transition is valid.
"""
function can_transition(from::OpcuaSessionState, to::OpcuaSessionState)::Bool
    ccall((:opcua_can_transition, LIB), UInt8,
          (UInt8, UInt8), UInt8(from), UInt8(to)) == 0x01
end

end # module Opcua
