-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- | Core protocol types for proven-servers.
--
-- Core ABI types shared across all protocols, mirroring the Idris2 ABI.
-- All tag values match the Idris2 ABI discriminants exactly.
--
-- This is a pure type-definition module with no FFI dependencies.

module ProvenServers.Core
  ( -- * ADT types matching Idris2 ABI
      ResultCode(..)
    , Platform(..)
    , resultCodeToTag
    , resultCodeFromTag
    , platformToTag
    , platformFromTag
  ) where

import Data.Word (Word8)

-- ---------------------------------------------------------------------------
-- ResultCode
-- ---------------------------------------------------------------------------

-- | ResultCode type matching the Idris2 ABI.
--
-- Tags 0-4 (5 constructors).
data ResultCode
  = Ok  -- ^ Tag 0.
  | Error  -- ^ Tag 1.
  | InvalidParam  -- ^ Tag 2.
  | OutOfMemory  -- ^ Tag 3.
  | NullPointer  -- ^ Tag 4.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'ResultCode' to its ABI tag value.
resultCodeToTag :: ResultCode -> Word8
resultCodeToTag = fromIntegral . fromEnum

-- | Decode a 'ResultCode' from its ABI tag value.
resultCodeFromTag :: Word8 -> Maybe ResultCode
resultCodeFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: ResultCode)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- Platform
-- ---------------------------------------------------------------------------

-- | Platform type matching the Idris2 ABI.
--
-- Tags 0-4 (5 constructors).
data Platform
  = Linux  -- ^ Tag 0.
  | Windows  -- ^ Tag 1.
  | MacOS  -- ^ Tag 2.
  | Bsd  -- ^ Tag 3.
  | Wasm  -- ^ Tag 4.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'Platform' to its ABI tag value.
platformToTag :: Platform -> Word8
platformToTag = fromIntegral . fromEnum

-- | Decode a 'Platform' from its ABI tag value.
platformFromTag :: Word8 -> Maybe Platform
platformFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: Platform)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing
