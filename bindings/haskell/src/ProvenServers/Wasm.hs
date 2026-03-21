-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- | WASM protocol types for proven-servers.
--
-- WebAssembly runtime types, mirroring the Idris2 ABI.
-- All tag values match the Idris2 ABI discriminants exactly.
--
-- This is a pure type-definition module with no FFI dependencies.

module ProvenServers.Wasm
  ( -- * ADT types matching Idris2 ABI
      ValType(..)
    , ExternKind(..)
    , Mutability(..)
    , valTypeToTag
    , valTypeFromTag
    , externKindToTag
    , externKindFromTag
    , mutabilityToTag
    , mutabilityFromTag
  ) where

import Data.Word (Word8)

-- ---------------------------------------------------------------------------
-- ValType
-- ---------------------------------------------------------------------------

-- | ValType type matching the Idris2 ABI.
--
-- Tags 0-6 (7 constructors).
data ValType
  = I32  -- ^ Tag 0.
  | I64  -- ^ Tag 1.
  | F32  -- ^ Tag 2.
  | F64  -- ^ Tag 3.
  | V128  -- ^ Tag 4.
  | FuncRef  -- ^ Tag 5.
  | ExternRef  -- ^ Tag 6.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'ValType' to its ABI tag value.
valTypeToTag :: ValType -> Word8
valTypeToTag = fromIntegral . fromEnum

-- | Decode a 'ValType' from its ABI tag value.
valTypeFromTag :: Word8 -> Maybe ValType
valTypeFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: ValType)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- ExternKind
-- ---------------------------------------------------------------------------

-- | ExternKind type matching the Idris2 ABI.
--
-- Tags 0-3 (4 constructors).
data ExternKind
  = FuncExtern  -- ^ Tag 0.
  | TableExtern  -- ^ Tag 1.
  | MemExtern  -- ^ Tag 2.
  | GlobalExtern  -- ^ Tag 3.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'ExternKind' to its ABI tag value.
externKindToTag :: ExternKind -> Word8
externKindToTag = fromIntegral . fromEnum

-- | Decode a 'ExternKind' from its ABI tag value.
externKindFromTag :: Word8 -> Maybe ExternKind
externKindFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: ExternKind)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- Mutability
-- ---------------------------------------------------------------------------

-- | Mutability type matching the Idris2 ABI.
--
-- Tags 0-1 (2 constructors).
data Mutability
  = Immutable  -- ^ Tag 0.
  | Mutable  -- ^ Tag 1.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'Mutability' to its ABI tag value.
mutabilityToTag :: Mutability -> Word8
mutabilityToTag = fromIntegral . fromEnum

-- | Decode a 'Mutability' from its ABI tag value.
mutabilityFromTag :: Word8 -> Maybe Mutability
mutabilityFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: Mutability)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing
