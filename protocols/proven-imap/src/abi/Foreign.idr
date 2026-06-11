-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
module IMAPABI.Foreign
import IMAPABI.Types
%default total
export data ImapContext : Type where [external]
public export abiVersion : Bits32; abiVersion = 1
