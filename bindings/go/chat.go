// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>

// Chat protocol types for proven-servers.
// All tag values match the Idris2 ABI discriminants exactly.
package proven

// MessageType represents the MessageType type (Idris2 ABI tags).
type MessageType uint8

const (
	MessageTypeText MessageType = iota
	MessageTypeImage
	MessageTypeFile
	MessageTypeSystem
	MessageTypeReaction
	MessageTypeEdit
	MessageTypeDelete
	MessageTypeReply
	MessageTypeThread
)

// PresenceStatus represents the PresenceStatus type (Idris2 ABI tags).
type PresenceStatus uint8

const (
	PresenceStatusOnline PresenceStatus = iota
	PresenceStatusAway
	PresenceStatusDnd
	PresenceStatusInvisible
	PresenceStatusOffline
)

// RoomType represents the RoomType type (Idris2 ABI tags).
type RoomType uint8

const (
	RoomTypeDirect RoomType = iota
	RoomTypeGroup
	RoomTypeChannel
	RoomTypeBroadcast
)

// Permission represents the Permission type (Idris2 ABI tags).
type Permission uint8

const (
	PermissionRead Permission = iota
	PermissionWrite
	PermissionAdmin
	PermissionInvite
	PermissionKick
	PermissionBan
	PermissionPin
	PermissionDeleteOthers
)

// Event represents the Event type (Idris2 ABI tags).
type Event uint8

const (
	EventMessageSent Event = iota
	EventMessageDelivered
	EventMessageRead
	EventUserJoined
	EventUserLeft
	EventTyping
	EventRoomCreated
)
