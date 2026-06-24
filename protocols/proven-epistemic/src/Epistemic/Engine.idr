-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
--
-- Epistemic.Engine: the runnable, pure, total disclosure engine.
--
-- This is Layer 0 ("truly proven: Idris2 through and through"): the engine
-- that does the real work IS the proven code. It threads the existing
-- witnesses from Epistemic.Lattice / Epistemic.Transitions so that a
-- performed disclosure CARRIES its permission proof -- an over-tier
-- disclosure event is unrepresentable, not merely rejected at runtime.
--
-- The Zig FFI (ffi/zig/src/epistemic.zig) is the imperative mirror of this
-- module; this module is the source of truth for behaviour.

module Epistemic.Engine

import Epistemic.Types
import Epistemic.Lattice
import Epistemic.Transitions

%default total

-- ============================================================================
-- Session state
-- ============================================================================

||| A disclosure session between two parties.
|||
||| `phase` is an ordinary field (not a type index): the transition proofs
||| already live in `ValidSessionTransition`, and non-amplification is carried
||| by `DisclosureEvent` (below), so indexing the record buys nothing and would
||| force every operation into a dependent pair. The effective tier is DERIVED
||| (`sessionEffective`), never stored, so it can never drift from the grants.
public export
record Session where
  constructor MkSession
  phase     : SessionPhase
  ourTier   : Tier                 -- the tier WE granted (Band until agreed)
  theirTier : Tier                 -- the tier the OTHER party granted
  policy    : List FieldGovernance -- the governance entries this session knows
  audit     : List String          -- append-only event log, newest last

||| The tier a session operates at: the meet of both parties' grants.
||| Derived from the proven `effectiveTier` (= `meet`).
public export
sessionEffective : Session -> Tier
sessionEffective s = effectiveTier s.ourTier s.theirTier

-- ============================================================================
-- A proof-carrying disclosure event
-- ============================================================================

||| A disclosure that actually happened, bundled with the proof that it was
||| permitted at the session's effective tier. Because `Disclosable`'s only
||| constructor demands `TierLTE (minTier g) eff`, a `DisclosureEvent` for an
||| over-tier field cannot be constructed at all.
public export
record DisclosureEvent where
  constructor MkDisclosureEvent
  field    : FieldGovernance
  atTier   : Tier
  evidence : Disclosable field atTier

export
Show DisclosureEvent where
  show ev = "disclosed " ++ fieldName ev.field ++ " @ " ++ show ev.atTier

-- ============================================================================
-- Internal lemmas (strictness of the chain), codebase `_ impossible` idiom
-- ============================================================================

bandNotFull : Band = Full -> Void
bandNotFull Refl impossible

relNotFull : Relational = Full -> Void
relNotFull Refl impossible

innocuousNotSensitive : Innocuous = Sensitive -> Void
innocuousNotSensitive Refl impossible

contextualNotSensitive : Contextual = Sensitive -> Void
contextualNotSensitive Refl impossible

-- ============================================================================
-- Decidable well-governedness (mirrors epistemic_well_governed)
-- ============================================================================

||| Totally decide whether a governance entry is well-formed: a Sensitive
||| field must be governed at Full. Pattern-matching the record makes
||| `revealingness g` / `minTier g` reduce, so each branch is direct.
public export
decideWellGoverned : (g : FieldGovernance) -> Dec (WellGoverned g)
decideWellGoverned (MkFieldGovernance _ _ Sensitive Full) =
  Yes (MkWellGoverned (\_ => Refl))
decideWellGoverned (MkFieldGovernance _ _ Sensitive Relational) =
  No (\(MkWellGoverned wf) => relNotFull (wf Refl))
decideWellGoverned (MkFieldGovernance _ _ Sensitive Band) =
  No (\(MkWellGoverned wf) => bandNotFull (wf Refl))
decideWellGoverned (MkFieldGovernance _ _ Innocuous _) =
  Yes (MkWellGoverned (\prf => void (innocuousNotSensitive prf)))
decideWellGoverned (MkFieldGovernance _ _ Contextual _) =
  Yes (MkWellGoverned (\prf => void (contextualNotSensitive prf)))

-- ============================================================================
-- Policy lookup
-- ============================================================================

||| Total lookup of a governance entry by field name (default deny: Nothing).
public export
lookupGov : String -> List FieldGovernance -> Maybe FieldGovernance
lookupGov _    []        = Nothing
lookupGov name (g :: gs) = if fieldName g == name then Just g else lookupGov name gs

-- ============================================================================
-- Operations: State -> Action -> Either DisclosureError State
-- ============================================================================

||| Open a session in the Initiated phase over a governance policy.
||| Deny-by-default: both grants start at Band until agreed.
public export
initiate : List FieldGovernance -> Session
initiate pol = MkSession Initiated Band Band pol ["initiated"]

||| Initiated -> TiersAgreed, recording both parties' grants.
||| The legal edge is witnessed by ValidSessionTransition.AgreeTiers; the
||| value-level phase guard enforces it for the runnable engine.
public export
agreeTiers : (ours, theirs : Tier) -> Session -> Either DisclosureError Session
agreeTiers ours theirs s = case s.phase of
  Initiated => Right $ { phase     := TiersAgreed
                       , ourTier   := ours
                       , theirTier := theirs
                       , audit     $= (++ ["agreeTiers " ++ show ours ++ "/" ++ show theirs
                                            ++ " => eff " ++ show (meet ours theirs)]) } s
  Closed    => Left SessionAlreadyClosed
  _         => Left NoActiveSession

||| TiersAgreed -> Disclosing (opens the gate).
public export
beginDisclosure : Session -> Either DisclosureError Session
beginDisclosure s = case s.phase of
  TiersAgreed => Right $ { phase := Disclosing, audit $= (++ ["beginDisclosure"]) } s
  Closed      => Left SessionAlreadyClosed
  _           => Left NoActiveSession

||| Close the session. Legal from any non-Closed phase (mirrors epistemic_close).
public export
close : Session -> Either DisclosureError Session
close s = case s.phase of
  Closed => Left SessionAlreadyClosed
  _      => Right $ { phase := Closed, audit $= (++ ["close"]) } s

||| Gated disclosure of a named field. On success returns the updated session
||| AND a DisclosureEvent witnessing permission. The error ladder mirrors
||| epistemic_disclose (NoActiveSession / SessionAlreadyClosed / IllGoverned /
||| TierExceeded); UnknownField is raised here because this engine carries the
||| policy list (the Zig FFI delegates lookup to a higher layer).
public export
disclose : (fieldName : String) -> Session
        -> Either DisclosureError (Session, DisclosureEvent)
disclose name s = case s.phase of
  Closed      => Left SessionAlreadyClosed
  Initiated   => Left NoActiveSession
  TiersAgreed => Left NoActiveSession
  Disclosing  => case lookupGov name s.policy of
    Nothing => Left UnknownField
    Just g  => case decideWellGoverned g of
      No _  => Left IllGoverned
      Yes _ => case decideDisclosable g (sessionEffective s) of
        No _   => Left TierExceeded
        Yes prf =>
          let s' = { audit $= (++ ["disclose " ++ name ++ " @ " ++ show (sessionEffective s)]) } s
           in Right (s', MkDisclosureEvent g (sessionEffective s) prf)
