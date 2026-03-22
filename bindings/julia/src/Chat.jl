# SPDX-License-Identifier: PMPL-1.0-or-later
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# Julia bindings for the proven-chat protocol (real-time chat server).
#
# Wraps the C-ABI functions from protocols/proven-chat/ffi/zig/src/chat.zig
# via ccall into libproven_chat.so.

module Chat

using ..ProvenServers: check_status, check_slot, SlotId

export MessageType, PresenceStatus, RoomType, Permission, Event,
       abi_version, create_context, destroy_context, get_state, can_transition

const LIB = "libproven_chat"

# --------------------------------------------------------------------------
# Enumeration types matching Idris2 ABI
# --------------------------------------------------------------------------

"""Chat message types.  Matches `MessageType` in `ChatABI.Types`."""
@enum MessageType::UInt8 begin
    TEXT = 0
    IMAGE = 1
    FILE = 2
    SYSTEM = 3
    REACTION = 4
    EDIT = 5
    DELETE = 6
    REPLY = 7
    THREAD = 8
end


"""User presence statuses.  Matches `PresenceStatus` in `ChatABI.Types`."""
@enum PresenceStatus::UInt8 begin
    ONLINE = 0
    AWAY = 1
    DND = 2
    INVISIBLE = 3
    OFFLINE = 4
end


"""Chat room types.  Matches `RoomType` in `ChatABI.Types`."""
@enum RoomType::UInt8 begin
    DIRECT = 0
    GROUP = 1
    CHANNEL = 2
    BROADCAST = 3
end


"""Chat permissions.  Matches `Permission` in `ChatABI.Types`."""
@enum Permission::UInt8 begin
    READ = 0
    WRITE = 1
    ADMIN = 2
    INVITE = 3
    KICK = 4
    BAN = 5
    PIN = 6
    DELETE_OTHERS = 7
end


"""Chat events.  Matches `Event` in `ChatABI.Types`."""
@enum Event::UInt8 begin
    MESSAGE_SENT = 0
    MESSAGE_DELIVERED = 1
    MESSAGE_READ = 2
    USER_JOINED = 3
    USER_LEFT = 4
    TYPING = 5
    ROOM_CREATED = 6
end

# --------------------------------------------------------------------------
# ccall declarations
# --------------------------------------------------------------------------

"""Return the ABI version of the linked libproven_chat."""
function abi_version()::UInt32
    ccall((:chat_abi_version, LIB), UInt32, ())
end

"""
    create_context() -> SlotId

Create a new real-time chat server context. Throws on pool exhaustion.
"""
function create_context()::SlotId
    check_slot(ccall((:chat_create_context, LIB), Cint, ()))
end

"""
    destroy_context(slot::SlotId)

Release the given real-time chat server context slot.
"""
function destroy_context(slot::SlotId)::Nothing
    ccall((:chat_destroy_context, LIB), Cvoid, (Cint,), slot)
    nothing
end

"""
    get_state(slot::SlotId) -> PresenceStatus

Get the current real-time chat server lifecycle state.
"""
function get_state(slot::SlotId)::PresenceStatus
    PresenceStatus(ccall((:chat_state, LIB), UInt8, (Cint,), slot))
end

"""
    can_transition(from::PresenceStatus, to::PresenceStatus) -> Bool

Check whether a real-time chat server state transition is valid.
"""
function can_transition(from::PresenceStatus, to::PresenceStatus)::Bool
    ccall((:chat_can_transition, LIB), UInt8,
          (UInt8, UInt8), UInt8(from), UInt8(to)) == 0x01
end

end # module Chat
