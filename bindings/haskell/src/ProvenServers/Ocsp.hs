-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- | OCSP types for the proven-servers ABI.
--
-- All tag values match the Idris2 ABI discriminants exactly.

module ProvenServers.Ocsp
  (
    ocspPort
  , CertStatus(..)
  , certStatusToTag
  , certStatusFromTag
  , ResponseStatus(..)
  , responseStatusToTag
  , responseStatusFromTag
  , HashAlgorithm(..)
  , hashAlgorithmToTag
  , hashAlgorithmFromTag
  , ResponderState(..)
  , responderStateToTag
  , responderStateFromTag
  ) where

import Data.Word (Word16, Word8)

-- | Standard OCSP HTTP port.
ocspPort :: Word16
ocspPort = 80

-- ---------------------------------------------------------------------------
-- CertStatus
-- ---------------------------------------------------------------------------

-- | Standard OCSP HTTP port.
--
-- Tags 0-2 (3 constructors).
data CertStatus
  = Good  -- ^ Good (tag 0).
  | Revoked  -- ^ Revoked (tag 1).
  | Unknown  -- ^ Unknown (tag 2).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'CertStatus' to its ABI tag value.
certStatusToTag :: CertStatus -> Word8
certStatusToTag = fromIntegral . fromEnum

-- | Decode a 'CertStatus' from its ABI tag value.
certStatusFromTag :: Word8 -> Maybe CertStatus
certStatusFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: CertStatus)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- ResponseStatus
-- ---------------------------------------------------------------------------

-- | OCSP response status.
--
-- Tags 0-5 (6 constructors).
data ResponseStatus
  = Successful  -- ^ Successful (tag 0).
  | MalformedRequest  -- ^ MalformedRequest (tag 1).
  | InternalError  -- ^ InternalError (tag 2).
  | TryLater  -- ^ TryLater (tag 3).
  | SigRequired  -- ^ SigRequired (tag 4).
  | Unauthorized  -- ^ Unauthorized (tag 5).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'ResponseStatus' to its ABI tag value.
responseStatusToTag :: ResponseStatus -> Word8
responseStatusToTag = fromIntegral . fromEnum

-- | Decode a 'ResponseStatus' from its ABI tag value.
responseStatusFromTag :: Word8 -> Maybe ResponseStatus
responseStatusFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: ResponseStatus)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- HashAlgorithm
-- ---------------------------------------------------------------------------

-- | OCSP hash algorithms.
--
-- Tags 0-3 (4 constructors).
data HashAlgorithm
  = Sha1  -- ^ SHA-1 (legacy) (tag 0).
  | Sha256  -- ^ SHA-256 (tag 1).
  | Sha384  -- ^ SHA-384 (tag 2).
  | Sha512  -- ^ SHA-512 (tag 3).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'HashAlgorithm' to its ABI tag value.
hashAlgorithmToTag :: HashAlgorithm -> Word8
hashAlgorithmToTag = fromIntegral . fromEnum

-- | Decode a 'HashAlgorithm' from its ABI tag value.
hashAlgorithmFromTag :: Word8 -> Maybe HashAlgorithm
hashAlgorithmFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: HashAlgorithm)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- ResponderState
-- ---------------------------------------------------------------------------

-- | OCSP responder states.
--
-- Tags 0-4 (5 constructors).
data ResponderState
  = Idle  -- ^ Idle (tag 0).
  | Ready  -- ^ Ready (tag 1).
  | Processing  -- ^ Processing (tag 2).
  | Signing  -- ^ Signing (tag 3).
  | Closing  -- ^ Closing (tag 4).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'ResponderState' to its ABI tag value.
responderStateToTag :: ResponderState -> Word8
responderStateToTag = fromIntegral . fromEnum

-- | Decode a 'ResponderState' from its ABI tag value.
responderStateFromTag :: Word8 -> Maybe ResponderState
responderStateFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: ResponderState)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing
