// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>

// NTP protocol types for proven-servers.
// All tag values match the Idris2 ABI discriminants exactly.
package proven

// LeapIndicator represents the LeapIndicator type (Idris2 ABI tags).
type LeapIndicator uint8

const (
	LeapIndicatorNoWarning LeapIndicator = iota
	LeapIndicatorLastMinute61
	LeapIndicatorLastMinute59
	LeapIndicatorUnsynchronised
)

// NtpMode represents the NtpMode type (Idris2 ABI tags).
type NtpMode uint8

const (
	NtpModeReserved NtpMode = iota
	NtpModeSymmetricActive
	NtpModeSymmetricPassive
	NtpModeClient
	NtpModeServer
	NtpModeBroadcast
	NtpModeControlMessage
	NtpModePrivate
)

// ExchangeState represents the ExchangeState type (Idris2 ABI tags).
type ExchangeState uint8

const (
	ExchangeStateIdle ExchangeState = iota
	ExchangeStateRequestReceived
	ExchangeStateTimestampCalculated
	ExchangeStateResponseSent
)

// ClockDisciplineState represents the ClockDisciplineState type (Idris2 ABI tags).
type ClockDisciplineState uint8

const (
	ClockDisciplineStateUnset ClockDisciplineState = iota
	ClockDisciplineStateSpike
	ClockDisciplineStateFreq
	ClockDisciplineStateSync
	ClockDisciplineStatePanic
)

// KissCode represents the KissCode type (Idris2 ABI tags).
type KissCode uint8

const (
	KissCodeDeny KissCode = iota
	KissCodeRstr
	KissCodeRate
	KissCodeOther
)

// NtpError represents the NtpError type (Idris2 ABI tags).
type NtpError uint8

const (
	NtpErrorOk NtpError = iota
	NtpErrorInvalidSlot
	NtpErrorNotActive
	NtpErrorInvalidPacket
	NtpErrorKissOfDeath
	NtpErrorStratumTooHigh
)
