-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
module HardenedABI.Foreign
import HardenedABI.Types
%default total
export
data HardenedContext : Type where [external]
public export
abiVersion : Bits32
abiVersion = 1
