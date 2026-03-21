-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- | KMS protocol types for proven-servers.
--
-- Key Management Service types, mirroring the Idris2 ABI.
-- All tag values match the Idris2 ABI discriminants exactly.
--
-- This is a pure type-definition module with no FFI dependencies.

module ProvenServers.Kms
  ( -- * ADT types matching Idris2 ABI
      ObjectType(..)
    , Operation(..)
    , KeyState(..)
    , KmsAlgorithm(..)
    , objectTypeToTag
    , objectTypeFromTag
    , operationToTag
    , operationFromTag
    , keyStateToTag
    , keyStateFromTag
    , kmsAlgorithmToTag
    , kmsAlgorithmFromTag
  ) where

import Data.Word (Word8)

-- ---------------------------------------------------------------------------
-- ObjectType
-- ---------------------------------------------------------------------------

-- | ObjectType type matching the Idris2 ABI.
--
-- Tags 0-5 (6 constructors).
data ObjectType
  = SymmetricKey  -- ^ Tag 0.
  | PublicKey  -- ^ Tag 1.
  | PrivateKey  -- ^ Tag 2.
  | SecretData  -- ^ Tag 3.
  | Certificate  -- ^ Tag 4.
  | OpaqueData  -- ^ Tag 5.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'ObjectType' to its ABI tag value.
objectTypeToTag :: ObjectType -> Word8
objectTypeToTag = fromIntegral . fromEnum

-- | Decode a 'ObjectType' from its ABI tag value.
objectTypeFromTag :: Word8 -> Maybe ObjectType
objectTypeFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: ObjectType)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- Operation
-- ---------------------------------------------------------------------------

-- | Operation type matching the Idris2 ABI.
--
-- Tags 0-14 (15 constructors).
data Operation
  = Create  -- ^ Tag 0.
  | Get  -- ^ Tag 1.
  | Activate  -- ^ Tag 2.
  | Revoke  -- ^ Tag 3.
  | Destroy  -- ^ Tag 4.
  | Locate  -- ^ Tag 5.
  | Register  -- ^ Tag 6.
  | Rekey  -- ^ Tag 7.
  | Encrypt  -- ^ Tag 8.
  | Decrypt  -- ^ Tag 9.
  | Sign  -- ^ Tag 10.
  | Verify  -- ^ Tag 11.
  | Wrap  -- ^ Tag 12.
  | Unwrap  -- ^ Tag 13.
  | Mac  -- ^ Tag 14.
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
-- KeyState
-- ---------------------------------------------------------------------------

-- | KeyState type matching the Idris2 ABI.
--
-- Tags 0-5 (6 constructors).
data KeyState
  = PreActive  -- ^ Tag 0.
  | Active  -- ^ Tag 1.
  | Deactivated  -- ^ Tag 2.
  | Compromised  -- ^ Tag 3.
  | Destroyed  -- ^ Tag 4.
  | DestroyedCompromised  -- ^ Tag 5.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'KeyState' to its ABI tag value.
keyStateToTag :: KeyState -> Word8
keyStateToTag = fromIntegral . fromEnum

-- | Decode a 'KeyState' from its ABI tag value.
keyStateFromTag :: Word8 -> Maybe KeyState
keyStateFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: KeyState)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- KmsAlgorithm
-- ---------------------------------------------------------------------------

-- | KmsAlgorithm type matching the Idris2 ABI.
--
-- Tags 0-8 (9 constructors).
data KmsAlgorithm
  = Aes128  -- ^ Tag 0.
  | Aes256  -- ^ Tag 1.
  | Rsa2048  -- ^ Tag 2.
  | Rsa4096  -- ^ Tag 3.
  | EcdsaP256  -- ^ Tag 4.
  | EcdsaP384  -- ^ Tag 5.
  | Ed25519  -- ^ Tag 6.
  | Chacha20Poly1305  -- ^ Tag 7.
  | HmacSha256  -- ^ Tag 8.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'KmsAlgorithm' to its ABI tag value.
kmsAlgorithmToTag :: KmsAlgorithm -> Word8
kmsAlgorithmToTag = fromIntegral . fromEnum

-- | Decode a 'KmsAlgorithm' from its ABI tag value.
kmsAlgorithmFromTag :: Word8 -> Maybe KmsAlgorithm
kmsAlgorithmFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: KmsAlgorithm)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing
