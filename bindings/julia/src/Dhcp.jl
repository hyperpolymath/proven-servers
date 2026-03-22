# SPDX-License-Identifier: PMPL-1.0-or-later
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# Julia bindings for the proven-dhcp protocol (DHCP (RFC 2131)).
#
# Wraps the C-ABI functions from protocols/proven-dhcp/ffi/zig/src/dhcp.zig
# via ccall into libproven_dhcp.so.

module Dhcp

using ..ProvenServers: check_status, check_slot, SlotId

export MessageType, OptionCode, HardwareType, DhcpState, LeaseState, RelaySubOption,
       abi_version, create_context, destroy_context, get_state, can_transition

const LIB = "libproven_dhcp"

# --------------------------------------------------------------------------
# Enumeration types matching Idris2 ABI
# --------------------------------------------------------------------------

"""DHCP message types (RFC 2131 Section 3.1).  Matches `MessageType` in `DhcpABI.Types`."""
@enum MessageType::UInt8 begin
    DISCOVER = 0
    OFFER = 1
    REQUEST = 2
    ACK = 3
    NAK = 4
    RELEASE = 5
    INFORM = 6
    DECLINE = 7
end


"""DHCP option codes (RFC 2132).  Matches `OptionCode` in `DhcpABI.Types`."""
@enum OptionCode::UInt8 begin
    SUBNET_MASK = 0
    ROUTER = 1
    DNS = 2
    DOMAIN_NAME = 3
    LEASE_TIME = 4
    SERVER_ID = 5
    REQUESTED_IP = 6
    MSG_TYPE = 7
end


"""Hardware address types (RFC 1700).  Matches `HardwareType` in `DhcpABI.Types`."""
@enum HardwareType::UInt8 begin
    ETHERNET = 0
    IEEE802 = 1
    ARCNET = 2
    FRAME_RELAY = 3
end


"""DHCP server state machine.  Matches `DhcpState` in `DhcpABI.Types`."""
@enum DhcpState::UInt8 begin
    IDLE = 0
    DISCOVER_RECEIVED = 1
    OFFER_SENT = 2
    REQUEST_RECEIVED = 3
    ACK_SENT = 4
    NAK_SENT = 5
end


"""DHCP lease lifecycle states.  Matches `LeaseState` in `DhcpABI.Types`."""
@enum LeaseState::UInt8 begin
    AVAILABLE = 0
    OFFERED = 1
    BOUND = 2
    RENEWING = 3
    REBINDING = 4
    EXPIRED = 5
end


"""DHCP relay agent sub-options (RFC 3046).  Matches `RelaySubOption` in `DhcpABI.Types`."""
@enum RelaySubOption::UInt8 begin
    CIRCUIT_ID = 0
    REMOTE_ID = 1
end

# --------------------------------------------------------------------------
# ccall declarations
# --------------------------------------------------------------------------

"""Return the ABI version of the linked libproven_dhcp."""
function abi_version()::UInt32
    ccall((:dhcp_abi_version, LIB), UInt32, ())
end

"""
    create_context() -> SlotId

Create a new DHCP (RFC 2131) context. Throws on pool exhaustion.
"""
function create_context()::SlotId
    check_slot(ccall((:dhcp_create_context, LIB), Cint, ()))
end

"""
    destroy_context(slot::SlotId)

Release the given DHCP (RFC 2131) context slot.
"""
function destroy_context(slot::SlotId)::Nothing
    ccall((:dhcp_destroy_context, LIB), Cvoid, (Cint,), slot)
    nothing
end

"""
    get_state(slot::SlotId) -> DhcpState

Get the current DHCP (RFC 2131) lifecycle state.
"""
function get_state(slot::SlotId)::DhcpState
    DhcpState(ccall((:dhcp_state, LIB), UInt8, (Cint,), slot))
end

"""
    can_transition(from::DhcpState, to::DhcpState) -> Bool

Check whether a DHCP (RFC 2131) state transition is valid.
"""
function can_transition(from::DhcpState, to::DhcpState)::Bool
    ccall((:dhcp_can_transition, LIB), UInt8,
          (UInt8, UInt8), UInt8(from), UInt8(to)) == 0x01
end

end # module Dhcp
