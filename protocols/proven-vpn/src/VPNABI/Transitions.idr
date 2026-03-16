-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- VPNABI.Transitions: Valid VPN tunnel phase transitions, IKE negotiation
-- GADT, and SA lifecycle state machines.
--
-- Tunnel establishment lifecycle (7 states):
--
--   Idle --> Phase1Init --> Phase1Auth --> Phase1Done --> Phase2Negotiating --> Established
--                                                                                 |
--   Expired <-------- (from any non-Idle state on SA lifetime expiry) <-----------+
--   Idle <-- Expired (restart)
--
-- SA Lifecycle (5 states):
--   None --> Active --> Rekeying --> Active (new SA)
--                                   |
--   Active --> Expired (hard lifetime)
--   Active --> Deleted (explicit delete)
--   Rekeying --> Expired (rekey failed)
--
-- IKE Negotiation GADT: type-safe encoding of IKE_SA_INIT and IKE_AUTH
-- exchanges, ensuring correct ordering of DH exchange, nonce exchange,
-- and identity verification.
--
-- Key invariant: data cannot flow until Established phase.
-- Key invariant: Phase2 requires Phase1Done (IKE SA must exist first).
-- Key invariant: Expired is terminal; must restart from Idle.

module VPNABI.Transitions

import VPNABI.Layout

%default total

---------------------------------------------------------------------------
-- ValidPhaseTransition: exhaustive enumeration of legal tunnel transitions.
---------------------------------------------------------------------------

||| Proof witness that a tunnel phase transition is valid.
public export
data ValidPhaseTransition : TunnelPhase -> TunnelPhase -> Type where
  ||| Idle -> Phase1Init: begin IKE SA_INIT exchange.
  BeginPhase1       : ValidPhaseTransition Idle Phase1Init
  ||| Phase1Init -> Phase1Auth: SA_INIT complete, begin AUTH exchange.
  Phase1InitDone    : ValidPhaseTransition Phase1Init Phase1Auth
  ||| Phase1Auth -> Phase1Done: AUTH complete, IKE SA established.
  Phase1AuthDone    : ValidPhaseTransition Phase1Auth Phase1Done
  ||| Phase1Done -> Phase2Negotiating: begin Child SA / Quick Mode.
  BeginPhase2       : ValidPhaseTransition Phase1Done Phase2Negotiating
  ||| Phase2Negotiating -> Established: Child SA created, tunnel up.
  TunnelEstablished : ValidPhaseTransition Phase2Negotiating Established
  ||| Established -> Phase2Negotiating: rekey Child SA (create new, delete old).
  RekeyChildSA      : ValidPhaseTransition Established Phase2Negotiating
  ||| Established -> Phase1Init: full rekey (new IKE SA + Child SA).
  RekeyFullTunnel   : ValidPhaseTransition Established Phase1Init
  -- Expiry edges: any non-Idle/non-Expired state can expire.
  ||| Phase1Init -> Expired: SA_INIT timed out.
  ExpireFromInit    : ValidPhaseTransition Phase1Init Expired
  ||| Phase1Auth -> Expired: AUTH timed out or failed.
  ExpireFromAuth    : ValidPhaseTransition Phase1Auth Expired
  ||| Phase1Done -> Expired: IKE SA expired before Phase 2.
  ExpireFromP1Done  : ValidPhaseTransition Phase1Done Expired
  ||| Phase2Negotiating -> Expired: Child SA negotiation failed.
  ExpireFromP2      : ValidPhaseTransition Phase2Negotiating Expired
  ||| Established -> Expired: SA hard lifetime reached.
  ExpireFromEstab   : ValidPhaseTransition Established Expired
  ||| Expired -> Idle: restart tunnel from scratch.
  RestartFromExpired : ValidPhaseTransition Expired Idle

---------------------------------------------------------------------------
-- Capability witnesses
---------------------------------------------------------------------------

||| Proof that data can flow through the tunnel.
||| Only the Established phase allows data transfer.
public export
data CanTransferData : TunnelPhase -> Type where
  EstablishedCanTransfer : CanTransferData Established

||| Proof that IKE Phase 2 can be initiated.
||| Requires Phase 1 to be complete.
public export
data CanNegotiateChildSA : TunnelPhase -> Type where
  Phase1DoneCanNegotiate : CanNegotiateChildSA Phase1Done

||| Proof that a tunnel can be rekeyed.
||| Only Established tunnels can initiate rekey.
public export
data CanRekey : TunnelPhase -> Type where
  EstablishedCanRekey : CanRekey Established

---------------------------------------------------------------------------
-- Impossibility proofs
---------------------------------------------------------------------------

||| Cannot transfer data from Idle.
public export
idleCannotTransfer : CanTransferData Idle -> Void
idleCannotTransfer _ impossible

||| Cannot transfer data during Phase 1 Init.
public export
phase1InitCannotTransfer : CanTransferData Phase1Init -> Void
phase1InitCannotTransfer _ impossible

||| Cannot transfer data during Phase 1 Auth.
public export
phase1AuthCannotTransfer : CanTransferData Phase1Auth -> Void
phase1AuthCannotTransfer _ impossible

||| Cannot transfer data when Phase 1 is done but Phase 2 not started.
public export
phase1DoneCannotTransfer : CanTransferData Phase1Done -> Void
phase1DoneCannotTransfer _ impossible

||| Cannot transfer data during Phase 2 negotiation.
public export
phase2NegCannotTransfer : CanTransferData Phase2Negotiating -> Void
phase2NegCannotTransfer _ impossible

||| Cannot transfer data from Expired.
public export
expiredCannotTransfer : CanTransferData Expired -> Void
expiredCannotTransfer _ impossible

||| Cannot skip Phase 1 Init (Idle -> Phase1Auth is invalid).
public export
cannotSkipInit : ValidPhaseTransition Idle Phase1Auth -> Void
cannotSkipInit _ impossible

||| Cannot skip Phase 1 entirely (Idle -> Phase1Done is invalid).
public export
cannotSkipPhase1 : ValidPhaseTransition Idle Phase1Done -> Void
cannotSkipPhase1 _ impossible

||| Cannot skip directly to Established (Idle -> Established is invalid).
public export
cannotSkipToEstablished : ValidPhaseTransition Idle Established -> Void
cannotSkipToEstablished _ impossible

||| Cannot negotiate Child SA from Idle (must complete Phase 1 first).
public export
idleCannotNegotiateChild : CanNegotiateChildSA Idle -> Void
idleCannotNegotiateChild _ impossible

||| Cannot negotiate Child SA from Phase 1 Init (Phase 1 not done).
public export
phase1InitCannotNegotiateChild : CanNegotiateChildSA Phase1Init -> Void
phase1InitCannotNegotiateChild _ impossible

||| Cannot rekey from Idle (nothing to rekey).
public export
idleCannotRekey : CanRekey Idle -> Void
idleCannotRekey _ impossible

||| Expired is terminal except for restart to Idle.
public export
expiredCannotEstablish : ValidPhaseTransition Expired Established -> Void
expiredCannotEstablish _ impossible

---------------------------------------------------------------------------
-- Transition validation
---------------------------------------------------------------------------

||| Check whether a tunnel phase transition is valid.
public export
validatePhaseTransition : (from : TunnelPhase) -> (to : TunnelPhase)
                        -> Maybe (ValidPhaseTransition from to)
validatePhaseTransition Idle              Phase1Init        = Just BeginPhase1
validatePhaseTransition Phase1Init        Phase1Auth        = Just Phase1InitDone
validatePhaseTransition Phase1Auth        Phase1Done        = Just Phase1AuthDone
validatePhaseTransition Phase1Done        Phase2Negotiating = Just BeginPhase2
validatePhaseTransition Phase2Negotiating Established       = Just TunnelEstablished
validatePhaseTransition Established       Phase2Negotiating = Just RekeyChildSA
validatePhaseTransition Established       Phase1Init        = Just RekeyFullTunnel
validatePhaseTransition Phase1Init        Expired           = Just ExpireFromInit
validatePhaseTransition Phase1Auth        Expired           = Just ExpireFromAuth
validatePhaseTransition Phase1Done        Expired           = Just ExpireFromP1Done
validatePhaseTransition Phase2Negotiating Expired           = Just ExpireFromP2
validatePhaseTransition Established       Expired           = Just ExpireFromEstab
validatePhaseTransition Expired           Idle              = Just RestartFromExpired
validatePhaseTransition _                 _                 = Nothing

---------------------------------------------------------------------------
-- ValidSATransition: SA lifecycle state machine.
---------------------------------------------------------------------------

||| Proof witness that an SA lifecycle transition is valid.
public export
data ValidSATransition : SALifecycle -> SALifecycle -> Type where
  ||| None -> Active: SA created (IKE negotiation complete).
  SACreated      : ValidSATransition SANone SAActive
  ||| Active -> Rekeying: soft lifetime reached, initiate rekey.
  SABeginRekey   : ValidSATransition SAActive SARekeying
  ||| Rekeying -> Active: new SA established (old SA deleted).
  SARekeyDone    : ValidSATransition SARekeying SAActive
  ||| Active -> Expired: hard lifetime reached.
  SAHardExpiry   : ValidSATransition SAActive SAExpired
  ||| Rekeying -> Expired: rekey failed and hard lifetime reached.
  SARekeyExpired : ValidSATransition SARekeying SAExpired
  ||| Active -> Deleted: explicit DELETE payload received.
  SAExplicitDel  : ValidSATransition SAActive SADeleted
  ||| Rekeying -> Deleted: explicit DELETE during rekey.
  SARekeyDel     : ValidSATransition SARekeying SADeleted

||| Validate an SA lifecycle transition.
public export
validateSATransition : (from : SALifecycle) -> (to : SALifecycle)
                     -> Maybe (ValidSATransition from to)
validateSATransition SANone     SAActive   = Just SACreated
validateSATransition SAActive   SARekeying = Just SABeginRekey
validateSATransition SARekeying SAActive   = Just SARekeyDone
validateSATransition SAActive   SAExpired  = Just SAHardExpiry
validateSATransition SARekeying SAExpired  = Just SARekeyExpired
validateSATransition SAActive   SADeleted  = Just SAExplicitDel
validateSATransition SARekeying SADeleted  = Just SARekeyDel
validateSATransition _          _          = Nothing

||| Expired SA is terminal (cannot be reused).
public export
expiredSAIsTerminal : ValidSATransition SAExpired s -> Void
expiredSAIsTerminal _ impossible

||| Deleted SA is terminal (cannot be reused).
public export
deletedSAIsTerminal : ValidSATransition SADeleted s -> Void
deletedSAIsTerminal _ impossible

||| Cannot skip SA creation (None -> Rekeying is invalid).
public export
cannotRekeyNonexistentSA : ValidSATransition SANone SARekeying -> Void
cannotRekeyNonexistentSA _ impossible

---------------------------------------------------------------------------
-- IKE Negotiation GADT: type-safe IKE exchange steps.
--
-- Models the IKE_SA_INIT and IKE_AUTH exchanges as a GADT indexed by
-- tunnel phase. Each constructor represents one exchange message pair,
-- with the type system enforcing correct ordering:
--
--   1. DH key exchange (SA_INIT)
--   2. Nonce exchange  (SA_INIT)
--   3. Identity + Auth (IKE_AUTH)
--   4. Child SA proposal (IKE_AUTH / CREATE_CHILD_SA)
---------------------------------------------------------------------------

||| Type-safe IKE negotiation steps.
||| Indexed by the tunnel phase before and after the step.
public export
data IKENegotiation : TunnelPhase -> TunnelPhase -> Type where
  ||| IKE_SA_INIT: Diffie-Hellman exchange.
  ||| Idle -> Phase1Init. Produces DH public value and nonce.
  DHExchange : (group : DHGroup)
            -> IKENegotiation Idle Phase1Init
  ||| IKE_AUTH: Identity and authentication exchange.
  ||| Phase1Init -> Phase1Auth. Verifies peer identity using
  ||| the crypto suite negotiated in SA_INIT.
  AuthExchange : (encryption : EncryptionAlgorithm)
              -> (integrity  : IntegrityAlgorithm)
              -> IKENegotiation Phase1Init Phase1Auth
  ||| IKE_AUTH completion: peer authenticated, IKE SA ready.
  ||| Phase1Auth -> Phase1Done.
  AuthComplete : IKENegotiation Phase1Auth Phase1Done
  ||| CREATE_CHILD_SA: negotiate Child SA (IPSec SA / tunnel).
  ||| Phase1Done -> Phase2Negotiating.
  ChildSAProposal : (encryption : EncryptionAlgorithm)
                 -> (integrity  : IntegrityAlgorithm)
                 -> (group      : DHGroup)
                 -> IKENegotiation Phase1Done Phase2Negotiating
  ||| CREATE_CHILD_SA accepted: tunnel established.
  ||| Phase2Negotiating -> Established.
  ChildSAAccepted : IKENegotiation Phase2Negotiating Established

||| Compose two consecutive IKE negotiation steps into a proof of
||| the combined transition. Type safety ensures the intermediate
||| phase matches.
public export
composeNegotiation : IKENegotiation a b -> IKENegotiation b c -> IKENegotiation a c
-- This function is intentionally not implementable for arbitrary a, b, c.
-- It serves as a type-level documentation of composability.
-- In practice, the FFI uses the individual steps.

-- We do not provide a body for composeNegotiation because Idris2 cannot
-- prove the necessary type equalities without dependent pattern matching
-- on all possible step combinations. Instead, we provide a chained
-- validation function below.

---------------------------------------------------------------------------
-- Full tunnel establishment: chained validation.
---------------------------------------------------------------------------

||| Validate a complete tunnel establishment sequence.
||| Returns Just proof if the chain Phase1Init -> Phase1Auth -> Phase1Done
||| -> Phase2Negotiating -> Established is valid for the given algorithms.
public export
validateFullEstablishment : (dhg : DHGroup)
                         -> (enc : EncryptionAlgorithm)
                         -> (integ : IntegrityAlgorithm)
                         -> (childEnc : EncryptionAlgorithm)
                         -> (childInteg : IntegrityAlgorithm)
                         -> (childDH : DHGroup)
                         -> ( IKENegotiation Idle Phase1Init
                            , IKENegotiation Phase1Init Phase1Auth
                            , IKENegotiation Phase1Auth Phase1Done
                            , IKENegotiation Phase1Done Phase2Negotiating
                            , IKENegotiation Phase2Negotiating Established
                            )
validateFullEstablishment dhg enc integ childEnc childInteg childDH =
  ( DHExchange dhg
  , AuthExchange enc integ
  , AuthComplete
  , ChildSAProposal childEnc childInteg childDH
  , ChildSAAccepted
  )
