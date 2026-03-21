-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- | PQC protocol types for proven-servers.
--
-- Post-Quantum Cryptography types, mirroring the Idris2 ABI.
-- All tag values match the Idris2 ABI discriminants exactly.
--
-- This is a pure type-definition module with no FFI dependencies.

module ProvenServers.Pqc
  ( -- * ADT types matching Idris2 ABI
      PqcAlgorithm(..)
    , NistLevel(..)
    , Operation(..)
    , HybridMode(..)
    , AlgorithmCategory(..)
    , KeyState(..)
    , pqcAlgorithmToTag
    , pqcAlgorithmFromTag
    , nistLevelToTag
    , nistLevelFromTag
    , operationToTag
    , operationFromTag
    , hybridModeToTag
    , hybridModeFromTag
    , algorithmCategoryToTag
    , algorithmCategoryFromTag
    , keyStateToTag
    , keyStateFromTag
  ) where

import Data.Word (Word8)

-- ---------------------------------------------------------------------------
-- PqcAlgorithm
-- ---------------------------------------------------------------------------

-- | PqcAlgorithm type matching the Idris2 ABI.
--
-- Tags 0-7 (8 constructors).
data PqcAlgorithm
  = CrystalsKyber  -- ^ Tag 0.
  | CrystalsDilithium  -- ^ Tag 1.
  | Falcon  -- ^ Tag 2.
  | SphincsPlus  -- ^ Tag 3.
  | ClassicMceliece  -- ^ Tag 4.
  | Bike  -- ^ Tag 5.
  | Hqc  -- ^ Tag 6.
  | Frodokem  -- ^ Tag 7.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'PqcAlgorithm' to its ABI tag value.
pqcAlgorithmToTag :: PqcAlgorithm -> Word8
pqcAlgorithmToTag = fromIntegral . fromEnum

-- | Decode a 'PqcAlgorithm' from its ABI tag value.
pqcAlgorithmFromTag :: Word8 -> Maybe PqcAlgorithm
pqcAlgorithmFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: PqcAlgorithm)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- NistLevel
-- ---------------------------------------------------------------------------

-- | NistLevel type matching the Idris2 ABI.
--
-- Tags 0-4 (5 constructors).
data NistLevel
  = Nist1  -- ^ Tag 0.
  | Nist2  -- ^ Tag 1.
  | Nist3  -- ^ Tag 2.
  | Nist4  -- ^ Tag 3.
  | Nist5  -- ^ Tag 4.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'NistLevel' to its ABI tag value.
nistLevelToTag :: NistLevel -> Word8
nistLevelToTag = fromIntegral . fromEnum

-- | Decode a 'NistLevel' from its ABI tag value.
nistLevelFromTag :: Word8 -> Maybe NistLevel
nistLevelFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: NistLevel)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- Operation
-- ---------------------------------------------------------------------------

-- | Operation type matching the Idris2 ABI.
--
-- Tags 0-4 (5 constructors).
data Operation
  = Keygen  -- ^ Tag 0.
  | Encapsulate  -- ^ Tag 1.
  | Decapsulate  -- ^ Tag 2.
  | Sign  -- ^ Tag 3.
  | Verify  -- ^ Tag 4.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'Operation' to its ABI tag value.
operationToTag :: Operation -> Word8
operationToTag = fromIntegral . fromEnum

-- | Decode a 'Operation' from its ABI tag value.
operationFromTag :: Word8 -> Maybe Operation
operationFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: Operation)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- HybridMode
-- ---------------------------------------------------------------------------

-- | HybridMode type matching the Idris2 ABI.
--
-- Tags 0-2 (3 constructors).
data HybridMode
  = ClassicalOnly  -- ^ Tag 0.
  | PqcOnly  -- ^ Tag 1.
  | Hybrid  -- ^ Tag 2.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'HybridMode' to its ABI tag value.
hybridModeToTag :: HybridMode -> Word8
hybridModeToTag = fromIntegral . fromEnum

-- | Decode a 'HybridMode' from its ABI tag value.
hybridModeFromTag :: Word8 -> Maybe HybridMode
hybridModeFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: HybridMode)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- AlgorithmCategory
-- ---------------------------------------------------------------------------

-- | AlgorithmCategory type matching the Idris2 ABI.
--
-- Tags 0-1 (2 constructors).
data AlgorithmCategory
  = Kem  -- ^ Tag 0.
  | Signature  -- ^ Tag 1.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'AlgorithmCategory' to its ABI tag value.
algorithmCategoryToTag :: AlgorithmCategory -> Word8
algorithmCategoryToTag = fromIntegral . fromEnum

-- | Decode a 'AlgorithmCategory' from its ABI tag value.
algorithmCategoryFromTag :: Word8 -> Maybe AlgorithmCategory
algorithmCategoryFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: AlgorithmCategory)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- KeyState
-- ---------------------------------------------------------------------------

-- | KeyState type matching the Idris2 ABI.
--
-- Tags 0-5 (6 constructors).
data KeyState
  = Empty  -- ^ Tag 0.
  | Generating  -- ^ Tag 1.
  | Generated  -- ^ Tag 2.
  | Active  -- ^ Tag 3.
  | Expired  -- ^ Tag 4.
  | Compromised  -- ^ Tag 5.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'KeyState' to its ABI tag value.
keyStateToTag :: KeyState -> Word8
keyStateToTag = fromIntegral . fromEnum

-- | Decode a 'KeyState' from its ABI tag value.
keyStateFromTag :: Word8 -> Maybe KeyState
keyStateFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: KeyState)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing
