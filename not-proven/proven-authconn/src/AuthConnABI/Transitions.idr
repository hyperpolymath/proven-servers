-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- AuthConnABI.Transitions: Valid state transition proofs for authentication sessions.
--
-- This module defines:
--
--   1. ValidTransition — a GADT whose constructors enumerate every legal
--      state transition in the authentication lifecycle.  Only legal
--      transitions have constructors, so any function requiring a
--      ValidTransition proof is statically guaranteed to perform valid
--      transitions only.
--
--   2. CanAuthenticate — a proof witness that authentication can be
--      attempted (only from Unauthenticated).
--
--   3. CanAccessResource — a proof witness that the session is active
--      and resource access is permitted (only from Authenticated).
--
--   4. Impossibility proofs and decidability procedures.
--
-- The state machine modelled here is:
--
--   Unauthenticated --InitAuth--> Challenging --ChallengeOk--> Authenticated
--        |   ^            ^            |                           |   |
--        |   |            |            |                           |   |
--        |   +--ChallengeFail-+        +--ChallengeLock-->        |   |
--        |   |                                            |       |   |
--        |   +--- Locked <---------LockOut----------------+       |   |
--        |   |     |                                              |   |
--        |   +--Unlock                                            |   |
--        |                                                        |   |
--        +--DirectAuth------> Authenticated                       |   |
--                                  |                              |   |
--                                  +--SessionExpire--> Expired    |   |
--                                  |                     |        |   |
--                                  |       ReAuth--------+        |   |
--                                  |                              |   |
--                                  +--Revoke--------> Revoked     |   |
--                                                       |         |   |
--                                       ResetRevoked----+-->Unauth    |
--
-- Every arrow has exactly one ValidTransition constructor.

module AuthConnABI.Transitions

import AuthConn.Types

%default total

---------------------------------------------------------------------------
-- ValidTransition: exhaustive enumeration of legal state transitions.
---------------------------------------------------------------------------

||| Proof witness that a state transition is valid.
||| Only constructors for legal transitions exist — the type system
||| prevents any transition not listed here.
public export
data ValidTransition : AuthState -> AuthState -> Type where
  ||| Unauthenticated -> Challenging (challenge issued, e.g. MFA prompt).
  InitAuth        : ValidTransition Unauthenticated Challenging
  ||| Unauthenticated -> Authenticated (direct auth, no challenge needed).
  DirectAuth      : ValidTransition Unauthenticated Authenticated
  ||| Unauthenticated -> Locked (too many failed attempts).
  LockOut         : ValidTransition Unauthenticated Locked
  ||| Challenging -> Authenticated (challenge completed successfully).
  ChallengeOk     : ValidTransition Challenging Authenticated
  ||| Challenging -> Unauthenticated (challenge failed, try again).
  ChallengeFail   : ValidTransition Challenging Unauthenticated
  ||| Challenging -> Locked (too many challenge failures).
  ChallengeLock   : ValidTransition Challenging Locked
  ||| Authenticated -> Expired (session or token timed out).
  SessionExpire   : ValidTransition Authenticated Expired
  ||| Authenticated -> Revoked (explicit logout or admin revocation).
  Revoke          : ValidTransition Authenticated Revoked
  ||| Expired -> Unauthenticated (must re-authenticate).
  ReAuth          : ValidTransition Expired Unauthenticated
  ||| Revoked -> Unauthenticated (session cleared, start over).
  ResetRevoked    : ValidTransition Revoked Unauthenticated
  ||| Locked -> Unauthenticated (lockout expired or admin unlock).
  Unlock          : ValidTransition Locked Unauthenticated

||| Show instance for ValidTransition.
public export
Show (ValidTransition from to) where
  show InitAuth      = "InitAuth"
  show DirectAuth    = "DirectAuth"
  show LockOut       = "LockOut"
  show ChallengeOk   = "ChallengeOk"
  show ChallengeFail = "ChallengeFail"
  show ChallengeLock = "ChallengeLock"
  show SessionExpire = "SessionExpire"
  show Revoke        = "Revoke"
  show ReAuth        = "ReAuth"
  show ResetRevoked  = "ResetRevoked"
  show Unlock        = "Unlock"

---------------------------------------------------------------------------
-- CanAuthenticate: proof that authentication can be attempted.
---------------------------------------------------------------------------

||| Proof witness that an authentication attempt can be initiated.
||| Only Unauthenticated permits new authentication attempts — you
||| cannot re-authenticate while already authenticated, challenged,
||| expired, revoked, or locked.
public export
data CanAuthenticate : AuthState -> Type where
  ||| Authentication can be attempted when no session exists.
  AuthFromUnauthenticated : CanAuthenticate Unauthenticated

---------------------------------------------------------------------------
-- CanAccessResource: proof that resource access is permitted.
---------------------------------------------------------------------------

||| Proof witness that the session is active and resource access is allowed.
||| Only the Authenticated state permits resource access — all other states
||| represent sessions that are incomplete, expired, revoked, or locked.
public export
data CanAccessResource : AuthState -> Type where
  ||| Resource access is allowed when authenticated.
  AccessAuthenticated : CanAccessResource Authenticated

---------------------------------------------------------------------------
-- Impossibility proofs
---------------------------------------------------------------------------

||| Proof that you cannot authenticate when already Challenging.
public export
challengingCantAuth : CanAuthenticate Challenging -> Void
challengingCantAuth x impossible

||| Proof that you cannot authenticate when already Authenticated.
public export
authenticatedCantAuth : CanAuthenticate Authenticated -> Void
authenticatedCantAuth x impossible

||| Proof that you cannot authenticate when Expired.
public export
expiredCantAuth : CanAuthenticate Expired -> Void
expiredCantAuth x impossible

||| Proof that you cannot authenticate when Revoked.
public export
revokedCantAuth : CanAuthenticate Revoked -> Void
revokedCantAuth x impossible

||| Proof that you cannot authenticate when Locked.
public export
lockedCantAuth : CanAuthenticate Locked -> Void
lockedCantAuth x impossible

||| Proof that you cannot access resources when Unauthenticated.
public export
unauthenticatedCantAccess : CanAccessResource Unauthenticated -> Void
unauthenticatedCantAccess x impossible

||| Proof that you cannot access resources when Challenging.
public export
challengingCantAccess : CanAccessResource Challenging -> Void
challengingCantAccess x impossible

||| Proof that you cannot access resources when Expired.
public export
expiredCantAccess : CanAccessResource Expired -> Void
expiredCantAccess x impossible

||| Proof that you cannot access resources when Revoked.
public export
revokedCantAccess : CanAccessResource Revoked -> Void
revokedCantAccess x impossible

||| Proof that you cannot access resources when Locked.
public export
lockedCantAccess : CanAccessResource Locked -> Void
lockedCantAccess x impossible

---------------------------------------------------------------------------
-- Decidability: runtime decision procedures for capabilities.
---------------------------------------------------------------------------

||| Decide at runtime whether a given state permits authentication attempts.
public export
canAuthenticate : (s : AuthState) -> Dec (CanAuthenticate s)
canAuthenticate Unauthenticated = Yes AuthFromUnauthenticated
canAuthenticate Challenging     = No challengingCantAuth
canAuthenticate Authenticated   = No authenticatedCantAuth
canAuthenticate Expired         = No expiredCantAuth
canAuthenticate Revoked         = No revokedCantAuth
canAuthenticate Locked          = No lockedCantAuth

||| Decide at runtime whether a given state permits resource access.
public export
canAccessResource : (s : AuthState) -> Dec (CanAccessResource s)
canAccessResource Unauthenticated = No unauthenticatedCantAccess
canAccessResource Challenging     = No challengingCantAccess
canAccessResource Authenticated   = Yes AccessAuthenticated
canAccessResource Expired         = No expiredCantAccess
canAccessResource Revoked         = No revokedCantAccess
canAccessResource Locked          = No lockedCantAccess
