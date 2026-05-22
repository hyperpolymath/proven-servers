-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- NesySolverAPIABI: Top-level ABI module for proven-nesy-solver-api.
-- Re-exports all ABI sub-modules so downstream consumers can import
-- a single module to get the complete ABI:
--
--   import NesySolverAPIABI
--
-- This brings into scope:
--   - Layout:      Bits8 tag encodings with roundtrip proofs
--   - Transitions: ValidTransition GADT + decidability
--   - Foreign:     Opaque handle types + FFI function contract

module NesySolverAPIABI

import public NesySolverAPIABI.Layout
import public NesySolverAPIABI.Foreign
import public NesySolverAPIABI.Transitions

%default total
