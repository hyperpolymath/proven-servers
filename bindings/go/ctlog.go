// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>

// CT Log protocol types for proven-servers.
// All tag values match the Idris2 ABI discriminants exactly.
package proven

// LogEntryType represents the LogEntryType type (Idris2 ABI tags).
type LogEntryType uint8

const (
	LogEntryTypeX509Entry LogEntryType = iota
	LogEntryTypePrecertEntry
)

// SignatureType represents the SignatureType type (Idris2 ABI tags).
type SignatureType uint8

const (
	SignatureTypeCertificateTimestamp SignatureType = iota
	SignatureTypeTreeHash
)

// MerkleLeafType represents the MerkleLeafType type (Idris2 ABI tags).
type MerkleLeafType uint8

const (
	MerkleLeafTypeTimestampedEntry MerkleLeafType = iota
)

// SubmissionStatus represents the SubmissionStatus type (Idris2 ABI tags).
type SubmissionStatus uint8

const (
	SubmissionStatusAccepted SubmissionStatus = iota
	SubmissionStatusDuplicate
	SubmissionStatusRateLimited
	SubmissionStatusRejected
	SubmissionStatusInvalidChain
	SubmissionStatusUnknownAnchor
)

// VerificationResult represents the VerificationResult type (Idris2 ABI tags).
type VerificationResult uint8

const (
	VerificationResultValidProof VerificationResult = iota
	VerificationResultInvalidProof
	VerificationResultInconsistentTree
	VerificationResultStaleSth
)

// ServerState represents the ServerState type (Idris2 ABI tags).
type ServerState uint8

const (
	ServerStateIdle ServerState = iota
	ServerStateActive
	ServerStateMerging
	ServerStateSigning
	ServerStateShutdown
)
