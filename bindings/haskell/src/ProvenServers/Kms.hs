-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- | Key Management Service types for the proven-servers ABI.
--
-- All tag values match the Idris2 ABI discriminants exactly.

module ProvenServers.Kms
  (
    kmsPort
  , ObjectType(..)
  , objectTypeToTag
  , objectTypeFromTag
  , Operation(..)
  , operationToTag
  , operationFromTag
  , isCryptoOp
  , isLifecycleOp
  , KeyState(..)
  , keyStateToTag
  , keyStateFromTag
  , isUsable
  , KmsAlgorithm(..)
  , kmsAlgorithmToTag
  , kmsAlgorithmFromTag
  ) where

import Data.Word (Word16, Word8)

-- | Standard KMIP port.
kmsPort :: Word16
kmsPort = 5696

-- ---------------------------------------------------------------------------
-- ObjectType
-- ---------------------------------------------------------------------------

-- | Standard KMIP port.
--
-- Tags 0-5 (6 constructors).
data ObjectType
  = SymmetricKey  -- ^ SymmetricKey (tag 0).
  | PublicKey  -- ^ PublicKey (tag 1).
  | PrivateKey  -- ^ PrivateKey (tag 2).
  | SecretData  -- ^ SecretData (tag 3).
  | Certificate  -- ^ Certificate (tag 4).
  | OpaqueData  -- ^ OpaqueData (tag 5).
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

-- | KMS operations.
--
-- Tags 0-14 (15 constructors).
data Operation
  = Create  -- ^ Create (tag 0).
  | Get  -- ^ Get (tag 1).
  | Activate  -- ^ Activate (tag 2).
  | Revoke  -- ^ Revoke (tag 3).
  | Destroy  -- ^ Destroy (tag 4).
  | Locate  -- ^ Locate (tag 5).
  | Register  -- ^ Register (tag 6).
  | Rekey  -- ^ Rekey (tag 7).
  | Encrypt  -- ^ Encrypt (tag 8).
  | Decrypt  -- ^ Decrypt (tag 9).
  | Sign  -- ^ Sign (tag 10).
  | Verify  -- ^ Verify (tag 11).
  | Wrap  -- ^ Wrap (tag 12).
  | Unwrap  -- ^ Unwrap (tag 13).
  | Mac  -- ^ MAC (tag 14).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'Operation' to its ABI tag value.
operationToTag :: Operation -> Word8
operationToTag = fromIntegral . fromEnum

-- | Decode a 'Operation' from its ABI tag value.
operationFromTag :: Word8 -> Maybe Operation
operationFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: Operation)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- | Whether this is a cryptographic operation.
isCryptoOp :: Operation -> Bool
isCryptoOp Encrypt = True
isCryptoOp Decrypt = True
isCryptoOp Sign = True
isCryptoOp Verify = True
isCryptoOp Wrap = True
isCryptoOp Unwrap = True
isCryptoOp Mac = True
isCryptoOp _ = False

-- | Whether this is a key lifecycle operation.
isLifecycleOp :: Operation -> Bool
isLifecycleOp Create = True
isLifecycleOp Activate = True
isLifecycleOp Revoke = True
isLifecycleOp Destroy = True
isLifecycleOp Rekey = True
isLifecycleOp _ = False

-- ---------------------------------------------------------------------------
-- KeyState
-- ---------------------------------------------------------------------------

-- | Key lifecycle states (KMIP).
--
-- Tags 0-5 (6 constructors).
data KeyState
  = PreActive  -- ^ PreActive (tag 0).
  | Active  -- ^ Active (tag 1).
  | Deactivated  -- ^ Deactivated (tag 2).
  | Compromised  -- ^ Compromised (tag 3).
  | Destroyed  -- ^ Destroyed (tag 4).
  | DestroyedCompromised  -- ^ DestroyedCompromised (tag 5).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'KeyState' to its ABI tag value.
keyStateToTag :: KeyState -> Word8
keyStateToTag = fromIntegral . fromEnum

-- | Decode a 'KeyState' from its ABI tag value.
keyStateFromTag :: Word8 -> Maybe KeyState
keyStateFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: KeyState)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- | Whether the key can be used for cryptographic operations.
isUsable :: KeyState -> Bool
isUsable Active = True
isUsable _ = False

-- ---------------------------------------------------------------------------
-- KmsAlgorithm
-- ---------------------------------------------------------------------------

-- | Cryptographic algorithms.
--
-- Tags 0-8 (9 constructors).
data KmsAlgorithm
  = Aes128  -- ^ AES-128 (tag 0).
  | Aes256  -- ^ AES-256 (tag 1).
  | Rsa2048  -- ^ RSA-2048 (tag 2).
  | Rsa4096  -- ^ RSA-4096 (tag 3).
  | EcdsaP256  -- ^ ECDSA P-256 (tag 4).
  | EcdsaP384  -- ^ ECDSA P-384 (tag 5).
  | Ed25519  -- ^ Ed25519 (tag 6).
  | Chacha20Poly1305  -- ^ Chacha20Poly1305 (tag 7).
  | HmacSha256  -- ^ HMAC-SHA256 (tag 8).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'KmsAlgorithm' to its ABI tag value.
kmsAlgorithmToTag :: KmsAlgorithm -> Word8
kmsAlgorithmToTag = fromIntegral . fromEnum

-- | Decode a 'KmsAlgorithm' from its ABI tag value.
kmsAlgorithmFromTag :: Word8 -> Maybe KmsAlgorithm
kmsAlgorithmFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: KmsAlgorithm)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing
