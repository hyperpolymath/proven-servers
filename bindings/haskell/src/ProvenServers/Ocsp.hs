-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- | OCSP protocol types for proven-servers.
--
-- OCSP (Online Certificate Status Protocol, RFC 6960) types, mirroring the Idris2 ABI.
-- All tag values match the Idris2 ABI discriminants exactly.
--
-- This is a pure type-definition module with no FFI dependencies.

module ProvenServers.Ocsp
  ( -- * ADT types matching Idris2 ABI
      CertStatus(..)
    , ResponseStatus(..)
    , HashAlgorithm(..)
    , ResponderState(..)
    , certStatusToTag
    , certStatusFromTag
    , responseStatusToTag
    , responseStatusFromTag
    , hashAlgorithmToTag
    , hashAlgorithmFromTag
    , responderStateToTag
    , responderStateFromTag
  ) where

import Data.Word (Word8)

-- ---------------------------------------------------------------------------
-- CertStatus
-- ---------------------------------------------------------------------------

-- | CertStatus type matching the Idris2 ABI.
--
-- Tags 0-2 (3 constructors).
data CertStatus
  = Good  -- ^ Tag 0.
  | Revoked  -- ^ Tag 1.
  | Unknown  -- ^ Tag 2.
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

-- | ResponseStatus type matching the Idris2 ABI.
--
-- Tags 0-5 (6 constructors).
data ResponseStatus
  = Successful  -- ^ Tag 0.
  | MalformedRequest  -- ^ Tag 1.
  | InternalError  -- ^ Tag 2.
  | TryLater  -- ^ Tag 3.
  | SigRequired  -- ^ Tag 4.
  | Unauthorized  -- ^ Tag 5.
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

-- | HashAlgorithm type matching the Idris2 ABI.
--
-- Tags 0-3 (4 constructors).
data HashAlgorithm
  = Sha1  -- ^ Tag 0.
  | Sha256  -- ^ Tag 1.
  | Sha384  -- ^ Tag 2.
  | Sha512  -- ^ Tag 3.
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

-- | ResponderState type matching the Idris2 ABI.
--
-- Tags 0-4 (5 constructors).
data ResponderState
  = Idle  -- ^ Tag 0.
  | Ready  -- ^ Tag 1.
  | Processing  -- ^ Tag 2.
  | Signing  -- ^ Tag 3.
  | Closing  -- ^ Tag 4.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'ResponderState' to its ABI tag value.
responderStateToTag :: ResponderState -> Word8
responderStateToTag = fromIntegral . fromEnum

-- | Decode a 'ResponderState' from its ABI tag value.
responderStateFromTag :: Word8 -> Maybe ResponderState
responderStateFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: ResponderState)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing
