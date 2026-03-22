// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>

// SDN protocol types for proven-servers.
// All tag values match the Idris2 ABI discriminants exactly.
package proven

// SdnMessageType represents the SdnMessageType type (Idris2 ABI tags).
type SdnMessageType uint8

const (
	SdnMessageTypeHello SdnMessageType = iota
	SdnMessageTypeError
	SdnMessageTypeEchoRequest
	SdnMessageTypeEchoReply
	SdnMessageTypeFeaturesRequest
	SdnMessageTypeFeaturesReply
	SdnMessageTypeFlowMod
	SdnMessageTypePacketIn
	SdnMessageTypePacketOut
	SdnMessageTypePortStatus
	SdnMessageTypeBarrierRequest
	SdnMessageTypeBarrierReply
)

// FlowAction represents the FlowAction type (Idris2 ABI tags).
type FlowAction uint8

const (
	FlowActionOutput FlowAction = iota
	FlowActionSetField
	FlowActionDrop
	FlowActionPushVlan
	FlowActionPopVlan
	FlowActionSetQueue
	FlowActionGroup
)

// MatchField represents the MatchField type (Idris2 ABI tags).
type MatchField uint8

const (
	MatchFieldInPort MatchField = iota
	MatchFieldEthDst
	MatchFieldEthSrc
	MatchFieldEthType
	MatchFieldVlanId
	MatchFieldIpSrc
	MatchFieldIpDst
	MatchFieldTcpSrc
	MatchFieldTcpDst
	MatchFieldUdpSrc
	MatchFieldUdpDst
)

// PortState represents the PortState type (Idris2 ABI tags).
type PortState uint8

const (
	PortStateUp PortState = iota
	PortStateDown
	PortStateBlocked
)
