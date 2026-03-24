-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- | Load Balancer types for the proven-servers ABI.
--
-- All tag values match the Idris2 ABI discriminants exactly.

module ProvenServers.Loadbalancer
  (
    Algorithm(..)
  , algorithmToTag
  , algorithmFromTag
  , HealthCheckType(..)
  , healthCheckTypeToTag
  , healthCheckTypeFromTag
  , BackendState(..)
  , backendStateToTag
  , backendStateFromTag
  , canReceiveTraffic
  , SessionPersistence(..)
  , sessionPersistenceToTag
  , sessionPersistenceFromTag
  , LbProtocol(..)
  , lbProtocolToTag
  , lbProtocolFromTag
  ) where

import Data.Word (Word8)

-- ---------------------------------------------------------------------------
-- Algorithm
-- ---------------------------------------------------------------------------

-- | Load balancing algorithms.
--
-- Tags 0-5 (6 constructors).
data Algorithm
  = RoundRobin  -- ^ RoundRobin (tag 0).
  | LeastConnections  -- ^ LeastConnections (tag 1).
  | IpHash  -- ^ IpHash (tag 2).
  | Random  -- ^ Random (tag 3).
  | WeightedRoundRobin  -- ^ WeightedRoundRobin (tag 4).
  | LeastResponseTime  -- ^ LeastResponseTime (tag 5).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'Algorithm' to its ABI tag value.
algorithmToTag :: Algorithm -> Word8
algorithmToTag = fromIntegral . fromEnum

-- | Decode a 'Algorithm' from its ABI tag value.
algorithmFromTag :: Word8 -> Maybe Algorithm
algorithmFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: Algorithm)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- HealthCheckType
-- ---------------------------------------------------------------------------

-- | Backend health check types.
--
-- Tags 0-3 (4 constructors).
data HealthCheckType
  = Http  -- ^ HTTP health check (tag 0).
  | Tcp  -- ^ TCP health check (tag 1).
  | Grpc  -- ^ gRPC health check (tag 2).
  | Script  -- ^ Script (tag 3).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'HealthCheckType' to its ABI tag value.
healthCheckTypeToTag :: HealthCheckType -> Word8
healthCheckTypeToTag = fromIntegral . fromEnum

-- | Decode a 'HealthCheckType' from its ABI tag value.
healthCheckTypeFromTag :: Word8 -> Maybe HealthCheckType
healthCheckTypeFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: HealthCheckType)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- BackendState
-- ---------------------------------------------------------------------------

-- | Backend server states.
--
-- Tags 0-3 (4 constructors).
data BackendState
  = Healthy  -- ^ Healthy (tag 0).
  | Unhealthy  -- ^ Unhealthy (tag 1).
  | Draining  -- ^ Draining (tag 2).
  | Disabled  -- ^ Disabled (tag 3).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'BackendState' to its ABI tag value.
backendStateToTag :: BackendState -> Word8
backendStateToTag = fromIntegral . fromEnum

-- | Decode a 'BackendState' from its ABI tag value.
backendStateFromTag :: Word8 -> Maybe BackendState
backendStateFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: BackendState)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- | Whether this backend can receive new connections.
canReceiveTraffic :: BackendState -> Bool
canReceiveTraffic Healthy = True
canReceiveTraffic _ = False

-- ---------------------------------------------------------------------------
-- SessionPersistence
-- ---------------------------------------------------------------------------

-- | Session persistence strategies.
--
-- Tags 0-3 (4 constructors).
data SessionPersistence
  = None  -- ^ None (tag 0).
  | Cookie  -- ^ Cookie (tag 1).
  | SourceIp  -- ^ Source IP affinity (tag 2).
  | Header  -- ^ Header (tag 3).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'SessionPersistence' to its ABI tag value.
sessionPersistenceToTag :: SessionPersistence -> Word8
sessionPersistenceToTag = fromIntegral . fromEnum

-- | Decode a 'SessionPersistence' from its ABI tag value.
sessionPersistenceFromTag :: Word8 -> Maybe SessionPersistence
sessionPersistenceFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: SessionPersistence)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- LbProtocol
-- ---------------------------------------------------------------------------

-- | Load balancer protocols.
--
-- Tags 0-4 (5 constructors).
data LbProtocol
  = Http  -- ^ HTTP (tag 0).
  | Https  -- ^ HTTPS (tag 1).
  | Tcp  -- ^ TCP (tag 2).
  | Udp  -- ^ UDP (tag 3).
  | Grpc  -- ^ gRPC (tag 4).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'LbProtocol' to its ABI tag value.
lbProtocolToTag :: LbProtocol -> Word8
lbProtocolToTag = fromIntegral . fromEnum

-- | Decode a 'LbProtocol' from its ABI tag value.
lbProtocolFromTag :: Word8 -> Maybe LbProtocol
lbProtocolFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: LbProtocol)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing
