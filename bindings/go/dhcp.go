// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>

// DHCP protocol types for proven-servers.
// All tag values match the Idris2 ABI discriminants exactly.
package proven

// MessageType represents the MessageType type (Idris2 ABI tags).
type MessageType uint8

const (
	MessageTypeDiscover MessageType = iota
	MessageTypeOffer
	MessageTypeRequest
	MessageTypeAck
	MessageTypeNak
	MessageTypeRelease
	MessageTypeInform
	MessageTypeDecline
)

// OptionCode represents the OptionCode type (Idris2 ABI tags).
type OptionCode uint8

const (
	OptionCodeSubnetMask OptionCode = iota
	OptionCodeRouter
	OptionCodeDns
	OptionCodeDomainName
	OptionCodeLeaseTime
	OptionCodeServerId
	OptionCodeRequestedIp
	OptionCodeMsgType
)

// HardwareType represents the HardwareType type (Idris2 ABI tags).
type HardwareType uint8

const (
	HardwareTypeEthernet HardwareType = iota
	HardwareTypeIeee802
	HardwareTypeArcnet
	HardwareTypeFrameRelay
)

// DhcpState represents the DhcpState type (Idris2 ABI tags).
type DhcpState uint8

const (
	DhcpStateIdle DhcpState = iota
	DhcpStateDiscoverReceived
	DhcpStateOfferSent
	DhcpStateRequestReceived
	DhcpStateAckSent
	DhcpStateNakSent
)

// LeaseState represents the LeaseState type (Idris2 ABI tags).
type LeaseState uint8

const (
	LeaseStateAvailable LeaseState = iota
	LeaseStateOffered
	LeaseStateBound
	LeaseStateRenewing
	LeaseStateRebinding
	LeaseStateExpired
)

// RelaySubOption represents the RelaySubOption type (Idris2 ABI tags).
type RelaySubOption uint8

const (
	RelaySubOptionCircuitId RelaySubOption = iota
	RelaySubOptionRemoteId
)
