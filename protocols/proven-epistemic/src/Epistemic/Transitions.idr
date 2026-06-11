-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
--
-- Epistemic.Transitions: session lifecycle and gated disclosure.
--
-- Session pipeline:
--
--   Initiated --> TiersAgreed --> Disclosing --> Closed
--        |              |
--        +--------------+-------------------->  Closed   (refusal edges)
--
-- Key invariant: nothing may be disclosed before both parties' tiers are
-- agreed and the session is in Disclosing.
-- Key invariant: Closed is terminal.
-- Key invariant (non-amplification): a disclosure event for a governed
-- field can only be CONSTRUCTED with a proof that the field's minimum
-- tier is within the session's effective tier -- ill-tiered disclosures
-- are not errors caught at runtime, they are unrepresentable.

module Epistemic.Transitions

import Epistemic.Types
import Epistemic.Lattice

%default total

-- ============================================================================
-- Session state machine
-- ============================================================================

||| Proof witness that a session phase transition is valid.
public export
data ValidSessionTransition : SessionPhase -> SessionPhase -> Type where
  ||| Initiated -> TiersAgreed (both parties' grants received).
  AgreeTiers          : ValidSessionTransition Initiated TiersAgreed
  ||| TiersAgreed -> Disclosing (effective tier computed; gate opens).
  BeginDisclosure     : ValidSessionTransition TiersAgreed Disclosing
  ||| Initiated -> Closed (a party declines before exchanging tiers).
  CloseFromInitiated  : ValidSessionTransition Initiated Closed
  ||| TiersAgreed -> Closed (a party declines after seeing the tier).
  CloseFromAgreed     : ValidSessionTransition TiersAgreed Closed
  ||| Disclosing -> Closed (normal end of session).
  CloseFromDisclosing : ValidSessionTransition Disclosing Closed

||| Proof that a phase permits disclosure events. Only Disclosing does.
public export
data CanDisclose : SessionPhase -> Type where
  DisclosingCanDisclose : CanDisclose Disclosing

-- ============================================================================
-- Impossibility proofs
-- ============================================================================

||| Closed is terminal: no outbound transitions.
public export
closedIsTerminal : ValidSessionTransition Closed s -> Void
closedIsTerminal _ impossible

||| Cannot disclose before tiers are exchanged.
public export
cannotDiscloseWhenInitiated : CanDisclose Initiated -> Void
cannotDiscloseWhenInitiated _ impossible

||| Cannot disclose after agreement but before the gate opens.
public export
cannotDiscloseWhenAgreed : CanDisclose TiersAgreed -> Void
cannotDiscloseWhenAgreed _ impossible

||| Cannot disclose after the session is closed.
public export
cannotDiscloseWhenClosed : CanDisclose Closed -> Void
cannotDiscloseWhenClosed _ impossible

||| Cannot skip tier agreement: Initiated -> Disclosing is not a transition.
public export
cannotSkipAgreement : ValidSessionTransition Initiated Disclosing -> Void
cannotSkipAgreement _ impossible

-- ============================================================================
-- Effective tier (reciprocity)
-- ============================================================================

||| The tier a session operates at: the meet of both parties' grants.
public export
effectiveTier : (granted : Tier) -> (theirs : Tier) -> Tier
effectiveTier granted theirs = meet granted theirs

||| Reciprocity: the effective tier is the same from either side.
public export
reciprocity : (a, b : Tier) -> effectiveTier a b = effectiveTier b a
reciprocity a b = meetSym a b

||| You never see above what YOU granted (the "LinkedIn property").
public export
neverAboveOwnGrant : (granted, theirs : Tier) ->
                     TierLTE (effectiveTier granted theirs) granted
neverAboveOwnGrant granted theirs = meetLowerLeft granted theirs

||| You never see above what the OTHER party granted.
public export
neverAboveTheirGrant : (granted, theirs : Tier) ->
                       TierLTE (effectiveTier granted theirs) theirs
neverAboveTheirGrant granted theirs = meetLowerRight granted theirs

-- ============================================================================
-- Gated disclosure
-- ============================================================================

||| Proof witness that a governed field may be disclosed at an effective
||| tier. The only constructor demands the ordering proof, so an
||| over-tier disclosure event cannot be constructed at all.
public export
data Disclosable : FieldGovernance -> Tier -> Type where
  MkDisclosable : TierLTE (minTier g) eff -> Disclosable g eff

||| Raising the effective tier never revokes a permitted disclosure
||| (monotonicity of the gate).
public export
disclosableMonotone : TierLTE eff eff' -> Disclosable g eff -> Disclosable g eff'
disclosableMonotone lte (MkDisclosable p) = MkDisclosable (tierLTETrans p lte)

||| Disclosability is decidable: the server can always decide, totally,
||| whether a field passes the gate at a given effective tier.
public export
decideDisclosable : (g : FieldGovernance) -> (eff : Tier) -> Dec (Disclosable g eff)
decideDisclosable g eff = case isTierLTE (minTier g) eff of
  Yes p  => Yes (MkDisclosable p)
  No np  => No (\d => case d of MkDisclosable p => np p)

-- ============================================================================
-- Well-governedness (sensitive fields demand Full)
-- ============================================================================

||| A governance entry is well-formed when Sensitive revealingness
||| implies a Full minimum tier.
public export
data WellGoverned : FieldGovernance -> Type where
  MkWellGoverned : (revealingness g = Sensitive -> minTier g = Full) ->
                   WellGoverned g

||| Any disclosure of a well-governed Sensitive field certifies that the
||| session is at Full tier.
public export
sensitiveRequiresFull : WellGoverned g -> revealingness g = Sensitive ->
                        Disclosable g eff -> TierLTE Full eff
sensitiveRequiresFull (MkWellGoverned wf) sens (MkDisclosable p) =
  replace {p = \t => TierLTE t eff} (wf sens) p

||| A well-governed Sensitive field can never be disclosed at Band tier.
public export
sensitiveNeverAtBand : WellGoverned g -> revealingness g = Sensitive ->
                       Disclosable g Band -> Void
sensitiveNeverAtBand wg sens d = fullNotLTEBand (sensitiveRequiresFull wg sens d)

||| A well-governed Sensitive field can never be disclosed at Relational
||| tier.
public export
sensitiveNeverAtRelational : WellGoverned g -> revealingness g = Sensitive ->
                             Disclosable g Relational -> Void
sensitiveNeverAtRelational wg sens d =
  fullNotLTERelational (sensitiveRequiresFull wg sens d)
