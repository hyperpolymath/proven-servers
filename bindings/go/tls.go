// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>

// TLS protocol bindings for proven-servers.
// All tag values match the Idris2 ABI discriminants exactly.
package proven

// TlsState represents the TlsState type (Idris2 ABI tags).
type TlsState uint8

const (
	TlsStateTlsIdle TlsState = iota
	TlsStateTlsClientHello
	TlsStateTlsServerHello
	TlsStateTlsNegotiating
	TlsStateTlsEstablished
	TlsStateTlsRenegotiating
	TlsStateTlsShutdown
)

// TlsVersion represents the TlsVersion type (Idris2 ABI tags).
type TlsVersion uint8

const (
	TlsVersionTls12 TlsVersion = iota
	TlsVersionTls13
)

// CipherSuite represents the CipherSuite type (Idris2 ABI tags).
type CipherSuite uint8

const (
	CipherSuiteAesGcm128Sha256 CipherSuite = iota
	CipherSuiteAesGcm256Sha384
	CipherSuiteChaCha20Poly1305Sha256
	CipherSuiteAesCcm128Sha256
)
