// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>

// OPC UA protocol types for proven-servers.
// All tag values match the Idris2 ABI discriminants exactly.
package proven

// ServiceType represents the ServiceType type (Idris2 ABI tags).
type ServiceType uint8

const (
	ServiceTypeRead ServiceType = iota
	ServiceTypeWrite
	ServiceTypeBrowse
	ServiceTypeSubscribe
	ServiceTypePublish
	ServiceTypeCall
	ServiceTypeCreateSession
	ServiceTypeActivateSession
	ServiceTypeCloseSession
	ServiceTypeCreateSubscription
	ServiceTypeDeleteSubscription
)

// NodeClass represents the NodeClass type (Idris2 ABI tags).
type NodeClass uint8

const (
	NodeClassObject NodeClass = iota
	NodeClassVariable
	NodeClassMethod
	NodeClassObjectType
	NodeClassVariableType
	NodeClassReferenceType
	NodeClassDataType
	NodeClassView
)

// StatusCode represents the StatusCode type (Idris2 ABI tags).
type StatusCode uint8

const (
	StatusCodeGood StatusCode = iota
	StatusCodeUncertain
	StatusCodeBad
	StatusCodeBadNodeIdUnknown
	StatusCodeBadAttributeIdInvalid
	StatusCodeBadNotReadable
	StatusCodeBadNotWritable
	StatusCodeBadOutOfRange
	StatusCodeBadTypeMismatch
	StatusCodeBadSessionIdInvalid
	StatusCodeBadSubscriptionIdInvalid
	StatusCodeBadTimeout
)

// SecurityMode represents the SecurityMode type (Idris2 ABI tags).
type SecurityMode uint8

const (
	SecurityModeNone SecurityMode = iota
	SecurityModeSign
	SecurityModeSignAndEncrypt
)

// SessionState represents the SessionState type (Idris2 ABI tags).
type SessionState uint8

const (
	SessionStateIdle SessionState = iota
	SessionStateConnected
	SessionStateCreated
	SessionStateActivated
	SessionStateMonitoring
	SessionStateClosing
)
