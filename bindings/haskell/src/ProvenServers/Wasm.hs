-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- | WASM Runtime types for the proven-servers ABI.
--
-- All tag values match the Idris2 ABI discriminants exactly.

module ProvenServers.Wasm
  (
    ValType(..)
  , valTypeToTag
  , valTypeFromTag
  , isNumeric
  , isReference
  , ExternKind(..)
  , externKindToTag
  , externKindFromTag
  , Mutability(..)
  , mutabilityToTag
  , mutabilityFromTag
  ) where

import Data.Word (Word8)

-- ---------------------------------------------------------------------------
-- ValType
-- ---------------------------------------------------------------------------

-- | WebAssembly value types.
--
-- Tags 0-6 (7 constructors).
data ValType
  = I32  -- ^ I32 (tag 0).
  | I64  -- ^ I64 (tag 1).
  | F32  -- ^ F32 (tag 2).
  | F64  -- ^ F64 (tag 3).
  | V128  -- ^ V128 (tag 4).
  | FuncRef  -- ^ FuncRef (tag 5).
  | ExternRef  -- ^ ExternRef (tag 6).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'ValType' to its ABI tag value.
valTypeToTag :: ValType -> Word8
valTypeToTag = fromIntegral . fromEnum

-- | Decode a 'ValType' from its ABI tag value.
valTypeFromTag :: Word8 -> Maybe ValType
valTypeFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: ValType)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- | Whether this is a numeric type.
isNumeric :: ValType -> Bool
isNumeric I32 = True
isNumeric I64 = True
isNumeric F32 = True
isNumeric F64 = True
isNumeric _ = False

-- | Whether this is a reference type.
isReference :: ValType -> Bool
isReference FuncRef = True
isReference ExternRef = True
isReference _ = False

-- ---------------------------------------------------------------------------
-- ExternKind
-- ---------------------------------------------------------------------------

-- | WebAssembly external kinds.
--
-- Tags 0-3 (4 constructors).
data ExternKind
  = FuncExtern  -- ^ Function (tag 0).
  | TableExtern  -- ^ Table (tag 1).
  | MemExtern  -- ^ Memory (tag 2).
  | GlobalExtern  -- ^ Global (tag 3).
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

-- | WebAssembly global mutability.
--
-- Tags 0-1 (2 constructors).
data Mutability
  = Immutable  -- ^ Immutable (tag 0).
  | Mutable  -- ^ Mutable (tag 1).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'Mutability' to its ABI tag value.
mutabilityToTag :: Mutability -> Word8
mutabilityToTag = fromIntegral . fromEnum

-- | Decode a 'Mutability' from its ABI tag value.
mutabilityFromTag :: Word8 -> Maybe Mutability
mutabilityFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: Mutability)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing
