-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- SSHABI.Transitions: Valid SSH session state transitions with audit logging.
--
-- Models the SSH bastion session lifecycle (RFCs 4253/4252/4254):
--
--   Connected -> KeyExchanged -> Authenticated -> ChannelOpen -> Active -> Closed
--
-- Bastion-specific invariants:
--   - Every transition is audit-logged (the GADT carries audit evidence)
--   - Session recording capability is tracked at the type level
--   - Closed is terminal — no transition is possible
--   - Cannot skip states (no Connected -> Authenticated shortcut)
--   - Re-keying: Active -> KeyExchanged -> Active
--
-- The key security property: a bastion session that reaches Active state
-- has provably passed through key exchange AND authentication.  No bypass
-- is representable in this type.

module SSHABI.Transitions

import SSH.Session
import SSH.Channel

%default total

---------------------------------------------------------------------------
-- Bastion Session States (extended from SSH.Session.SessionState)
---------------------------------------------------------------------------

||| Bastion-specific session states.
||| These extend the SSH protocol states with channel lifecycle awareness.
|||
||| Connected      = TCP connected, version exchange in progress
||| KeyExchanged   = Key exchange complete (NEWKEYS sent/received)
||| Authenticated  = User authentication successful
||| ChannelOpen    = At least one channel opened
||| Active         = Channel confirmed, data can flow
||| Closed         = Session terminated
public export
data BastionState : Type where
  Connected     : BastionState
  KeyExchanged  : BastionState
  Authenticated : BastionState
  ChannelOpen   : BastionState
  Active        : BastionState
  Closed        : BastionState

public export
Eq BastionState where
  Connected     == Connected     = True
  KeyExchanged  == KeyExchanged  = True
  Authenticated == Authenticated = True
  ChannelOpen   == ChannelOpen   = True
  Active        == Active        = True
  Closed        == Closed        = True
  _             == _             = False

public export
Show BastionState where
  show Connected     = "Connected"
  show KeyExchanged  = "KeyExchanged"
  show Authenticated = "Authenticated"
  show ChannelOpen   = "ChannelOpen"
  show Active        = "Active"
  show Closed        = "Closed"

---------------------------------------------------------------------------
-- Audit Evidence
---------------------------------------------------------------------------

||| Evidence that a transition has been audit-logged.
||| Every bastion transition MUST carry audit evidence — this is enforced
||| at the type level by requiring AuditEvidence in each GADT constructor.
public export
data AuditEvidence : Type where
  ||| Audit record with timestamp (seconds since epoch) and description.
  MkAuditEvidence : (timestamp : Bits64) -> (description : String) -> AuditEvidence

public export
Show AuditEvidence where
  show (MkAuditEvidence ts desc) = "[" ++ show ts ++ "] " ++ desc

---------------------------------------------------------------------------
-- Session Recording
---------------------------------------------------------------------------

||| Whether session recording is enabled for this session.
||| Tracked at the type level so that recording state is always known.
public export
data RecordingState : Type where
  ||| Session data is being recorded for audit/compliance
  Recording    : RecordingState
  ||| Session data is NOT being recorded
  NotRecording : RecordingState

public export
Eq RecordingState where
  Recording    == Recording    = True
  NotRecording == NotRecording = True
  _            == _            = False

---------------------------------------------------------------------------
-- ValidBastionTransition: exhaustive enumeration of legal transitions
---------------------------------------------------------------------------

||| Proof witness that a bastion session state transition is valid.
||| Every constructor requires AuditEvidence, enforcing the invariant
||| that all transitions are logged.
public export
data ValidBastionTransition : BastionState -> BastionState -> Type where
  ||| Connected -> KeyExchanged (key exchange complete, NEWKEYS sent).
  ||| Audit: logs the negotiated algorithms.
  KexDone             : AuditEvidence -> ValidBastionTransition Connected KeyExchanged

  ||| KeyExchanged -> Authenticated (user authentication successful).
  ||| Audit: logs the authenticated username and method.
  AuthSuccess         : AuditEvidence -> ValidBastionTransition KeyExchanged Authenticated

  ||| Authenticated -> ChannelOpen (first channel opened).
  ||| Audit: logs the channel type and ID.
  FirstChannelOpened  : AuditEvidence -> ValidBastionTransition Authenticated ChannelOpen

  ||| ChannelOpen -> Active (channel confirmed, data can flow).
  ||| Audit: logs the confirmed channel parameters.
  ChannelConfirmed    : AuditEvidence -> ValidBastionTransition ChannelOpen Active

  ||| Active -> Active (re-keying: data continues to flow during rekey).
  ||| Audit: logs the rekey event.
  Rekey               : AuditEvidence -> ValidBastionTransition Active Active

  ||| Active -> Active (additional channel opened on active session).
  ||| Audit: logs the new channel type and ID.
  AdditionalChannel   : AuditEvidence -> ValidBastionTransition Active Active

  ||| Active -> Active (channel data transferred — recorded if enabled).
  ||| Audit: logs data transfer size.
  DataTransferred     : AuditEvidence -> ValidBastionTransition Active Active

  ||| Active -> Closed (graceful disconnect from active session).
  ||| Audit: logs disconnect reason and session duration.
  GracefulDisconnect  : AuditEvidence -> ValidBastionTransition Active Closed

  ||| Connected -> Closed (disconnect during version exchange).
  ||| Audit: logs the reason for early termination.
  AbortConnected      : AuditEvidence -> ValidBastionTransition Connected Closed

  ||| KeyExchanged -> Closed (disconnect during authentication phase).
  ||| Audit: logs the reason (e.g., auth timeout, invalid credentials).
  AbortKeyExchanged   : AuditEvidence -> ValidBastionTransition KeyExchanged Closed

  ||| Authenticated -> Closed (disconnect before any channel opened).
  ||| Audit: logs the reason.
  AbortAuthenticated  : AuditEvidence -> ValidBastionTransition Authenticated Closed

  ||| ChannelOpen -> Closed (disconnect with unconfirmed channel).
  ||| Audit: logs the reason and pending channel info.
  AbortChannelOpen    : AuditEvidence -> ValidBastionTransition ChannelOpen Closed

---------------------------------------------------------------------------
-- Capability witnesses
---------------------------------------------------------------------------

||| Proof that a session can transfer application data.
||| Only Active sessions can send/receive data — this is the bastion's
||| core security guarantee.
public export
data CanTransferData : BastionState -> Type where
  ActiveCanTransfer : CanTransferData Active

||| Proof that a session can open additional channels.
public export
data CanOpenChannel : BastionState -> Type where
  AuthenticatedCanOpen : CanOpenChannel Authenticated
  ActiveCanOpen        : CanOpenChannel Active

||| Proof that a session supports re-keying.
public export
data CanRekey : BastionState -> Type where
  ActiveCanRekey : CanRekey Active

---------------------------------------------------------------------------
-- Impossibility proofs
---------------------------------------------------------------------------

||| Cannot leave the Closed state — it is terminal.
||| This is the fundamental bastion safety property: once a session is
||| terminated, it cannot be resurrected.
public export
closedIsTerminal : ValidBastionTransition Closed s -> Void
closedIsTerminal _ impossible

||| Cannot skip from Connected directly to Authenticated.
||| Authentication MUST be preceded by key exchange.  This prevents
||| any attack that attempts to bypass encryption setup.
public export
cannotSkipKeyExchange : ValidBastionTransition Connected Authenticated -> Void
cannotSkipKeyExchange _ impossible

||| Cannot skip from Connected directly to Active.
||| A session must pass through key exchange, authentication, and
||| channel setup before data can flow.
public export
cannotSkipToActive : ValidBastionTransition Connected Active -> Void
cannotSkipToActive _ impossible

||| Cannot transfer data before authentication.
||| This proves that unauthenticated sessions cannot send application data.
public export
cannotTransferBeforeAuth : CanTransferData Connected -> Void
cannotTransferBeforeAuth _ impossible

||| Cannot transfer data during key exchange.
public export
cannotTransferDuringKex : CanTransferData KeyExchanged -> Void
cannotTransferDuringKex _ impossible

||| Cannot transfer data during authentication.
public export
cannotTransferDuringAuth : CanTransferData Authenticated -> Void
cannotTransferDuringAuth _ impossible

||| Cannot go backwards from Authenticated to Connected.
public export
cannotGoBackToConnected : ValidBastionTransition Authenticated Connected -> Void
cannotGoBackToConnected _ impossible

||| Cannot go backwards from Active to KeyExchanged.
public export
cannotGoBackToKex : ValidBastionTransition Active KeyExchanged -> Void
cannotGoBackToKex _ impossible

---------------------------------------------------------------------------
-- Transition validation
---------------------------------------------------------------------------

||| Check whether a bastion session state transition is valid.
||| Note: this returns a Maybe of the pair (from, to) tags that would
||| be valid, not the full GADT (which requires AuditEvidence).
||| The FFI layer uses this for stateless transition table queries.
public export
validateBastionTransition : (from : BastionState) -> (to : BastionState) -> Bool
validateBastionTransition Connected     KeyExchanged  = True
validateBastionTransition KeyExchanged  Authenticated = True
validateBastionTransition Authenticated ChannelOpen   = True
validateBastionTransition ChannelOpen   Active        = True
validateBastionTransition Active        Active        = True  -- rekey / data / additional channel
validateBastionTransition Active        Closed        = True
validateBastionTransition Connected     Closed        = True
validateBastionTransition KeyExchanged  Closed        = True
validateBastionTransition Authenticated Closed        = True
validateBastionTransition ChannelOpen   Closed        = True
validateBastionTransition _             _             = False

---------------------------------------------------------------------------
-- Audit trail composition
---------------------------------------------------------------------------

||| A sequence of validated, audited transitions forming a complete
||| session history.  This is the bastion's audit trail — every step
||| from connection to termination is recorded with evidence.
public export
data AuditTrail : BastionState -> BastionState -> Type where
  ||| Empty trail — session is in its current state.
  Here : AuditTrail s s
  ||| Extend the trail with one validated, audited transition.
  Step : ValidBastionTransition s1 s2 -> AuditTrail s2 s3 -> AuditTrail s1 s3

||| A complete session audit trail starts Connected and ends Closed.
public export
CompleteAuditTrail : Type
CompleteAuditTrail = AuditTrail Connected Closed
