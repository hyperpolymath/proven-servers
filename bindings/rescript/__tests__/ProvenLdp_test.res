// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Tests for ProvenLdp protocol bindings.

open ProvenLdp

let test_containerType_roundtrip = () => {
  assert(containerTypeFromTag(0) == Some(Basic))
  assert(containerTypeFromTag(1) == Some(Direct))
  assert(containerTypeFromTag(2) == Some(Indirect))
  assert(containerTypeFromTag(3) == None)
}

let test_containerType_toTag = () => {
  assert(containerTypeToTag(Basic) == 0)
  assert(containerTypeToTag(Direct) == 1)
  assert(containerTypeToTag(Indirect) == 2)
}

let test_ldpResourceType_roundtrip = () => {
  assert(ldpResourceTypeFromTag(0) == Some(RdfSource))
  assert(ldpResourceTypeFromTag(1) == Some(NonRdfSource))
  assert(ldpResourceTypeFromTag(2) == Some(Container))
  assert(ldpResourceTypeFromTag(3) == None)
}

let test_ldpResourceType_toTag = () => {
  assert(ldpResourceTypeToTag(RdfSource) == 0)
  assert(ldpResourceTypeToTag(NonRdfSource) == 1)
  assert(ldpResourceTypeToTag(Container) == 2)
}

let test_preference_roundtrip = () => {
  assert(preferenceFromTag(0) == Some(MinimalContainer))
  assert(preferenceFromTag(1) == Some(IncludeContainment))
  assert(preferenceFromTag(2) == Some(IncludeMembership))
  assert(preferenceFromTag(3) == Some(OmitContainment))
  assert(preferenceFromTag(4) == Some(OmitMembership))
  assert(preferenceFromTag(5) == None)
}

let test_preference_toTag = () => {
  assert(preferenceToTag(MinimalContainer) == 0)
  assert(preferenceToTag(IncludeContainment) == 1)
  assert(preferenceToTag(IncludeMembership) == 2)
  assert(preferenceToTag(OmitContainment) == 3)
  assert(preferenceToTag(OmitMembership) == 4)
}

let test_interactionModel_roundtrip = () => {
  assert(interactionModelFromTag(0) == Some(Ldpr))
  assert(interactionModelFromTag(1) == Some(Ldpc))
  assert(interactionModelFromTag(2) == Some(LdpBasicContainer))
  assert(interactionModelFromTag(3) == Some(LdpDirectContainer))
  assert(interactionModelFromTag(4) == Some(LdpIndirectContainer))
  assert(interactionModelFromTag(5) == None)
}

let test_interactionModel_toTag = () => {
  assert(interactionModelToTag(Ldpr) == 0)
  assert(interactionModelToTag(Ldpc) == 1)
  assert(interactionModelToTag(LdpBasicContainer) == 2)
  assert(interactionModelToTag(LdpDirectContainer) == 3)
  assert(interactionModelToTag(LdpIndirectContainer) == 4)
}

let test_constraintViolation_roundtrip = () => {
  assert(constraintViolationFromTag(0) == Some(MembershipConstant))
  assert(constraintViolationFromTag(1) == Some(ContainsTriplesModified))
  assert(constraintViolationFromTag(2) == Some(ServerManaged))
  assert(constraintViolationFromTag(3) == Some(TypeConflict))
  assert(constraintViolationFromTag(4) == None)
}

let test_constraintViolation_toTag = () => {
  assert(constraintViolationToTag(MembershipConstant) == 0)
  assert(constraintViolationToTag(ContainsTriplesModified) == 1)
  assert(constraintViolationToTag(ServerManaged) == 2)
  assert(constraintViolationToTag(TypeConflict) == 3)
}

// Run all tests
test_containerType_roundtrip()
test_containerType_toTag()
test_ldpResourceType_roundtrip()
test_ldpResourceType_toTag()
test_preference_roundtrip()
test_preference_toTag()
test_interactionModel_roundtrip()
test_interactionModel_toTag()
test_constraintViolation_roundtrip()
test_constraintViolation_toTag()
