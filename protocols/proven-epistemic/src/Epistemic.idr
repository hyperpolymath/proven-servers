-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
--
-- proven-epistemic: Epistemic disclosure server.
--
-- Architecture:
--   - Types:       Tier, Revealingness, Purpose, FieldGovernance,
--                  SessionPhase, DisclosureError
--   - Lattice:     TierLTE order, meet, and the lattice laws
--   - Transitions: session FSM, gated disclosure, non-amplification
--
-- This module defines core constants and re-exports the submodules.

module Epistemic

import public Epistemic.Types
import public Epistemic.Lattice
import public Epistemic.Transitions

%default total

||| Skeleton version string.
public export
skeletonVersion : String
skeletonVersion = "0.1.0"

||| Default disclosure tier: the bottom of the lattice (deny-by-default).
public export
defaultTier : Tier
defaultTier = Band

||| Deny-by-default is sound: the default tier is within every grant.
public export
defaultTierIsBottom : (t : Tier) -> TierLTE Epistemic.defaultTier t
defaultTierIsBottom Band       = BandLTEBand
defaultTierIsBottom Relational = BandLTERelational
defaultTierIsBottom Full       = BandLTEFull
