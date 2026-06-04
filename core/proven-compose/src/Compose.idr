-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
--
-- Compose: Top-level module for proven-compose.
-- Re-exports Compose.Types and provides composition-related constants.

module Compose

import public Compose.Types

%default total

---------------------------------------------------------------------------
-- Constants
---------------------------------------------------------------------------

||| Maximum depth of a Chain composition (to prevent unbounded recursion).
public export
maxChainDepth : Nat
maxChainDepth = 16

||| Maximum number of parallel branches in a Parallel composition.
public export
maxParallelBranches : Nat
maxParallelBranches = 64
