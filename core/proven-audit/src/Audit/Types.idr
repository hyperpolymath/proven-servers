-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- Audit.Types: Core type definitions for provably complete audit trails.
-- Closed sum types representing audit levels, event categories, integrity
-- mechanisms, retention policies, and audit errors — so every state
-- transition can be logged provably.

module Audit.Types

%default total

---------------------------------------------------------------------------
-- Audit level — how much detail to record.
---------------------------------------------------------------------------

||| The verbosity level for audit logging.
public export
data AuditLevel : Type where
  ||| No audit logging.
  None    : AuditLevel
  ||| Log only critical events (auth, errors).
  Minimal : AuditLevel
  ||| Log standard events (state transitions, data access).
  Standard : AuditLevel
  ||| Log detailed events including internal operations.
  Verbose : AuditLevel
  ||| Log everything — full packet-level detail.
  Full    : AuditLevel

public export
Show AuditLevel where
  show None     = "None"
  show Minimal  = "Minimal"
  show Standard = "Standard"
  show Verbose  = "Verbose"
  show Full     = "Full"

---------------------------------------------------------------------------
-- Event category — what kind of event occurred.
---------------------------------------------------------------------------

||| The category of an auditable event.
public export
data EventCategory : Type where
  ||| A state machine transition occurred.
  StateTransition : EventCategory
  ||| An authentication attempt (success or failure).
  Authentication  : EventCategory
  ||| An authorization decision was made.
  Authorization   : EventCategory
  ||| Data was accessed (read or written).
  DataAccess      : EventCategory
  ||| Configuration was changed.
  Configuration   : EventCategory
  ||| An error occurred.
  Error           : EventCategory
  ||| A security-relevant event (e.g., TLS renegotiation).
  Security        : EventCategory
  ||| A lifecycle event (startup, shutdown, restart).
  Lifecycle       : EventCategory

public export
Show EventCategory where
  show StateTransition = "StateTransition"
  show Authentication  = "Authentication"
  show Authorization   = "Authorization"
  show DataAccess      = "DataAccess"
  show Configuration   = "Configuration"
  show Error           = "Error"
  show Security        = "Security"
  show Lifecycle       = "Lifecycle"

---------------------------------------------------------------------------
-- Integrity — how audit records are protected from tampering.
---------------------------------------------------------------------------

||| The integrity mechanism protecting audit records.
public export
data Integrity : Type where
  ||| No integrity protection.
  Unsigned   : Integrity
  ||| HMAC-based message authentication code.
  HMAC       : Integrity
  ||| Digital signature (asymmetric).
  Signed     : Integrity
  ||| Hash-chained (each record includes hash of previous).
  Chained    : Integrity
  ||| Merkle tree proof (batch integrity verification).
  MerkleProof : Integrity

public export
Show Integrity where
  show Unsigned    = "Unsigned"
  show HMAC        = "HMAC"
  show Signed      = "Signed"
  show Chained     = "Chained"
  show MerkleProof = "MerkleProof"

---------------------------------------------------------------------------
-- Retention policy — how long audit records are kept.
---------------------------------------------------------------------------

||| How long audit records are retained.
public export
data RetentionPolicy : Type where
  ||| Records are discarded after use (not persisted).
  Ephemeral  : RetentionPolicy
  ||| Records are kept for the duration of a session.
  Session    : RetentionPolicy
  ||| Records are kept for one day.
  Daily      : RetentionPolicy
  ||| Records are kept indefinitely.
  Indefinite : RetentionPolicy
  ||| Records are kept per regulatory requirements.
  Regulatory : RetentionPolicy

public export
Show RetentionPolicy where
  show Ephemeral  = "Ephemeral"
  show Session    = "Session"
  show Daily      = "Daily"
  show Indefinite = "Indefinite"
  show Regulatory = "Regulatory"

---------------------------------------------------------------------------
-- Audit error — errors that arise during audit operations.
---------------------------------------------------------------------------

||| Errors that can arise during audit logging operations.
public export
data AuditError : Type where
  ||| The audit storage is full.
  StorageFull         : AuditError
  ||| Failed to write the audit record.
  WriteFailure        : AuditError
  ||| The integrity check on an existing record failed.
  IntegrityViolation  : AuditError
  ||| The timestamp could not be obtained or is invalid.
  TimestampError      : AuditError
  ||| The hash chain is broken (missing or mismatched link).
  ChainBroken         : AuditError

public export
Show AuditError where
  show StorageFull        = "StorageFull"
  show WriteFailure       = "WriteFailure"
  show IntegrityViolation = "IntegrityViolation"
  show TimestampError     = "TimestampError"
  show ChainBroken        = "ChainBroken"
