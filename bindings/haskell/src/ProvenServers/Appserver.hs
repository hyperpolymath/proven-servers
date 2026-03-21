-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- | App Server protocol types for proven-servers.
--
-- Application server types, mirroring the Idris2 ABI.
-- All tag values match the Idris2 ABI discriminants exactly.
--
-- This is a pure type-definition module with no FFI dependencies.

module ProvenServers.Appserver
  ( -- * ADT types matching Idris2 ABI
      RequestType(..)
    , LifecycleState(..)
    , HealthCheck(..)
    , DeployStrategy(..)
    , ErrorCategory(..)
    , requestTypeToTag
    , requestTypeFromTag
    , lifecycleStateToTag
    , lifecycleStateFromTag
    , healthCheckToTag
    , healthCheckFromTag
    , deployStrategyToTag
    , deployStrategyFromTag
    , errorCategoryToTag
    , errorCategoryFromTag
  ) where

import Data.Word (Word8)

-- ---------------------------------------------------------------------------
-- RequestType
-- ---------------------------------------------------------------------------

-- | RequestType type matching the Idris2 ABI.
--
-- Tags 0-3 (4 constructors).
data RequestType
  = Http  -- ^ Tag 0.
  | WebSocket  -- ^ Tag 1.
  | Grpc  -- ^ Tag 2.
  | GraphQl  -- ^ Tag 3.
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

-- | LifecycleState type matching the Idris2 ABI.
--
-- Tags 0-5 (6 constructors).
data LifecycleState
  = Initializing  -- ^ Tag 0.
  | Starting  -- ^ Tag 1.
  | Running  -- ^ Tag 2.
  | Draining  -- ^ Tag 3.
  | Stopping  -- ^ Tag 4.
  | Stopped  -- ^ Tag 5.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'LifecycleState' to its ABI tag value.
lifecycleStateToTag :: LifecycleState -> Word8
lifecycleStateToTag = fromIntegral . fromEnum

-- | Decode a 'LifecycleState' from its ABI tag value.
lifecycleStateFromTag :: Word8 -> Maybe LifecycleState
lifecycleStateFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: LifecycleState)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- HealthCheck
-- ---------------------------------------------------------------------------

-- | HealthCheck type matching the Idris2 ABI.
--
-- Tags 0-2 (3 constructors).
data HealthCheck
  = Liveness  -- ^ Tag 0.
  | Readiness  -- ^ Tag 1.
  | Startup  -- ^ Tag 2.
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

-- | DeployStrategy type matching the Idris2 ABI.
--
-- Tags 0-3 (4 constructors).
data DeployStrategy
  = RollingUpdate  -- ^ Tag 0.
  | BlueGreen  -- ^ Tag 1.
  | Canary  -- ^ Tag 2.
  | Recreate  -- ^ Tag 3.
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

-- | ErrorCategory type matching the Idris2 ABI.
--
-- Tags 0-4 (5 constructors).
data ErrorCategory
  = ClientError  -- ^ Tag 0.
  | ServerError  -- ^ Tag 1.
  | Timeout  -- ^ Tag 2.
  | CircuitOpen  -- ^ Tag 3.
  | RateLimited  -- ^ Tag 4.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'ErrorCategory' to its ABI tag value.
errorCategoryToTag :: ErrorCategory -> Word8
errorCategoryToTag = fromIntegral . fromEnum

-- | Decode a 'ErrorCategory' from its ABI tag value.
errorCategoryFromTag :: Word8 -> Maybe ErrorCategory
errorCategoryFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: ErrorCategory)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing
