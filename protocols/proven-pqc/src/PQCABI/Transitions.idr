-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
--
-- PQCABI.Transitions: Key lifecycle state transitions and hybrid negotiation.
--
-- Models the PQC key material lifecycle:
--
--   Empty --> Generating --> Generated --> Active --> Expired
--                                      --> Compromised
--
-- And the hybrid negotiation lifecycle:
--
--   Idle --> ClassicalSelected --> PQCSelected --> HybridNegotiated --> Complete
--
-- Key invariants:
--   - Expired and Compromised are terminal (no outbound edges).
--   - Cannot use a key that is not in Active state.
--   - Cannot skip from Empty directly to Active.
--   - Hybrid negotiation requires both classical and PQC selection.
--   - Compromised keys cannot transition to any state (must be destroyed).

module PQCABI.Transitions

import PQC.Types

%default total

---------------------------------------------------------------------------
-- Key lifecycle states
---------------------------------------------------------------------------

||| The lifecycle state of a PQC key context.
public export
data KeyState : Type where
  ||| No key material has been allocated.
  Empty        : KeyState
  ||| Key generation is in progress.
  Generating   : KeyState
  ||| Key pair has been generated but is not yet activated.
  Generated    : KeyState
  ||| Key is active and available for cryptographic operations.
  Active       : KeyState
  ||| Key has expired (time-based or usage-count-based).
  Expired      : KeyState
  ||| Key has been marked as compromised (requires immediate rotation).
  Compromised  : KeyState

public export
Eq KeyState where
  Empty       == Empty       = True
  Generating  == Generating  = True
  Generated   == Generated   = True
  Active      == Active      = True
  Expired     == Expired     = True
  Compromised == Compromised = True
  _           == _           = False

---------------------------------------------------------------------------
-- ValidKeyTransition: exhaustive enumeration of legal key state changes.
---------------------------------------------------------------------------

||| Proof witness that a key lifecycle state transition is valid.
public export
data ValidKeyTransition : KeyState -> KeyState -> Type where
  ||| Empty -> Generating (begin key generation).
  BeginKeyGen     : ValidKeyTransition Empty Generating
  ||| Generating -> Generated (key generation complete).
  FinishKeyGen    : ValidKeyTransition Generating Generated
  ||| Generated -> Active (activate key for use).
  ActivateKey     : ValidKeyTransition Generated Active
  ||| Active -> Expired (key reaches end of life).
  ExpireKey       : ValidKeyTransition Active Expired
  ||| Active -> Compromised (key compromise detected).
  CompromiseKey   : ValidKeyTransition Active Compromised
  ||| Generated -> Expired (key expired before activation).
  ExpireBeforeUse : ValidKeyTransition Generated Expired
  ||| Empty -> Expired (abort: context destroyed without generating).
  AbortEmpty      : ValidKeyTransition Empty Expired
  ||| Generating -> Expired (abort: generation failed/timed out).
  AbortGenerating : ValidKeyTransition Generating Expired

---------------------------------------------------------------------------
-- Hybrid negotiation states
---------------------------------------------------------------------------

||| The lifecycle state of a hybrid key agreement negotiation.
public export
data HybridState : Type where
  ||| No negotiation has begun.
  HybridIdle          : HybridState
  ||| Classical algorithm has been selected.
  ClassicalSelected   : HybridState
  ||| PQC algorithm has been selected.
  PQCSelected         : HybridState
  ||| Both algorithms selected, hybrid combination negotiated.
  HybridNegotiated    : HybridState
  ||| Negotiation is complete, shared secret is established.
  HybridComplete      : HybridState

public export
Eq HybridState where
  HybridIdle        == HybridIdle        = True
  ClassicalSelected == ClassicalSelected = True
  PQCSelected       == PQCSelected       = True
  HybridNegotiated  == HybridNegotiated  = True
  HybridComplete    == HybridComplete    = True
  _                 == _                 = False

---------------------------------------------------------------------------
-- ValidHybridTransition: legal hybrid negotiation state changes.
---------------------------------------------------------------------------

||| Proof witness that a hybrid negotiation state transition is valid.
public export
data ValidHybridTransition : HybridState -> HybridState -> Type where
  ||| Idle -> ClassicalSelected (select classical algorithm first).
  SelectClassical     : ValidHybridTransition HybridIdle ClassicalSelected
  ||| Idle -> PQCSelected (select PQC algorithm first).
  SelectPQC           : ValidHybridTransition HybridIdle PQCSelected
  ||| ClassicalSelected -> HybridNegotiated (add PQC selection).
  AddPQCToClassical   : ValidHybridTransition ClassicalSelected HybridNegotiated
  ||| PQCSelected -> HybridNegotiated (add classical selection).
  AddClassicalToPQC   : ValidHybridTransition PQCSelected HybridNegotiated
  ||| HybridNegotiated -> HybridComplete (shared secret established).
  CompleteHybrid      : ValidHybridTransition HybridNegotiated HybridComplete
  ||| Idle -> HybridComplete (abort: non-hybrid mode, direct completion).
  DirectComplete      : ValidHybridTransition HybridIdle HybridComplete

---------------------------------------------------------------------------
-- Capability witnesses
---------------------------------------------------------------------------

||| Proof that a key context is in a state where cryptographic operations
||| can be performed.
public export
data CanUseKey : KeyState -> Type where
  ActiveCanUse : CanUseKey Active

||| Proof that a key context can begin key generation.
public export
data CanGenerate : KeyState -> Type where
  EmptyCanGenerate : CanGenerate Empty

||| Proof that a key context can be activated.
public export
data CanActivate : KeyState -> Type where
  GeneratedCanActivate : CanActivate Generated

||| Proof that a hybrid negotiation can proceed to completion.
public export
data CanComplete : HybridState -> Type where
  NegotiatedCanComplete : CanComplete HybridNegotiated

---------------------------------------------------------------------------
-- Impossibility proofs
---------------------------------------------------------------------------

||| Cannot leave the Expired state — it is terminal.
public export
expiredIsTerminal : ValidKeyTransition Expired s -> Void
expiredIsTerminal _ impossible

||| Cannot leave the Compromised state — it is terminal.
public export
compromisedIsTerminal : ValidKeyTransition Compromised s -> Void
compromisedIsTerminal _ impossible

||| Cannot skip from Empty directly to Active.
public export
cannotSkipToActive : ValidKeyTransition Empty Active -> Void
cannotSkipToActive _ impossible

||| Cannot go backwards from Active to Generating.
public export
cannotGoBackToGenerating : ValidKeyTransition Active Generating -> Void
cannotGoBackToGenerating _ impossible

||| Cannot go backwards from Active to Empty.
public export
cannotGoBackToEmpty : ValidKeyTransition Active Empty -> Void
cannotGoBackToEmpty _ impossible

||| Cannot use a key that is not active (Empty state).
public export
cannotUseEmpty : CanUseKey Empty -> Void
cannotUseEmpty _ impossible

||| Cannot use a key that is not active (Generating state).
public export
cannotUseGenerating : CanUseKey Generating -> Void
cannotUseGenerating _ impossible

||| Cannot use a key that is not active (Expired state).
public export
cannotUseExpired : CanUseKey Expired -> Void
cannotUseExpired _ impossible

||| Cannot use a compromised key.
public export
cannotUseCompromised : CanUseKey Compromised -> Void
cannotUseCompromised _ impossible

||| Cannot complete hybrid negotiation from Idle (must negotiate).
public export
cannotCompleteFromClassical : CanComplete ClassicalSelected -> Void
cannotCompleteFromClassical _ impossible

||| Cannot leave HybridComplete state.
public export
hybridCompleteIsTerminal : ValidHybridTransition HybridComplete s -> Void
hybridCompleteIsTerminal _ impossible

---------------------------------------------------------------------------
-- Transition validation
---------------------------------------------------------------------------

||| Check whether a key lifecycle state transition is valid.
public export
validateKeyTransition : (from : KeyState) -> (to : KeyState)
                     -> Maybe (ValidKeyTransition from to)
validateKeyTransition Empty      Generating  = Just BeginKeyGen
validateKeyTransition Generating Generated   = Just FinishKeyGen
validateKeyTransition Generated  Active      = Just ActivateKey
validateKeyTransition Active     Expired     = Just ExpireKey
validateKeyTransition Active     Compromised = Just CompromiseKey
validateKeyTransition Generated  Expired     = Just ExpireBeforeUse
validateKeyTransition Empty      Expired     = Just AbortEmpty
validateKeyTransition Generating Expired     = Just AbortGenerating
validateKeyTransition _          _           = Nothing

||| Check whether a hybrid negotiation state transition is valid.
public export
validateHybridTransition : (from : HybridState) -> (to : HybridState)
                        -> Maybe (ValidHybridTransition from to)
validateHybridTransition HybridIdle        ClassicalSelected = Just SelectClassical
validateHybridTransition HybridIdle        PQCSelected       = Just SelectPQC
validateHybridTransition ClassicalSelected HybridNegotiated  = Just AddPQCToClassical
validateHybridTransition PQCSelected       HybridNegotiated  = Just AddClassicalToPQC
validateHybridTransition HybridNegotiated  HybridComplete    = Just CompleteHybrid
validateHybridTransition HybridIdle        HybridComplete    = Just DirectComplete
validateHybridTransition _                 _                 = Nothing
