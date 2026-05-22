-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- | Certificate Authority types for the proven-servers ABI.
--
-- All tag values match the Idris2 ABI discriminants exactly.

module ProvenServers.Ca
  (
    caPort
  , CertType(..)
  , certTypeToTag
  , certTypeFromTag
  , isCa
  , KeyAlgorithm(..)
  , keyAlgorithmToTag
  , keyAlgorithmFromTag
  , isRsa
  , isEllipticCurve
  , SignatureAlgorithm(..)
  , signatureAlgorithmToTag
  , signatureAlgorithmFromTag
  , CertState(..)
  , certStateToTag
  , certStateFromTag
  , isUsable
  , RevocationReason(..)
  , revocationReasonToTag
  , revocationReasonFromTag
  , isSecurityIncident
  , CrlStatus(..)
  , crlStatusToTag
  , crlStatusFromTag
  , OcspStatus(..)
  , ocspStatusToTag
  , ocspStatusFromTag
  , Extension(..)
  , extensionToTag
  , extensionFromTag
  , KeyUsageBit(..)
  , keyUsageBitToTag
  , keyUsageBitFromTag
  ) where

import Data.Word (Word16, Word8)

-- | Standard CA API port.
caPort :: Word16
caPort = 8443

-- ---------------------------------------------------------------------------
-- CertType
-- ---------------------------------------------------------------------------

-- | Standard CA API port.
--
-- Tags 0-6 (7 constructors).
data CertType
  = Root  -- ^ Root (tag 0).
  | Intermediate  -- ^ Intermediate (tag 1).
  | EndEntity  -- ^ EndEntity (tag 2).
  | CrossSigned  -- ^ CrossSigned (tag 3).
  | CodeSigning  -- ^ CodeSigning (tag 4).
  | EmailProtection  -- ^ EmailProtection (tag 5).
  | OcspSigning  -- ^ OCSP signing (tag 6).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'CertType' to its ABI tag value.
certTypeToTag :: CertType -> Word8
certTypeToTag = fromIntegral . fromEnum

-- | Decode a 'CertType' from its ABI tag value.
certTypeFromTag :: Word8 -> Maybe CertType
certTypeFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: CertType)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- | Whether this certificate type is a CA certificate.
isCa :: CertType -> Bool
isCa Root = True
isCa Intermediate = True
isCa CrossSigned = True
isCa _ = False

-- ---------------------------------------------------------------------------
-- KeyAlgorithm
-- ---------------------------------------------------------------------------

-- | Cryptographic key algorithms.
--
-- Tags 0-5 (6 constructors).
data KeyAlgorithm
  = Rsa2048  -- ^ Rsa2048 (tag 0).
  | Rsa4096  -- ^ Rsa4096 (tag 1).
  | EcdsaP256  -- ^ ECDSA P-256 (tag 2).
  | EcdsaP384  -- ^ ECDSA P-384 (tag 3).
  | Ed25519  -- ^ Ed25519 (tag 4).
  | Ed448  -- ^ Ed448 (tag 5).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'KeyAlgorithm' to its ABI tag value.
keyAlgorithmToTag :: KeyAlgorithm -> Word8
keyAlgorithmToTag = fromIntegral . fromEnum

-- | Decode a 'KeyAlgorithm' from its ABI tag value.
keyAlgorithmFromTag :: Word8 -> Maybe KeyAlgorithm
keyAlgorithmFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: KeyAlgorithm)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- | Whether this is an RSA algorithm.
isRsa :: KeyAlgorithm -> Bool
isRsa Rsa2048 = True
isRsa Rsa4096 = True
isRsa _ = False

-- | Whether this is an elliptic curve algorithm.
isEllipticCurve :: KeyAlgorithm -> Bool
isEllipticCurve EcdsaP256 = True
isEllipticCurve EcdsaP384 = True
isEllipticCurve Ed25519 = True
isEllipticCurve Ed448 = True
isEllipticCurve _ = False

-- ---------------------------------------------------------------------------
-- SignatureAlgorithm
-- ---------------------------------------------------------------------------

-- | Cryptographic signature algorithms.
--
-- Tags 0-6 (7 constructors).
data SignatureAlgorithm
  = Sha256WithRsa  -- ^ Sha256WithRsa (tag 0).
  | Sha384WithRsa  -- ^ Sha384WithRsa (tag 1).
  | Sha512WithRsa  -- ^ Sha512WithRsa (tag 2).
  | Sha256WithEcdsa  -- ^ Sha256WithEcdsa (tag 3).
  | Sha384WithEcdsa  -- ^ Sha384WithEcdsa (tag 4).
  | PureEd25519  -- ^ PureEd25519 (tag 5).
  | PureEd448  -- ^ PureEd448 (tag 6).
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

-- | Certificate lifecycle states.
--
-- Tags 0-4 (5 constructors).
data CertState
  = Pending  -- ^ Pending (tag 0).
  | Active  -- ^ Active (tag 1).
  | Revoked  -- ^ Revoked (tag 2).
  | Expired  -- ^ Expired (tag 3).
  | Suspended  -- ^ Suspended (tag 4).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'CertState' to its ABI tag value.
certStateToTag :: CertState -> Word8
certStateToTag = fromIntegral . fromEnum

-- | Decode a 'CertState' from its ABI tag value.
certStateFromTag :: Word8 -> Maybe CertState
certStateFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: CertState)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- | Whether the certificate can be used.
isUsable :: CertState -> Bool
isUsable Active = True
isUsable _ = False

-- ---------------------------------------------------------------------------
-- RevocationReason
-- ---------------------------------------------------------------------------

-- | Certificate revocation reasons (RFC 5280).
--
-- Tags 0-6 (7 constructors).
data RevocationReason
  = Unspecified  -- ^ Unspecified (tag 0).
  | KeyCompromise  -- ^ KeyCompromise (tag 1).
  | CaCompromise  -- ^ CaCompromise (tag 2).
  | AffiliationChanged  -- ^ AffiliationChanged (tag 3).
  | Superseded  -- ^ Superseded (tag 4).
  | CessationOfOperation  -- ^ CessationOfOperation (tag 5).
  | CertificateHold  -- ^ CertificateHold (tag 6).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'RevocationReason' to its ABI tag value.
revocationReasonToTag :: RevocationReason -> Word8
revocationReasonToTag = fromIntegral . fromEnum

-- | Decode a 'RevocationReason' from its ABI tag value.
revocationReasonFromTag :: Word8 -> Maybe RevocationReason
revocationReasonFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: RevocationReason)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- | Whether this revocation indicates a security incident.
isSecurityIncident :: RevocationReason -> Bool
isSecurityIncident KeyCompromise = True
isSecurityIncident CaCompromise = True
isSecurityIncident _ = False

-- ---------------------------------------------------------------------------
-- CrlStatus
-- ---------------------------------------------------------------------------

-- | CRL status.
--
-- Tags 0-3 (4 constructors).
data CrlStatus
  = Current  -- ^ Current (tag 0).
  | CrlExpired  -- ^ CrlExpired (tag 1).
  | CrlPending  -- ^ CrlPending (tag 2).
  | CrlError  -- ^ CrlError (tag 3).
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

-- | OCSP response status.
--
-- Tags 0-3 (4 constructors).
data OcspStatus
  = Good  -- ^ Good (tag 0).
  | OcspRevoked  -- ^ OcspRevoked (tag 1).
  | Unknown  -- ^ Unknown (tag 2).
  | Unavailable  -- ^ Unavailable (tag 3).
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

-- | X.509 extension types.
--
-- Tags 0-5 (6 constructors).
data Extension
  = BasicConstraints  -- ^ BasicConstraints (tag 0).
  | KeyUsage  -- ^ KeyUsage (tag 1).
  | ExtKeyUsage  -- ^ ExtKeyUsage (tag 2).
  | SubjectAltName  -- ^ SubjectAltName (tag 3).
  | AuthorityInfoAccess  -- ^ AuthorityInfoAccess (tag 4).
  | CrlDistributionPoints  -- ^ CrlDistributionPoints (tag 5).
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

-- | Key usage bit flags (RFC 5280).
--
-- Tags 0-8 (9 constructors).
data KeyUsageBit
  = DigitalSignature  -- ^ DigitalSignature (tag 0).
  | NonRepudiation  -- ^ NonRepudiation (tag 1).
  | KeyEncipherment  -- ^ KeyEncipherment (tag 2).
  | DataEncipherment  -- ^ DataEncipherment (tag 3).
  | KeyAgreement  -- ^ KeyAgreement (tag 4).
  | KeyCertSign  -- ^ KeyCertSign (tag 5).
  | CrlSign  -- ^ CrlSign (tag 6).
  | EncipherOnly  -- ^ EncipherOnly (tag 7).
  | DecipherOnly  -- ^ DecipherOnly (tag 8).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'KeyUsageBit' to its ABI tag value.
keyUsageBitToTag :: KeyUsageBit -> Word8
keyUsageBitToTag = fromIntegral . fromEnum

-- | Decode a 'KeyUsageBit' from its ABI tag value.
keyUsageBitFromTag :: Word8 -> Maybe KeyUsageBit
keyUsageBitFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: KeyUsageBit)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing
