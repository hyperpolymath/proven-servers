// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>

// Proxy protocol types for proven-servers.
// All tag values match the Idris2 ABI discriminants exactly.
package proven

// ProxyMode represents the ProxyMode type (Idris2 ABI tags).
type ProxyMode uint8

const (
	ProxyModeForward ProxyMode = iota
	ProxyModeReverse
)

// HopByHopHeader represents the HopByHopHeader type (Idris2 ABI tags).
type HopByHopHeader uint8

const (
	HopByHopHeaderConnection HopByHopHeader = iota
	HopByHopHeaderKeepAlive
	HopByHopHeaderProxyAuth
	HopByHopHeaderProxyAuthz
	HopByHopHeaderTe
	HopByHopHeaderTrailers
	HopByHopHeaderTransferEncoding
	HopByHopHeaderUpgrade
)

// CacheDirective represents the CacheDirective type (Idris2 ABI tags).
type CacheDirective uint8

const (
	CacheDirectiveNoCache CacheDirective = iota
	CacheDirectiveNoStore
	CacheDirectiveMaxAge
	CacheDirectivePublic
	CacheDirectivePrivate
	CacheDirectiveMustRevalidate
)

// ProxyError represents the ProxyError type (Idris2 ABI tags).
type ProxyError uint8

const (
	ProxyErrorBadGateway ProxyError = iota
	ProxyErrorGatewayTimeout
	ProxyErrorUpstreamRefused
	ProxyErrorUpstreamTls
)
