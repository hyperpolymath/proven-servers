-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- | Post-Quantum Cryptography types for the proven-servers ABI.
--
-- All tag values match the Idris2 ABI discriminants exactly.

module ProvenServers.Pqc
  (
    PqcAlgorithm(..)
  , pqcAlgorithmToTag
  , pqcAlgorithmFromTag
  , isKem
  , isSignature
  , NistLevel(..)
  , nistLevelToTag
  , nistLevelFromTag
  , Operation(..)
  , operationToTag
  , operationFromTag
  , HybridMode(..)
  , hybridModeToTag
  , hybridModeFromTag
  , AlgorithmCategory(..)
  , algorithmCategoryToTag
  , algorithmCategoryFromTag
  , KeyState(..)
  , keyStateToTag
  , keyStateFromTag
  , isUsable
  ) where

import Data.Word (Word8)

-- ---------------------------------------------------------------------------
-- PqcAlgorithm
-- ---------------------------------------------------------------------------

-- | Post-quantum cryptographic algorithms.
--
-- Tags 0-7 (8 constructors).
data PqcAlgorithm
  = CrystalsKyber  -- ^ CRYSTALS-Kyber KEM (tag 0).
  | CrystalsDilithium  -- ^ CRYSTALS-Dilithium signature (tag 1).
  | Falcon  -- ^ FALCON signature (tag 2).
  | SphincsPlus  -- ^ SPHINCS+ signature (tag 3).
  | ClassicMceliece  -- ^ Classic McEliece KEM (tag 4).
  | Bike  -- ^ BIKE KEM (tag 5).
  | Hqc  -- ^ HQC KEM (tag 6).
  | Frodokem  -- ^ FrodoKEM (tag 7).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'PqcAlgorithm' to its ABI tag value.
pqcAlgorithmToTag :: PqcAlgorithm -> Word8
pqcAlgorithmToTag = fromIntegral . fromEnum

-- | Decode a 'PqcAlgorithm' from its ABI tag value.
pqcAlgorithmFromTag :: Word8 -> Maybe PqcAlgorithm
pqcAlgorithmFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: PqcAlgorithm)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- | Whether this is a KEM (key encapsulation) algorithm.
isKem :: PqcAlgorithm -> Bool
isKem CrystalsKyber = True
isKem ClassicMceliece = True
isKem Bike = True
isKem Hqc = True
isKem Frodokem = True
isKem _ = False

-- | Whether this is a signature algorithm.
isSignature :: PqcAlgorithm -> Bool
isSignature CrystalsDilithium = True
isSignature Falcon = True
isSignature SphincsPlus = True
isSignature _ = False

-- ---------------------------------------------------------------------------
-- NistLevel
-- ---------------------------------------------------------------------------

-- | NIST security levels (1-5).
--
-- Tags 0-4 (5 constructors).
data NistLevel
  = Nist1  -- ^ Nist1 (tag 0).
  | Nist2  -- ^ Nist2 (tag 1).
  | Nist3  -- ^ Nist3 (tag 2).
  | Nist4  -- ^ Nist4 (tag 3).
  | Nist5  -- ^ Nist5 (tag 4).
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

-- | PQC cryptographic operations.
--
-- Tags 0-4 (5 constructors).
data Operation
  = Keygen  -- ^ Keygen (tag 0).
  | Encapsulate  -- ^ Encapsulate (tag 1).
  | Decapsulate  -- ^ Decapsulate (tag 2).
  | Sign  -- ^ Sign (tag 3).
  | Verify  -- ^ Verify (tag 4).
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

-- | Classical/PQC hybrid modes.
--
-- Tags 0-2 (3 constructors).
data HybridMode
  = ClassicalOnly  -- ^ ClassicalOnly (tag 0).
  | PqcOnly  -- ^ PqcOnly (tag 1).
  | Hybrid  -- ^ Hybrid (tag 2).
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

-- | PQC algorithm categories.
--
-- Tags 0-1 (2 constructors).
data AlgorithmCategory
  = Kem  -- ^ Key encapsulation (tag 0).
  | Signature  -- ^ Signature (tag 1).
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

-- | PQC key lifecycle states.
--
-- Tags 0-5 (6 constructors).
data KeyState
  = Empty  -- ^ Empty (tag 0).
  | Generating  -- ^ Generating (tag 1).
  | Generated  -- ^ Generated (tag 2).
  | Active  -- ^ Active (tag 3).
  | Expired  -- ^ Expired (tag 4).
  | Compromised  -- ^ Compromised (tag 5).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'KeyState' to its ABI tag value.
keyStateToTag :: KeyState -> Word8
keyStateToTag = fromIntegral . fromEnum

-- | Decode a 'KeyState' from its ABI tag value.
keyStateFromTag :: Word8 -> Maybe KeyState
keyStateFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: KeyState)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- | Whether the key can be used.
isUsable :: KeyState -> Bool
isUsable Active = True
isUsable _ = False
