// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>

// PTP protocol types for proven-servers.
// All tag values match the Idris2 ABI discriminants exactly.
package proven

// PtpMessageType represents the PtpMessageType type (Idris2 ABI tags).
type PtpMessageType uint8

const (
	PtpMessageTypeSync PtpMessageType = iota
	PtpMessageTypeDelayReq
	PtpMessageTypePdelayReq
	PtpMessageTypePdelayResp
	PtpMessageTypeFollowUp
	PtpMessageTypeDelayResp
	PtpMessageTypePdelayRespFollowUp
	PtpMessageTypeAnnounce
	PtpMessageTypeSignaling
	PtpMessageTypeManagement
)

// ClockClass represents the ClockClass type (Idris2 ABI tags).
type ClockClass uint8

const (
	ClockClassPrimaryClock ClockClass = iota
	ClockClassApplicationSpecific
	ClockClassSlaveOnly
	ClockClassDefaultClass
)

// PtpPortState represents the PtpPortState type (Idris2 ABI tags).
type PtpPortState uint8

const (
	PtpPortStateInitializing PtpPortState = iota
	PtpPortStateFaulty
	PtpPortStateDisabled
	PtpPortStateListening
	PtpPortStatePreMaster
	PtpPortStateMaster
	PtpPortStatePassive
	PtpPortStateUncalibrated
	PtpPortStateSlave
)

// DelayMechanism represents the DelayMechanism type (Idris2 ABI tags).
type DelayMechanism uint8

const (
	DelayMechanismE2E DelayMechanism = iota
	DelayMechanismP2P
	DelayMechanismDmDisabled
)
