# SPDX-License-Identifier: MPL-2.0
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# Julia bindings for the proven-nfs protocol (NFS (Network File System, RFC 7530) server).
#
# Wraps the C-ABI functions from protocols/proven-nfs/ffi/zig/src/nfs.zig
# via ccall into libproven_nfs.so.

module Nfs

using ..ProvenServers: check_status, check_slot, SlotId

export NFS_PORT,
       NfsOperation,
       NfsFileType,
       NfsStatus,
       NfsState,
       abi_version,
       create_context,
       destroy_context,
       get_state,
       can_transition

const LIB = "libproven_nfs"

# --------------------------------------------------------------------------
# Constants
# --------------------------------------------------------------------------

"""NFS_PORT: protocol constant."""
const NFS_PORT = UInt16(2049)

# --------------------------------------------------------------------------
# Enumeration types matching Idris2 ABI
# --------------------------------------------------------------------------

"""NFSv4 operations."""
@enum NfsOperation::UInt8 begin
    OP_ACCESS = 0
    OP_CLOSE = 1
    OP_COMMIT = 2
    OP_CREATE = 3
    OP_GETATTR = 4
    OP_LINK = 5
    OP_LOCK = 6
    OP_LOOKUP = 7
    OP_OPEN = 8
    OP_READ = 9
    OP_READDIR = 10
    OP_REMOVE = 11
    OP_RENAME = 12
    OP_SETATTR = 13
    OP_WRITE = 14
end

"""NFS file types."""
@enum NfsFileType::UInt8 begin
    FT_REGULAR = 0
    FT_DIRECTORY = 1
    FT_BLOCK_DEVICE = 2
    FT_CHAR_DEVICE = 3
    FT_LINK = 4
    FT_SOCKET = 5
    FT_FIFO = 6
end

"""NFS status codes."""
@enum NfsStatus::UInt8 begin
    NFS_OK = 0
    NFS_PERM = 1
    NFS_NOENT = 2
    NFS_IO = 3
    NFS_NXIO = 4
    NFS_ACCESS = 5
    NFS_EXIST = 6
    NFS_NOTDIR = 7
    NFS_ISDIR = 8
    NFS_FBIG = 9
    NFS_NOSPC = 10
    NFS_ROFS = 11
    NFS_NOTEMPTY = 12
    NFS_STALE = 13
end

"""NFS server lifecycle states."""
@enum NfsState::UInt8 begin
    STATE_IDLE = 0
    STATE_MOUNTED = 1
    STATE_FILE_OPEN = 2
    STATE_LOCKED = 3
    STATE_BUSY = 4
    STATE_UNMOUNTING = 5
end

# --------------------------------------------------------------------------
# ccall declarations
# --------------------------------------------------------------------------

"""Return the ABI version of the linked libproven_nfs."""
function abi_version()::UInt32
    ccall((:nfs_abi_version, LIB), UInt32, ())
end

"""
    create_context() -> SlotId

Create a new Nfs context. Throws on pool exhaustion.
"""
function create_context()::SlotId
    check_slot(ccall((:nfs_create_context, LIB), Cint, ()))
end

"""
    destroy_context(slot::SlotId)

Release the given Nfs context slot.
"""
function destroy_context(slot::SlotId)::Nothing
    ccall((:nfs_destroy_context, LIB), Cvoid, (Cint,), slot)
    nothing
end

"""
    get_state(slot::SlotId) -> NfsState

Get the current Nfs lifecycle state.
"""
function get_state(slot::SlotId)::NfsState
    NfsState(ccall((:nfs_state, LIB), UInt8, (Cint,), slot))
end

"""
    can_transition(from::NfsState, to::NfsState) -> Bool

Check whether a Nfs state transition is valid.
"""
function can_transition(from::NfsState, to::NfsState)::Bool
    ccall((:nfs_can_transition, LIB), UInt8,
          (UInt8, UInt8), UInt8(from), UInt8(to)) == 0x01
end

end # module Nfs
