-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
||| C-ABI-compatible numeric encodings of the proven-timestamp enums, plus
||| the server lifecycle state machine.
|||
||| Every enum gets a total encoder, a partial decoder, and a round-trip
||| proof (encode-then-decode = identity).  Tag values here MUST match the
||| Zig FFI (ffi/zig/src/timestamp.zig) exactly.
module TimestampABI.Types

import Timestamp.Types

%default total

---------------------------------------------------------------------------
-- HashAlgo (4 constructors, tags 0-3)
---------------------------------------------------------------------------

public export
hashAlgoToTag : HashAlgo -> Bits8
hashAlgoToTag SHA256     = 0
hashAlgoToTag SHA512_256 = 1
hashAlgoToTag SHA3_256   = 2
hashAlgoToTag SHAKE256   = 3

public export
tagToHashAlgo : Bits8 -> Maybe HashAlgo
tagToHashAlgo 0 = Just SHA256
tagToHashAlgo 1 = Just SHA512_256
tagToHashAlgo 2 = Just SHA3_256
tagToHashAlgo 3 = Just SHAKE256
tagToHashAlgo _ = Nothing

public export
hashAlgoRoundtrip : (a : HashAlgo) -> tagToHashAlgo (hashAlgoToTag a) = Just a
hashAlgoRoundtrip SHA256     = Refl
hashAlgoRoundtrip SHA512_256 = Refl
hashAlgoRoundtrip SHA3_256   = Refl
hashAlgoRoundtrip SHAKE256   = Refl

---------------------------------------------------------------------------
-- TimestampSource (3 constructors, tags 0-2)
---------------------------------------------------------------------------

public export
sourceToTag : TimestampSource -> Bits8
sourceToTag Internal = 0
sourceToTag Rfc3161  = 1
sourceToTag Anchored = 2

public export
tagToSource : Bits8 -> Maybe TimestampSource
tagToSource 0 = Just Internal
tagToSource 1 = Just Rfc3161
tagToSource 2 = Just Anchored
tagToSource _ = Nothing

public export
sourceRoundtrip : (s : TimestampSource) -> tagToSource (sourceToTag s) = Just s
sourceRoundtrip Internal = Refl
sourceRoundtrip Rfc3161  = Refl
sourceRoundtrip Anchored = Refl

---------------------------------------------------------------------------
-- VerificationResult (4 constructors, tags 0-3)
---------------------------------------------------------------------------

public export
verificationToTag : VerificationResult -> Bits8
verificationToTag Verified        = 0
verificationToTag ContentMismatch = 1
verificationToTag ChainBroken     = 2
verificationToTag NotFound        = 3

public export
tagToVerification : Bits8 -> Maybe VerificationResult
tagToVerification 0 = Just Verified
tagToVerification 1 = Just ContentMismatch
tagToVerification 2 = Just ChainBroken
tagToVerification 3 = Just NotFound
tagToVerification _ = Nothing

public export
verificationRoundtrip : (v : VerificationResult) -> tagToVerification (verificationToTag v) = Just v
verificationRoundtrip Verified        = Refl
verificationRoundtrip ContentMismatch = Refl
verificationRoundtrip ChainBroken     = Refl
verificationRoundtrip NotFound        = Refl

---------------------------------------------------------------------------
-- ServerState (4 constructors, tags 0-3)
---------------------------------------------------------------------------

||| Lifecycle of a timestamp-log session.
|||
|||   Idle --start--> Active --seal--> Sealed --reopen--> Active
|||                   Active --shutdown--> Shutdown
|||                   Sealed --shutdown--> Shutdown
|||                   Shutdown --cleanup--> Idle
|||
||| Receipts may only be appended while Active.  Sealed is append-frozen but
||| still verifiable (the append-only log is never mutated in either state).
public export
data ServerState : Type where
  ||| Not started. Initial and terminal state.
  SSIdle     : ServerState
  ||| Accepting new timestamp submissions.
  SSActive   : ServerState
  ||| Append-frozen; reads and verification still allowed.
  SSSealed   : ServerState
  ||| Shutting down gracefully.
  SSShutdown : ServerState

public export
Eq ServerState where
  SSIdle     == SSIdle     = True
  SSActive   == SSActive   = True
  SSSealed   == SSSealed   = True
  SSShutdown == SSShutdown = True
  _          == _          = False

public export
Show ServerState where
  show SSIdle     = "Idle"
  show SSActive   = "Active"
  show SSSealed   = "Sealed"
  show SSShutdown = "Shutdown"

public export
serverStateToTag : ServerState -> Bits8
serverStateToTag SSIdle     = 0
serverStateToTag SSActive   = 1
serverStateToTag SSSealed   = 2
serverStateToTag SSShutdown = 3

public export
tagToServerState : Bits8 -> Maybe ServerState
tagToServerState 0 = Just SSIdle
tagToServerState 1 = Just SSActive
tagToServerState 2 = Just SSSealed
tagToServerState 3 = Just SSShutdown
tagToServerState _ = Nothing

public export
serverStateRoundtrip : (s : ServerState) -> tagToServerState (serverStateToTag s) = Just s
serverStateRoundtrip SSIdle     = Refl
serverStateRoundtrip SSActive   = Refl
serverStateRoundtrip SSSealed   = Refl
serverStateRoundtrip SSShutdown = Refl

---------------------------------------------------------------------------
-- State transitions
---------------------------------------------------------------------------

||| Proof witness that a server lifecycle transition is legal.
public export
data ValidServerTransition : ServerState -> ServerState -> Type where
  ||| Idle -> Active (open the log for submissions).
  StartLog       : ValidServerTransition SSIdle SSActive
  ||| Active -> Sealed (freeze appends).
  SealLog        : ValidServerTransition SSActive SSSealed
  ||| Sealed -> Active (resume appends).
  ReopenLog      : ValidServerTransition SSSealed SSActive
  ||| Active -> Shutdown (graceful stop from open).
  ShutdownActive : ValidServerTransition SSActive SSShutdown
  ||| Sealed -> Shutdown (graceful stop from frozen).
  ShutdownSealed : ValidServerTransition SSSealed SSShutdown
  ||| Shutdown -> Idle (cleanup complete).
  CleanupLog     : ValidServerTransition SSShutdown SSIdle

||| Decide whether a transition is legal, returning the witness.
public export
validateServerTransition : (from : ServerState) -> (to : ServerState)
                         -> Maybe (ValidServerTransition from to)
validateServerTransition SSIdle     SSActive   = Just StartLog
validateServerTransition SSActive   SSSealed   = Just SealLog
validateServerTransition SSSealed   SSActive   = Just ReopenLog
validateServerTransition SSActive   SSShutdown = Just ShutdownActive
validateServerTransition SSSealed   SSShutdown = Just ShutdownSealed
validateServerTransition SSShutdown SSIdle     = Just CleanupLog
validateServerTransition _          _          = Nothing

---------------------------------------------------------------------------
-- Impossibility proofs
---------------------------------------------------------------------------

||| You cannot jump straight from Idle to Shutdown.
public export
idleCannotShutdown : ValidServerTransition SSIdle SSShutdown -> Void
idleCannotShutdown _ impossible

||| A shut-down log cannot resume directly into Active (must cleanup first).
public export
shutdownCannotResume : ValidServerTransition SSShutdown SSActive -> Void
shutdownCannotResume _ impossible
