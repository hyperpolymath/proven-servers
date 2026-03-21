// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// LDP types for the proven-servers ABI.
//
// Mirrors the Idris2 module LdpABI.Types.
// All tag values match the Idris2 ABI tag definitions exactly.

// ===========================================================================
// ContainerType (tags 0-2)
// ===========================================================================

/// LDP container types.
type containerType =
  | @as(0) Basic
  | @as(1) Direct
  | @as(2) Indirect

/// Decode from the C-ABI tag value.
let containerTypeFromTag = (tag: int): option<containerType> =>
  switch tag {
  | 0 => Some(Basic)
  | 1 => Some(Direct)
  | 2 => Some(Indirect)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let containerTypeToTag = (v: containerType): int =>
  switch v {
  | Basic => 0
  | Direct => 1
  | Indirect => 2
  }

// ===========================================================================
// LdpResourceType (tags 0-2)
// ===========================================================================

/// Decode from an ABI tag value.
type ldpResourceType =
  | @as(0) RdfSource
  | @as(1) NonRdfSource
  | @as(2) Container

/// Decode from the C-ABI tag value.
let ldpResourceTypeFromTag = (tag: int): option<ldpResourceType> =>
  switch tag {
  | 0 => Some(RdfSource)
  | 1 => Some(NonRdfSource)
  | 2 => Some(Container)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let ldpResourceTypeToTag = (v: ldpResourceType): int =>
  switch v {
  | RdfSource => 0
  | NonRdfSource => 1
  | Container => 2
  }

// ===========================================================================
// Preference (tags 0-4)
// ===========================================================================

/// Decode from an ABI tag value.
type preference =
  | @as(0) MinimalContainer
  | @as(1) IncludeContainment
  | @as(2) IncludeMembership
  | @as(3) OmitContainment
  | @as(4) OmitMembership

/// Decode from the C-ABI tag value.
let preferenceFromTag = (tag: int): option<preference> =>
  switch tag {
  | 0 => Some(MinimalContainer)
  | 1 => Some(IncludeContainment)
  | 2 => Some(IncludeMembership)
  | 3 => Some(OmitContainment)
  | 4 => Some(OmitMembership)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let preferenceToTag = (v: preference): int =>
  switch v {
  | MinimalContainer => 0
  | IncludeContainment => 1
  | IncludeMembership => 2
  | OmitContainment => 3
  | OmitMembership => 4
  }

// ===========================================================================
// InteractionModel (tags 0-4)
// ===========================================================================

/// Decode from an ABI tag value.
type interactionModel =
  | @as(0) Ldpr
  | @as(1) Ldpc
  | @as(2) LdpBasicContainer
  | @as(3) LdpDirectContainer
  | @as(4) LdpIndirectContainer

/// Decode from the C-ABI tag value.
let interactionModelFromTag = (tag: int): option<interactionModel> =>
  switch tag {
  | 0 => Some(Ldpr)
  | 1 => Some(Ldpc)
  | 2 => Some(LdpBasicContainer)
  | 3 => Some(LdpDirectContainer)
  | 4 => Some(LdpIndirectContainer)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let interactionModelToTag = (v: interactionModel): int =>
  switch v {
  | Ldpr => 0
  | Ldpc => 1
  | LdpBasicContainer => 2
  | LdpDirectContainer => 3
  | LdpIndirectContainer => 4
  }

// ===========================================================================
// ConstraintViolation (tags 0-3)
// ===========================================================================

/// Decode from an ABI tag value.
type constraintViolation =
  | @as(0) MembershipConstant
  | @as(1) ContainsTriplesModified
  | @as(2) ServerManaged
  | @as(3) TypeConflict

/// Decode from the C-ABI tag value.
let constraintViolationFromTag = (tag: int): option<constraintViolation> =>
  switch tag {
  | 0 => Some(MembershipConstant)
  | 1 => Some(ContainsTriplesModified)
  | 2 => Some(ServerManaged)
  | 3 => Some(TypeConflict)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let constraintViolationToTag = (v: constraintViolation): int =>
  switch v {
  | MembershipConstant => 0
  | ContainsTriplesModified => 1
  | ServerManaged => 2
  | TypeConflict => 3
  }

