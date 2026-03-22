# SPDX-License-Identifier: PMPL-1.0-or-later
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# Julia bindings for the proven-smb protocol (SMB (Server Message Block) server).
#
# Wraps the C-ABI functions from protocols/proven-smb/ffi/zig/src/smb.zig
# via ccall into libproven_smb.so.

module Smb

using ..ProvenServers: check_status, check_slot, SlotId

export SMB_PORT,
       SmbCommand,
       SmbDialect,
       ShareType,
       SmbSessionState,
       abi_version,
       create_context,
       destroy_context,
       get_state,
       can_transition

const LIB = "libproven_smb"

# --------------------------------------------------------------------------
# Constants
# --------------------------------------------------------------------------

"""SMB_PORT: protocol constant."""
const SMB_PORT = UInt16(445)

# --------------------------------------------------------------------------
# Enumeration types matching Idris2 ABI
# --------------------------------------------------------------------------

"""SMB2/3 commands."""
@enum SmbCommand::UInt8 begin
    CMD_NEGOTIATE = 0
    CMD_SESSION_SETUP = 1
    CMD_LOGOFF = 2
    CMD_TREE_CONNECT = 3
    CMD_TREE_DISCONNECT = 4
    CMD_CREATE = 5
    CMD_CLOSE = 6
    CMD_READ = 7
    CMD_WRITE = 8
    CMD_LOCK = 9
    CMD_IOCTL = 10
    CMD_CANCEL = 11
    CMD_QUERY_DIRECTORY = 12
    CMD_CHANGE_NOTIFY = 13
    CMD_QUERY_INFO = 14
    CMD_SET_INFO = 15
end

"""SMB protocol dialects."""
@enum SmbDialect::UInt8 begin
    DIALECT_SMB2_0_2 = 0
    DIALECT_SMB2_1 = 1
    DIALECT_SMB3_0 = 2
    DIALECT_SMB3_0_2 = 3
    DIALECT_SMB3_1_1 = 4
end

"""SMB share types."""
@enum ShareType::UInt8 begin
    SHARE_DISK = 0
    SHARE_PIPE = 1
    SHARE_PRINT = 2
end

"""SMB session lifecycle states."""
@enum SmbSessionState::UInt8 begin
    STATE_IDLE = 0
    STATE_NEGOTIATED = 1
    STATE_AUTHENTICATED = 2
    STATE_TREE_CONNECTED = 3
    STATE_FILE_OPEN = 4
    STATE_DISCONNECTING = 5
end

# --------------------------------------------------------------------------
# ccall declarations
# --------------------------------------------------------------------------

"""Return the ABI version of the linked libproven_smb."""
function abi_version()::UInt32
    ccall((:smb_abi_version, LIB), UInt32, ())
end

"""
    create_context() -> SlotId

Create a new Smb context. Throws on pool exhaustion.
"""
function create_context()::SlotId
    check_slot(ccall((:smb_create_context, LIB), Cint, ()))
end

"""
    destroy_context(slot::SlotId)

Release the given Smb context slot.
"""
function destroy_context(slot::SlotId)::Nothing
    ccall((:smb_destroy_context, LIB), Cvoid, (Cint,), slot)
    nothing
end

"""
    get_state(slot::SlotId) -> SmbSessionState

Get the current Smb lifecycle state.
"""
function get_state(slot::SlotId)::SmbSessionState
    SmbSessionState(ccall((:smb_state, LIB), UInt8, (Cint,), slot))
end

"""
    can_transition(from::SmbSessionState, to::SmbSessionState) -> Bool

Check whether a Smb state transition is valid.
"""
function can_transition(from::SmbSessionState, to::SmbSessionState)::Bool
    ccall((:smb_can_transition, LIB), UInt8,
          (UInt8, UInt8), UInt8(from), UInt8(to)) == 0x01
end

end # module Smb
