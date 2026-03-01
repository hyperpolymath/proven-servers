-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- Wire: Top-level module for proven-wire.
-- Re-exports Wire.Types and provides wire-encoding-related constants.

module Wire

import public Wire.Types

%default total

---------------------------------------------------------------------------
-- Constants
---------------------------------------------------------------------------

||| Maximum wire message size in bytes (64 MiB).
public export
maxWireSize : Nat
maxWireSize = 67108864

||| Sentinel value indicating no checksum is used.
public export
checksumNone : Nat
checksumNone = 0
