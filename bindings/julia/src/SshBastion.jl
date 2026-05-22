# SPDX-License-Identifier: MPL-2.0
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# Julia bindings for the proven-ssh-bastion protocol (SSH Bastion / jump host).
#
# Wraps the C-ABI functions from protocols/proven-ssh-bastion/ffi/zig/src/ssh_bastion.zig
# via ccall into libproven_ssh_bastion.so.

module SshBastion

using ..ProvenServers: check_status, check_slot, SlotId

export SshMessageType,
       BastionAuthMethod,
       KexMethod,
       ChannelType,
       BastionState,
       ChannelState,
       DisconnectReason,
       HostKeyAlgorithm,
       CipherAlgorithm,
       ChannelOpenFailure,
       abi_version,
       create_context,
       destroy_context,
       get_state,
       can_transition

const LIB = "libproven_ssh_bastion"

# --------------------------------------------------------------------------
# Enumeration types matching Idris2 ABI
# --------------------------------------------------------------------------

"""SSH message types."""
@enum SshMessageType::UInt8 begin
    MSG_KEXINIT = 0
    MSG_NEWKEYS = 1
    MSG_SERVICE_REQUEST = 2
    MSG_USERAUTH_REQUEST = 3
    MSG_CHANNEL_OPEN = 4
    MSG_CHANNEL_DATA = 5
    MSG_CHANNEL_CLOSE = 6
    MSG_DISCONNECT = 7
end

"""SSH bastion authentication methods."""
@enum BastionAuthMethod::UInt8 begin
    AUTH_PUBLICKEY = 0
    AUTH_PASSWORD = 1
    AUTH_KEYBOARD_INTERACTIVE = 2
    AUTH_NONE = 3
end

"""SSH key exchange methods."""
@enum KexMethod::UInt8 begin
    KEX_DH_GROUP14_SHA256 = 0
    KEX_CURVE25519_SHA256 = 1
    KEX_DH_GROUP16_SHA512 = 2
    KEX_DH_GROUP18_SHA512 = 3
    KEX_ECDH_SHA2_NISTP256 = 4
    KEX_ECDH_SHA2_NISTP384 = 5
end

"""SSH channel types."""
@enum ChannelType::UInt8 begin
    CHAN_SESSION = 0
    CHAN_DIRECT_TCPIP = 1
    CHAN_FORWARDED_TCPIP = 2
    CHAN_X11 = 3
end

"""SSH bastion lifecycle states."""
@enum BastionState::UInt8 begin
    STATE_CONNECTED = 0
    STATE_KEY_EXCHANGED = 1
    STATE_AUTHENTICATED = 2
    STATE_CHANNEL_OPEN = 3
    STATE_ACTIVE = 4
    STATE_CLOSED = 5
end

"""SSH channel states."""
@enum ChannelState::UInt8 begin
    CHAN_OPENING = 0
    CHAN_OPEN = 1
    CHAN_CLOSING = 2
    CHAN_CLOSED = 3
end

"""SSH disconnect reasons."""
@enum DisconnectReason::UInt8 begin
    DC_HOST_NOT_ALLOWED = 0
    DC_PROTOCOL_ERROR = 1
    DC_KEY_EXCHANGE_FAILED = 2
    DC_HOST_AUTH_FAILED = 3
    DC_MAC_ERROR = 4
    DC_SERVICE_NOT_AVAILABLE = 5
    DC_VERSION_NOT_SUPPORTED = 6
    DC_HOST_KEY_NOT_VERIFIABLE = 7
    DC_CONNECTION_LOST = 8
    DC_BY_APPLICATION = 9
    DC_TOO_MANY_CONNECTIONS = 10
    DC_AUTH_CANCELLED = 11
end

"""SSH host key algorithms."""
@enum HostKeyAlgorithm::UInt8 begin
    HK_SSH_ED25519 = 0
    HK_RSA_SHA2_256 = 1
    HK_RSA_SHA2_512 = 2
    HK_ECDSA_NISTP256 = 3
end

"""SSH cipher algorithms."""
@enum CipherAlgorithm::UInt8 begin
    CIPHER_CHACHA20_POLY1305 = 0
    CIPHER_AES256_GCM = 1
    CIPHER_AES128_GCM = 2
    CIPHER_AES256_CTR = 3
    CIPHER_AES192_CTR = 4
    CIPHER_AES128_CTR = 5
end

"""SSH channel open failure reasons."""
@enum ChannelOpenFailure::UInt8 begin
    FAIL_ADMIN_PROHIBITED = 0
    FAIL_CONNECT_FAILED = 1
    FAIL_UNKNOWN_CHANNEL_TYPE = 2
    FAIL_RESOURCE_SHORTAGE = 3
end

# --------------------------------------------------------------------------
# ccall declarations
# --------------------------------------------------------------------------

"""Return the ABI version of the linked libproven_ssh_bastion."""
function abi_version()::UInt32
    ccall((:ssh_bastion_abi_version, LIB), UInt32, ())
end

"""
    create_context() -> SlotId

Create a new SshBastion context. Throws on pool exhaustion.
"""
function create_context()::SlotId
    check_slot(ccall((:ssh_bastion_create_context, LIB), Cint, ()))
end

"""
    destroy_context(slot::SlotId)

Release the given SshBastion context slot.
"""
function destroy_context(slot::SlotId)::Nothing
    ccall((:ssh_bastion_destroy_context, LIB), Cvoid, (Cint,), slot)
    nothing
end

"""
    get_state(slot::SlotId) -> ChannelState

Get the current SshBastion lifecycle state.
"""
function get_state(slot::SlotId)::ChannelState
    ChannelState(ccall((:ssh_bastion_state, LIB), UInt8, (Cint,), slot))
end

"""
    can_transition(from::ChannelState, to::ChannelState) -> Bool

Check whether a SshBastion state transition is valid.
"""
function can_transition(from::ChannelState, to::ChannelState)::Bool
    ccall((:ssh_bastion_can_transition, LIB), UInt8,
          (UInt8, UInt8), UInt8(from), UInt8(to)) == 0x01
end

end # module SshBastion
