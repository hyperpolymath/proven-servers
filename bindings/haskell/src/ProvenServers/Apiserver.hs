-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- | API Server protocol types for proven-servers.
--
-- API gateway/server types, mirroring the Idris2 ABI.
-- All tag values match the Idris2 ABI discriminants exactly.
--
-- This is a pure type-definition module with no FFI dependencies.

module ProvenServers.Apiserver
  ( -- * ADT types matching Idris2 ABI
      AuthScheme(..)
    , RateLimitStrategy(..)
    , ApiVersion(..)
    , ResponseFormat(..)
    , GatewayError(..)
    , authSchemeToTag
    , authSchemeFromTag
    , rateLimitStrategyToTag
    , rateLimitStrategyFromTag
    , apiVersionToTag
    , apiVersionFromTag
    , responseFormatToTag
    , responseFormatFromTag
    , gatewayErrorToTag
    , gatewayErrorFromTag
  ) where

import Data.Word (Word8)

-- ---------------------------------------------------------------------------
-- AuthScheme
-- ---------------------------------------------------------------------------

-- | AuthScheme type matching the Idris2 ABI.
--
-- Tags 0-5 (6 constructors).
data AuthScheme
  = ApiKey  -- ^ Tag 0.
  | Bearer  -- ^ Tag 1.
  | Basic  -- ^ Tag 2.
  | OAuth2  -- ^ Tag 3.
  | Hmac  -- ^ Tag 4.
  | Mtls  -- ^ Tag 5.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'AuthScheme' to its ABI tag value.
authSchemeToTag :: AuthScheme -> Word8
authSchemeToTag = fromIntegral . fromEnum

-- | Decode a 'AuthScheme' from its ABI tag value.
authSchemeFromTag :: Word8 -> Maybe AuthScheme
authSchemeFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: AuthScheme)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- RateLimitStrategy
-- ---------------------------------------------------------------------------

-- | RateLimitStrategy type matching the Idris2 ABI.
--
-- Tags 0-3 (4 constructors).
data RateLimitStrategy
  = FixedWindow  -- ^ Tag 0.
  | SlidingWindow  -- ^ Tag 1.
  | TokenBucket  -- ^ Tag 2.
  | LeakyBucket  -- ^ Tag 3.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'RateLimitStrategy' to its ABI tag value.
rateLimitStrategyToTag :: RateLimitStrategy -> Word8
rateLimitStrategyToTag = fromIntegral . fromEnum

-- | Decode a 'RateLimitStrategy' from its ABI tag value.
rateLimitStrategyFromTag :: Word8 -> Maybe RateLimitStrategy
rateLimitStrategyFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: RateLimitStrategy)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- ApiVersion
-- ---------------------------------------------------------------------------

-- | ApiVersion type matching the Idris2 ABI.
--
-- Tags 0-4 (5 constructors).
data ApiVersion
  = V1  -- ^ Tag 0.
  | V2  -- ^ Tag 1.
  | V3  -- ^ Tag 2.
  | Latest  -- ^ Tag 3.
  | Deprecated  -- ^ Tag 4.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'ApiVersion' to its ABI tag value.
apiVersionToTag :: ApiVersion -> Word8
apiVersionToTag = fromIntegral . fromEnum

-- | Decode a 'ApiVersion' from its ABI tag value.
apiVersionFromTag :: Word8 -> Maybe ApiVersion
apiVersionFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: ApiVersion)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- ResponseFormat
-- ---------------------------------------------------------------------------

-- | ResponseFormat type matching the Idris2 ABI.
--
-- Tags 0-3 (4 constructors).
data ResponseFormat
  = Json  -- ^ Tag 0.
  | Xml  -- ^ Tag 1.
  | Protobuf  -- ^ Tag 2.
  | MessagePack  -- ^ Tag 3.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'ResponseFormat' to its ABI tag value.
responseFormatToTag :: ResponseFormat -> Word8
responseFormatToTag = fromIntegral . fromEnum

-- | Decode a 'ResponseFormat' from its ABI tag value.
responseFormatFromTag :: Word8 -> Maybe ResponseFormat
responseFormatFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: ResponseFormat)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- GatewayError
-- ---------------------------------------------------------------------------

-- | GatewayError type matching the Idris2 ABI.
--
-- Tags 0-5 (6 constructors).
data GatewayError
  = Unauthorized  -- ^ Tag 0.
  | RateLimited  -- ^ Tag 1.
  | NotFound  -- ^ Tag 2.
  | BadRequest  -- ^ Tag 3.
  | ServiceUnavailable  -- ^ Tag 4.
  | CircuitOpen  -- ^ Tag 5.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'GatewayError' to its ABI tag value.
gatewayErrorToTag :: GatewayError -> Word8
gatewayErrorToTag = fromIntegral . fromEnum

-- | Decode a 'GatewayError' from its ABI tag value.
gatewayErrorFromTag :: Word8 -> Maybe GatewayError
gatewayErrorFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: GatewayError)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing
