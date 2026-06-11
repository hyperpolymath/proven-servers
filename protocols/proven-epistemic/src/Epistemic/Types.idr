-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
--
-- proven-epistemic: Core types for the epistemic disclosure server.
--
-- An epistemic disclosure server governs WHO MAY LEARN WHAT about a data
-- subject, as a typed, machine-checked property. The name is ours; the
-- lineage is classical:
--   Denning (1976), "A Lattice Model of Secure Information Flow" (CACM);
--   Goguen & Meseguer (1982), noninterference;
--   Volpano, Smith & Irvine (1996), security type systems;
--   Myers (1999), JFlow/Jif language-based information-flow control;
--   Fagin, Halpern, Moses & Vardi, "Reasoning About Knowledge";
--   Byun & Li (2005), purpose-based access control.
--
-- Scope: AUTHORIZED disclosure (the policy layer). Out of scope, by design:
-- inferential leakage bounds (differential privacy) and blind computation
-- (SMPC, homomorphic encryption) -- those are different layers of the same
-- stack. See docs/decisions/0002-add-proven-epistemic-disclosure-core.md.
--
-- All types are closed sum types with total Show instances.
-- No parsers, no full implementations -- skeleton only.

module Epistemic.Types

%default total

-- ============================================================================
-- Tier
-- ============================================================================

||| Disclosure tiers, ordered Band < Relational < Full.
||| Band is the bottom (deny-by-default): verdict-band-level output only.
public export
data Tier : Type where
  ||| T0: coarse verdict band only; nothing attributable is revealed.
  Band       : Tier
  ||| T1: relational statements about the pair ("you two differ on X"),
  ||| no counterpart attribute values, no attribution of objections.
  Relational : Tier
  ||| T2: full disclosure -- attributed reasons, warnings, attribute values.
  Full       : Tier

export
Show Tier where
  show Band       = "Band"
  show Relational = "Relational"
  show Full       = "Full"

-- ============================================================================
-- Revealingness
-- ============================================================================

||| How much a governed field discloses about its subject.
||| Classification drives the minimum tier a field may be released at.
public export
data Revealingness : Type where
  ||| Reveals nothing personal beyond the interaction itself.
  Innocuous  : Revealingness
  ||| Reveals lifestyle or contextual facts (habits, schedules, preferences).
  Contextual : Revealingness
  ||| Liable to reveal a legally protected or intimate attribute,
  ||| directly or by inference (cf. CJEU C-184/20 on derived data).
  Sensitive  : Revealingness

export
Show Revealingness where
  show Innocuous  = "Innocuous"
  show Contextual = "Contextual"
  show Sensitive  = "Sensitive"

-- ============================================================================
-- Purpose
-- ============================================================================

||| The declared purpose a governed field is processed for
||| (purpose limitation: a field released for one purpose may not be
||| repurposed without re-evaluation).
public export
data Purpose : Type where
  ||| Establishing who a party is.
  Identification : Purpose
  ||| Hard feasibility constraints (budgets, dates, capacity).
  Eligibility    : Purpose
  ||| Soft compatibility assessment between parties.
  Compatibility  : Purpose
  ||| Drafting an agreement between consenting parties.
  Contractual    : Purpose
  ||| Append-only audit and accountability records.
  Audit          : Purpose

export
Show Purpose where
  show Identification = "Identification"
  show Eligibility    = "Eligibility"
  show Compatibility  = "Compatibility"
  show Contractual    = "Contractual"
  show Audit          = "Audit"

-- ============================================================================
-- FieldGovernance
-- ============================================================================

||| Governance metadata attached to every disclosable field.
||| A field may be released only at or above its minimum tier.
public export
record FieldGovernance where
  constructor MkFieldGovernance
  fieldName     : String
  purpose       : Purpose
  revealingness : Revealingness
  minTier       : Tier

-- ============================================================================
-- SessionPhase
-- ============================================================================

||| Phases of an epistemic disclosure session between two parties.
public export
data SessionPhase : Type where
  ||| Session opened; no tiers exchanged yet. Nothing may be disclosed.
  Initiated   : SessionPhase
  ||| Both parties' granted tiers are known; effective tier is their meet.
  TiersAgreed : SessionPhase
  ||| Disclosure events may occur, each gated by the effective tier.
  Disclosing  : SessionPhase
  ||| Session ended. Terminal: no further transitions or disclosures.
  Closed      : SessionPhase

export
Show SessionPhase where
  show Initiated   = "Initiated"
  show TiersAgreed = "TiersAgreed"
  show Disclosing  = "Disclosing"
  show Closed      = "Closed"

-- ============================================================================
-- DisclosureError
-- ============================================================================

||| Errors the disclosure server can return.
public export
data DisclosureError : Type where
  ||| Requested field's minimum tier exceeds the session's effective tier.
  TierExceeded         : DisclosureError
  ||| Requested field has no governance entry (default deny).
  UnknownField         : DisclosureError
  ||| Disclosure was requested outside an active Disclosing phase.
  NoActiveSession      : DisclosureError
  ||| Session has already been closed.
  SessionAlreadyClosed : DisclosureError
  ||| Governance entry is ill-formed (e.g. Sensitive below Full).
  IllGoverned          : DisclosureError

export
Show DisclosureError where
  show TierExceeded         = "TierExceeded"
  show UnknownField         = "UnknownField"
  show NoActiveSession      = "NoActiveSession"
  show SessionAlreadyClosed = "SessionAlreadyClosed"
  show IllGoverned          = "IllGoverned"
