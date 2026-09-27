-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
--
-- ZeroTrustABI.Foreign: Foreign function declarations for the C bridge.
--
-- Declares the opaque handle type and documents the complete FFI contract
-- that the Zig implementation (ffi/zig/src/zerotrust.zig) must provide.
--
-- The Zig FFI models the policy state machine and caller-supplied signal
-- aggregation only. No identity verifier or device attestation backend exists;
-- claimed confidence/trust scores are not evidence and access is denied.
--
-- All functions use C calling convention and communicate state via
-- Bits8 tags matching ZeroTrustABI.Layout exactly.

module ZeroTrustABI.Foreign

import ZeroTrustABI.Layout

%default total

---------------------------------------------------------------------------
-- Opaque handle type
---------------------------------------------------------------------------

||| Opaque handle to a Zero Trust evaluation session.
||| Created by zt_create(), destroyed by zt_destroy().
export
data ZtContext : Type where [external]

---------------------------------------------------------------------------
-- ABI version
---------------------------------------------------------------------------

||| ABI version -- must match zt_abi_version() return value.
public export
abiVersion : Bits32
abiVersion = 1

---------------------------------------------------------------------------
-- FFI function contract (20+ functions)
---------------------------------------------------------------------------

-- +-----------------------------+---------------------------------------------+
-- | Function                    | Signature                                   |
-- +-----------------------------+---------------------------------------------+
-- | zt_abi_version              | () -> u32                                   |
-- |                             | Returns ABI version (must equal abiVersion).|
-- +-----------------------------+---------------------------------------------+
-- | zt_create                   | (policy: u8) -> c_int (slot)                |
-- |                             | Creates session with given policy type.      |
-- |                             | Starts in RequestReceived phase.             |
-- |                             | Returns -1 on failure (no slots or invalid   |
-- |                             | policy tag).                                |
-- +-----------------------------+---------------------------------------------+
-- | zt_destroy                  | (slot: c_int) -> void                       |
-- |                             | Releases a session slot.                    |
-- +-----------------------------+---------------------------------------------+
-- | zt_phase                    | (slot: c_int) -> u8 (EvaluationPhase tag)   |
-- |                             | Returns current evaluation phase.           |
-- +-----------------------------+---------------------------------------------+
-- | zt_policy                   | (slot: c_int) -> u8 (PolicyType tag)        |
-- |                             | Returns the configured policy type.         |
-- +-----------------------------+---------------------------------------------+
-- | zt_identity_confidence      | (slot: c_int) -> u8 (IdentityConfidence tag)|
-- |                             | Returns current identity confidence level.  |
-- +-----------------------------+---------------------------------------------+
-- | zt_device_trust             | (slot: c_int) -> u8 (DeviceTrustScore tag)  |
-- |                             | Returns current device trust score.         |
-- +-----------------------------+---------------------------------------------+
-- | zt_access_decision          | (slot: c_int) -> u8 (AccessDecision tag)    |
-- |                             | Returns the access decision (only valid     |
-- |                             | after PolicyEvaluated/Granted/Denied).      |
-- +-----------------------------+---------------------------------------------+
-- | zt_verify_identity          | (slot: c_int, confidence: u8) -> u8         |
-- |                             | Rejects caller-supplied confidence because  |
-- |                             | no authentication backend exists. Valid tags|
-- |                             | move RequestReceived -> AccessDenied;      |
-- |                             | confidence is not stored; returns 1.        |
-- +-----------------------------+---------------------------------------------+
-- | zt_check_device             | (slot: c_int, trust: u8) -> u8              |
-- |                             | Always rejects: no identity evidence or   |
-- |                             | device attestation backend is connected.  |
-- |                             | Caller-supplied scores are never stored.   |
-- +-----------------------------+---------------------------------------------+
-- | zt_evaluate_policy          | (slot: c_int) -> u8                         |
-- |                             | Unreachable: no verified identity or       |
-- |                             | device state can be established.           |
-- |                             | Caller-supplied signals do not grant access.|
-- +-----------------------------+---------------------------------------------+
-- | zt_grant_access             | (slot: c_int) -> u8                         |
-- |                             | Cannot grant in this FFI: no verified      |
-- |                             | identity/device evidence reaches policy.   |
-- +-----------------------------+---------------------------------------------+
-- | zt_add_signal               | (slot: c_int, kind: u8, value: u16) -> u8   |
-- |                             | Store caller-supplied signal metadata only;  |
-- |                             | it is not verified evidence for access.    |
-- +-----------------------------+---------------------------------------------+
-- | zt_signal_count             | (slot: c_int) -> u32                        |
-- |                             | Returns number of active context signals.   |
-- +-----------------------------+---------------------------------------------+
-- | zt_signal_value             | (slot: c_int, kind: u8) -> u16              |
-- |                             | Returns the value of a specific signal kind.|
-- |                             | Returns 0 if signal not set.                |
-- +-----------------------------+---------------------------------------------+
-- | zt_trust_score              | (slot: c_int) -> u16                        |
-- |                             | Compute an aggregate of caller-supplied     |
-- |                             | metadata; this is not identity evidence.   |
-- +-----------------------------+---------------------------------------------+
-- | zt_trust_level              | (slot: c_int) -> u8 (TrustLevel tag)        |
-- |                             | Returns trust level derived from aggregate  |
-- |                             | trust score.                                |
-- +-----------------------------+---------------------------------------------+
-- | zt_can_transition           | (from: u8, to: u8) -> u8 (1=yes, 0=no)     |
-- |                             | Stateless: checks if an evaluation phase    |
-- |                             | transition is valid per Transitions.idr.    |
-- +-----------------------------+---------------------------------------------+
-- | zt_can_deny                 | (phase: u8) -> u8 (1=yes, 0=no)            |
-- |                             | Stateless: checks if denial is possible     |
-- |                             | from the given phase.                       |
-- +-----------------------------+---------------------------------------------+
-- | zt_can_grant                | (phase: u8) -> u8 (1=yes, 0=no)            |
-- |                             | Stateless: checks if granting is possible   |
-- |                             | from the given phase.                       |
-- +-----------------------------+---------------------------------------------+
-- | zt_is_terminal              | (phase: u8) -> u8 (1=yes, 0=no)            |
-- |                             | Stateless: checks if a phase is terminal    |
-- |                             | (AccessGranted or AccessDenied).            |
-- +-----------------------------+---------------------------------------------+
