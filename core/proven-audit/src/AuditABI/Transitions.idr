-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- AuditABI.Transitions: Valid audit trail lifecycle proofs.
--
-- Models the lifecycle of an audit trail session:
--
--   Idle --Open--> Recording --Seal--> Sealed
--   Recording --Fail--> Failed
--   Failed --Reset--> Idle
--   Sealed --Archive--> Archived
--   Sealed --Reset--> Idle
--   Archived --Reset--> Idle
--
-- Key invariants:
--   - Cannot record events on a sealed or archived trail
--   - Cannot seal an idle or already-sealed trail
--   - Cannot archive without sealing first
--   - Failed trails must be reset before reuse

module AuditABI.Transitions

import Audit.Types

%default total

---------------------------------------------------------------------------
-- AuditTrailState — the lifecycle state of an audit trail session.
---------------------------------------------------------------------------

||| The lifecycle state of an audit trail session.
public export
data AuditTrailState : Type where
  ||| No audit trail in progress.
  Idle      : AuditTrailState
  ||| Actively recording audit events.
  Recording : AuditTrailState
  ||| Trail has been sealed (integrity-protected, no more writes).
  Sealed    : AuditTrailState
  ||| Trail has been archived (long-term storage).
  Archived  : AuditTrailState
  ||| Trail recording failed with an error.
  Failed    : AuditTrailState

public export
Show AuditTrailState where
  show Idle      = "Idle"
  show Recording = "Recording"
  show Sealed    = "Sealed"
  show Archived  = "Archived"
  show Failed    = "Failed"

---------------------------------------------------------------------------
-- ValidAuditTransition: exhaustive enumeration of legal transitions.
---------------------------------------------------------------------------

||| Proof witness that an audit trail state transition is valid.
public export
data ValidAuditTransition : AuditTrailState -> AuditTrailState -> Type where
  ||| Idle -> Recording (begin audit trail).
  Open          : ValidAuditTransition Idle Recording
  ||| Recording -> Sealed (finalise and integrity-protect).
  Seal          : ValidAuditTransition Recording Sealed
  ||| Recording -> Failed (recording error).
  FailRecording : ValidAuditTransition Recording Failed
  ||| Sealed -> Archived (move to long-term storage).
  Archive       : ValidAuditTransition Sealed Archived
  ||| Sealed -> Idle (discard sealed trail, reuse slot).
  ResetSealed   : ValidAuditTransition Sealed Idle
  ||| Archived -> Idle (release archived trail, reuse slot).
  ResetArchived : ValidAuditTransition Archived Idle
  ||| Failed -> Idle (reset after error).
  ResetFailed   : ValidAuditTransition Failed Idle

---------------------------------------------------------------------------
-- Capability witnesses
---------------------------------------------------------------------------

||| Proof that an audit trail can accept new events (recording in progress).
public export
data CanRecord : AuditTrailState -> Type where
  RecordingCanRecord : CanRecord Recording

||| Proof that an audit trail can be sealed (recording in progress).
public export
data CanSeal : AuditTrailState -> Type where
  RecordingCanSeal : CanSeal Recording

---------------------------------------------------------------------------
-- Impossibility proofs
---------------------------------------------------------------------------

||| Cannot record on a sealed trail.
public export
sealedCannotRecord : ValidAuditTransition Sealed Recording -> Void
sealedCannotRecord _ impossible

||| Cannot record on an archived trail.
public export
archivedCannotRecord : ValidAuditTransition Archived Recording -> Void
archivedCannotRecord _ impossible

||| Cannot seal an idle trail (must open first).
public export
idleCannotSeal : ValidAuditTransition Idle Sealed -> Void
idleCannotSeal _ impossible

||| Cannot archive without sealing first.
public export
recordingCannotArchive : ValidAuditTransition Recording Archived -> Void
recordingCannotArchive _ impossible

||| Cannot open a trail that is already recording.
public export
recordingCannotReopen : ValidAuditTransition Recording Recording -> Void
recordingCannotReopen _ impossible

||| Cannot archive a failed trail.
public export
failedCannotArchive : ValidAuditTransition Failed Archived -> Void
failedCannotArchive _ impossible

---------------------------------------------------------------------------
-- Transition validation
---------------------------------------------------------------------------

||| Check whether an audit trail state transition is valid.
public export
validateAuditTransition : (from : AuditTrailState) -> (to : AuditTrailState) -> Maybe (ValidAuditTransition from to)
validateAuditTransition Idle      Recording = Just Open
validateAuditTransition Recording Sealed    = Just Seal
validateAuditTransition Recording Failed    = Just FailRecording
validateAuditTransition Sealed    Archived  = Just Archive
validateAuditTransition Sealed    Idle      = Just ResetSealed
validateAuditTransition Archived  Idle      = Just ResetArchived
validateAuditTransition Failed    Idle      = Just ResetFailed
validateAuditTransition _ _                 = Nothing
