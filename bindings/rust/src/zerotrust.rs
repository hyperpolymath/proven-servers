// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//

//! Zero Trust types for the proven-servers ABI.
//!
//! Formally verified Zero Trust architecture types.
//! Mirrors the Idris2 module `ZerotrustABI.Types`.
//!
//! - `PolicyType` -- Zero Trust policy types.
//! - `IdentityConfidence` -- Identity verification confidence.
//! - `DeviceTrustScore` -- Device trust assessment.
//! - `AccessDecision` -- Zero Trust access decisions.
//! - `ContextSignalKind` -- Context signals for trust evaluation.
//! - `AuthFactor` -- Authentication factor types.
//!
//! All discriminant values match the Idris2 ABI tag definitions exactly.

use std::fmt;

// ===========================================================================
// PolicyType (tags 0-3)
// ===========================================================================

/// Zero Trust policy types.
///
/// Matches `PolicyType` in `ZerotrustABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum PolicyType {
    /// AlwaysVerify (tag 0).
    AlwaysVerify = 0,
    /// NeverTrust (tag 1).
    NeverTrust = 1,
    /// LeastPrivilege (tag 2).
    LeastPrivilege = 2,
    /// MicroSegmentation (tag 3).
    MicroSegmentation = 3,
}

impl PolicyType {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::AlwaysVerify),
            1 => Some(Self::NeverTrust),
            2 => Some(Self::LeastPrivilege),
            3 => Some(Self::MicroSegmentation),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [PolicyType; 4] = [
        Self::AlwaysVerify, Self::NeverTrust, Self::LeastPrivilege, Self::MicroSegmentation,
    ];
}

impl fmt::Display for PolicyType {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// IdentityConfidence (tags 0-4)
// ===========================================================================

/// Identity verification confidence.
///
/// Matches `IdentityConfidence` in `ZerotrustABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum IdentityConfidence {
    /// Unverified (tag 0).
    Unverified = 0,
    /// BasicAuth (tag 1).
    BasicAuth = 1,
    /// MFA verified (tag 2).
    MfaVerified = 2,
    /// StrongAuth (tag 3).
    StrongAuth = 3,
    /// ContinuousAuth (tag 4).
    ContinuousAuth = 4,
}

impl IdentityConfidence {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Unverified),
            1 => Some(Self::BasicAuth),
            2 => Some(Self::MfaVerified),
            3 => Some(Self::StrongAuth),
            4 => Some(Self::ContinuousAuth),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [IdentityConfidence; 5] = [
        Self::Unverified, Self::BasicAuth, Self::MfaVerified, Self::StrongAuth, Self::ContinuousAuth,
    ];
}

impl fmt::Display for IdentityConfidence {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// DeviceTrustScore (tags 0-4)
// ===========================================================================

/// Device trust assessment.
///
/// Matches `DeviceTrustScore` in `ZerotrustABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum DeviceTrustScore {
    /// DeviceUnknown (tag 0).
    DeviceUnknown = 0,
    /// DevicePartial (tag 1).
    DevicePartial = 1,
    /// DeviceCompliant (tag 2).
    DeviceCompliant = 2,
    /// DeviceManaged (tag 3).
    DeviceManaged = 3,
    /// DeviceHardened (tag 4).
    DeviceHardened = 4,
}

impl DeviceTrustScore {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::DeviceUnknown),
            1 => Some(Self::DevicePartial),
            2 => Some(Self::DeviceCompliant),
            3 => Some(Self::DeviceManaged),
            4 => Some(Self::DeviceHardened),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [DeviceTrustScore; 5] = [
        Self::DeviceUnknown, Self::DevicePartial, Self::DeviceCompliant, Self::DeviceManaged, Self::DeviceHardened,
    ];
}

impl fmt::Display for DeviceTrustScore {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// AccessDecision (tags 0-3)
// ===========================================================================

/// Zero Trust access decisions.
///
/// Matches `AccessDecision` in `ZerotrustABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum AccessDecision {
    /// Allow (tag 0).
    Allow = 0,
    /// Deny (tag 1).
    Deny = 1,
    /// Challenge (tag 2).
    Challenge = 2,
    /// StepUp (tag 3).
    StepUp = 3,
}

impl AccessDecision {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Allow),
            1 => Some(Self::Deny),
            2 => Some(Self::Challenge),
            3 => Some(Self::StepUp),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// Whether access is granted.
    pub fn is_granted(self) -> bool {
        matches!(self, Self::Allow)
    }

    /// All variants of this type.
    pub const ALL: [AccessDecision; 4] = [
        Self::Allow, Self::Deny, Self::Challenge, Self::StepUp,
    ];
}

impl fmt::Display for AccessDecision {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// ContextSignalKind (tags 0-4)
// ===========================================================================

/// Context signals for trust evaluation.
///
/// Matches `ContextSignalKind` in `ZerotrustABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum ContextSignalKind {
    /// Location (tag 0).
    Location = 0,
    /// Time (tag 1).
    Time = 1,
    /// Device (tag 2).
    Device = 2,
    /// Behavior (tag 3).
    Behavior = 3,
    /// Network (tag 4).
    Network = 4,
}

impl ContextSignalKind {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Location),
            1 => Some(Self::Time),
            2 => Some(Self::Device),
            3 => Some(Self::Behavior),
            4 => Some(Self::Network),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [ContextSignalKind; 5] = [
        Self::Location, Self::Time, Self::Device, Self::Behavior, Self::Network,
    ];
}

impl fmt::Display for ContextSignalKind {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// AuthFactor (tags 0-5)
// ===========================================================================

/// Authentication factor types.
///
/// Matches `AuthFactor` in `ZerotrustABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum AuthFactor {
    /// Certificate (tag 0).
    Certificate = 0,
    /// Token (tag 1).
    Token = 1,
    /// Biometric (tag 2).
    Biometric = 2,
    /// FIDO2 (tag 3).
    Fido2 = 3,
    /// TOTP (tag 4).
    Totp = 4,
    /// Push (tag 5).
    Push = 5,
}

impl AuthFactor {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Certificate),
            1 => Some(Self::Token),
            2 => Some(Self::Biometric),
            3 => Some(Self::Fido2),
            4 => Some(Self::Totp),
            5 => Some(Self::Push),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [AuthFactor; 6] = [
        Self::Certificate, Self::Token, Self::Biometric, Self::Fido2, Self::Totp, Self::Push,
    ];
}

impl fmt::Display for AuthFactor {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// Tests
// ===========================================================================

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn policy_type_roundtrip() {
        for v in PolicyType::ALL {
            let tag = v.to_tag();
            let decoded = PolicyType::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(PolicyType::from_tag(4).is_none());
    }

    #[test]
    fn identity_confidence_roundtrip() {
        for v in IdentityConfidence::ALL {
            let tag = v.to_tag();
            let decoded = IdentityConfidence::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(IdentityConfidence::from_tag(5).is_none());
    }

    #[test]
    fn device_trust_score_roundtrip() {
        for v in DeviceTrustScore::ALL {
            let tag = v.to_tag();
            let decoded = DeviceTrustScore::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(DeviceTrustScore::from_tag(5).is_none());
    }

    #[test]
    fn access_decision_roundtrip() {
        for v in AccessDecision::ALL {
            let tag = v.to_tag();
            let decoded = AccessDecision::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(AccessDecision::from_tag(4).is_none());
    }

    #[test]
    fn context_signal_kind_roundtrip() {
        for v in ContextSignalKind::ALL {
            let tag = v.to_tag();
            let decoded = ContextSignalKind::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(ContextSignalKind::from_tag(5).is_none());
    }

    #[test]
    fn auth_factor_roundtrip() {
        for v in AuthFactor::ALL {
            let tag = v.to_tag();
            let decoded = AuthFactor::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(AuthFactor::from_tag(6).is_none());
    }

}
