-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- Frame: Top-level module for proven-frame.
-- Re-exports Frame.Types and provides framing-related constants.

module Frame

import public Frame.Types

%default total

---------------------------------------------------------------------------
-- Constants
---------------------------------------------------------------------------

||| Maximum frame size in bytes (16 MiB).
public export
maxFrameSize : Nat
maxFrameSize = 16777216

||| Default read buffer size in bytes (8 KiB).
public export
defaultBufferSize : Nat
defaultBufferSize = 8192
