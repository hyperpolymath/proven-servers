// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>

// Federation protocol types for proven-servers.
// All tag values match the Idris2 ABI discriminants exactly.
package proven

// ActivityType represents the ActivityType type (Idris2 ABI tags).
type ActivityType uint8

const (
	ActivityTypeCreate ActivityType = iota
	ActivityTypeUpdate
	ActivityTypeDelete
	ActivityTypeFollow
	ActivityTypeAccept
	ActivityTypeReject
	ActivityTypeAnnounce
	ActivityTypeLike
	ActivityTypeUndo
	ActivityTypeBlock
	ActivityTypeFlag
)

// ActorType represents the ActorType type (Idris2 ABI tags).
type ActorType uint8

const (
	ActorTypePerson ActorType = iota
	ActorTypeService
	ActorTypeApplication
	ActorTypeGroup
	ActorTypeOrganization
)

// DeliveryStatus represents the DeliveryStatus type (Idris2 ABI tags).
type DeliveryStatus uint8

const (
	DeliveryStatusPending DeliveryStatus = iota
	DeliveryStatusDelivered
	DeliveryStatusFailed
	DeliveryStatusRejected
	DeliveryStatusDeferred
)

// TrustLevel represents the TrustLevel type (Idris2 ABI tags).
type TrustLevel uint8

const (
	TrustLevelSelfSigned TrustLevel = iota
	TrustLevelPeerVerified
	TrustLevelFederationTrusted
	TrustLevelRevoked
	TrustLevelUnknown
)

// ObjectType represents the ObjectType type (Idris2 ABI tags).
type ObjectType uint8

const (
	ObjectTypeNote ObjectType = iota
	ObjectTypeArticle
	ObjectTypeImage
	ObjectTypeVideo
	ObjectTypeAudio
	ObjectTypeDocument
	ObjectTypeEvent
	ObjectTypeCollection
	ObjectTypeOrderedCollection
)

// ServerState represents the ServerState type (Idris2 ABI tags).
type ServerState uint8

const (
	ServerStateIdle ServerState = iota
	ServerStateActive
	ServerStateProcessing
	ServerStateDelivering
	ServerStateShutdown
)
