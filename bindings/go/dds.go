// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>

// DDS protocol types for proven-servers.
// All tag values match the Idris2 ABI discriminants exactly.
package proven

// ReliabilityKind represents the ReliabilityKind type (Idris2 ABI tags).
type ReliabilityKind uint8

const (
	ReliabilityKindBestEffort ReliabilityKind = iota
	ReliabilityKindReliable
)

// DurabilityKind represents the DurabilityKind type (Idris2 ABI tags).
type DurabilityKind uint8

const (
	DurabilityKindTransientLocal DurabilityKind = iota
	DurabilityKindTransient
	DurabilityKindPersistent
)

// HistoryKind represents the HistoryKind type (Idris2 ABI tags).
type HistoryKind uint8

const (
	HistoryKindKeepLast HistoryKind = iota
	HistoryKindKeepAll
)

// OwnershipKind represents the OwnershipKind type (Idris2 ABI tags).
type OwnershipKind uint8

const (
	OwnershipKindShared OwnershipKind = iota
	OwnershipKindExclusive
)

// EntityType represents the EntityType type (Idris2 ABI tags).
type EntityType uint8

const (
	EntityTypeParticipant EntityType = iota
	EntityTypePublisher
	EntityTypeSubscriber
	EntityTypeTopic
	EntityTypeDataWriter
	EntityTypeDataReader
)

// ParticipantState represents the ParticipantState type (Idris2 ABI tags).
type ParticipantState uint8

const (
	ParticipantStateIdle ParticipantState = iota
	ParticipantStateJoined
	ParticipantStatePublishing
	ParticipantStateSubscribing
	ParticipantStateLeaving
)
