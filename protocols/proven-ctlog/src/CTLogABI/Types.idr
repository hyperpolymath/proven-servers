-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
--
-- CTLogABI.Types: C-ABI-compatible numeric representations of CT Log types.
--
-- Maps every constructor of the core CT Log sum types to fixed Bits8 values
-- for C interop. Each type gets a total encoder, partial decoder, and
-- roundtrip proof (encode then decode = identity).
--
-- Tag values here MUST match the Zig FFI enums (ffi/zig/src/ctlog.zig) exactly.
--
-- Types covered:
--   LogEntryType       (2 constructors, tags 0-1)
--   SignatureType      (2 constructors, tags 0-1)
--   MerkleLeafType     (1 constructor,  tag  0)
--   SubmissionStatus   (6 constructors, tags 0-5)
--   VerificationResult (4 constructors, tags 0-3)
--   ServerState        (5 constructors, tags 0-4)

module CTLogABI.Types

import CTLog.Types

%default total

---------------------------------------------------------------------------
-- LogEntryType (2 constructors, tags 0-1)
---------------------------------------------------------------------------

public export
logEntryTypeToTag : LogEntryType -> Bits8
logEntryTypeToTag X509Entry    = 0
logEntryTypeToTag PrecertEntry = 1

public export
tagToLogEntryType : Bits8 -> Maybe LogEntryType
tagToLogEntryType 0 = Just X509Entry
tagToLogEntryType 1 = Just PrecertEntry
tagToLogEntryType _ = Nothing

public export
logEntryTypeRoundtrip : (e : LogEntryType) -> tagToLogEntryType (logEntryTypeToTag e) = Just e
logEntryTypeRoundtrip X509Entry    = Refl
logEntryTypeRoundtrip PrecertEntry = Refl

---------------------------------------------------------------------------
-- SignatureType (2 constructors, tags 0-1)
---------------------------------------------------------------------------

public export
signatureTypeToTag : SignatureType -> Bits8
signatureTypeToTag CertificateTimestamp = 0
signatureTypeToTag TreeHash             = 1

public export
tagToSignatureType : Bits8 -> Maybe SignatureType
tagToSignatureType 0 = Just CertificateTimestamp
tagToSignatureType 1 = Just TreeHash
tagToSignatureType _ = Nothing

public export
signatureTypeRoundtrip : (s : SignatureType) -> tagToSignatureType (signatureTypeToTag s) = Just s
signatureTypeRoundtrip CertificateTimestamp = Refl
signatureTypeRoundtrip TreeHash             = Refl

---------------------------------------------------------------------------
-- MerkleLeafType (1 constructor, tag 0)
---------------------------------------------------------------------------

public export
merkleLeafTypeToTag : MerkleLeafType -> Bits8
merkleLeafTypeToTag TimestampedEntry = 0

public export
tagToMerkleLeafType : Bits8 -> Maybe MerkleLeafType
tagToMerkleLeafType 0 = Just TimestampedEntry
tagToMerkleLeafType _ = Nothing

public export
merkleLeafTypeRoundtrip : (m : MerkleLeafType) -> tagToMerkleLeafType (merkleLeafTypeToTag m) = Just m
merkleLeafTypeRoundtrip TimestampedEntry = Refl

---------------------------------------------------------------------------
-- SubmissionStatus (6 constructors, tags 0-5)
---------------------------------------------------------------------------

public export
submissionStatusToTag : SubmissionStatus -> Bits8
submissionStatusToTag Accepted      = 0
submissionStatusToTag Duplicate     = 1
submissionStatusToTag RateLimited   = 2
submissionStatusToTag Rejected      = 3
submissionStatusToTag InvalidChain  = 4
submissionStatusToTag UnknownAnchor = 5

public export
tagToSubmissionStatus : Bits8 -> Maybe SubmissionStatus
tagToSubmissionStatus 0 = Just Accepted
tagToSubmissionStatus 1 = Just Duplicate
tagToSubmissionStatus 2 = Just RateLimited
tagToSubmissionStatus 3 = Just Rejected
tagToSubmissionStatus 4 = Just InvalidChain
tagToSubmissionStatus 5 = Just UnknownAnchor
tagToSubmissionStatus _ = Nothing

public export
submissionStatusRoundtrip : (s : SubmissionStatus) -> tagToSubmissionStatus (submissionStatusToTag s) = Just s
submissionStatusRoundtrip Accepted      = Refl
submissionStatusRoundtrip Duplicate     = Refl
submissionStatusRoundtrip RateLimited   = Refl
submissionStatusRoundtrip Rejected      = Refl
submissionStatusRoundtrip InvalidChain  = Refl
submissionStatusRoundtrip UnknownAnchor = Refl

---------------------------------------------------------------------------
-- VerificationResult (4 constructors, tags 0-3)
---------------------------------------------------------------------------

public export
verificationResultToTag : VerificationResult -> Bits8
verificationResultToTag ValidProof       = 0
verificationResultToTag InvalidProof     = 1
verificationResultToTag InconsistentTree = 2
verificationResultToTag StaleSTH         = 3

public export
tagToVerificationResult : Bits8 -> Maybe VerificationResult
tagToVerificationResult 0 = Just ValidProof
tagToVerificationResult 1 = Just InvalidProof
tagToVerificationResult 2 = Just InconsistentTree
tagToVerificationResult 3 = Just StaleSTH
tagToVerificationResult _ = Nothing

public export
verificationResultRoundtrip : (v : VerificationResult) -> tagToVerificationResult (verificationResultToTag v) = Just v
verificationResultRoundtrip ValidProof       = Refl
verificationResultRoundtrip InvalidProof     = Refl
verificationResultRoundtrip InconsistentTree = Refl
verificationResultRoundtrip StaleSTH         = Refl

---------------------------------------------------------------------------
-- ServerState (5 constructors, tags 0-4)
-- Composite lifecycle state used by the FFI for simplified management.
---------------------------------------------------------------------------

||| CT Log server lifecycle states.
||| Simplified view used by the FFI layer for the C ABI.
public export
data ServerState : Type where
  ||| Server not started. Initial and terminal state.
  SSIdle       : ServerState
  ||| Server initialised and accepting submissions.
  SSActive     : ServerState
  ||| Merging new entries into the Merkle tree.
  SSMerging    : ServerState
  ||| Signing a new Signed Tree Head (STH).
  SSSigning    : ServerState
  ||| Server shutting down gracefully.
  SSShutdown   : ServerState

public export
Eq ServerState where
  SSIdle     == SSIdle     = True
  SSActive   == SSActive   = True
  SSMerging  == SSMerging  = True
  SSSigning  == SSSigning  = True
  SSShutdown == SSShutdown = True
  _          == _          = False

public export
Show ServerState where
  show SSIdle     = "Idle"
  show SSActive   = "Active"
  show SSMerging  = "Merging"
  show SSSigning  = "Signing"
  show SSShutdown = "Shutdown"

public export
serverStateToTag : ServerState -> Bits8
serverStateToTag SSIdle     = 0
serverStateToTag SSActive   = 1
serverStateToTag SSMerging  = 2
serverStateToTag SSSigning  = 3
serverStateToTag SSShutdown = 4

public export
tagToServerState : Bits8 -> Maybe ServerState
tagToServerState 0 = Just SSIdle
tagToServerState 1 = Just SSActive
tagToServerState 2 = Just SSMerging
tagToServerState 3 = Just SSSigning
tagToServerState 4 = Just SSShutdown
tagToServerState _ = Nothing

public export
serverStateRoundtrip : (s : ServerState) -> tagToServerState (serverStateToTag s) = Just s
serverStateRoundtrip SSIdle     = Refl
serverStateRoundtrip SSActive   = Refl
serverStateRoundtrip SSMerging  = Refl
serverStateRoundtrip SSSigning  = Refl
serverStateRoundtrip SSShutdown = Refl

---------------------------------------------------------------------------
-- Transition validation
---------------------------------------------------------------------------

||| Proof witness that a CT Log server state transition is valid.
public export
data ValidServerTransition : ServerState -> ServerState -> Type where
  ||| Idle -> Active (server starts, ready for submissions).
  ServerStarted     : ValidServerTransition SSIdle SSActive
  ||| Active -> Merging (begin integrating pending entries).
  BeginMerge        : ValidServerTransition SSActive SSMerging
  ||| Merging -> Active (merge complete, resume accepting).
  MergeDone         : ValidServerTransition SSMerging SSActive
  ||| Merging -> Signing (tree updated, sign new STH).
  BeginSign         : ValidServerTransition SSMerging SSSigning
  ||| Signing -> Active (STH published, resume operations).
  SignDone           : ValidServerTransition SSSigning SSActive
  ||| Active -> Shutdown (graceful shutdown initiated).
  ShutdownFromActive : ValidServerTransition SSActive SSShutdown
  ||| Merging -> Shutdown (shutdown during merge).
  ShutdownFromMerge  : ValidServerTransition SSMerging SSShutdown
  ||| Signing -> Shutdown (shutdown during signing).
  ShutdownFromSign   : ValidServerTransition SSSigning SSShutdown
  ||| Shutdown -> Idle (cleanup complete).
  CleanupDone        : ValidServerTransition SSShutdown SSIdle

||| Check whether a server state transition is valid.
public export
validateServerTransition : (from : ServerState) -> (to : ServerState)
                         -> Maybe (ValidServerTransition from to)
validateServerTransition SSIdle     SSActive   = Just ServerStarted
validateServerTransition SSActive   SSMerging  = Just BeginMerge
validateServerTransition SSMerging  SSActive   = Just MergeDone
validateServerTransition SSMerging  SSSigning  = Just BeginSign
validateServerTransition SSSigning  SSActive   = Just SignDone
validateServerTransition SSActive   SSShutdown = Just ShutdownFromActive
validateServerTransition SSMerging  SSShutdown = Just ShutdownFromMerge
validateServerTransition SSSigning  SSShutdown = Just ShutdownFromSign
validateServerTransition SSShutdown SSIdle     = Just CleanupDone
validateServerTransition _          _          = Nothing

---------------------------------------------------------------------------
-- Impossibility proofs
---------------------------------------------------------------------------

||| Cannot accept submissions from Idle.
public export
idleCannotSubmit : ValidServerTransition SSIdle SSMerging -> Void
idleCannotSubmit _ impossible

||| Cannot go from Shutdown back to Active directly.
public export
cannotResumeFromShutdown : ValidServerTransition SSShutdown SSActive -> Void
cannotResumeFromShutdown _ impossible
