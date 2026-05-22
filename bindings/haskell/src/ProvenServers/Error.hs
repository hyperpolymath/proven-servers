-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- | Shared error types for proven-servers FFI bindings.
--
-- All tag values match the Idris2 ABI discriminants exactly.

module ProvenServers.Error
  (
  ) where

import Data.Word (Word8)
