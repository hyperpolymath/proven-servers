// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>

// BGP protocol types for proven-servers.
// All tag values match the Idris2 ABI discriminants exactly.
package proven

// BgpState represents the BgpState type (Idris2 ABI tags).
type BgpState uint8

const (
	BgpStateIdle BgpState = iota
	BgpStateConnect
	BgpStateActive
	BgpStateOpenSent
	BgpStateOpenConfirm
	BgpStateEstablished
)

// BgpEvent represents the BgpEvent type (Idris2 ABI tags).
type BgpEvent uint8

const (
	BgpEventManualStart BgpEvent = iota
	BgpEventManualStop
	BgpEventAutomaticStart
	BgpEventConnectRetryTimerExpires
	BgpEventHoldTimerExpires
	BgpEventKeepaliveTimerExpires
	BgpEventDelayOpenTimerExpires
	BgpEventTcpConnectionValid
	BgpEventTcpCrAcked
	BgpEventTcpConnectionConfirmed
	BgpEventTcpConnectionFails
	BgpEventBgpOpenReceived
	BgpEventBgpHeaderErr
	BgpEventBgpOpenMsgErr
	BgpEventNotifMsgVerErr
	BgpEventNotifMsg
	BgpEventKeepaliveMsg
	BgpEventUpdateMsg
	BgpEventUpdateMsgErr
)

// MessageType represents the MessageType type (Idris2 ABI tags).
type MessageType uint8

const (
	MessageTypeOpen MessageType = iota
	MessageTypeUpdate
	MessageTypeNotification
	MessageTypeKeepalive
)

// ErrorCode represents the ErrorCode type (Idris2 ABI tags).
type ErrorCode uint8

const (
	ErrorCodeMessageHeaderError ErrorCode = iota
	ErrorCodeOpenMessageError
	ErrorCodeUpdateMessageError
	ErrorCodeHoldTimerExpired
	ErrorCodeFsmError
	ErrorCodeCease
)

// Origin represents the Origin type (Idris2 ABI tags).
type Origin uint8

const (
	OriginIgp Origin = iota
	OriginEgp
	OriginIncomplete
)

// AsPathSegmentType represents the AsPathSegmentType type (Idris2 ABI tags).
type AsPathSegmentType uint8

const (
	AsPathSegmentTypeAsSet AsPathSegmentType = iota
	AsPathSegmentTypeAsSequence
)

// PathAttrType represents the PathAttrType type (Idris2 ABI tags).
type PathAttrType uint8

const (
	PathAttrTypeOrigin PathAttrType = iota
	PathAttrTypeAsPath
	PathAttrTypeNextHop
	PathAttrTypeMed
	PathAttrTypeLocalPref
	PathAttrTypeAtomicAggr
	PathAttrTypeAggregator
	PathAttrTypeUnknown
)
