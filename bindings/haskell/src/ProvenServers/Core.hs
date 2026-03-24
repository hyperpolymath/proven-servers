-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- | Core ABI types shared across all proven-servers protocols.
--
-- All tag values match the Idris2 ABI discriminants exactly.

module ProvenServers.Core
  (
    ResultCode(..)
  , resultCodeToTag
  , resultCodeFromTag
  , isOk
  , isError
  , description
  , Platform(..)
  , platformToTag
  , platformFromTag
  ) where

import Data.Word (Word8)

-- ---------------------------------------------------------------------------
-- ResultCode
-- ---------------------------------------------------------------------------

-- | FFI operation result codes.
--
-- Tags 0-4 (5 constructors).
data ResultCode
  = Ok  -- ^ Operation succeeded (tag 0).
  | Error  -- ^ Generic error (tag 1).
  | InvalidParam  -- ^ Invalid parameter provided (tag 2).
  | OutOfMemory  -- ^ Out of memory (tag 3).
  | NullPointer  -- ^ Null pointer encountered (tag 4).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'ResultCode' to its ABI tag value.
resultCodeToTag :: ResultCode -> Word8
resultCodeToTag = fromIntegral . fromEnum

-- | Decode a 'ResultCode' from its ABI tag value.
resultCodeFromTag :: Word8 -> Maybe ResultCode
resultCodeFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: ResultCode)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- | Whether this result represents success.
isOk :: ResultCode -> Bool
isOk Ok = True
isOk _ = False

-- | Whether this result represents any kind of error.
isError :: ResultCode -> Bool
isError Ok = False
isError _ = True

-- | `src/abi/Foreign.idr`.
description :: ResultCode -> String
description Ok = "Success"
description Error = "Generic error"
description InvalidParam = "Invalid parameter"
description OutOfMemory = "Out of memory"
description NullPointer = "Null pointer"

-- ---------------------------------------------------------------------------
-- Platform
-- ---------------------------------------------------------------------------

-- | Supported target platforms for ABI layout selection.
--
-- Tags 0-4 (5 constructors).
data Platform
  = Linux  -- ^ Linux (64-bit pointers, 64-bit size_t).
  | Windows  -- ^ Windows (64-bit pointers, 64-bit size_t).
  | MacOS  -- ^ macOS (64-bit pointers, 64-bit size_t).
  | Bsd  -- ^ BSD variants (64-bit pointers, 64-bit size_t).
  | Wasm  -- ^ WebAssembly (32-bit pointers, 32-bit size_t).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'Platform' to its ABI tag value.
platformToTag :: Platform -> Word8
platformToTag = fromIntegral . fromEnum

-- | Decode a 'Platform' from its ABI tag value.
platformFromTag :: Word8 -> Maybe Platform
platformFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: Platform)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing
