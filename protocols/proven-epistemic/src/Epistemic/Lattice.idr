-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
--
-- Epistemic.Lattice: the disclosure-tier lattice and its laws.
--
-- The three tiers form a total order Band < Relational < Full, hence a
-- (chain) lattice whose meet is minimum. All lattice laws are proved by
-- exhaustive case analysis -- every proof is Refl or a constructor, with
-- no escape hatches.
--
-- The load-bearing theorems for the disclosure server:
--   meetSym         -- reciprocity is symmetric (the "LinkedIn property")
--   meetLowerLeft   -- you never see above what YOU granted
--   meetLowerRight  -- you never see above what the OTHER party granted
--   meetGreatest    -- meet is the greatest such bound (no tier is wasted)
--   bandAbsorbs     -- deny-by-default is absorbing

module Epistemic.Lattice

import Epistemic.Types

%default total

-- ============================================================================
-- Ordering
-- ============================================================================

||| Numeric rank of a tier (Band lowest).
public export
tierLevel : Tier -> Nat
tierLevel Band       = 0
tierLevel Relational = 1
tierLevel Full       = 2

||| Proof witness that one tier discloses no more than another.
||| Exhaustive enumeration of the six inhabited pairs of the chain.
public export
data TierLTE : Tier -> Tier -> Type where
  BandLTEBand             : TierLTE Band Band
  BandLTERelational       : TierLTE Band Relational
  BandLTEFull             : TierLTE Band Full
  RelationalLTERelational : TierLTE Relational Relational
  RelationalLTEFull       : TierLTE Relational Full
  FullLTEFull             : TierLTE Full Full

||| Reflexivity: every tier discloses no more than itself.
public export
tierLTERefl : (t : Tier) -> TierLTE t t
tierLTERefl Band       = BandLTEBand
tierLTERefl Relational = RelationalLTERelational
tierLTERefl Full       = FullLTEFull

||| Transitivity of the disclosure order.
public export
tierLTETrans : TierLTE a b -> TierLTE b c -> TierLTE a c
tierLTETrans BandLTEBand             y                       = y
tierLTETrans BandLTERelational       RelationalLTERelational = BandLTERelational
tierLTETrans BandLTERelational       RelationalLTEFull       = BandLTEFull
tierLTETrans BandLTEFull             FullLTEFull             = BandLTEFull
tierLTETrans RelationalLTERelational y                       = y
tierLTETrans RelationalLTEFull       FullLTEFull             = RelationalLTEFull
tierLTETrans FullLTEFull             y                       = y

-- ============================================================================
-- Impossibility lemmas (strictness of the chain)
-- ============================================================================

||| Relational discloses strictly more than Band.
public export
relationalNotLTEBand : TierLTE Relational Band -> Void
relationalNotLTEBand _ impossible

||| Full discloses strictly more than Band.
public export
fullNotLTEBand : TierLTE Full Band -> Void
fullNotLTEBand _ impossible

||| Full discloses strictly more than Relational.
public export
fullNotLTERelational : TierLTE Full Relational -> Void
fullNotLTERelational _ impossible

-- ============================================================================
-- Decidability
-- ============================================================================

||| The disclosure order is decidable: a server can always decide,
||| totally, whether one tier is within another.
public export
isTierLTE : (a, b : Tier) -> Dec (TierLTE a b)
isTierLTE Band       Band       = Yes BandLTEBand
isTierLTE Band       Relational = Yes BandLTERelational
isTierLTE Band       Full       = Yes BandLTEFull
isTierLTE Relational Band       = No relationalNotLTEBand
isTierLTE Relational Relational = Yes RelationalLTERelational
isTierLTE Relational Full       = Yes RelationalLTEFull
isTierLTE Full       Band       = No fullNotLTEBand
isTierLTE Full       Relational = No fullNotLTERelational
isTierLTE Full       Full       = Yes FullLTEFull

-- ============================================================================
-- Meet (greatest lower bound)
-- ============================================================================

||| Meet of two tiers: the most that may be disclosed between two parties
||| who granted these tiers. Exhaustive table; minimum on the chain.
public export
meet : Tier -> Tier -> Tier
meet Band       Band       = Band
meet Band       Relational = Band
meet Band       Full       = Band
meet Relational Band       = Band
meet Relational Relational = Relational
meet Relational Full       = Relational
meet Full       Band       = Band
meet Full       Relational = Relational
meet Full       Full       = Full

||| Reciprocity is symmetric: the effective tier between A and B is the
||| same computed from either side.
public export
meetSym : (a, b : Tier) -> meet a b = meet b a
meetSym Band       Band       = Refl
meetSym Band       Relational = Refl
meetSym Band       Full       = Refl
meetSym Relational Band       = Refl
meetSym Relational Relational = Refl
meetSym Relational Full       = Refl
meetSym Full       Band       = Refl
meetSym Full       Relational = Refl
meetSym Full       Full       = Refl

||| Meet is idempotent: granting a tier to a party who granted the same
||| tier discloses exactly that tier.
public export
meetIdem : (t : Tier) -> meet t t = t
meetIdem Band       = Refl
meetIdem Relational = Refl
meetIdem Full       = Refl

||| Meet is associative: effective tiers compose across multi-party
||| sessions without order dependence.
public export
meetAssoc : (a, b, c : Tier) -> meet (meet a b) c = meet a (meet b c)
meetAssoc Band       Band       Band       = Refl
meetAssoc Band       Band       Relational = Refl
meetAssoc Band       Band       Full       = Refl
meetAssoc Band       Relational Band       = Refl
meetAssoc Band       Relational Relational = Refl
meetAssoc Band       Relational Full       = Refl
meetAssoc Band       Full       Band       = Refl
meetAssoc Band       Full       Relational = Refl
meetAssoc Band       Full       Full       = Refl
meetAssoc Relational Band       Band       = Refl
meetAssoc Relational Band       Relational = Refl
meetAssoc Relational Band       Full       = Refl
meetAssoc Relational Relational Band       = Refl
meetAssoc Relational Relational Relational = Refl
meetAssoc Relational Relational Full       = Refl
meetAssoc Relational Full       Band       = Refl
meetAssoc Relational Full       Relational = Refl
meetAssoc Relational Full       Full       = Refl
meetAssoc Full       Band       Band       = Refl
meetAssoc Full       Band       Relational = Refl
meetAssoc Full       Band       Full       = Refl
meetAssoc Full       Relational Band       = Refl
meetAssoc Full       Relational Relational = Refl
meetAssoc Full       Relational Full       = Refl
meetAssoc Full       Full       Band       = Refl
meetAssoc Full       Full       Relational = Refl
meetAssoc Full       Full       Full       = Refl

||| Band (deny-by-default) is absorbing: one refusing party caps the
||| session at the bottom tier regardless of the other's grant.
public export
bandAbsorbs : (t : Tier) -> meet Band t = Band
bandAbsorbs Band       = Refl
bandAbsorbs Relational = Refl
bandAbsorbs Full       = Refl

-- ============================================================================
-- Bound theorems (the non-amplification core)
-- ============================================================================

||| The effective tier never exceeds the left party's grant:
||| you never see more than YOU granted.
public export
meetLowerLeft : (a, b : Tier) -> TierLTE (meet a b) a
meetLowerLeft Band       Band       = BandLTEBand
meetLowerLeft Band       Relational = BandLTEBand
meetLowerLeft Band       Full       = BandLTEBand
meetLowerLeft Relational Band       = BandLTERelational
meetLowerLeft Relational Relational = RelationalLTERelational
meetLowerLeft Relational Full       = RelationalLTERelational
meetLowerLeft Full       Band       = BandLTEFull
meetLowerLeft Full       Relational = RelationalLTEFull
meetLowerLeft Full       Full       = FullLTEFull

||| The effective tier never exceeds the right party's grant:
||| you never see more than the OTHER party granted.
public export
meetLowerRight : (a, b : Tier) -> TierLTE (meet a b) b
meetLowerRight Band       Band       = BandLTEBand
meetLowerRight Band       Relational = BandLTERelational
meetLowerRight Band       Full       = BandLTEFull
meetLowerRight Relational Band       = BandLTEBand
meetLowerRight Relational Relational = RelationalLTERelational
meetLowerRight Relational Full       = RelationalLTEFull
meetLowerRight Full       Band       = BandLTEBand
meetLowerRight Full       Relational = RelationalLTERelational
meetLowerRight Full       Full       = FullLTEFull

||| Meet is the GREATEST lower bound: any tier within both grants is
||| within the effective tier -- the lattice wastes no permitted disclosure.
public export
meetGreatest : TierLTE c a -> TierLTE c b -> TierLTE c (meet a b)
meetGreatest BandLTEBand             BandLTEBand             = BandLTEBand
meetGreatest BandLTEBand             BandLTERelational       = BandLTEBand
meetGreatest BandLTEBand             BandLTEFull             = BandLTEBand
meetGreatest BandLTERelational       BandLTEBand             = BandLTEBand
meetGreatest BandLTERelational       BandLTERelational       = BandLTERelational
meetGreatest BandLTERelational       BandLTEFull             = BandLTERelational
meetGreatest BandLTEFull             BandLTEBand             = BandLTEBand
meetGreatest BandLTEFull             BandLTERelational       = BandLTERelational
meetGreatest BandLTEFull             BandLTEFull             = BandLTEFull
meetGreatest RelationalLTERelational RelationalLTERelational = RelationalLTERelational
meetGreatest RelationalLTERelational RelationalLTEFull       = RelationalLTERelational
meetGreatest RelationalLTEFull       RelationalLTERelational = RelationalLTERelational
meetGreatest RelationalLTEFull       RelationalLTEFull       = RelationalLTEFull
meetGreatest FullLTEFull             FullLTEFull             = FullLTEFull
