-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- | Application Server types for the proven-servers ABI.
--
-- All tag values match the Idris2 ABI discriminants exactly.

module ProvenServers.Appserver
  (
    appPort
  , RequestType(..)
  , requestTypeToTag
  , requestTypeFromTag
  , LifecycleState(..)
  , lifecycleStateToTag
  , lifecycleStateFromTag
  , isReady
  , HealthCheck(..)
  , healthCheckToTag
  , healthCheckFromTag
  , DeployStrategy(..)
  , deployStrategyToTag
  , deployStrategyFromTag
  , ErrorCategory(..)
  , errorCategoryToTag
  , errorCategoryFromTag
  ) where

import Data.Word (Word16, Word8)

-- | Standard application server port.
appPort :: Word16
appPort = 8080

-- ---------------------------------------------------------------------------
-- RequestType
-- ---------------------------------------------------------------------------

-- | Standard application server port.
--
-- Tags 0-3 (4 constructors).
data RequestType
  = Http  -- ^ HTTP (tag 0).
  | WebSocket  -- ^ WebSocket (tag 1).
  | Grpc  -- ^ gRPC (tag 2).
  | GraphQl  -- ^ GraphQL (tag 3).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'RequestType' to its ABI tag value.
requestTypeToTag :: RequestType -> Word8
requestTypeToTag = fromIntegral . fromEnum

-- | Decode a 'RequestType' from its ABI tag value.
requestTypeFromTag :: Word8 -> Maybe RequestType
requestTypeFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: RequestType)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- LifecycleState
-- ---------------------------------------------------------------------------

-- | Application lifecycle states.
--
-- Tags 0-5 (6 constructors).
data LifecycleState
  = Initializing  -- ^ Initializing (tag 0).
  | Starting  -- ^ Starting (tag 1).
  | Running  -- ^ Running (tag 2).
  | Draining  -- ^ Draining (tag 3).
  | Stopping  -- ^ Stopping (tag 4).
  | Stopped  -- ^ Stopped (tag 5).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'LifecycleState' to its ABI tag value.
lifecycleStateToTag :: LifecycleState -> Word8
lifecycleStateToTag = fromIntegral . fromEnum

-- | Decode a 'LifecycleState' from its ABI tag value.
lifecycleStateFromTag :: Word8 -> Maybe LifecycleState
lifecycleStateFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: LifecycleState)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- | Whether the server is ready to handle requests.
isReady :: LifecycleState -> Bool
isReady Running = True
isReady _ = False

-- ---------------------------------------------------------------------------
-- HealthCheck
-- ---------------------------------------------------------------------------

-- | Health check types.
--
-- Tags 0-2 (3 constructors).
data HealthCheck
  = Liveness  -- ^ Liveness (tag 0).
  | Readiness  -- ^ Readiness (tag 1).
  | Startup  -- ^ Startup (tag 2).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'HealthCheck' to its ABI tag value.
healthCheckToTag :: HealthCheck -> Word8
healthCheckToTag = fromIntegral . fromEnum

-- | Decode a 'HealthCheck' from its ABI tag value.
healthCheckFromTag :: Word8 -> Maybe HealthCheck
healthCheckFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: HealthCheck)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- DeployStrategy
-- ---------------------------------------------------------------------------

-- | Deployment strategies.
--
-- Tags 0-3 (4 constructors).
data DeployStrategy
  = RollingUpdate  -- ^ RollingUpdate (tag 0).
  | BlueGreen  -- ^ BlueGreen (tag 1).
  | Canary  -- ^ Canary (tag 2).
  | Recreate  -- ^ Recreate (tag 3).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'DeployStrategy' to its ABI tag value.
deployStrategyToTag :: DeployStrategy -> Word8
deployStrategyToTag = fromIntegral . fromEnum

-- | Decode a 'DeployStrategy' from its ABI tag value.
deployStrategyFromTag :: Word8 -> Maybe DeployStrategy
deployStrategyFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: DeployStrategy)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- ErrorCategory
-- ---------------------------------------------------------------------------

-- | Application error categories.
--
-- Tags 0-4 (5 constructors).
data ErrorCategory
  = ClientError  -- ^ ClientError (tag 0).
  | ServerError  -- ^ ServerError (tag 1).
  | Timeout  -- ^ Timeout (tag 2).
  | CircuitOpen  -- ^ CircuitOpen (tag 3).
  | RateLimited  -- ^ RateLimited (tag 4).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'ErrorCategory' to its ABI tag value.
errorCategoryToTag :: ErrorCategory -> Word8
errorCategoryToTag = fromIntegral . fromEnum

-- | Decode a 'ErrorCategory' from its ABI tag value.
errorCategoryFromTag :: Word8 -> Maybe ErrorCategory
errorCategoryFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: ErrorCategory)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing
