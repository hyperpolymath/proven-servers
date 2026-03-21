-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- | Shared error types for all proven-servers FFI operations.
--
-- Every protocol FFI uses the same slot-based context pool pattern with
-- @CInt@ return values (-1 = no slot, 0\/1 = success\/failure). This
-- module maps those patterns to a descriptive Haskell ADT.

module ProvenServers.Error
  ( -- * Error type
    ProvenError(..)
    -- * Interpreting FFI return values
  , fromSlot
  , fromStatus
  ) where

import Data.Int (Int32)
import Data.Word (Word8)

-- | Unified error type for all proven-servers FFI operations.
--
-- Maps the common failure modes of the slot-based context pool pattern
-- used by every Zig FFI implementation to descriptive Haskell values.
data ProvenError
  = PoolExhausted
    -- ^ No free context slots available in the pool (64-slot limit).
  | InvalidSlot
    -- ^ The slot index is invalid or the context is not active.
  | InvalidState
    -- ^ The operation was rejected because the context is in the wrong
    -- lifecycle state for the requested transition.
  | InvalidParameter
    -- ^ A parameter value is outside the valid ABI tag range.
  | CapacityExceeded
    -- ^ The operation would exceed a fixed-size buffer or array limit
    -- (e.g. max headers, max subscriptions, max rules).
  | ValidationFailed
    -- ^ Input validation failed (e.g. path traversal attack, too long).
  | UnknownError Int32
    -- ^ The FFI returned an unexpected or undocumented error code.
  deriving (Show, Eq, Ord)

-- | Interpret a slot-returning FFI call (@CInt@ result).
--
-- Returns @Right slot@ for non-negative values, @Left PoolExhausted@ for
-- negative values (typically -1).
fromSlot :: Int32 -> Either ProvenError Int32
fromSlot raw
  | raw >= 0  = Right raw
  | otherwise = Left PoolExhausted

-- | Interpret a status-returning FFI call (0 = success, non-zero = error).
--
-- Maps non-zero status codes to the appropriate 'ProvenError' variant:
--
-- * 0 -> @Right ()@
-- * 1 -> @Left InvalidState@
-- * 2 -> @Left ValidationFailed@
-- * other -> @Left (UnknownError code)@
fromStatus :: Word8 -> Either ProvenError ()
fromStatus 0 = Right ()
fromStatus 1 = Left InvalidState
fromStatus 2 = Left ValidationFailed
fromStatus n = Left (UnknownError (fromIntegral n))
