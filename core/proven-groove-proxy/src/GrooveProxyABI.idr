-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- GrooveProxyABI: Top-level ABI module for proven-groove-proxy.
--
-- Re-exports all ABI sub-modules:
--   - Layout:      Bits8 tag encodings with roundtrip proofs
--   - Transitions: ValidTransition GADT, impossibility proofs, decidability
--   - Foreign:     Opaque handle types and FFI function contracts
--   - Proofs:      Transport transparency, bounded memory, liveness

module GrooveProxyABI

import public GrooveProxyABI.Layout
import public GrooveProxyABI.Foreign
import public GrooveProxyABI.Transitions
import public GrooveProxyABI.Proofs

%default total
