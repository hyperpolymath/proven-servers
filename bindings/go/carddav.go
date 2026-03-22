// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>

// CardDAV protocol types for proven-servers.
// All tag values match the Idris2 ABI discriminants exactly.
package proven

// PropertyType represents the PropertyType type (Idris2 ABI tags).
type PropertyType uint8

const (
	PropertyTypeFnName PropertyType = iota
	PropertyTypeN
	PropertyTypeEmail
	PropertyTypeTel
	PropertyTypeAdr
	PropertyTypeOrg
	PropertyTypePhoto
	PropertyTypeUrl
	PropertyTypeNote
)

// CardMethod represents the CardMethod type (Idris2 ABI tags).
type CardMethod uint8

const (
	CardMethodGet CardMethod = iota
	CardMethodPut
	CardMethodDelete
	CardMethodPropfind
	CardMethodProppatch
	CardMethodReport
	CardMethodMkcol
)

// VCardVersion represents the VCardVersion type (Idris2 ABI tags).
type VCardVersion uint8

const (
	VCardVersionVcard3 VCardVersion = iota
	VCardVersionVcard4
)

// CardError represents the CardError type (Idris2 ABI tags).
type CardError uint8

const (
	CardErrorValidAddressData CardError = iota
	CardErrorNoResourceType
	CardErrorMaxResourceSize
	CardErrorUidConflict
	CardErrorSupportedAddressData
	CardErrorPreconditionFailed
)

// ServerState represents the ServerState type (Idris2 ABI tags).
type ServerState uint8

const (
	ServerStateIdle ServerState = iota
	ServerStateBound
	ServerStateServing
	ServerStateShutdown
)
