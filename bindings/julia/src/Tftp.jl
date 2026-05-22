# SPDX-License-Identifier: MPL-2.0
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# Julia bindings for the proven-tftp protocol (TFTP (RFC 1350) server).
#
# Wraps the C-ABI functions from protocols/proven-tftp/ffi/zig/src/tftp.zig
# via ccall into libproven_tftp.so.

module Tftp

using ..ProvenServers: check_status, check_slot, SlotId

export TFTP_PORT,
       TFTP_BLOCK_SIZE,
       TftpOpcode,
       TransferMode,
       TftpError,
       TransferState,
       abi_version,
       create_context,
       destroy_context,
       get_state,
       can_transition

const LIB = "libproven_tftp"

# --------------------------------------------------------------------------
# Constants
# --------------------------------------------------------------------------

"""TFTP_PORT: protocol constant."""
const TFTP_PORT = UInt16(69)

"""TFTP_BLOCK_SIZE: protocol constant."""
const TFTP_BLOCK_SIZE = UInt16(512)

# --------------------------------------------------------------------------
# Enumeration types matching Idris2 ABI
# --------------------------------------------------------------------------

"""TFTP opcodes."""
@enum TftpOpcode::UInt8 begin
    OP_RRQ = 0
    OP_WRQ = 1
    OP_DATA = 2
    OP_ACK = 3
    OP_ERROR = 4
end

"""TFTP transfer modes."""
@enum TransferMode::UInt8 begin
    MODE_NETASCII = 0
    MODE_OCTET = 1
    MODE_MAIL = 2
end

"""TFTP error codes."""
@enum TftpError::UInt8 begin
    ERR_NOT_DEFINED = 0
    ERR_FILE_NOT_FOUND = 1
    ERR_ACCESS_VIOLATION = 2
    ERR_DISK_FULL = 3
    ERR_ILLEGAL_OPERATION = 4
    ERR_UNKNOWN_TID = 5
    ERR_FILE_EXISTS = 6
    ERR_NO_SUCH_USER = 7
end

"""TFTP transfer states."""
@enum TransferState::UInt8 begin
    STATE_IDLE = 0
    STATE_READING = 1
    STATE_WRITING = 2
    STATE_IN_ERROR = 3
    STATE_COMPLETE = 4
end

# --------------------------------------------------------------------------
# ccall declarations
# --------------------------------------------------------------------------

"""Return the ABI version of the linked libproven_tftp."""
function abi_version()::UInt32
    ccall((:tftp_abi_version, LIB), UInt32, ())
end

"""
    create_context() -> SlotId

Create a new Tftp context. Throws on pool exhaustion.
"""
function create_context()::SlotId
    check_slot(ccall((:tftp_create_context, LIB), Cint, ()))
end

"""
    destroy_context(slot::SlotId)

Release the given Tftp context slot.
"""
function destroy_context(slot::SlotId)::Nothing
    ccall((:tftp_destroy_context, LIB), Cvoid, (Cint,), slot)
    nothing
end

"""
    get_state(slot::SlotId) -> TransferState

Get the current Tftp lifecycle state.
"""
function get_state(slot::SlotId)::TransferState
    TransferState(ccall((:tftp_state, LIB), UInt8, (Cint,), slot))
end

"""
    can_transition(from::TransferState, to::TransferState) -> Bool

Check whether a Tftp state transition is valid.
"""
function can_transition(from::TransferState, to::TransferState)::Bool
    ccall((:tftp_can_transition, LIB), UInt8,
          (UInt8, UInt8), UInt8(from), UInt8(to)) == 0x01
end

end # module Tftp
