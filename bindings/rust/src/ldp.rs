// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//

//! LDP types for the proven-servers ABI.
//!
//! Formally verified Linked Data Platform types (W3C LDP).
//! Mirrors the Idris2 module `LdpABI.Types`.
//!
//! - `ContainerType` -- LDP container types.
//! - `LdpResourceType` -- LDP resource types.
//! - `Preference` -- LDP prefer header values.
//! - `InteractionModel` -- LDP interaction models.
//! - `ConstraintViolation` -- LDP constraint violations.
//!
//! All discriminant values match the Idris2 ABI tag definitions exactly.

use std::fmt;

// ===========================================================================
// ContainerType (tags 0-2)
// ===========================================================================

/// LDP container types.
///
/// Matches `ContainerType` in `LdpABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum ContainerType {
    /// Basic (tag 0).
    Basic = 0,
    /// Direct (tag 1).
    Direct = 1,
    /// Indirect (tag 2).
    Indirect = 2,
}

impl ContainerType {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Basic),
            1 => Some(Self::Direct),
            2 => Some(Self::Indirect),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [ContainerType; 3] = [
        Self::Basic, Self::Direct, Self::Indirect,
    ];
}

impl fmt::Display for ContainerType {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// LdpResourceType (tags 0-2)
// ===========================================================================

/// LDP resource types.
///
/// Matches `LdpResourceType` in `LdpABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum LdpResourceType {
    /// RdfSource (tag 0).
    RdfSource = 0,
    /// NonRdfSource (tag 1).
    NonRdfSource = 1,
    /// Container (tag 2).
    Container = 2,
}

impl LdpResourceType {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::RdfSource),
            1 => Some(Self::NonRdfSource),
            2 => Some(Self::Container),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [LdpResourceType; 3] = [
        Self::RdfSource, Self::NonRdfSource, Self::Container,
    ];
}

impl fmt::Display for LdpResourceType {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// Preference (tags 0-4)
// ===========================================================================

/// LDP prefer header values.
///
/// Matches `Preference` in `LdpABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum Preference {
    /// MinimalContainer (tag 0).
    MinimalContainer = 0,
    /// IncludeContainment (tag 1).
    IncludeContainment = 1,
    /// IncludeMembership (tag 2).
    IncludeMembership = 2,
    /// OmitContainment (tag 3).
    OmitContainment = 3,
    /// OmitMembership (tag 4).
    OmitMembership = 4,
}

impl Preference {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::MinimalContainer),
            1 => Some(Self::IncludeContainment),
            2 => Some(Self::IncludeMembership),
            3 => Some(Self::OmitContainment),
            4 => Some(Self::OmitMembership),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [Preference; 5] = [
        Self::MinimalContainer, Self::IncludeContainment, Self::IncludeMembership, Self::OmitContainment, Self::OmitMembership,
    ];
}

impl fmt::Display for Preference {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// InteractionModel (tags 0-4)
// ===========================================================================

/// LDP interaction models.
///
/// Matches `InteractionModel` in `LdpABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum InteractionModel {
    /// LDP Resource (tag 0).
    Ldpr = 0,
    /// LDP Container (tag 1).
    Ldpc = 1,
    /// LdpBasicContainer (tag 2).
    LdpBasicContainer = 2,
    /// LdpDirectContainer (tag 3).
    LdpDirectContainer = 3,
    /// LdpIndirectContainer (tag 4).
    LdpIndirectContainer = 4,
}

impl InteractionModel {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Ldpr),
            1 => Some(Self::Ldpc),
            2 => Some(Self::LdpBasicContainer),
            3 => Some(Self::LdpDirectContainer),
            4 => Some(Self::LdpIndirectContainer),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [InteractionModel; 5] = [
        Self::Ldpr, Self::Ldpc, Self::LdpBasicContainer, Self::LdpDirectContainer, Self::LdpIndirectContainer,
    ];
}

impl fmt::Display for InteractionModel {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// ConstraintViolation (tags 0-3)
// ===========================================================================

/// LDP constraint violations.
///
/// Matches `ConstraintViolation` in `LdpABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum ConstraintViolation {
    /// MembershipConstant (tag 0).
    MembershipConstant = 0,
    /// ContainsTriplesModified (tag 1).
    ContainsTriplesModified = 1,
    /// ServerManaged (tag 2).
    ServerManaged = 2,
    /// TypeConflict (tag 3).
    TypeConflict = 3,
}

impl ConstraintViolation {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::MembershipConstant),
            1 => Some(Self::ContainsTriplesModified),
            2 => Some(Self::ServerManaged),
            3 => Some(Self::TypeConflict),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [ConstraintViolation; 4] = [
        Self::MembershipConstant, Self::ContainsTriplesModified, Self::ServerManaged, Self::TypeConflict,
    ];
}

impl fmt::Display for ConstraintViolation {
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
    fn container_type_roundtrip() {
        for v in ContainerType::ALL {
            let tag = v.to_tag();
            let decoded = ContainerType::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(ContainerType::from_tag(3).is_none());
    }

    #[test]
    fn ldp_resource_type_roundtrip() {
        for v in LdpResourceType::ALL {
            let tag = v.to_tag();
            let decoded = LdpResourceType::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(LdpResourceType::from_tag(3).is_none());
    }

    #[test]
    fn preference_roundtrip() {
        for v in Preference::ALL {
            let tag = v.to_tag();
            let decoded = Preference::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(Preference::from_tag(5).is_none());
    }

    #[test]
    fn interaction_model_roundtrip() {
        for v in InteractionModel::ALL {
            let tag = v.to_tag();
            let decoded = InteractionModel::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(InteractionModel::from_tag(5).is_none());
    }

    #[test]
    fn constraint_violation_roundtrip() {
        for v in ConstraintViolation::ALL {
            let tag = v.to_tag();
            let decoded = ConstraintViolation::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(ConstraintViolation::from_tag(4).is_none());
    }

}
