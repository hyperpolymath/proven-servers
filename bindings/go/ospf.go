// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>

// OSPF protocol types for proven-servers.
// All tag values match the Idris2 ABI discriminants exactly.
package proven

// PacketType represents the PacketType type (Idris2 ABI tags).
type PacketType uint8

const (
	PacketTypeHello PacketType = iota
	PacketTypeDatabaseDescription
	PacketTypeLinkStateRequest
	PacketTypeLinkStateUpdate
	PacketTypeLinkStateAck
)

// NeighborState represents the NeighborState type (Idris2 ABI tags).
type NeighborState uint8

const (
	NeighborStateDown NeighborState = iota
	NeighborStateAttempt
	NeighborStateInit
	NeighborStateTwoWay
	NeighborStateExStart
	NeighborStateExchange
	NeighborStateLoading
	NeighborStateFull
)

// LsaType represents the LsaType type (Idris2 ABI tags).
type LsaType uint8

const (
	LsaTypeRouterLsa LsaType = iota
	LsaTypeNetworkLsa
	LsaTypeSummaryLsa
	LsaTypeAsbrSummaryLsa
	LsaTypeAsExternalLsa
)

// AreaType represents the AreaType type (Idris2 ABI tags).
type AreaType uint8

const (
	AreaTypeNormal AreaType = iota
	AreaTypeStub
	AreaTypeTotallyStub
	AreaTypeNssa
)

// OspfError represents the OspfError type (Idris2 ABI tags).
type OspfError uint8

const (
	OspfErrorOk OspfError = iota
	OspfErrorInvalidSlot
	OspfErrorNotActive
	OspfErrorInvalidTransition
	OspfErrorInvalidPacket
	OspfErrorAreaError
	OspfErrorFloodLimit
)
