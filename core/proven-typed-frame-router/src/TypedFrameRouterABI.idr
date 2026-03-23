-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- TypedFrameRouterABI: Top-level ABI module for proven-typed-frame-router.
--
-- Re-exports all ABI sub-modules:
--   - Layout:      Bits8 tag encodings with roundtrip proofs
--   - Transitions: ValidTransition GADT, impossibility proofs, decidability
--   - Foreign:     Opaque handle types and FFI function contracts
--   - Proofs:      Transport transparency, bounded memory, liveness

module TypedFrameRouterABI

import public TypedFrameRouterABI.Layout
import public TypedFrameRouterABI.Foreign
import public TypedFrameRouterABI.Transitions
import public TypedFrameRouterABI.Proofs

%default total
