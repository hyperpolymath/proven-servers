-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- RADIUSABI.Transitions: AAA lifecycle state machine for RADIUS sessions.
--
-- Models the Authentication, Authorization, Accounting (AAA) lifecycle
-- of a RADIUS session as a GADT with formal proof witnesses.
--
-- Session lifecycle diagram:
--
--   Idle --Receive(AccessRequest)--> Authenticating
--     |                                    |
--     |                         +----------+----------+
--     |                         |          |          |
--     |                      Accept     Reject    Challenge
--     |                         |          |          |
--     |                         v          v          v
--     |                    Authorized   Rejected   Challenged
--     |                         |                     |
--     |                         v                     |
--     |                    Accounting                 |
--     |                         |           (re-authenticate)
--     |                         v                     |
--     |                     Complete                  |
--     |                         |                     |
--     +---<---Timeout/Done---<--+--<--Timeout--<------+
--
-- Additionally, any active state can transition to Idle on timeout,
-- and Authenticating can loop through Challenged back to Authenticating.
--
-- Every arrow has exactly one ValidRadiusTransition constructor.
-- The type system prevents any transition not listed here.

module RADIUSABI.Transitions

import RADIUS.Types
import RADIUSABI.Layout

%default total

---------------------------------------------------------------------------
-- Session state (AAA lifecycle phases)
---------------------------------------------------------------------------

||| Session lifecycle states for a RADIUS AAA interaction.
||| Each state corresponds to a distinct phase in the RADIUS protocol flow.
public export
data SessionState : Type where
  ||| No active session; waiting for an Access-Request.
  Idle           : SessionState
  ||| Access-Request received; authentication is in progress.
  Authenticating : SessionState
  ||| Authentication succeeded; authorisation attributes assigned.
  Authorized     : SessionState
  ||| Authentication failed; Access-Reject sent.
  Rejected       : SessionState
  ||| Server issued an Access-Challenge; awaiting client response.
  Challenged     : SessionState
  ||| Accounting phase (Accounting-Request received and acknowledged).
  Accounting     : SessionState
  ||| Session fully complete (Accounting-Response sent or session ended).
  Complete       : SessionState

public export
Eq SessionState where
  Idle           == Idle           = True
  Authenticating == Authenticating = True
  Authorized     == Authorized     = True
  Rejected       == Rejected       = True
  Challenged     == Challenged     = True
  Accounting     == Accounting     = True
  Complete       == Complete       = True
  _              == _              = False

public export
Show SessionState where
  show Idle           = "Idle(0)"
  show Authenticating = "Authenticating(1)"
  show Authorized     = "Authorized(2)"
  show Rejected       = "Rejected(3)"
  show Challenged     = "Challenged(4)"
  show Accounting     = "Accounting(5)"
  show Complete       = "Complete(6)"

---------------------------------------------------------------------------
-- SessionState C-ABI tags (tags 0-6)
---------------------------------------------------------------------------

||| C-ABI representation size for SessionState (1 byte).
public export
sessionStateSize : Nat
sessionStateSize = 1

||| Map SessionState to its C-ABI byte value.
public export
sessionStateToTag : SessionState -> Bits8
sessionStateToTag Idle           = 0
sessionStateToTag Authenticating = 1
sessionStateToTag Authorized     = 2
sessionStateToTag Rejected       = 3
sessionStateToTag Challenged     = 4
sessionStateToTag Accounting     = 5
sessionStateToTag Complete       = 6

||| Recover SessionState from its C-ABI byte value.
public export
tagToSessionState : Bits8 -> Maybe SessionState
tagToSessionState 0 = Just Idle
tagToSessionState 1 = Just Authenticating
tagToSessionState 2 = Just Authorized
tagToSessionState 3 = Just Rejected
tagToSessionState 4 = Just Challenged
tagToSessionState 5 = Just Accounting
tagToSessionState 6 = Just Complete
tagToSessionState _ = Nothing

||| Proof: encoding then decoding SessionState is the identity.
public export
sessionStateRoundtrip : (s : SessionState) -> tagToSessionState (sessionStateToTag s) = Just s
sessionStateRoundtrip Idle           = Refl
sessionStateRoundtrip Authenticating = Refl
sessionStateRoundtrip Authorized     = Refl
sessionStateRoundtrip Rejected       = Refl
sessionStateRoundtrip Challenged     = Refl
sessionStateRoundtrip Accounting     = Refl
sessionStateRoundtrip Complete       = Refl

---------------------------------------------------------------------------
-- ValidRadiusTransition: exhaustive enumeration of legal AAA transitions
---------------------------------------------------------------------------

||| Proof witness that a RADIUS session state transition is valid.
||| Only constructors for legal transitions exist -- the type system
||| prevents any transition not listed here.
public export
data ValidRadiusTransition : SessionState -> SessionState -> Type where
  ||| Idle -> Authenticating (Access-Request received).
  BeginAuth      : ValidRadiusTransition Idle Authenticating
  ||| Authenticating -> Authorized (authentication succeeded, Access-Accept sent).
  AcceptAuth     : ValidRadiusTransition Authenticating Authorized
  ||| Authenticating -> Rejected (authentication failed, Access-Reject sent).
  RejectAuth     : ValidRadiusTransition Authenticating Rejected
  ||| Authenticating -> Challenged (Access-Challenge sent, awaiting response).
  ChallengeAuth  : ValidRadiusTransition Authenticating Challenged
  ||| Challenged -> Authenticating (client responded to challenge).
  RespondChallenge : ValidRadiusTransition Challenged Authenticating
  ||| Authorized -> Accounting (Accounting-Request received).
  BeginAccounting : ValidRadiusTransition Authorized Accounting
  ||| Accounting -> Complete (Accounting-Response sent, session ended).
  EndAccounting  : ValidRadiusTransition Accounting Complete
  ||| Authorized -> Complete (session ended without accounting).
  EndAuthorized  : ValidRadiusTransition Authorized Complete
  ||| Complete -> Idle (session slot released, ready for reuse).
  SessionDone    : ValidRadiusTransition Complete Idle
  ||| Rejected -> Idle (rejection acknowledged, slot released).
  RejectionDone  : ValidRadiusTransition Rejected Idle
  ||| Challenged -> Idle (challenge timed out, slot released).
  ChallengeTimeout : ValidRadiusTransition Challenged Idle

---------------------------------------------------------------------------
-- Capability witnesses
---------------------------------------------------------------------------

||| Proof that a session is in a state that can receive an Access-Request.
||| Only Idle sessions can begin authentication.
public export
data CanAuthenticate : SessionState -> Type where
  IdleCanAuth : CanAuthenticate Idle

||| Proof that a session is in a state that can receive accounting data.
||| Only Authorized sessions can begin accounting.
public export
data CanAccount : SessionState -> Type where
  AuthorizedCanAccount : CanAccount Authorized

||| Proof that a session is in a state that can issue a challenge response.
||| Only Challenged sessions can respond.
public export
data CanRespondToChallenge : SessionState -> Type where
  ChallengedCanRespond : CanRespondToChallenge Challenged

---------------------------------------------------------------------------
-- Impossibility proofs
---------------------------------------------------------------------------

||| An Idle session cannot be directly authorized (must authenticate first).
public export
idleCannotAuthorize : ValidRadiusTransition Idle Authorized -> Void
idleCannotAuthorize _ impossible

||| An Idle session cannot be directly rejected (must authenticate first).
public export
idleCannotReject : ValidRadiusTransition Idle Rejected -> Void
idleCannotReject _ impossible

||| A Complete session cannot begin authentication (must return to Idle first).
public export
completeCannotAuth : ValidRadiusTransition Complete Authenticating -> Void
completeCannotAuth _ impossible

||| A Rejected session cannot be authorized (authentication already failed).
public export
rejectedCannotAuthorize : ValidRadiusTransition Rejected Authorized -> Void
rejectedCannotAuthorize _ impossible

||| An Accounting session cannot go back to Authenticating.
public export
accountingCannotReauth : ValidRadiusTransition Accounting Authenticating -> Void
accountingCannotReauth _ impossible

||| An Authorized session cannot go back to Authenticating.
public export
authorizedCannotReauth : ValidRadiusTransition Authorized Authenticating -> Void
authorizedCannotReauth _ impossible

||| A Complete session cannot begin accounting (session is over).
public export
completeCannotAccount : ValidRadiusTransition Complete Accounting -> Void
completeCannotAccount _ impossible

---------------------------------------------------------------------------
-- Transition validation function
---------------------------------------------------------------------------

||| Check whether a transition between two session states is valid.
||| Returns the proof witness if valid, Nothing otherwise.
public export
validateTransition : (from : SessionState) -> (to : SessionState)
                   -> Maybe (ValidRadiusTransition from to)
validateTransition Idle           Authenticating = Just BeginAuth
validateTransition Authenticating Authorized     = Just AcceptAuth
validateTransition Authenticating Rejected       = Just RejectAuth
validateTransition Authenticating Challenged     = Just ChallengeAuth
validateTransition Challenged     Authenticating = Just RespondChallenge
validateTransition Authorized     Accounting     = Just BeginAccounting
validateTransition Accounting     Complete       = Just EndAccounting
validateTransition Authorized     Complete       = Just EndAuthorized
validateTransition Complete       Idle           = Just SessionDone
validateTransition Rejected       Idle           = Just RejectionDone
validateTransition Challenged     Idle           = Just ChallengeTimeout
validateTransition _              _              = Nothing

---------------------------------------------------------------------------
-- All session states enumeration
---------------------------------------------------------------------------

||| All session states.
public export
allSessionStates : List SessionState
allSessionStates = [Idle, Authenticating, Authorized, Rejected,
                    Challenged, Accounting, Complete]
