# SPDX-License-Identifier: MPL-2.0
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# Julia bindings for the proven-vpn protocol (VPN (IPsec/WireGuard) server).
#
# Wraps the C-ABI functions from protocols/proven-vpn/ffi/zig/src/vpn.zig
# via ccall into libproven_vpn.so.

module Vpn

using ..ProvenServers: check_status, check_slot, SlotId

export IKE_PORT,
       WIREGUARD_PORT,
       TunnelType,
       TunnelPhase,
       EncryptionAlgorithm,
       IntegrityAlgorithm,
       DhGroup,
       SaLifecycle,
       VpnError,
       abi_version,
       create_context,
       destroy_context,
       get_state,
       can_transition

const LIB = "libproven_vpn"

# --------------------------------------------------------------------------
# Constants
# --------------------------------------------------------------------------

"""IKE_PORT: protocol constant."""
const IKE_PORT = UInt16(500)

"""WIREGUARD_PORT: protocol constant."""
const WIREGUARD_PORT = UInt16(51820)

# --------------------------------------------------------------------------
# Enumeration types matching Idris2 ABI
# --------------------------------------------------------------------------

"""VPN tunnel types."""
@enum TunnelType::UInt8 begin
    TUNNEL_IPSEC = 0
    TUNNEL_WIREGUARD = 1
    TUNNEL_OPENVPN = 2
    TUNNEL_L2TP = 3
end

"""VPN tunnel phases."""
@enum TunnelPhase::UInt8 begin
    PHASE_IDLE = 0
    PHASE_1_INIT = 1
    PHASE_1_AUTH = 2
    PHASE_1_DONE = 3
    PHASE_2_NEGOTIATING = 4
    PHASE_ESTABLISHED = 5
    PHASE_EXPIRED = 6
end

"""VPN encryption algorithms."""
@enum EncryptionAlgorithm::UInt8 begin
    ENC_AES128_CBC = 0
    ENC_AES256_CBC = 1
    ENC_AES128_GCM = 2
    ENC_AES256_GCM = 3
    ENC_CHACHA20_POLY1305 = 4
    ENC_NULL_CIPHER = 5
end

"""VPN integrity algorithms."""
@enum IntegrityAlgorithm::UInt8 begin
    INT_HMAC_SHA1 = 0
    INT_HMAC_SHA256 = 1
    INT_HMAC_SHA384 = 2
    INT_HMAC_SHA512 = 3
    INT_NO_INTEGRITY = 4
end

"""VPN Diffie-Hellman groups."""
@enum DhGroup::UInt8 begin
    DH_14 = 0
    DH_ECP256 = 1
    DH_ECP384 = 2
    DH_CURVE25519 = 3
end

"""VPN SA lifecycle states."""
@enum SaLifecycle::UInt8 begin
    SA_NONE = 0
    SA_ACTIVE = 1
    SA_REKEYING = 2
    SA_EXPIRED = 3
    SA_DELETED = 4
end

"""VPN error codes."""
@enum VpnError::UInt8 begin
    ERR_AUTH_FAILED = 0
    ERR_NO_PROPOSAL_CHOSEN = 1
    ERR_LIFETIME_EXPIRED = 2
    ERR_INVALID_SPI = 3
    ERR_REPLAY_DETECTED = 4
    ERR_NEGOTIATION_TIMEOUT = 5
end

# --------------------------------------------------------------------------
# ccall declarations
# --------------------------------------------------------------------------

"""Return the ABI version of the linked libproven_vpn."""
function abi_version()::UInt32
    ccall((:vpn_abi_version, LIB), UInt32, ())
end

"""
    create_context() -> SlotId

Create a new Vpn context. Throws on pool exhaustion.
"""
function create_context()::SlotId
    check_slot(ccall((:vpn_create_context, LIB), Cint, ()))
end

"""
    destroy_context(slot::SlotId)

Release the given Vpn context slot.
"""
function destroy_context(slot::SlotId)::Nothing
    ccall((:vpn_destroy_context, LIB), Cvoid, (Cint,), slot)
    nothing
end

"""
    get_state(slot::SlotId) -> TunnelPhase

Get the current Vpn lifecycle state.
"""
function get_state(slot::SlotId)::TunnelPhase
    TunnelPhase(ccall((:vpn_state, LIB), UInt8, (Cint,), slot))
end

"""
    can_transition(from::TunnelPhase, to::TunnelPhase) -> Bool

Check whether a Vpn state transition is valid.
"""
function can_transition(from::TunnelPhase, to::TunnelPhase)::Bool
    ccall((:vpn_can_transition, LIB), UInt8,
          (UInt8, UInt8), UInt8(from), UInt8(to)) == 0x01
end

end # module Vpn
