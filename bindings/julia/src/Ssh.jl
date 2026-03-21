# SPDX-License-Identifier: PMPL-1.0-or-later
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# Julia bindings for the proven-ssh-bastion protocol (SSH bastion host).
#
# Wraps the C-ABI functions from protocols/proven-ssh-bastion/ffi/zig/src/ssh_bastion.zig
# via ccall into libproven_ssh_bastion.so.

module Ssh

using ..ProvenServers: check_status, check_slot, SlotId

export BastionState, KexMethod, AuthMethod, ChannelType, ChannelState,
       DisconnectReason,
       abi_version, create, destroy, get_state, complete_kex, authenticate,
       open_channel, confirm_channel, close_channel, channel_count,
       rekey, disconnect, can_transition, is_recording

const LIB = "libproven_ssh_bastion"

# --------------------------------------------------------------------------
# Enumeration types matching Idris2 ABI
# --------------------------------------------------------------------------

"""SSH bastion session states."""
@enum BastionState::UInt8 begin
    STATE_INIT          = 0
    STATE_KEX           = 1
    STATE_AUTH          = 2
    STATE_AUTHENTICATED = 3
    STATE_CHANNEL_OPEN  = 4
    STATE_REKEY         = 5
    STATE_DISCONNECTED  = 6
end

"""SSH key exchange methods."""
@enum KexMethod::UInt8 begin
    KEX_CURVE25519_SHA256   = 0
    KEX_ECDH_SHA2_NISTP256  = 1
    KEX_ECDH_SHA2_NISTP384  = 2
    KEX_DH_GROUP14_SHA256   = 3
    KEX_DH_GROUP16_SHA512   = 4
end

"""SSH authentication methods."""
@enum AuthMethod::UInt8 begin
    AUTH_PUBLIC_KEY           = 0
    AUTH_PASSWORD             = 1
    AUTH_KEYBOARD_INTERACTIVE = 2
    AUTH_CERTIFICATE          = 3
end

"""SSH channel types."""
@enum ChannelType::UInt8 begin
    CHANNEL_SESSION         = 0
    CHANNEL_DIRECT_TCPIP    = 1
    CHANNEL_FORWARDED_TCPIP = 2
    CHANNEL_X11             = 3
end

"""SSH channel states."""
@enum ChannelState::UInt8 begin
    CH_OPENING             = 0
    CH_OPEN                = 1
    CH_HALF_CLOSED_LOCAL   = 2
    CH_HALF_CLOSED_REMOTE  = 3
    CH_CLOSED              = 4
end

"""SSH disconnect reasons."""
@enum DisconnectReason::UInt8 begin
    REASON_BY_APPLICATION         = 0
    REASON_TOO_MANY_AUTH_FAILURES = 1
    REASON_PROTOCOL_ERROR         = 2
    REASON_TIMEOUT                = 3
end

# --------------------------------------------------------------------------
# ccall declarations
# --------------------------------------------------------------------------

"""Return the ABI version of the linked libproven_ssh_bastion."""
function abi_version()::UInt32
    ccall((:ssh_bastion_abi_version, LIB), UInt32, ())
end

"""
    create(kex::KexMethod, auth::AuthMethod) -> SlotId

Create a new SSH bastion session. Throws on pool exhaustion.
"""
function create(kex::KexMethod, auth::AuthMethod)::SlotId
    check_slot(ccall((:ssh_bastion_create, LIB), Cint,
                     (UInt8, UInt8), UInt8(kex), UInt8(auth)))
end

"""
    destroy(slot::SlotId)

Release the given SSH bastion context slot.
"""
function destroy(slot::SlotId)::Nothing
    ccall((:ssh_bastion_destroy, LIB), Cvoid, (Cint,), slot)
    nothing
end

"""
    get_state(slot::SlotId) -> BastionState

Get the current SSH bastion session state.
"""
function get_state(slot::SlotId)::BastionState
    BastionState(ccall((:ssh_bastion_state, LIB), UInt8, (Cint,), slot))
end

"""
    complete_kex(slot::SlotId)

Complete key exchange. Throws on invalid state.
"""
function complete_kex(slot::SlotId)::Nothing
    check_status(ccall((:ssh_bastion_complete_kex, LIB), UInt8, (Cint,), slot))
end

"""
    authenticate(slot::SlotId, user_len::UInt16)

Authenticate user. Throws on invalid state.
"""
function authenticate(slot::SlotId, user_len::UInt16)::Nothing
    check_status(ccall((:ssh_bastion_authenticate, LIB), UInt8,
                       (Cint, UInt16), slot, user_len))
end

"""
    open_channel(slot::SlotId, ch_type::ChannelType) -> Cint

Open a new channel. Returns channel ID. Throws on pool exhaustion.
"""
function open_channel(slot::SlotId, ch_type::ChannelType)::Cint
    check_slot(ccall((:ssh_bastion_open_channel, LIB), Cint,
                     (Cint, UInt8), slot, UInt8(ch_type)))
end

"""
    confirm_channel(slot::SlotId, ch_id::UInt8)

Confirm an open channel. Throws on invalid state.
"""
function confirm_channel(slot::SlotId, ch_id::UInt8)::Nothing
    check_status(ccall((:ssh_bastion_confirm_channel, LIB), UInt8,
                       (Cint, UInt8), slot, ch_id))
end

"""
    close_channel(slot::SlotId, ch_id::UInt8)

Close a channel. Throws on invalid state.
"""
function close_channel(slot::SlotId, ch_id::UInt8)::Nothing
    check_status(ccall((:ssh_bastion_close_channel, LIB), UInt8,
                       (Cint, UInt8), slot, ch_id))
end

"""
    channel_count(slot::SlotId) -> UInt8

Get the number of open channels.
"""
function channel_count(slot::SlotId)::UInt8
    ccall((:ssh_bastion_channel_count, LIB), UInt8, (Cint,), slot)
end

"""
    rekey(slot::SlotId)

Initiate re-keying. Throws on invalid state.
"""
function rekey(slot::SlotId)::Nothing
    check_status(ccall((:ssh_bastion_rekey, LIB), UInt8, (Cint,), slot))
end

"""
    disconnect(slot::SlotId, reason::DisconnectReason)

Disconnect with the given reason. Throws on invalid state.
"""
function disconnect(slot::SlotId, reason::DisconnectReason)::Nothing
    check_status(ccall((:ssh_bastion_disconnect, LIB), UInt8,
                       (Cint, UInt8), slot, UInt8(reason)))
end

"""
    can_transition(from::BastionState, to::BastionState) -> Bool

Check whether an SSH bastion state transition is valid.
"""
function can_transition(from::BastionState, to::BastionState)::Bool
    ccall((:ssh_bastion_can_transition, LIB), UInt8,
          (UInt8, UInt8), UInt8(from), UInt8(to)) == 0x01
end

"""
    is_recording(slot::SlotId) -> Bool

Check if session recording is enabled.
"""
function is_recording(slot::SlotId)::Bool
    ccall((:ssh_bastion_is_recording, LIB), UInt8, (Cint,), slot) == 0x01
end

end # module Ssh
