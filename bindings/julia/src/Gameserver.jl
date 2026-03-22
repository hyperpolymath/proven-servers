# SPDX-License-Identifier: PMPL-1.0-or-later
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# Julia bindings for the proven-gameserver protocol (game server).
#
# Wraps the C-ABI functions from protocols/proven-gameserver/ffi/zig/src/gameserver.zig
# via ccall into libproven_gameserver.so.

module Gameserver

using ..ProvenServers: check_status, check_slot, SlotId

export SessionType, PlayerState, MatchState,
       abi_version, create_context, destroy_context, get_state, can_transition

const LIB = "libproven_gameserver"

# --------------------------------------------------------------------------
# Enumeration types matching Idris2 ABI
# --------------------------------------------------------------------------

"""Game session types.  Matches `SessionType` in `GameserverABI.Types`."""
@enum SessionType::UInt8 begin
    LOBBY = 0
    MATCH = 1
    PRACTICE = 2
    SPECTATOR = 3
    TOURNAMENT = 4
end


"""Game player states.  Matches `PlayerState` in `GameserverABI.Types`."""
@enum PlayerState::UInt8 begin
    IDLE = 0
    QUEUING = 1
    LOADING = 2
    PLAYING = 3
    SPECTATING = 4
    DISCONNECTED = 5
end


"""Game match states.  Matches `MatchState` in `GameserverABI.Types`."""
@enum MatchState::UInt8 begin
    WAITING = 0
    STARTING = 1
    IN_PROGRESS = 2
    PAUSED = 3
    ENDING = 4
    COMPLETE = 5
end

# --------------------------------------------------------------------------
# ccall declarations
# --------------------------------------------------------------------------

"""Return the ABI version of the linked libproven_gameserver."""
function abi_version()::UInt32
    ccall((:gameserver_abi_version, LIB), UInt32, ())
end

"""
    create_context() -> SlotId

Create a new game server context. Throws on pool exhaustion.
"""
function create_context()::SlotId
    check_slot(ccall((:gameserver_create_context, LIB), Cint, ()))
end

"""
    destroy_context(slot::SlotId)

Release the given game server context slot.
"""
function destroy_context(slot::SlotId)::Nothing
    ccall((:gameserver_destroy_context, LIB), Cvoid, (Cint,), slot)
    nothing
end

"""
    get_state(slot::SlotId) -> MatchState

Get the current game server lifecycle state.
"""
function get_state(slot::SlotId)::MatchState
    MatchState(ccall((:gameserver_state, LIB), UInt8, (Cint,), slot))
end

"""
    can_transition(from::MatchState, to::MatchState) -> Bool

Check whether a game server state transition is valid.
"""
function can_transition(from::MatchState, to::MatchState)::Bool
    ccall((:gameserver_can_transition, LIB), UInt8,
          (UInt8, UInt8), UInt8(from), UInt8(to)) == 0x01
end

end # module Gameserver
