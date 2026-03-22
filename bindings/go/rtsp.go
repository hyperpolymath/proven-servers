// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>

// RTSP protocol types for proven-servers.
// All tag values match the Idris2 ABI discriminants exactly.
package proven

// Method represents the Method type (Idris2 ABI tags).
type Method uint8

const (
	MethodDescribe Method = iota
	MethodSetup
	MethodPlay
	MethodPause
	MethodTeardown
	MethodGetParameter
	MethodSetParameter
	MethodOptions
	MethodAnnounce
	MethodRecord
	MethodRedirect
)

// TransportProtocol represents the TransportProtocol type (Idris2 ABI tags).
type TransportProtocol uint8

const (
	TransportProtocolRtpAvpUdp TransportProtocol = iota
	TransportProtocolRtpAvpTcp
	TransportProtocolRtpAvpUdpMulticast
)

// SessionState represents the SessionState type (Idris2 ABI tags).
type SessionState uint8

const (
	SessionStateInit SessionState = iota
	SessionStateReady
	SessionStatePlaying
	SessionStateRecording
)

// StatusCode represents the StatusCode type (Idris2 ABI tags).
type StatusCode uint8

const (
	StatusCodeOk StatusCode = iota
	StatusCodeMovedPermanently
	StatusCodeMovedTemporarily
	StatusCodeBadRequest
	StatusCodeUnauthorized
	StatusCodeNotFound
	StatusCodeMethodNotAllowed
	StatusCodeNotAcceptable
	StatusCodeSessionNotFound
	StatusCodeInternalServerError
	StatusCodeNotImplemented
	StatusCodeServiceUnavailable
)

// RtspError represents the RtspError type (Idris2 ABI tags).
type RtspError uint8

const (
	RtspErrorOk RtspError = iota
	RtspErrorInvalidSlot
	RtspErrorNotActive
	RtspErrorInvalidTransition
	RtspErrorMethodNotAllowed
	RtspErrorTransportError
	RtspErrorSessionExpired
)
