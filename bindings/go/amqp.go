// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>

// AMQP protocol types for proven-servers.
// All tag values match the Idris2 ABI discriminants exactly.
package proven

// FrameType represents the FrameType type (Idris2 ABI tags).
type FrameType uint8

const (
	FrameTypeMethod FrameType = iota
	FrameTypeHeader
	FrameTypeBody
	FrameTypeHeartbeat
)

// MethodClass represents the MethodClass type (Idris2 ABI tags).
type MethodClass uint8

const (
	MethodClassConnection MethodClass = iota
	MethodClassChannel
	MethodClassExchange
	MethodClassQueue
	MethodClassBasic
	MethodClassTx
	MethodClassConfirm
)

// ExchangeType represents the ExchangeType type (Idris2 ABI tags).
type ExchangeType uint8

const (
	ExchangeTypeDirect ExchangeType = iota
	ExchangeTypeFanout
	ExchangeTypeTopic
	ExchangeTypeHeaders
)

// DeliveryMode represents the DeliveryMode type (Idris2 ABI tags).
type DeliveryMode uint8

const (
	DeliveryModeNonPersistent DeliveryMode = iota
	DeliveryModePersistent
)

// ErrorSeverity represents the ErrorSeverity type (Idris2 ABI tags).
type ErrorSeverity uint8

const (
	ErrorSeverityChannelLevel ErrorSeverity = iota
	ErrorSeverityConnectionLevel
)

// ConnectionState represents the ConnectionState type (Idris2 ABI tags).
type ConnectionState uint8

const (
	ConnectionStateIdle ConnectionState = iota
	ConnectionStateNegotiating
	ConnectionStateTuningOk
	ConnectionStateOpen
	ConnectionStateClosing
)

// ChannelState represents the ChannelState type (Idris2 ABI tags).
type ChannelState uint8

const (
	ChannelStateClosed ChannelState = iota
	ChannelStateOpening
	ChannelStateChOpen
	ChannelStateChClosing
)

// BrokerState represents the BrokerState type (Idris2 ABI tags).
type BrokerState uint8

const (
	BrokerStateIdle BrokerState = iota
	BrokerStateConnected
	BrokerStateChannelOpen
	BrokerStateConsuming
	BrokerStatePublishing
	BrokerStateDisconnecting
)
