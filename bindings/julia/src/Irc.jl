# SPDX-License-Identifier: PMPL-1.0-or-later
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# Julia bindings for the proven-irc protocol (IRC (RFC 2812)).
#
# Wraps the C-ABI functions from protocols/proven-irc/ffi/zig/src/irc.zig
# via ccall into libproven_irc.so.

module Irc

using ..ProvenServers: check_status, check_slot, SlotId

export Command, NumericReply, ChannelMode, State, IrcError,
       abi_version, create_context, destroy_context, get_state, can_transition

const LIB = "libproven_irc"

# --------------------------------------------------------------------------
# Enumeration types matching Idris2 ABI
# --------------------------------------------------------------------------

"""IRC protocol commands (RFC 2812).  Matches `Command` in `IrcABI.Types`."""
@enum Command::UInt8 begin
    NICK = 0
    USER = 1
    JOIN = 2
    PART = 3
    PRIVMSG = 4
    NOTICE = 5
    QUIT = 6
    PING = 7
    PONG = 8
    MODE = 9
    KICK = 10
    TOPIC = 11
    INVITE = 12
    NAMES = 13
    LIST = 14
    WHO = 15
    WHOIS = 16
end


"""Selected IRC numeric reply codes (RFC 2812).  Matches `NumericReply` in `IrcABI.Types`."""
@enum NumericReply::UInt8 begin
    WELCOME = 0
    YOUR_HOST = 1
    CREATED = 2
    MY_INFO = 3
    BOUNCE = 4
    NICK_IN_USE = 5
    NO_SUCH_NICK = 6
    NO_SUCH_CHANNEL = 7
    CHANNEL_IS_FULL = 8
    INVITE_ONLY_CHAN = 9
    BANNED_FROM_CHAN = 10
end


"""IRC channel modes (RFC 2812 Section 4).  Matches `ChannelMode` in `IrcABI.Types`."""
@enum ChannelMode::UInt8 begin
    OP = 0
    VOICE = 1
    BAN = 2
    LIMIT = 3
    INVITE_ONLY = 4
    MODERATED = 5
    NO_EXTERNAL_MSGS = 6
    TOPIC_LOCK = 7
    SECRET = 8
    PRIVATE = 9
end


"""IRC client connection lifecycle states.  Matches `IRCState` in `IrcABI.Types`."""
@enum State::UInt8 begin
    DISCONNECTED = 0
    CONNECTING = 1
    REGISTERED = 2
    IN_CHANNEL = 3
    QUITTING = 4
end


"""IRC server error categories.  Matches `IRCError` in `IrcABI.Types`."""
@enum IrcError::UInt8 begin
    NONE = 0
    NICK_IN_USE = 1
    CHANNEL_FULL = 2
    INVITE_ONLY = 3
    BANNED = 4
    NOT_REGISTERED = 5
end

# --------------------------------------------------------------------------
# ccall declarations
# --------------------------------------------------------------------------

"""Return the ABI version of the linked libproven_irc."""
function abi_version()::UInt32
    ccall((:irc_abi_version, LIB), UInt32, ())
end

"""
    create_context() -> SlotId

Create a new IRC (RFC 2812) context. Throws on pool exhaustion.
"""
function create_context()::SlotId
    check_slot(ccall((:irc_create_context, LIB), Cint, ()))
end

"""
    destroy_context(slot::SlotId)

Release the given IRC (RFC 2812) context slot.
"""
function destroy_context(slot::SlotId)::Nothing
    ccall((:irc_destroy_context, LIB), Cvoid, (Cint,), slot)
    nothing
end

"""
    get_state(slot::SlotId) -> State

Get the current IRC (RFC 2812) lifecycle state.
"""
function get_state(slot::SlotId)::State
    State(ccall((:irc_state, LIB), UInt8, (Cint,), slot))
end

"""
    can_transition(from::State, to::State) -> Bool

Check whether a IRC (RFC 2812) state transition is valid.
"""
function can_transition(from::State, to::State)::Bool
    ccall((:irc_can_transition, LIB), UInt8,
          (UInt8, UInt8), UInt8(from), UInt8(to)) == 0x01
end

end # module Irc
