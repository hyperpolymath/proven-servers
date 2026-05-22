-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- | Reverse Proxy types for the proven-servers ABI.
--
-- All tag values match the Idris2 ABI discriminants exactly.

module ProvenServers.Proxy
  (
    proxyHttpPort
  , proxyHttpsPort
  , ProxyMode(..)
  , proxyModeToTag
  , proxyModeFromTag
  , HopByHopHeader(..)
  , hopByHopHeaderToTag
  , hopByHopHeaderFromTag
  , CacheDirective(..)
  , cacheDirectiveToTag
  , cacheDirectiveFromTag
  , ProxyError(..)
  , proxyErrorToTag
  , proxyErrorFromTag
  ) where

import Data.Word (Word16, Word8)

-- | Standard HTTP proxy port.
proxyHttpPort :: Word16
proxyHttpPort = 80

-- | Standard HTTPS proxy port.
proxyHttpsPort :: Word16
proxyHttpsPort = 443

-- ---------------------------------------------------------------------------
-- ProxyMode
-- ---------------------------------------------------------------------------

-- | Standard HTTP proxy port.
--
-- Tags 0-1 (2 constructors).
data ProxyMode
  = Forward  -- ^ Forward (tag 0).
  | Reverse  -- ^ Reverse (tag 1).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'ProxyMode' to its ABI tag value.
proxyModeToTag :: ProxyMode -> Word8
proxyModeToTag = fromIntegral . fromEnum

-- | Decode a 'ProxyMode' from its ABI tag value.
proxyModeFromTag :: Word8 -> Maybe ProxyMode
proxyModeFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: ProxyMode)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- HopByHopHeader
-- ---------------------------------------------------------------------------

-- | HTTP hop-by-hop headers (RFC 2616).
--
-- Tags 0-7 (8 constructors).
data HopByHopHeader
  = Connection  -- ^ Connection (tag 0).
  | KeepAlive  -- ^ KeepAlive (tag 1).
  | ProxyAuth  -- ^ Proxy-Authenticate (tag 2).
  | ProxyAuthz  -- ^ Proxy-Authorization (tag 3).
  | Te  -- ^ TE (tag 4).
  | Trailers  -- ^ Trailers (tag 5).
  | TransferEncoding  -- ^ TransferEncoding (tag 6).
  | Upgrade  -- ^ Upgrade (tag 7).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'HopByHopHeader' to its ABI tag value.
hopByHopHeaderToTag :: HopByHopHeader -> Word8
hopByHopHeaderToTag = fromIntegral . fromEnum

-- | Decode a 'HopByHopHeader' from its ABI tag value.
hopByHopHeaderFromTag :: Word8 -> Maybe HopByHopHeader
hopByHopHeaderFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: HopByHopHeader)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- CacheDirective
-- ---------------------------------------------------------------------------

-- | HTTP cache directives.
--
-- Tags 0-5 (6 constructors).
data CacheDirective
  = NoCache  -- ^ NoCache (tag 0).
  | NoStore  -- ^ NoStore (tag 1).
  | MaxAge  -- ^ MaxAge (tag 2).
  | Public  -- ^ Public (tag 3).
  | Private  -- ^ Private (tag 4).
  | MustRevalidate  -- ^ MustRevalidate (tag 5).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'CacheDirective' to its ABI tag value.
cacheDirectiveToTag :: CacheDirective -> Word8
cacheDirectiveToTag = fromIntegral . fromEnum

-- | Decode a 'CacheDirective' from its ABI tag value.
cacheDirectiveFromTag :: Word8 -> Maybe CacheDirective
cacheDirectiveFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: CacheDirective)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- ProxyError
-- ---------------------------------------------------------------------------

-- | Proxy-specific error codes.
--
-- Tags 0-3 (4 constructors).
data ProxyError
  = BadGateway  -- ^ BadGateway (tag 0).
  | GatewayTimeout  -- ^ GatewayTimeout (tag 1).
  | UpstreamRefused  -- ^ UpstreamRefused (tag 2).
  | UpstreamTls  -- ^ Upstream TLS error (tag 3).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'ProxyError' to its ABI tag value.
proxyErrorToTag :: ProxyError -> Word8
proxyErrorToTag = fromIntegral . fromEnum

-- | Decode a 'ProxyError' from its ABI tag value.
proxyErrorFromTag :: Word8 -> Maybe ProxyError
proxyErrorFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: ProxyError)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing
