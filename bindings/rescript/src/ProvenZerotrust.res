// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Zero Trust types for the proven-servers ABI.
//
// Mirrors the Idris2 module ZerotrustABI.Types.
// All tag values match the Idris2 ABI tag definitions exactly.

// ===========================================================================
// PolicyType (tags 0-3)
// ===========================================================================

/// Zero Trust policy types.
type policyType =
  | @as(0) AlwaysVerify
  | @as(1) NeverTrust
  | @as(2) LeastPrivilege
  | @as(3) MicroSegmentation

/// Decode from the C-ABI tag value.
let policyTypeFromTag = (tag: int): option<policyType> =>
  switch tag {
  | 0 => Some(AlwaysVerify)
  | 1 => Some(NeverTrust)
  | 2 => Some(LeastPrivilege)
  | 3 => Some(MicroSegmentation)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let policyTypeToTag = (v: policyType): int =>
  switch v {
  | AlwaysVerify => 0
  | NeverTrust => 1
  | LeastPrivilege => 2
  | MicroSegmentation => 3
  }

// ===========================================================================
// IdentityConfidence (tags 0-4)
// ===========================================================================

/// Decode from an ABI tag value.
type identityConfidence =
  | @as(0) Unverified
  | @as(1) BasicAuth
  | @as(2) MfaVerified
  | @as(3) StrongAuth
  | @as(4) ContinuousAuth

/// Decode from the C-ABI tag value.
let identityConfidenceFromTag = (tag: int): option<identityConfidence> =>
  switch tag {
  | 0 => Some(Unverified)
  | 1 => Some(BasicAuth)
  | 2 => Some(MfaVerified)
  | 3 => Some(StrongAuth)
  | 4 => Some(ContinuousAuth)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let identityConfidenceToTag = (v: identityConfidence): int =>
  switch v {
  | Unverified => 0
  | BasicAuth => 1
  | MfaVerified => 2
  | StrongAuth => 3
  | ContinuousAuth => 4
  }

// ===========================================================================
// DeviceTrustScore (tags 0-4)
// ===========================================================================

/// Decode from an ABI tag value.
type deviceTrustScore =
  | @as(0) DeviceUnknown
  | @as(1) DevicePartial
  | @as(2) DeviceCompliant
  | @as(3) DeviceManaged
  | @as(4) DeviceHardened

/// Decode from the C-ABI tag value.
let deviceTrustScoreFromTag = (tag: int): option<deviceTrustScore> =>
  switch tag {
  | 0 => Some(DeviceUnknown)
  | 1 => Some(DevicePartial)
  | 2 => Some(DeviceCompliant)
  | 3 => Some(DeviceManaged)
  | 4 => Some(DeviceHardened)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let deviceTrustScoreToTag = (v: deviceTrustScore): int =>
  switch v {
  | DeviceUnknown => 0
  | DevicePartial => 1
  | DeviceCompliant => 2
  | DeviceManaged => 3
  | DeviceHardened => 4
  }

// ===========================================================================
// AccessDecision (tags 0-3)
// ===========================================================================

/// Decode from an ABI tag value.
type accessDecision =
  | @as(0) Allow
  | @as(1) Deny
  | @as(2) Challenge
  | @as(3) StepUp

/// Decode from the C-ABI tag value.
let accessDecisionFromTag = (tag: int): option<accessDecision> =>
  switch tag {
  | 0 => Some(Allow)
  | 1 => Some(Deny)
  | 2 => Some(Challenge)
  | 3 => Some(StepUp)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let accessDecisionToTag = (v: accessDecision): int =>
  switch v {
  | Allow => 0
  | Deny => 1
  | Challenge => 2
  | StepUp => 3
  }

/// Whether access is granted.
let accessDecisionIsGranted = (v: accessDecision): bool =>
  switch v {
  | Allow => true
  | _ => false
  }

// ===========================================================================
// ContextSignalKind (tags 0-4)
// ===========================================================================

/// Decode from an ABI tag value.
type contextSignalKind =
  | @as(0) Location
  | @as(1) Time
  | @as(2) Device
  | @as(3) Behavior
  | @as(4) Network

/// Decode from the C-ABI tag value.
let contextSignalKindFromTag = (tag: int): option<contextSignalKind> =>
  switch tag {
  | 0 => Some(Location)
  | 1 => Some(Time)
  | 2 => Some(Device)
  | 3 => Some(Behavior)
  | 4 => Some(Network)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let contextSignalKindToTag = (v: contextSignalKind): int =>
  switch v {
  | Location => 0
  | Time => 1
  | Device => 2
  | Behavior => 3
  | Network => 4
  }

// ===========================================================================
// AuthFactor (tags 0-5)
// ===========================================================================

/// Decode from an ABI tag value.
type authFactor =
  | @as(0) Certificate
  | @as(1) Token
  | @as(2) Biometric
  | @as(3) Fido2
  | @as(4) Totp
  | @as(5) Push

/// Decode from the C-ABI tag value.
let authFactorFromTag = (tag: int): option<authFactor> =>
  switch tag {
  | 0 => Some(Certificate)
  | 1 => Some(Token)
  | 2 => Some(Biometric)
  | 3 => Some(Fido2)
  | 4 => Some(Totp)
  | 5 => Some(Push)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let authFactorToTag = (v: authFactor): int =>
  switch v {
  | Certificate => 0
  | Token => 1
  | Biometric => 2
  | Fido2 => 3
  | Totp => 4
  | Push => 5
  }

