# SPDX-License-Identifier: MPL-2.0
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# Julia bindings for the proven-socks protocol (SOCKS5 (RFC 1928) proxy).
#
# Wraps the C-ABI functions from protocols/proven-socks/ffi/zig/src/socks.zig
# via ccall into libproven_socks.so.

module Socks

using ..ProvenServers: check_status, check_slot, SlotId

export SOCKS_PORT,
       SocksAuthMethod,
       SocksCommand,
       AddressType,
       SocksReply,
       SocksState,
       abi_version,
       create_context,
       destroy_context,
       get_state,
       can_transition

const LIB = "libproven_socks"

# --------------------------------------------------------------------------
# Constants
# --------------------------------------------------------------------------

"""SOCKS_PORT: protocol constant."""
const SOCKS_PORT = UInt16(1080)

# --------------------------------------------------------------------------
# Enumeration types matching Idris2 ABI
# --------------------------------------------------------------------------

"""SOCKS5 authentication methods."""
@enum SocksAuthMethod::UInt8 begin
    AUTH_NO_AUTH = 0
    AUTH_GSSAPI = 1
    AUTH_USERNAME_PASSWORD = 2
    AUTH_NO_ACCEPTABLE = 3
end

"""SOCKS5 commands."""
@enum SocksCommand::UInt8 begin
    CMD_CONNECT = 0
    CMD_BIND = 1
    CMD_UDP_ASSOCIATE = 2
end

"""SOCKS5 address types."""
@enum AddressType::UInt8 begin
    ADDR_IPV4 = 0
    ADDR_DOMAIN_NAME = 1
    ADDR_IPV6 = 2
end

"""SOCKS5 reply codes."""
@enum SocksReply::UInt8 begin
    REPLY_SUCCEEDED = 0
    REPLY_GENERAL_FAILURE = 1
    REPLY_NOT_ALLOWED = 2
    REPLY_NETWORK_UNREACHABLE = 3
    REPLY_HOST_UNREACHABLE = 4
    REPLY_CONNECTION_REFUSED = 5
    REPLY_TTL_EXPIRED = 6
    REPLY_COMMAND_NOT_SUPPORTED = 7
    REPLY_ADDRESS_TYPE_NOT_SUPPORTED = 8
end

"""SOCKS5 connection states."""
@enum SocksState::UInt8 begin
    STATE_INITIAL = 0
    STATE_AUTHENTICATING = 1
    STATE_AUTHENTICATED = 2
    STATE_CONNECTING = 3
    STATE_ESTABLISHED = 4
    STATE_CLOSED = 5
end

# --------------------------------------------------------------------------
# ccall declarations
# --------------------------------------------------------------------------

"""Return the ABI version of the linked libproven_socks."""
function abi_version()::UInt32
    ccall((:socks_abi_version, LIB), UInt32, ())
end

"""
    create_context() -> SlotId

Create a new Socks context. Throws on pool exhaustion.
"""
function create_context()::SlotId
    check_slot(ccall((:socks_create_context, LIB), Cint, ()))
end

"""
    destroy_context(slot::SlotId)

Release the given Socks context slot.
"""
function destroy_context(slot::SlotId)::Nothing
    ccall((:socks_destroy_context, LIB), Cvoid, (Cint,), slot)
    nothing
end

"""
    get_state(slot::SlotId) -> SocksState

Get the current Socks lifecycle state.
"""
function get_state(slot::SlotId)::SocksState
    SocksState(ccall((:socks_state, LIB), UInt8, (Cint,), slot))
end

"""
    can_transition(from::SocksState, to::SocksState) -> Bool

Check whether a Socks state transition is valid.
"""
function can_transition(from::SocksState, to::SocksState)::Bool
    ccall((:socks_can_transition, LIB), UInt8,
          (UInt8, UInt8), UInt8(from), UInt8(to)) == 0x01
end

end # module Socks
