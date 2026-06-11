-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
module HoneypotABI.Foreign
import HoneypotABI.Types
%default total
export data HpContext : Type where [external]
public export abiVersion : Bits32; abiVersion = 1
