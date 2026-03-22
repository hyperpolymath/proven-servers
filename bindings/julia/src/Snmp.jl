# SPDX-License-Identifier: PMPL-1.0-or-later
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# Julia bindings for the proven-snmp protocol (SNMP (RFC 3411-3418) agent).
#
# Wraps the C-ABI functions from protocols/proven-snmp/ffi/zig/src/snmp.zig
# via ccall into libproven_snmp.so.

module Snmp

using ..ProvenServers: check_status, check_slot, SlotId

export SNMP_PORT,
       SNMP_TRAP_PORT,
       SnmpVersion,
       PduType,
       SnmpErrorStatus,
       abi_version,
       create_context,
       destroy_context,
       get_state,
       can_transition

const LIB = "libproven_snmp"

# --------------------------------------------------------------------------
# Constants
# --------------------------------------------------------------------------

"""SNMP_PORT: protocol constant."""
const SNMP_PORT = UInt16(161)

"""SNMP_TRAP_PORT: protocol constant."""
const SNMP_TRAP_PORT = UInt16(162)

# --------------------------------------------------------------------------
# Enumeration types matching Idris2 ABI
# --------------------------------------------------------------------------

"""SNMP protocol versions."""
@enum SnmpVersion::UInt8 begin
    SNMP_V1 = 0
    SNMP_V2C = 1
    SNMP_V3 = 2
end

"""SNMP PDU types."""
@enum PduType::UInt8 begin
    PDU_GET_REQUEST = 0
    PDU_GET_NEXT_REQUEST = 1
    PDU_GET_RESPONSE = 2
    PDU_SET_REQUEST = 3
    PDU_GET_BULK_REQUEST = 4
    PDU_INFORM_REQUEST = 5
    PDU_SNMPV2_TRAP = 6
end

"""SNMP error status codes."""
@enum SnmpErrorStatus::UInt8 begin
    ERR_NO_ERROR = 0
    ERR_TOO_BIG = 1
    ERR_NO_SUCH_NAME = 2
    ERR_BAD_VALUE = 3
    ERR_READ_ONLY = 4
    ERR_GEN_ERR = 5
    ERR_NO_ACCESS = 6
    ERR_WRONG_TYPE = 7
    ERR_WRONG_LENGTH = 8
    ERR_WRONG_VALUE = 9
    ERR_NO_CREATION = 10
    ERR_INCONSISTENT_VALUE = 11
    ERR_RESOURCE_UNAVAILABLE = 12
    ERR_COMMIT_FAILED = 13
    ERR_UNDO_FAILED = 14
    ERR_AUTHORIZATION_ERROR = 15
end

# --------------------------------------------------------------------------
# ccall declarations
# --------------------------------------------------------------------------

"""Return the ABI version of the linked libproven_snmp."""
function abi_version()::UInt32
    ccall((:snmp_abi_version, LIB), UInt32, ())
end

"""
    create_context() -> SlotId

Create a new Snmp context. Throws on pool exhaustion.
"""
function create_context()::SlotId
    check_slot(ccall((:snmp_create_context, LIB), Cint, ()))
end

"""
    destroy_context(slot::SlotId)

Release the given Snmp context slot.
"""
function destroy_context(slot::SlotId)::Nothing
    ccall((:snmp_destroy_context, LIB), Cvoid, (Cint,), slot)
    nothing
end

"""
    get_state(slot::SlotId) -> SnmpErrorStatus

Get the current Snmp lifecycle state.
"""
function get_state(slot::SlotId)::SnmpErrorStatus
    SnmpErrorStatus(ccall((:snmp_state, LIB), UInt8, (Cint,), slot))
end

"""
    can_transition(from::SnmpErrorStatus, to::SnmpErrorStatus) -> Bool

Check whether a Snmp state transition is valid.
"""
function can_transition(from::SnmpErrorStatus, to::SnmpErrorStatus)::Bool
    ccall((:snmp_can_transition, LIB), UInt8,
          (UInt8, UInt8), UInt8(from), UInt8(to)) == 0x01
end

end # module Snmp
