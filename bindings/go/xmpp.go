// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>

// XMPP protocol types for proven-servers.
// All tag values match the Idris2 ABI discriminants exactly.
package proven

// StanzaType represents the StanzaType type (Idris2 ABI tags).
type StanzaType uint8

const (
	StanzaTypeMessage StanzaType = iota
	StanzaTypePresence
	StanzaTypeIq
)

// MessageType represents the MessageType type (Idris2 ABI tags).
type MessageType uint8

const (
	MessageTypeChat MessageType = iota
	MessageTypeError
	MessageTypeGroupchat
	MessageTypeHeadline
	MessageTypeNormal
)

// PresenceType represents the PresenceType type (Idris2 ABI tags).
type PresenceType uint8

const (
	PresenceTypeAvailable PresenceType = iota
	PresenceTypeAway
	PresenceTypeDnd
	PresenceTypeXa
	PresenceTypeUnavailable
)

// IqType represents the IqType type (Idris2 ABI tags).
type IqType uint8

const (
	IqTypeGet IqType = iota
	IqTypeSet
	IqTypeResult
	IqTypeError
)

// StreamError represents the StreamError type (Idris2 ABI tags).
type StreamError uint8

const (
	StreamErrorBadFormat StreamError = iota
	StreamErrorConflict
	StreamErrorConnectionTimeout
	StreamErrorHostGone
	StreamErrorHostUnknown
	StreamErrorNotAuthorized
	StreamErrorPolicyViolation
	StreamErrorResourceConstraint
	StreamErrorSystemShutdown
)
