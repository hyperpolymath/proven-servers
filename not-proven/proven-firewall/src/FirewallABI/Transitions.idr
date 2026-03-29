-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- FirewallABI.Transitions: Valid packet lifecycle and rule chain state transitions.
--
-- Models the packet processing lifecycle through the firewall:
--
--   Arrived --> Classified --> ChainTraversal --> Decided --> Committed
--
-- With stateful connection tracking layered on top:
--
--   Untracked | Tracking | Tracked | Expired
--
-- The key invariants:
--   - Committed is terminal (no outbound edges).
--   - Connection tracking requires a classified packet (CanTrack witness).
--   - Cannot skip from Arrived directly to Committed without classification.
--   - Cannot go backwards from Decided to Arrived.
--   - NAT actions (DNAT/SNAT/Masquerade) require Tracking or Tracked state.

module FirewallABI.Transitions

import Firewall.Types

%default total

---------------------------------------------------------------------------
-- Packet lifecycle states
---------------------------------------------------------------------------

||| The lifecycle state of a packet being processed by the firewall.
public export
data PacketState : Type where
  ||| Packet has arrived but has not been classified yet.
  Arrived        : PacketState
  ||| Packet headers parsed, protocol and chain determined.
  Classified     : PacketState
  ||| Walking the rule chain, evaluating match criteria.
  ChainTraversal : PacketState
  ||| A rule has matched; action decided but not yet applied.
  Decided        : PacketState
  ||| Action applied, packet handled (accept/drop/etc.) -- terminal.
  Committed      : PacketState

public export
Eq PacketState where
  Arrived        == Arrived        = True
  Classified     == Classified     = True
  ChainTraversal == ChainTraversal = True
  Decided        == Decided        = True
  Committed      == Committed      = True
  _              == _              = False

---------------------------------------------------------------------------
-- Connection tracking states
---------------------------------------------------------------------------

||| Connection tracking state, orthogonal to packet lifecycle.
public export
data ConnTrackState : Type where
  ||| Connection tracking not yet initialised for this packet.
  Untracked : ConnTrackState
  ||| Connection tracking lookup in progress.
  Tracking  : ConnTrackState
  ||| Connection is tracked (state determined: New/Established/Related/Invalid).
  Tracked   : ConnTrackState
  ||| Connection entry has expired (timed out).
  Expired   : ConnTrackState

public export
Eq ConnTrackState where
  Untracked == Untracked = True
  Tracking  == Tracking  = True
  Tracked   == Tracked   = True
  Expired   == Expired   = True
  _         == _         = False

---------------------------------------------------------------------------
-- ValidPacketTransition: exhaustive enumeration of legal transitions.
---------------------------------------------------------------------------

||| Proof witness that a packet lifecycle state transition is valid.
public export
data ValidPacketTransition : PacketState -> PacketState -> Type where
  ||| Arrived -> Classified (parse packet headers, determine chain).
  ClassifyPacket   : ValidPacketTransition Arrived Classified
  ||| Classified -> ChainTraversal (begin walking the rule chain).
  BeginChain       : ValidPacketTransition Classified ChainTraversal
  ||| ChainTraversal -> Decided (a rule matched, action determined).
  MatchRule        : ValidPacketTransition ChainTraversal Decided
  ||| ChainTraversal -> Decided (no rule matched, apply default policy).
  DefaultPolicy    : ValidPacketTransition ChainTraversal Decided
  ||| Decided -> Committed (apply the action to the packet).
  CommitAction     : ValidPacketTransition Decided Committed
  ||| Arrived -> Committed (abort: drop malformed packet before classification).
  AbortArrived     : ValidPacketTransition Arrived Committed
  ||| Classified -> Committed (abort: drop after classification, e.g. invalid chain).
  AbortClassified  : ValidPacketTransition Classified Committed
  ||| ChainTraversal -> Committed (abort: error during chain walk).
  AbortTraversal   : ValidPacketTransition ChainTraversal Committed

---------------------------------------------------------------------------
-- ValidConnTrackTransition: legal connection tracking state changes.
---------------------------------------------------------------------------

||| Proof witness that a connection tracking state transition is valid.
public export
data ValidConnTrackTransition : ConnTrackState -> ConnTrackState -> Type where
  ||| Untracked -> Tracking (begin connection lookup).
  BeginTracking : ValidConnTrackTransition Untracked Tracking
  ||| Tracking -> Tracked (connection state determined).
  CompleteTrack : ValidConnTrackTransition Tracking Tracked
  ||| Tracked -> Expired (connection entry timed out).
  ExpireConn    : ValidConnTrackTransition Tracked Expired

---------------------------------------------------------------------------
-- Capability witnesses
---------------------------------------------------------------------------

||| Proof that a packet can have rules evaluated against it.
public export
data CanEvaluate : PacketState -> Type where
  TraversalCanEvaluate : CanEvaluate ChainTraversal

||| Proof that connection tracking can be initiated.
||| Requires packet to be Classified (headers parsed).
public export
data CanTrack : PacketState -> Type where
  ClassifiedCanTrack : CanTrack Classified

||| Proof that a NAT action can be applied.
||| Requires connection tracking to be active (Tracking or Tracked).
public export
data CanNAT : ConnTrackState -> Type where
  TrackingCanNAT : CanNAT Tracking
  TrackedCanNAT  : CanNAT Tracked

||| Proof that an action can be committed.
public export
data CanCommit : PacketState -> Type where
  DecidedCanCommit : CanCommit Decided

||| Proof that a packet has arrived and can be classified.
public export
data CanClassify : PacketState -> Type where
  ArrivedCanClassify : CanClassify Arrived

---------------------------------------------------------------------------
-- Impossibility proofs
---------------------------------------------------------------------------

||| Cannot leave the Committed state -- it is terminal.
public export
committedIsTerminal : ValidPacketTransition Committed s -> Void
committedIsTerminal _ impossible

||| Cannot skip from Arrived directly to Decided.
public export
cannotSkipToDecided : ValidPacketTransition Arrived Decided -> Void
cannotSkipToDecided _ impossible

||| Cannot go backwards from Decided to Arrived.
public export
cannotGoBackToArrived : ValidPacketTransition Decided Arrived -> Void
cannotGoBackToArrived _ impossible

||| Cannot go backwards from ChainTraversal to Arrived.
public export
cannotGoBackFromTraversal : ValidPacketTransition ChainTraversal Arrived -> Void
cannotGoBackFromTraversal _ impossible

||| Cannot go backwards from Decided to Classified.
public export
cannotGoBackToClassified : ValidPacketTransition Decided Classified -> Void
cannotGoBackToClassified _ impossible

||| Cannot evaluate rules when in Arrived state.
public export
cannotEvaluateFromArrived : CanEvaluate Arrived -> Void
cannotEvaluateFromArrived _ impossible

||| Cannot commit from Arrived (must go through Decided first).
public export
cannotCommitFromArrived : CanCommit Arrived -> Void
cannotCommitFromArrived _ impossible

||| Cannot perform NAT when Untracked.
public export
cannotNATUntracked : CanNAT Untracked -> Void
cannotNATUntracked _ impossible

||| Cannot perform NAT when Expired.
public export
cannotNATExpired : CanNAT Expired -> Void
cannotNATExpired _ impossible

||| Cannot revert connection tracking from Expired back to Untracked.
public export
cannotRevertConnTrack : ValidConnTrackTransition Expired Untracked -> Void
cannotRevertConnTrack _ impossible

||| Cannot skip connection tracking from Untracked to Tracked.
public export
cannotSkipToTracked : ValidConnTrackTransition Untracked Tracked -> Void
cannotSkipToTracked _ impossible

---------------------------------------------------------------------------
-- Transition validation
---------------------------------------------------------------------------

||| Check whether a packet lifecycle state transition is valid.
public export
validatePacketTransition : (from : PacketState) -> (to : PacketState)
                        -> Maybe (ValidPacketTransition from to)
validatePacketTransition Arrived        Classified     = Just ClassifyPacket
validatePacketTransition Classified     ChainTraversal = Just BeginChain
validatePacketTransition ChainTraversal Decided        = Just MatchRule
validatePacketTransition Decided        Committed      = Just CommitAction
validatePacketTransition Arrived        Committed      = Just AbortArrived
validatePacketTransition Classified     Committed      = Just AbortClassified
validatePacketTransition ChainTraversal Committed      = Just AbortTraversal
validatePacketTransition _              _              = Nothing

||| Check whether a connection tracking state transition is valid.
public export
validateConnTrackTransition : (from : ConnTrackState) -> (to : ConnTrackState)
                           -> Maybe (ValidConnTrackTransition from to)
validateConnTrackTransition Untracked Tracking = Just BeginTracking
validateConnTrackTransition Tracking  Tracked  = Just CompleteTrack
validateConnTrackTransition Tracked   Expired  = Just ExpireConn
validateConnTrackTransition _         _        = Nothing
