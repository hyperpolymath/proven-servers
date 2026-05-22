# SPDX-License-Identifier: MPL-2.0
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# Julia bindings for the proven-fileserver protocol (file server).
#
# Wraps the C-ABI functions from protocols/proven-fileserver/ffi/zig/src/fileserver.zig
# via ccall into libproven_fileserver.so.

module Fileserver

using ..ProvenServers: check_status, check_slot, SlotId

export FileOperation, FileType, FilePermission, LockType, FileErrorCode, SessionState,
       abi_version, create_context, destroy_context, get_state, can_transition

const LIB = "libproven_fileserver"

# --------------------------------------------------------------------------
# Enumeration types matching Idris2 ABI
# --------------------------------------------------------------------------

"""File server operations.  Matches `FileOperation` in `FileserverABI.Types`."""
@enum FileOperation::UInt8 begin
    READ = 0
    WRITE = 1
    CREATE = 2
    DELETE = 3
    RENAME = 4
    LIST = 5
    STAT = 6
    LOCK = 7
    UNLOCK = 8
    WATCH = 9
end


"""File types.  Matches `FileType` in `FileserverABI.Types`."""
@enum FileType::UInt8 begin
    REGULAR = 0
    DIRECTORY = 1
    SYMLINK = 2
    BLOCK_DEVICE = 3
    CHAR_DEVICE = 4
    FIFO = 5
    SOCKET = 6
end


"""POSIX file permissions.  Matches `FilePermission` in `FileserverABI.Types`."""
@enum FilePermission::UInt8 begin
    OWNER_READ = 0
    OWNER_WRITE = 1
    OWNER_EXECUTE = 2
    GROUP_READ = 3
    GROUP_WRITE = 4
    GROUP_EXECUTE = 5
    OTHER_READ = 6
    OTHER_WRITE = 7
    OTHER_EXECUTE = 8
end


"""File lock types.  Matches `LockType` in `FileserverABI.Types`."""
@enum LockType::UInt8 begin
    SHARED = 0
    EXCLUSIVE = 1
    ADVISORY = 2
    MANDATORY = 3
end


"""File server error codes.  Matches `FileErrorCode` in `FileserverABI.Types`."""
@enum FileErrorCode::UInt8 begin
    NOT_FOUND = 0
    PERMISSION_DENIED = 1
    ALREADY_EXISTS = 2
    NOT_EMPTY = 3
    IS_DIRECTORY = 4
    NOT_DIRECTORY = 5
    NO_SPACE = 6
    READ_ONLY = 7
    LOCKED = 8
    IO_ERROR = 9
end


"""File server session states.  Matches `SessionState` in `FileserverABI.Types`."""
@enum SessionState::UInt8 begin
    IDLE = 0
    CONNECTED = 1
    OPERATING = 2
    FS_LOCKED = 3
    DISCONNECTING = 4
end

# --------------------------------------------------------------------------
# ccall declarations
# --------------------------------------------------------------------------

"""Return the ABI version of the linked libproven_fileserver."""
function abi_version()::UInt32
    ccall((:fileserver_abi_version, LIB), UInt32, ())
end

"""
    create_context() -> SlotId

Create a new file server context. Throws on pool exhaustion.
"""
function create_context()::SlotId
    check_slot(ccall((:fileserver_create_context, LIB), Cint, ()))
end

"""
    destroy_context(slot::SlotId)

Release the given file server context slot.
"""
function destroy_context(slot::SlotId)::Nothing
    ccall((:fileserver_destroy_context, LIB), Cvoid, (Cint,), slot)
    nothing
end

"""
    get_state(slot::SlotId) -> SessionState

Get the current file server lifecycle state.
"""
function get_state(slot::SlotId)::SessionState
    SessionState(ccall((:fileserver_state, LIB), UInt8, (Cint,), slot))
end

"""
    can_transition(from::SessionState, to::SessionState) -> Bool

Check whether a file server state transition is valid.
"""
function can_transition(from::SessionState, to::SessionState)::Bool
    ccall((:fileserver_can_transition, LIB), UInt8,
          (UInt8, UInt8), UInt8(from), UInt8(to)) == 0x01
end

end # module Fileserver
