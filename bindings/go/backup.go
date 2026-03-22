// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>

// Backup protocol types for proven-servers.
// All tag values match the Idris2 ABI discriminants exactly.
package proven

// BackupType represents the BackupType type (Idris2 ABI tags).
type BackupType uint8

const (
	BackupTypeFull BackupType = iota
	BackupTypeIncremental
	BackupTypeDifferential
	BackupTypeSnapshot
	BackupTypeMirror
)

// ScheduleFreq represents the ScheduleFreq type (Idris2 ABI tags).
type ScheduleFreq uint8

const (
	ScheduleFreqHourly ScheduleFreq = iota
	ScheduleFreqDaily
	ScheduleFreqWeekly
	ScheduleFreqMonthly
	ScheduleFreqOnDemand
)

// CompressionAlg represents the CompressionAlg type (Idris2 ABI tags).
type CompressionAlg uint8

const (
	CompressionAlgNone CompressionAlg = iota
	CompressionAlgGzip
	CompressionAlgZstd
	CompressionAlgLz4
	CompressionAlgXz
)

// EncryptionAlg represents the EncryptionAlg type (Idris2 ABI tags).
type EncryptionAlg uint8

const (
	EncryptionAlgNoEncryption EncryptionAlg = iota
	EncryptionAlgAes256Gcm
	EncryptionAlgChaCha20Poly1305
)

// BackupState represents the BackupState type (Idris2 ABI tags).
type BackupState uint8

const (
	BackupStateIdle BackupState = iota
	BackupStateRunning
	BackupStateVerifying
	BackupStateComplete
	BackupStateFailed
	BackupStateCancelled
)

// RetentionPolicy represents the RetentionPolicy type (Idris2 ABI tags).
type RetentionPolicy uint8

const (
	RetentionPolicyKeepAll RetentionPolicy = iota
	RetentionPolicyKeepLast
	RetentionPolicyKeepDaily
	RetentionPolicyKeepWeekly
	RetentionPolicyKeepMonthly
)
