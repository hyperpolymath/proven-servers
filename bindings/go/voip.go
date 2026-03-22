// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>

// VoIP/SIP protocol types for proven-servers.
// All tag values match the Idris2 ABI discriminants exactly.
package proven

// Method represents the Method type (Idris2 ABI tags).
type Method uint8

const (
	MethodInvite Method = iota
	MethodAck
	MethodBye
	MethodCancel
	MethodRegister
	MethodOptions
	MethodInfo
	MethodUpdate
	MethodSubscribe
	MethodNotify
	MethodRefer
	MethodMessage
	MethodPrack
)

// ResponseCode represents the ResponseCode type (Idris2 ABI tags).
type ResponseCode uint8

const (
	ResponseCodeTrying ResponseCode = iota
	ResponseCodeRinging
	ResponseCodeSessionProgress
	ResponseCodeOk
	ResponseCodeMultipleChoices
	ResponseCodeMovedPermanently
	ResponseCodeMovedTemporarily
	ResponseCodeBadRequest
	ResponseCodeUnauthorized
	ResponseCodeForbidden
	ResponseCodeNotFound
	ResponseCodeMethodNotAllowed
	ResponseCodeRequestTimeout
	ResponseCodeBusyHere
	ResponseCodeDecline
	ResponseCodeServerInternalError
	ResponseCodeServiceUnavailable
)

// DialogState represents the DialogState type (Idris2 ABI tags).
type DialogState uint8

const (
	DialogStateEarly DialogState = iota
	DialogStateConfirmed
	DialogStateTerminated
)
