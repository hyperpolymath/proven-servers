-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- | DNS-over-HTTPS types for the proven-servers ABI.
--
-- All tag values match the Idris2 ABI discriminants exactly.

module ProvenServers.Doh
  (
    dohPort
  , ContentType(..)
  , contentTypeToTag
  , contentTypeFromTag
  , RequestMethod(..)
  , requestMethodToTag
  , requestMethodFromTag
  , WireFormat(..)
  , wireFormatToTag
  , wireFormatFromTag
  , ErrorReason(..)
  , errorReasonToTag
  , errorReasonFromTag
  , SessionState(..)
  , sessionStateToTag
  , sessionStateFromTag
  ) where

import Data.Word (Word16, Word8)

-- | Standard HTTPS port for DoH.
dohPort :: Word16
dohPort = 443

-- ---------------------------------------------------------------------------
-- ContentType
-- ---------------------------------------------------------------------------

-- | Standard HTTPS port for DoH.
--
-- Tags 0-1 (2 constructors).
data ContentType
  = DnsMessage  -- ^ application/dns-message (tag 0).
  | DnsJson  -- ^ application/dns-json (tag 1).
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

-- | DoH HTTP request methods.
--
-- Tags 0-1 (2 constructors).
data RequestMethod
  = Get  -- ^ Get (tag 0).
  | Post  -- ^ Post (tag 1).
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

-- | DNS wire format.
--
-- Tags 0-1 (2 constructors).
data WireFormat
  = Binary  -- ^ Binary (tag 0).
  | Json  -- ^ Json (tag 1).
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

-- | DoH-specific error reasons.
--
-- Tags 0-4 (5 constructors).
data ErrorReason
  = BadContentType  -- ^ BadContentType (tag 0).
  | BadMethod  -- ^ BadMethod (tag 1).
  | PayloadTooLarge  -- ^ PayloadTooLarge (tag 2).
  | UpstreamTimeout  -- ^ UpstreamTimeout (tag 3).
  | UpstreamError  -- ^ UpstreamError (tag 4).
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

-- | DoH session lifecycle states.
--
-- Tags 0-4 (5 constructors).
data SessionState
  = Idle  -- ^ Idle (tag 0).
  | Bound  -- ^ Bound (tag 1).
  | Serving  -- ^ Serving (tag 2).
  | Resolving  -- ^ Resolving (tag 3).
  | Shutdown  -- ^ Shutdown (tag 4).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'SessionState' to its ABI tag value.
sessionStateToTag :: SessionState -> Word8
sessionStateToTag = fromIntegral . fromEnum

-- | Decode a 'SessionState' from its ABI tag value.
sessionStateFromTag :: Word8 -> Maybe SessionState
sessionStateFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: SessionState)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing
