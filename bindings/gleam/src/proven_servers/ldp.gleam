//// SPDX-License-Identifier: MPL-2.0
//// (PMPL-1.0-or-later preferred; MPL-2.0 required for Gleam ecosystem)
//// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
////
//// Linked Data Platform protocol types for the proven-servers ABI.
////
//// Mirrors the Idris2 module `LdpABI.Types`.
//// All tag values match the Idris2 ABI definitions exactly.

// ===========================================================================
// ContainerType
// ===========================================================================

/// LDP container types.
/// 
/// Matches `ContainerType` in `LdpABI.Types`.
pub type ContainerType {
  /// Basic (tag 0).
  Basic
  /// Direct (tag 1).
  Direct
  /// Indirect (tag 2).
  Indirect
}

/// Convert a `ContainerType` to its C-ABI tag value.
pub fn container_type_to_int(value: ContainerType) -> Int {
  case value {
    Basic -> 0
    Direct -> 1
    Indirect -> 2
  }
}

/// Decode from a C-ABI tag value.
pub fn container_type_from_int(tag: Int) -> Result(ContainerType, Nil) {
  case tag {
    0 -> Ok(Basic)
    1 -> Ok(Direct)
    2 -> Ok(Indirect)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// LdpResourceType
// ===========================================================================

/// LDP resource types.
/// 
/// Matches `LdpResourceType` in `LdpABI.Types`.
pub type LdpResourceType {
  /// RdfSource (tag 0).
  RdfSource
  /// NonRdfSource (tag 1).
  NonRdfSource
  /// Container (tag 2).
  Container
}

/// Convert a `LdpResourceType` to its C-ABI tag value.
pub fn ldp_resource_type_to_int(value: LdpResourceType) -> Int {
  case value {
    RdfSource -> 0
    NonRdfSource -> 1
    Container -> 2
  }
}

/// Decode from a C-ABI tag value.
pub fn ldp_resource_type_from_int(tag: Int) -> Result(LdpResourceType, Nil) {
  case tag {
    0 -> Ok(RdfSource)
    1 -> Ok(NonRdfSource)
    2 -> Ok(Container)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// Preference
// ===========================================================================

/// LDP prefer header values.
/// 
/// Matches `Preference` in `LdpABI.Types`.
pub type Preference {
  /// MinimalContainer (tag 0).
  MinimalContainer
  /// IncludeContainment (tag 1).
  IncludeContainment
  /// IncludeMembership (tag 2).
  IncludeMembership
  /// OmitContainment (tag 3).
  OmitContainment
  /// OmitMembership (tag 4).
  OmitMembership
}

/// Convert a `Preference` to its C-ABI tag value.
pub fn preference_to_int(value: Preference) -> Int {
  case value {
    MinimalContainer -> 0
    IncludeContainment -> 1
    IncludeMembership -> 2
    OmitContainment -> 3
    OmitMembership -> 4
  }
}

/// Decode from a C-ABI tag value.
pub fn preference_from_int(tag: Int) -> Result(Preference, Nil) {
  case tag {
    0 -> Ok(MinimalContainer)
    1 -> Ok(IncludeContainment)
    2 -> Ok(IncludeMembership)
    3 -> Ok(OmitContainment)
    4 -> Ok(OmitMembership)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// InteractionModel
// ===========================================================================

/// LDP interaction models.
/// 
/// Matches `InteractionModel` in `LdpABI.Types`.
pub type InteractionModel {
  /// LDP Resource (tag 0).
  Ldpr
  /// LDP Container (tag 1).
  Ldpc
  /// LdpBasicContainer (tag 2).
  LdpBasicContainer
  /// LdpDirectContainer (tag 3).
  LdpDirectContainer
  /// LdpIndirectContainer (tag 4).
  LdpIndirectContainer
}

/// Convert a `InteractionModel` to its C-ABI tag value.
pub fn interaction_model_to_int(value: InteractionModel) -> Int {
  case value {
    Ldpr -> 0
    Ldpc -> 1
    LdpBasicContainer -> 2
    LdpDirectContainer -> 3
    LdpIndirectContainer -> 4
  }
}

/// Decode from a C-ABI tag value.
pub fn interaction_model_from_int(tag: Int) -> Result(InteractionModel, Nil) {
  case tag {
    0 -> Ok(Ldpr)
    1 -> Ok(Ldpc)
    2 -> Ok(LdpBasicContainer)
    3 -> Ok(LdpDirectContainer)
    4 -> Ok(LdpIndirectContainer)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// ConstraintViolation
// ===========================================================================

/// LDP constraint violations.
/// 
/// Matches `ConstraintViolation` in `LdpABI.Types`.
pub type ConstraintViolation {
  /// MembershipConstant (tag 0).
  MembershipConstant
  /// ContainsTriplesModified (tag 1).
  ContainsTriplesModified
  /// ServerManaged (tag 2).
  ServerManaged
  /// TypeConflict (tag 3).
  TypeConflict
}

/// Convert a `ConstraintViolation` to its C-ABI tag value.
pub fn constraint_violation_to_int(value: ConstraintViolation) -> Int {
  case value {
    MembershipConstant -> 0
    ContainsTriplesModified -> 1
    ServerManaged -> 2
    TypeConflict -> 3
  }
}

/// Decode from a C-ABI tag value.
pub fn constraint_violation_from_int(tag: Int) -> Result(ConstraintViolation, Nil) {
  case tag {
    0 -> Ok(MembershipConstant)
    1 -> Ok(ContainsTriplesModified)
    2 -> Ok(ServerManaged)
    3 -> Ok(TypeConflict)
    _ -> Error(Nil)
  }
}

