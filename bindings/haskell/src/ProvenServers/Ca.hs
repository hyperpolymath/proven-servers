-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- | CA protocol types for proven-servers.
--
-- Certificate Authority / PKI types, mirroring the Idris2 ABI.
-- All tag values match the Idris2 ABI discriminants exactly.
--
-- This is a pure type-definition module with no FFI dependencies.

module ProvenServers.Ca
  ( -- * ADT types matching Idris2 ABI
      CertType(..)
    , KeyAlgorithm(..)
    , SignatureAlgorithm(..)
    , CertState(..)
    , RevocationReason(..)
    , CrlStatus(..)
    , OcspStatus(..)
    , Extension(..)
    , KeyUsageBit(..)
    , certTypeToTag
    , certTypeFromTag
    , keyAlgorithmToTag
    , keyAlgorithmFromTag
    , signatureAlgorithmToTag
    , signatureAlgorithmFromTag
    , certStateToTag
    , certStateFromTag
    , revocationReasonToTag
    , revocationReasonFromTag
    , crlStatusToTag
    , crlStatusFromTag
    , ocspStatusToTag
    , ocspStatusFromTag
    , extensionToTag
    , extensionFromTag
    , keyUsageBitToTag
    , keyUsageBitFromTag
  ) where

import Data.Word (Word8)

-- ---------------------------------------------------------------------------
-- CertType
-- ---------------------------------------------------------------------------

-- | CertType type matching the Idris2 ABI.
--
-- Tags 0-6 (7 constructors).
data CertType
  = Root  -- ^ Tag 0.
  | Intermediate  -- ^ Tag 1.
  | EndEntity  -- ^ Tag 2.
  | CrossSigned  -- ^ Tag 3.
  | CodeSigning  -- ^ Tag 4.
  | EmailProtection  -- ^ Tag 5.
  | OcspSigning  -- ^ Tag 6.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'CertType' to its ABI tag value.
certTypeToTag :: CertType -> Word8
certTypeToTag = fromIntegral . fromEnum

-- | Decode a 'CertType' from its ABI tag value.
certTypeFromTag :: Word8 -> Maybe CertType
certTypeFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: CertType)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- KeyAlgorithm
-- ---------------------------------------------------------------------------

-- | KeyAlgorithm type matching the Idris2 ABI.
--
-- Tags 0-5 (6 constructors).
data KeyAlgorithm
  = Rsa2048  -- ^ Tag 0.
  | Rsa4096  -- ^ Tag 1.
  | EcdsaP256  -- ^ Tag 2.
  | EcdsaP384  -- ^ Tag 3.
  | Ed25519  -- ^ Tag 4.
  | Ed448  -- ^ Tag 5.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'KeyAlgorithm' to its ABI tag value.
keyAlgorithmToTag :: KeyAlgorithm -> Word8
keyAlgorithmToTag = fromIntegral . fromEnum

-- | Decode a 'KeyAlgorithm' from its ABI tag value.
keyAlgorithmFromTag :: Word8 -> Maybe KeyAlgorithm
keyAlgorithmFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: KeyAlgorithm)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- SignatureAlgorithm
-- ---------------------------------------------------------------------------

-- | SignatureAlgorithm type matching the Idris2 ABI.
--
-- Tags 0-6 (7 constructors).
data SignatureAlgorithm
  = Sha256WithRsa  -- ^ Tag 0.
  | Sha384WithRsa  -- ^ Tag 1.
  | Sha512WithRsa  -- ^ Tag 2.
  | Sha256WithEcdsa  -- ^ Tag 3.
  | Sha384WithEcdsa  -- ^ Tag 4.
  | PureEd25519  -- ^ Tag 5.
  | PureEd448  -- ^ Tag 6.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'SignatureAlgorithm' to its ABI tag value.
signatureAlgorithmToTag :: SignatureAlgorithm -> Word8
signatureAlgorithmToTag = fromIntegral . fromEnum

-- | Decode a 'SignatureAlgorithm' from its ABI tag value.
signatureAlgorithmFromTag :: Word8 -> Maybe SignatureAlgorithm
signatureAlgorithmFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: SignatureAlgorithm)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- CertState
-- ---------------------------------------------------------------------------

-- | CertState type matching the Idris2 ABI.
--
-- Tags 0-4 (5 constructors).
data CertState
  = Pending  -- ^ Tag 0.
  | Active  -- ^ Tag 1.
  | Revoked  -- ^ Tag 2.
  | Expired  -- ^ Tag 3.
  | Suspended  -- ^ Tag 4.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'CertState' to its ABI tag value.
certStateToTag :: CertState -> Word8
certStateToTag = fromIntegral . fromEnum

-- | Decode a 'CertState' from its ABI tag value.
certStateFromTag :: Word8 -> Maybe CertState
certStateFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: CertState)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- RevocationReason
-- ---------------------------------------------------------------------------

-- | RevocationReason type matching the Idris2 ABI.
--
-- Tags 0-6 (7 constructors).
data RevocationReason
  = Unspecified  -- ^ Tag 0.
  | KeyCompromise  -- ^ Tag 1.
  | CaCompromise  -- ^ Tag 2.
  | AffiliationChanged  -- ^ Tag 3.
  | Superseded  -- ^ Tag 4.
  | CessationOfOperation  -- ^ Tag 5.
  | CertificateHold  -- ^ Tag 6.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'RevocationReason' to its ABI tag value.
revocationReasonToTag :: RevocationReason -> Word8
revocationReasonToTag = fromIntegral . fromEnum

-- | Decode a 'RevocationReason' from its ABI tag value.
revocationReasonFromTag :: Word8 -> Maybe RevocationReason
revocationReasonFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: RevocationReason)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- CrlStatus
-- ---------------------------------------------------------------------------

-- | CrlStatus type matching the Idris2 ABI.
--
-- Tags 0-3 (4 constructors).
data CrlStatus
  = Current  -- ^ Tag 0.
  | CrlExpired  -- ^ Tag 1.
  | CrlPending  -- ^ Tag 2.
  | CrlError  -- ^ Tag 3.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'CrlStatus' to its ABI tag value.
crlStatusToTag :: CrlStatus -> Word8
crlStatusToTag = fromIntegral . fromEnum

-- | Decode a 'CrlStatus' from its ABI tag value.
crlStatusFromTag :: Word8 -> Maybe CrlStatus
crlStatusFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: CrlStatus)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- OcspStatus
-- ---------------------------------------------------------------------------

-- | OcspStatus type matching the Idris2 ABI.
--
-- Tags 0-3 (4 constructors).
data OcspStatus
  = Good  -- ^ Tag 0.
  | OcspRevoked  -- ^ Tag 1.
  | Unknown  -- ^ Tag 2.
  | Unavailable  -- ^ Tag 3.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'OcspStatus' to its ABI tag value.
ocspStatusToTag :: OcspStatus -> Word8
ocspStatusToTag = fromIntegral . fromEnum

-- | Decode a 'OcspStatus' from its ABI tag value.
ocspStatusFromTag :: Word8 -> Maybe OcspStatus
ocspStatusFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: OcspStatus)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- Extension
-- ---------------------------------------------------------------------------

-- | Extension type matching the Idris2 ABI.
--
-- Tags 0-5 (6 constructors).
data Extension
  = BasicConstraints  -- ^ Tag 0.
  | KeyUsage  -- ^ Tag 1.
  | ExtKeyUsage  -- ^ Tag 2.
  | SubjectAltName  -- ^ Tag 3.
  | AuthorityInfoAccess  -- ^ Tag 4.
  | CrlDistributionPoints  -- ^ Tag 5.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'Extension' to its ABI tag value.
extensionToTag :: Extension -> Word8
extensionToTag = fromIntegral . fromEnum

-- | Decode a 'Extension' from its ABI tag value.
extensionFromTag :: Word8 -> Maybe Extension
extensionFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: Extension)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- KeyUsageBit
-- ---------------------------------------------------------------------------

-- | KeyUsageBit type matching the Idris2 ABI.
--
-- Tags 0-8 (9 constructors).
data KeyUsageBit
  = DigitalSignature  -- ^ Tag 0.
  | NonRepudiation  -- ^ Tag 1.
  | KeyEncipherment  -- ^ Tag 2.
  | DataEncipherment  -- ^ Tag 3.
  | KeyAgreement  -- ^ Tag 4.
  | KeyCertSign  -- ^ Tag 5.
  | CrlSign  -- ^ Tag 6.
  | EncipherOnly  -- ^ Tag 7.
  | DecipherOnly  -- ^ Tag 8.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'KeyUsageBit' to its ABI tag value.
keyUsageBitToTag :: KeyUsageBit -> Word8
keyUsageBitToTag = fromIntegral . fromEnum

-- | Decode a 'KeyUsageBit' from its ABI tag value.
keyUsageBitFromTag :: Word8 -> Maybe KeyUsageBit
keyUsageBitFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: KeyUsageBit)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing
