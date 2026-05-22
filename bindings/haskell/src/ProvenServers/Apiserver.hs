-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- | API Server types for the proven-servers ABI.
--
-- All tag values match the Idris2 ABI discriminants exactly.

module ProvenServers.Apiserver
  (
    apiPort
  , AuthScheme(..)
  , authSchemeToTag
  , authSchemeFromTag
  , RateLimitStrategy(..)
  , rateLimitStrategyToTag
  , rateLimitStrategyFromTag
  , ApiVersion(..)
  , apiVersionToTag
  , apiVersionFromTag
  , ResponseFormat(..)
  , responseFormatToTag
  , responseFormatFromTag
  , GatewayError(..)
  , gatewayErrorToTag
  , gatewayErrorFromTag
  ) where

import Data.Word (Word16, Word8)

-- | Standard API server port.
apiPort :: Word16
apiPort = 8080

-- ---------------------------------------------------------------------------
-- AuthScheme
-- ---------------------------------------------------------------------------

-- | Standard API server port.
--
-- Tags 0-5 (6 constructors).
data AuthScheme
  = ApiKey  -- ^ API Key (tag 0).
  | Bearer  -- ^ Bearer (tag 1).
  | Basic  -- ^ Basic (tag 2).
  | OAuth2  -- ^ OAuth2 (tag 3).
  | Hmac  -- ^ HMAC (tag 4).
  | Mtls  -- ^ mTLS (tag 5).
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

-- | API rate limiting strategies.
--
-- Tags 0-3 (4 constructors).
data RateLimitStrategy
  = FixedWindow  -- ^ FixedWindow (tag 0).
  | SlidingWindow  -- ^ SlidingWindow (tag 1).
  | TokenBucket  -- ^ TokenBucket (tag 2).
  | LeakyBucket  -- ^ LeakyBucket (tag 3).
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

-- | API version identifiers.
--
-- Tags 0-4 (5 constructors).
data ApiVersion
  = V1  -- ^ V1 (tag 0).
  | V2  -- ^ V2 (tag 1).
  | V3  -- ^ V3 (tag 2).
  | Latest  -- ^ Latest (tag 3).
  | Deprecated  -- ^ Deprecated (tag 4).
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

-- | API response formats.
--
-- Tags 0-3 (4 constructors).
data ResponseFormat
  = Json  -- ^ JSON (tag 0).
  | Xml  -- ^ XML (tag 1).
  | Protobuf  -- ^ Protobuf (tag 2).
  | MessagePack  -- ^ MessagePack (tag 3).
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

-- | API gateway error codes.
--
-- Tags 0-5 (6 constructors).
data GatewayError
  = Unauthorized  -- ^ Unauthorized (tag 0).
  | RateLimited  -- ^ RateLimited (tag 1).
  | NotFound  -- ^ NotFound (tag 2).
  | BadRequest  -- ^ BadRequest (tag 3).
  | ServiceUnavailable  -- ^ ServiceUnavailable (tag 4).
  | CircuitOpen  -- ^ CircuitOpen (tag 5).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'GatewayError' to its ABI tag value.
gatewayErrorToTag :: GatewayError -> Word8
gatewayErrorToTag = fromIntegral . fromEnum

-- | Decode a 'GatewayError' from its ABI tag value.
gatewayErrorFromTag :: Word8 -> Maybe GatewayError
gatewayErrorFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: GatewayError)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing
