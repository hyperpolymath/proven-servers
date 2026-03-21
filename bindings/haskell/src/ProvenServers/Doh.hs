-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- | DoH protocol types for proven-servers.
--
-- DNS-over-HTTPS types (RFC 8484), mirroring the Idris2 ABI.
-- All tag values match the Idris2 ABI discriminants exactly.
--
-- This is a pure type-definition module with no FFI dependencies.

module ProvenServers.Doh
  ( -- * ADT types matching Idris2 ABI
      ContentType(..)
    , RequestMethod(..)
    , WireFormat(..)
    , ErrorReason(..)
    , SessionState(..)
    , contentTypeToTag
    , contentTypeFromTag
    , requestMethodToTag
    , requestMethodFromTag
    , wireFormatToTag
    , wireFormatFromTag
    , errorReasonToTag
    , errorReasonFromTag
    , sessionStateToTag
    , sessionStateFromTag
  ) where

import Data.Word (Word8)

-- ---------------------------------------------------------------------------
-- ContentType
-- ---------------------------------------------------------------------------

-- | ContentType type matching the Idris2 ABI.
--
-- Tags 0-1 (2 constructors).
data ContentType
  = DnsMessage  -- ^ Tag 0.
  | DnsJson  -- ^ Tag 1.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'ContentType' to its ABI tag value.
contentTypeToTag :: ContentType -> Word8
contentTypeToTag = fromIntegral . fromEnum

-- | Decode a 'ContentType' from its ABI tag value.
contentTypeFromTag :: Word8 -> Maybe ContentType
contentTypeFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: ContentType)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- RequestMethod
-- ---------------------------------------------------------------------------

-- | RequestMethod type matching the Idris2 ABI.
--
-- Tags 0-1 (2 constructors).
data RequestMethod
  = Get  -- ^ Tag 0.
  | Post  -- ^ Tag 1.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'RequestMethod' to its ABI tag value.
requestMethodToTag :: RequestMethod -> Word8
requestMethodToTag = fromIntegral . fromEnum

-- | Decode a 'RequestMethod' from its ABI tag value.
requestMethodFromTag :: Word8 -> Maybe RequestMethod
requestMethodFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: RequestMethod)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- WireFormat
-- ---------------------------------------------------------------------------

-- | WireFormat type matching the Idris2 ABI.
--
-- Tags 0-1 (2 constructors).
data WireFormat
  = Binary  -- ^ Tag 0.
  | Json  -- ^ Tag 1.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'WireFormat' to its ABI tag value.
wireFormatToTag :: WireFormat -> Word8
wireFormatToTag = fromIntegral . fromEnum

-- | Decode a 'WireFormat' from its ABI tag value.
wireFormatFromTag :: Word8 -> Maybe WireFormat
wireFormatFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: WireFormat)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- ErrorReason
-- ---------------------------------------------------------------------------

-- | ErrorReason type matching the Idris2 ABI.
--
-- Tags 0-4 (5 constructors).
data ErrorReason
  = BadContentType  -- ^ Tag 0.
  | BadMethod  -- ^ Tag 1.
  | PayloadTooLarge  -- ^ Tag 2.
  | UpstreamTimeout  -- ^ Tag 3.
  | UpstreamError  -- ^ Tag 4.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'ErrorReason' to its ABI tag value.
errorReasonToTag :: ErrorReason -> Word8
errorReasonToTag = fromIntegral . fromEnum

-- | Decode a 'ErrorReason' from its ABI tag value.
errorReasonFromTag :: Word8 -> Maybe ErrorReason
errorReasonFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: ErrorReason)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- SessionState
-- ---------------------------------------------------------------------------

-- | SessionState type matching the Idris2 ABI.
--
-- Tags 0-4 (5 constructors).
data SessionState
  = Idle  -- ^ Tag 0.
  | Bound  -- ^ Tag 1.
  | Serving  -- ^ Tag 2.
  | Resolving  -- ^ Tag 3.
  | Shutdown  -- ^ Tag 4.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'SessionState' to its ABI tag value.
sessionStateToTag :: SessionState -> Word8
sessionStateToTag = fromIntegral . fromEnum

-- | Decode a 'SessionState' from its ABI tag value.
sessionStateFromTag :: Word8 -> Maybe SessionState
sessionStateFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: SessionState)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing
