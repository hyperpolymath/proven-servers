//// SPDX-License-Identifier: MPL-2.0
//// (MPL-2.0 preferred; MPL-2.0 required for Gleam ecosystem)
//// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
////
//// Zero Trust protocol types for the proven-servers ABI.
////
//// Mirrors the Idris2 module `ZerotrustABI.Types`.
//// All tag values match the Idris2 ABI definitions exactly.

// ===========================================================================
// PolicyType
// ===========================================================================

/// Zero Trust policy types.
/// 
/// Matches `PolicyType` in `ZerotrustABI.Types`.
pub type PolicyType {
  /// AlwaysVerify (tag 0).
  AlwaysVerify
  /// NeverTrust (tag 1).
  NeverTrust
  /// LeastPrivilege (tag 2).
  LeastPrivilege
  /// MicroSegmentation (tag 3).
  MicroSegmentation
}

/// Convert a `PolicyType` to its C-ABI tag value.
pub fn policy_type_to_int(value: PolicyType) -> Int {
  case value {
    AlwaysVerify -> 0
    NeverTrust -> 1
    LeastPrivilege -> 2
    MicroSegmentation -> 3
  }
}

/// Decode from a C-ABI tag value.
pub fn policy_type_from_int(tag: Int) -> Result(PolicyType, Nil) {
  case tag {
    0 -> Ok(AlwaysVerify)
    1 -> Ok(NeverTrust)
    2 -> Ok(LeastPrivilege)
    3 -> Ok(MicroSegmentation)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// IdentityConfidence
// ===========================================================================

/// Identity verification confidence.
/// 
/// Matches `IdentityConfidence` in `ZerotrustABI.Types`.
pub type IdentityConfidence {
  /// Unverified (tag 0).
  Unverified
  /// BasicAuth (tag 1).
  BasicAuth
  /// MFA verified (tag 2).
  MfaVerified
  /// StrongAuth (tag 3).
  StrongAuth
  /// ContinuousAuth (tag 4).
  ContinuousAuth
}

/// Convert a `IdentityConfidence` to its C-ABI tag value.
pub fn identity_confidence_to_int(value: IdentityConfidence) -> Int {
  case value {
    Unverified -> 0
    BasicAuth -> 1
    MfaVerified -> 2
    StrongAuth -> 3
    ContinuousAuth -> 4
  }
}

/// Decode from a C-ABI tag value.
pub fn identity_confidence_from_int(tag: Int) -> Result(IdentityConfidence, Nil) {
  case tag {
    0 -> Ok(Unverified)
    1 -> Ok(BasicAuth)
    2 -> Ok(MfaVerified)
    3 -> Ok(StrongAuth)
    4 -> Ok(ContinuousAuth)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// DeviceTrustScore
// ===========================================================================

/// Device trust assessment.
/// 
/// Matches `DeviceTrustScore` in `ZerotrustABI.Types`.
pub type DeviceTrustScore {
  /// DeviceUnknown (tag 0).
  DeviceUnknown
  /// DevicePartial (tag 1).
  DevicePartial
  /// DeviceCompliant (tag 2).
  DeviceCompliant
  /// DeviceManaged (tag 3).
  DeviceManaged
  /// DeviceHardened (tag 4).
  DeviceHardened
}

/// Convert a `DeviceTrustScore` to its C-ABI tag value.
pub fn device_trust_score_to_int(value: DeviceTrustScore) -> Int {
  case value {
    DeviceUnknown -> 0
    DevicePartial -> 1
    DeviceCompliant -> 2
    DeviceManaged -> 3
    DeviceHardened -> 4
  }
}

/// Decode from a C-ABI tag value.
pub fn device_trust_score_from_int(tag: Int) -> Result(DeviceTrustScore, Nil) {
  case tag {
    0 -> Ok(DeviceUnknown)
    1 -> Ok(DevicePartial)
    2 -> Ok(DeviceCompliant)
    3 -> Ok(DeviceManaged)
    4 -> Ok(DeviceHardened)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// AccessDecision
// ===========================================================================

/// Zero Trust access decisions.
/// 
/// Matches `AccessDecision` in `ZerotrustABI.Types`.
pub type AccessDecision {
  /// Allow (tag 0).
  Allow
  /// Deny (tag 1).
  Deny
  /// Challenge (tag 2).
  Challenge
  /// StepUp (tag 3).
  StepUp
}

/// Convert a `AccessDecision` to its C-ABI tag value.
pub fn access_decision_to_int(value: AccessDecision) -> Int {
  case value {
    Allow -> 0
    Deny -> 1
    Challenge -> 2
    StepUp -> 3
  }
}

/// Decode from a C-ABI tag value.
pub fn access_decision_from_int(tag: Int) -> Result(AccessDecision, Nil) {
  case tag {
    0 -> Ok(Allow)
    1 -> Ok(Deny)
    2 -> Ok(Challenge)
    3 -> Ok(StepUp)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// ContextSignalKind
// ===========================================================================

/// Context signals for trust evaluation.
/// 
/// Matches `ContextSignalKind` in `ZerotrustABI.Types`.
pub type ContextSignalKind {
  /// Location (tag 0).
  Location
  /// Time (tag 1).
  Time
  /// Device (tag 2).
  Device
  /// Behavior (tag 3).
  Behavior
  /// Network (tag 4).
  Network
}

/// Convert a `ContextSignalKind` to its C-ABI tag value.
pub fn context_signal_kind_to_int(value: ContextSignalKind) -> Int {
  case value {
    Location -> 0
    Time -> 1
    Device -> 2
    Behavior -> 3
    Network -> 4
  }
}

/// Decode from a C-ABI tag value.
pub fn context_signal_kind_from_int(tag: Int) -> Result(ContextSignalKind, Nil) {
  case tag {
    0 -> Ok(Location)
    1 -> Ok(Time)
    2 -> Ok(Device)
    3 -> Ok(Behavior)
    4 -> Ok(Network)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// AuthFactor
// ===========================================================================

/// Authentication factor types.
/// 
/// Matches `AuthFactor` in `ZerotrustABI.Types`.
pub type AuthFactor {
  /// Certificate (tag 0).
  Certificate
  /// Token (tag 1).
  Token
  /// Biometric (tag 2).
  Biometric
  /// FIDO2 (tag 3).
  Fido2
  /// TOTP (tag 4).
  Totp
  /// Push (tag 5).
  Push
}

/// Convert a `AuthFactor` to its C-ABI tag value.
pub fn auth_factor_to_int(value: AuthFactor) -> Int {
  case value {
    Certificate -> 0
    Token -> 1
    Biometric -> 2
    Fido2 -> 3
    Totp -> 4
    Push -> 5
  }
}

/// Decode from a C-ABI tag value.
pub fn auth_factor_from_int(tag: Int) -> Result(AuthFactor, Nil) {
  case tag {
    0 -> Ok(Certificate)
    1 -> Ok(Token)
    2 -> Ok(Biometric)
    3 -> Ok(Fido2)
    4 -> Ok(Totp)
    5 -> Ok(Push)
    _ -> Error(Nil)
  }
}

