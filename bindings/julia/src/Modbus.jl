# SPDX-License-Identifier: PMPL-1.0-or-later
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# Julia bindings for the proven-modbus protocol (Modbus TCP gateway).
#
# Wraps the C-ABI functions from protocols/proven-modbus/ffi/zig/src/modbus.zig
# via ccall into libproven_modbus.so.

module Modbus

using ..ProvenServers: check_status, check_slot, SlotId

export MODBUS_TCP_PORT,
       FunctionCode,
       ExceptionCode,
       DeviceRole,
       GatewayState,
       abi_version,
       create_context,
       destroy_context,
       get_state,
       can_transition

const LIB = "libproven_modbus"

# --------------------------------------------------------------------------
# Constants
# --------------------------------------------------------------------------

"""MODBUS_TCP_PORT: protocol constant."""
const MODBUS_TCP_PORT = UInt16(502)

# --------------------------------------------------------------------------
# Enumeration types matching Idris2 ABI
# --------------------------------------------------------------------------

"""Modbus function codes."""
@enum FunctionCode::UInt8 begin
    FC_READ_COILS = 0
    FC_READ_DISCRETE_INPUTS = 1
    FC_READ_HOLDING_REGISTERS = 2
    FC_READ_INPUT_REGISTERS = 3
    FC_WRITE_SINGLE_COIL = 4
    FC_WRITE_SINGLE_REGISTER = 5
    FC_WRITE_MULTIPLE_COILS = 6
    FC_WRITE_MULTIPLE_REGISTERS = 7
    FC_READ_WRITE_MULTIPLE_REGISTERS = 8
    FC_MASK_WRITE_REGISTER = 9
end

"""Modbus exception codes."""
@enum ExceptionCode::UInt8 begin
    EX_ILLEGAL_FUNCTION = 0
    EX_ILLEGAL_DATA_ADDRESS = 1
    EX_ILLEGAL_DATA_VALUE = 2
    EX_SLAVE_DEVICE_FAILURE = 3
    EX_ACKNOWLEDGE = 4
    EX_SLAVE_DEVICE_BUSY = 5
    EX_MEMORY_PARITY_ERROR = 6
    EX_GATEWAY_PATH_UNAVAILABLE = 7
    EX_GATEWAY_TARGET_FAILED = 8
end

"""Modbus device role."""
@enum DeviceRole::UInt8 begin
    ROLE_MASTER = 0
    ROLE_SLAVE = 1
end

"""Modbus TCP gateway lifecycle states."""
@enum GatewayState::UInt8 begin
    STATE_IDLE = 0
    STATE_LISTENING = 1
    STATE_PROCESSING = 2
    STATE_ERROR = 3
    STATE_STOPPING = 4
end

# --------------------------------------------------------------------------
# ccall declarations
# --------------------------------------------------------------------------

"""Return the ABI version of the linked libproven_modbus."""
function abi_version()::UInt32
    ccall((:modbus_abi_version, LIB), UInt32, ())
end

"""
    create_context() -> SlotId

Create a new Modbus context. Throws on pool exhaustion.
"""
function create_context()::SlotId
    check_slot(ccall((:modbus_create_context, LIB), Cint, ()))
end

"""
    destroy_context(slot::SlotId)

Release the given Modbus context slot.
"""
function destroy_context(slot::SlotId)::Nothing
    ccall((:modbus_destroy_context, LIB), Cvoid, (Cint,), slot)
    nothing
end

"""
    get_state(slot::SlotId) -> GatewayState

Get the current Modbus lifecycle state.
"""
function get_state(slot::SlotId)::GatewayState
    GatewayState(ccall((:modbus_state, LIB), UInt8, (Cint,), slot))
end

"""
    can_transition(from::GatewayState, to::GatewayState) -> Bool

Check whether a Modbus state transition is valid.
"""
function can_transition(from::GatewayState, to::GatewayState)::Bool
    ccall((:modbus_can_transition, LIB), UInt8,
          (UInt8, UInt8), UInt8(from), UInt8(to)) == 0x01
end

end # module Modbus
