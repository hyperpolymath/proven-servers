-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
--
-- Config: Top-level module for proven-config.
-- Re-exports Config.Types and provides configuration-related constants.

module Config

import public Config.Types

%default total

---------------------------------------------------------------------------
-- Constants
---------------------------------------------------------------------------

||| Maximum configuration file size in bytes (1 MiB).
public export
maxConfigSize : Nat
maxConfigSize = 1048576
