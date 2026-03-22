# SPDX-License-Identifier: PMPL-1.0-or-later
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# Julia bindings for the proven-git protocol (Git protocol).
#
# Wraps the C-ABI functions from protocols/proven-git/ffi/zig/src/git.zig
# via ccall into libproven_git.so.

module Git

using ..ProvenServers: check_status, check_slot, SlotId

export Command, PacketType, RefType, Capability, HookResult, ServerState,
       abi_version, create_context, destroy_context, get_state, can_transition

const LIB = "libproven_git"

# --------------------------------------------------------------------------
# Enumeration types matching Idris2 ABI
# --------------------------------------------------------------------------

"""Git protocol commands.  Matches `Command` in `GitABI.Types`."""
@enum Command::UInt8 begin
    UPLOAD_PACK = 0
    RECEIVE_PACK = 1
    UPLOAD_ARCHIVE = 2
end


"""Git protocol packet types.  Matches `PacketType` in `GitABI.Types`."""
@enum PacketType::UInt8 begin
    FLUSH = 0
    DELIMITER = 1
    RESPONSE_END = 2
    DATA = 3
    PKT_ERROR = 4
    SIDEBAND_DATA = 5
    SIDEBAND_PROGRESS = 6
    SIDEBAND_ERROR = 7
end


"""Git reference types.  Matches `RefType` in `GitABI.Types`."""
@enum RefType::UInt8 begin
    BRANCH = 0
    TAG = 1
    HEAD = 2
    REMOTE = 3
    GIT_NOTE = 4
end


"""Git protocol capabilities.  Matches `Capability` in `GitABI.Types`."""
@enum Capability::UInt8 begin
    MULTI_ACK = 0
    THIN_PACK = 1
    SIDE_BAND64K = 2
    OFS_DELTA = 3
    SHALLOW = 4
    DEEPEN_SINCE = 5
    DEEPEN_NOT = 6
    FILTER_SPEC = 7
    OBJECT_FORMAT = 8
end


"""Git hook results.  Matches `HookResult` in `GitABI.Types`."""
@enum HookResult::UInt8 begin
    ACCEPT = 0
    REJECT = 1
end


"""Git server states.  Matches `ServerState` in `GitABI.Types`."""
@enum ServerState::UInt8 begin
    IDLE = 0
    DISCOVERY = 1
    NEGOTIATING = 2
    TRANSFER = 3
    SHUTDOWN = 4
end

# --------------------------------------------------------------------------
# ccall declarations
# --------------------------------------------------------------------------

"""Return the ABI version of the linked libproven_git."""
function abi_version()::UInt32
    ccall((:git_abi_version, LIB), UInt32, ())
end

"""
    create_context() -> SlotId

Create a new Git protocol context. Throws on pool exhaustion.
"""
function create_context()::SlotId
    check_slot(ccall((:git_create_context, LIB), Cint, ()))
end

"""
    destroy_context(slot::SlotId)

Release the given Git protocol context slot.
"""
function destroy_context(slot::SlotId)::Nothing
    ccall((:git_destroy_context, LIB), Cvoid, (Cint,), slot)
    nothing
end

"""
    get_state(slot::SlotId) -> ServerState

Get the current Git protocol lifecycle state.
"""
function get_state(slot::SlotId)::ServerState
    ServerState(ccall((:git_state, LIB), UInt8, (Cint,), slot))
end

"""
    can_transition(from::ServerState, to::ServerState) -> Bool

Check whether a Git protocol state transition is valid.
"""
function can_transition(from::ServerState, to::ServerState)::Bool
    ccall((:git_can_transition, LIB), UInt8,
          (UInt8, UInt8), UInt8(from), UInt8(to)) == 0x01
end

end # module Git
