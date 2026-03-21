-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- | Shared foreign import declarations and FFI utilities.
--
-- Provides common C type aliases and helper functions used across all
-- protocol-specific FFI modules. Individual protocol modules import
-- this for shared infrastructure.

module ProvenServers.FFI
  ( -- * C type aliases
    CSlot
  , CStatus
  , CTag
    -- * Slot-based context helpers
  , withSlot
  , checkStatus
  ) where

import Foreign.C.Types (CInt)
import Data.Word (Word8)
import ProvenServers.Error (ProvenError, fromSlot, fromStatus)

-- | Slot handle type used by all context pool functions.
-- Maps to @c_int@ in the Zig FFI layer.
type CSlot = CInt

-- | Status return type (0 = success, non-zero = error).
type CStatus = Word8

-- | ABI tag type for enum discriminants.
type CTag = Word8

-- | Interpret a slot-returning FFI call and convert the raw @CInt@ to
-- a checked slot value.
--
-- Wraps 'fromSlot' with automatic @CInt@ -> @Int32@ conversion.
withSlot :: CInt -> Either ProvenError CInt
withSlot raw =
  case fromSlot (fromIntegral raw) of
    Left err   -> Left err
    Right slot -> Right (fromIntegral slot)

-- | Interpret a status-returning FFI call.
--
-- Alias for 'fromStatus' for use in protocol modules.
checkStatus :: Word8 -> Either ProvenError ()
checkStatus = fromStatus
