# SPDX-License-Identifier: PMPL-1.0-or-later
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# Julia bindings for the proven-zerotrust protocol (Zero Trust security engine).
#
# Wraps the C-ABI functions from protocols/proven-zerotrust/ffi/zig/src/zerotrust.zig
# via ccall into libproven_zerotrust.so.

module Zerotrust

using ..ProvenServers: check_status, check_slot, SlotId

export PolicyType,
       IdentityConfidence,
       DeviceTrustScore,
       AccessDecision,
       ContextSignalKind,
       ZtAuthFactor,
       abi_version,
       create_context,
       destroy_context,
       get_state,
       can_transition

const LIB = "libproven_zerotrust"

# --------------------------------------------------------------------------
# Enumeration types matching Idris2 ABI
# --------------------------------------------------------------------------

"""Zero Trust policy types."""
@enum PolicyType::UInt8 begin
    POLICY_ALWAYS_VERIFY = 0
    POLICY_NEVER_TRUST = 1
    POLICY_LEAST_PRIVILEGE = 2
    POLICY_MICRO_SEGMENTATION = 3
end

"""Identity confidence levels."""
@enum IdentityConfidence::UInt8 begin
    ID_UNVERIFIED = 0
    ID_BASIC_AUTH = 1
    ID_MFA_VERIFIED = 2
    ID_STRONG_AUTH = 3
    ID_CONTINUOUS_AUTH = 4
end

"""Device trust scores."""
@enum DeviceTrustScore::UInt8 begin
    DEVICE_UNKNOWN = 0
    DEVICE_PARTIAL = 1
    DEVICE_COMPLIANT = 2
    DEVICE_MANAGED = 3
    DEVICE_HARDENED = 4
end

"""Zero Trust access decisions."""
@enum AccessDecision::UInt8 begin
    ACCESS_ALLOW = 0
    ACCESS_DENY = 1
    ACCESS_CHALLENGE = 2
    ACCESS_STEP_UP = 3
end

"""Zero Trust context signal types."""
@enum ContextSignalKind::UInt8 begin
    SIGNAL_LOCATION = 0
    SIGNAL_TIME = 1
    SIGNAL_DEVICE = 2
    SIGNAL_BEHAVIOR = 3
    SIGNAL_NETWORK = 4
end

"""Zero Trust authentication factors."""
@enum ZtAuthFactor::UInt8 begin
    FACTOR_CERTIFICATE = 0
    FACTOR_TOKEN = 1
    FACTOR_BIOMETRIC = 2
    FACTOR_FIDO2 = 3
    FACTOR_TOTP = 4
    FACTOR_PUSH = 5
end

# --------------------------------------------------------------------------
# ccall declarations
# --------------------------------------------------------------------------

"""Return the ABI version of the linked libproven_zerotrust."""
function abi_version()::UInt32
    ccall((:zerotrust_abi_version, LIB), UInt32, ())
end

"""
    create_context() -> SlotId

Create a new Zerotrust context. Throws on pool exhaustion.
"""
function create_context()::SlotId
    check_slot(ccall((:zerotrust_create_context, LIB), Cint, ()))
end

"""
    destroy_context(slot::SlotId)

Release the given Zerotrust context slot.
"""
function destroy_context(slot::SlotId)::Nothing
    ccall((:zerotrust_destroy_context, LIB), Cvoid, (Cint,), slot)
    nothing
end

"""
    get_state(slot::SlotId) -> AccessDecision

Get the current Zerotrust lifecycle state.
"""
function get_state(slot::SlotId)::AccessDecision
    AccessDecision(ccall((:zerotrust_state, LIB), UInt8, (Cint,), slot))
end

"""
    can_transition(from::AccessDecision, to::AccessDecision) -> Bool

Check whether a Zerotrust state transition is valid.
"""
function can_transition(from::AccessDecision, to::AccessDecision)::Bool
    ccall((:zerotrust_can_transition, LIB), UInt8,
          (UInt8, UInt8), UInt8(from), UInt8(to)) == 0x01
end

end # module Zerotrust
