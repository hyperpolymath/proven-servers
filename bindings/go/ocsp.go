// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>

// OCSP protocol types for proven-servers.
// All tag values match the Idris2 ABI discriminants exactly.
package proven

// CertStatus represents the CertStatus type (Idris2 ABI tags).
type CertStatus uint8

const (
	CertStatusGood CertStatus = iota
	CertStatusRevoked
	CertStatusUnknown
)

// ResponseStatus represents the ResponseStatus type (Idris2 ABI tags).
type ResponseStatus uint8

const (
	ResponseStatusSuccessful ResponseStatus = iota
	ResponseStatusMalformedRequest
	ResponseStatusInternalError
	ResponseStatusTryLater
	ResponseStatusSigRequired
	ResponseStatusUnauthorized
)

// HashAlgorithm represents the HashAlgorithm type (Idris2 ABI tags).
type HashAlgorithm uint8

const (
	HashAlgorithmSha1 HashAlgorithm = iota
	HashAlgorithmSha256
	HashAlgorithmSha384
	HashAlgorithmSha512
)

// ResponderState represents the ResponderState type (Idris2 ABI tags).
type ResponderState uint8

const (
	ResponderStateIdle ResponderState = iota
	ResponderStateReady
	ResponderStateProcessing
	ResponderStateSigning
	ResponderStateClosing
)
