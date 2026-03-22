// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>

// LDP protocol types for proven-servers.
// All tag values match the Idris2 ABI discriminants exactly.
package proven

// ContainerType represents the ContainerType type (Idris2 ABI tags).
type ContainerType uint8

const (
	ContainerTypeBasic ContainerType = iota
	ContainerTypeDirect
	ContainerTypeIndirect
)

// LdpResourceType represents the LdpResourceType type (Idris2 ABI tags).
type LdpResourceType uint8

const (
	LdpResourceTypeRdfSource LdpResourceType = iota
	LdpResourceTypeNonRdfSource
	LdpResourceTypeContainer
)

// Preference represents the Preference type (Idris2 ABI tags).
type Preference uint8

const (
	PreferenceMinimalContainer Preference = iota
	PreferenceIncludeContainment
	PreferenceIncludeMembership
	PreferenceOmitContainment
	PreferenceOmitMembership
)

// InteractionModel represents the InteractionModel type (Idris2 ABI tags).
type InteractionModel uint8

const (
	InteractionModelLdpr InteractionModel = iota
	InteractionModelLdpc
	InteractionModelLdpBasicContainer
	InteractionModelLdpDirectContainer
	InteractionModelLdpIndirectContainer
)

// ConstraintViolation represents the ConstraintViolation type (Idris2 ABI tags).
type ConstraintViolation uint8

const (
	ConstraintViolationMembershipConstant ConstraintViolation = iota
	ConstraintViolationContainsTriplesModified
	ConstraintViolationServerManaged
	ConstraintViolationTypeConflict
)
