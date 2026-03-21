-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- | Proxy protocol types for proven-servers.
--
-- Reverse proxy types, mirroring the Idris2 ABI.
-- All tag values match the Idris2 ABI discriminants exactly.
--
-- This is a pure type-definition module with no FFI dependencies.

module ProvenServers.Proxy
  ( -- * ADT types matching Idris2 ABI
      ProxyMode(..)
    , HopByHopHeader(..)
    , CacheDirective(..)
    , ProxyError(..)
    , proxyModeToTag
    , proxyModeFromTag
    , hopByHopHeaderToTag
    , hopByHopHeaderFromTag
    , cacheDirectiveToTag
    , cacheDirectiveFromTag
    , proxyErrorToTag
    , proxyErrorFromTag
  ) where

import Data.Word (Word8)

-- ---------------------------------------------------------------------------
-- ProxyMode
-- ---------------------------------------------------------------------------

-- | ProxyMode type matching the Idris2 ABI.
--
-- Tags 0-1 (2 constructors).
data ProxyMode
  = Forward  -- ^ Tag 0.
  | Reverse  -- ^ Tag 1.
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

-- | HopByHopHeader type matching the Idris2 ABI.
--
-- Tags 0-7 (8 constructors).
data HopByHopHeader
  = Connection  -- ^ Tag 0.
  | KeepAlive  -- ^ Tag 1.
  | ProxyAuth  -- ^ Tag 2.
  | ProxyAuthz  -- ^ Tag 3.
  | Te  -- ^ Tag 4.
  | Trailers  -- ^ Tag 5.
  | TransferEncoding  -- ^ Tag 6.
  | Upgrade  -- ^ Tag 7.
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

-- | CacheDirective type matching the Idris2 ABI.
--
-- Tags 0-5 (6 constructors).
data CacheDirective
  = NoCache  -- ^ Tag 0.
  | NoStore  -- ^ Tag 1.
  | MaxAge  -- ^ Tag 2.
  | Public  -- ^ Tag 3.
  | Private  -- ^ Tag 4.
  | MustRevalidate  -- ^ Tag 5.
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

-- | ProxyError type matching the Idris2 ABI.
--
-- Tags 0-3 (4 constructors).
data ProxyError
  = BadGateway  -- ^ Tag 0.
  | GatewayTimeout  -- ^ Tag 1.
  | UpstreamRefused  -- ^ Tag 2.
  | UpstreamTls  -- ^ Tag 3.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'ProxyError' to its ABI tag value.
proxyErrorToTag :: ProxyError -> Word8
proxyErrorToTag = fromIntegral . fromEnum

-- | Decode a 'ProxyError' from its ABI tag value.
proxyErrorFromTag :: Word8 -> Maybe ProxyError
proxyErrorFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: ProxyError)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing
