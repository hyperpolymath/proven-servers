-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
module IMAPABI.Foreign
import IMAPABI.Types
%default total
export data ImapContext : Type where [external]
public export abiVersion : Bits32; abiVersion = 1
