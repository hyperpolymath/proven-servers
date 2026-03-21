-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- | Load Balancer protocol types for proven-servers.
--
-- Load balancer types, mirroring the Idris2 ABI.
-- All tag values match the Idris2 ABI discriminants exactly.
--
-- This is a pure type-definition module with no FFI dependencies.

module ProvenServers.Loadbalancer
  ( -- * ADT types matching Idris2 ABI
      Algorithm(..)
    , HealthCheckType(..)
    , BackendState(..)
    , SessionPersistence(..)
    , LbProtocol(..)
    , algorithmToTag
    , algorithmFromTag
    , healthCheckTypeToTag
    , healthCheckTypeFromTag
    , backendStateToTag
    , backendStateFromTag
    , sessionPersistenceToTag
    , sessionPersistenceFromTag
    , lbProtocolToTag
    , lbProtocolFromTag
  ) where

import Data.Word (Word8)

-- ---------------------------------------------------------------------------
-- Algorithm
-- ---------------------------------------------------------------------------

-- | Algorithm type matching the Idris2 ABI.
--
-- Tags 0-5 (6 constructors).
data Algorithm
  = RoundRobin  -- ^ Tag 0.
  | LeastConnections  -- ^ Tag 1.
  | IpHash  -- ^ Tag 2.
  | Random  -- ^ Tag 3.
  | WeightedRoundRobin  -- ^ Tag 4.
  | LeastResponseTime  -- ^ Tag 5.
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

-- | HealthCheckType type matching the Idris2 ABI.
--
-- Tags 0-3 (4 constructors).
data HealthCheckType
  = HealthCheckType_Http  -- ^ Tag 0.
  | HealthCheckType_Tcp  -- ^ Tag 1.
  | HealthCheckType_Grpc  -- ^ Tag 2.
  | Script  -- ^ Tag 3.
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

-- | BackendState type matching the Idris2 ABI.
--
-- Tags 0-3 (4 constructors).
data BackendState
  = Healthy  -- ^ Tag 0.
  | Unhealthy  -- ^ Tag 1.
  | Draining  -- ^ Tag 2.
  | Disabled  -- ^ Tag 3.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'BackendState' to its ABI tag value.
backendStateToTag :: BackendState -> Word8
backendStateToTag = fromIntegral . fromEnum

-- | Decode a 'BackendState' from its ABI tag value.
backendStateFromTag :: Word8 -> Maybe BackendState
backendStateFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: BackendState)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- SessionPersistence
-- ---------------------------------------------------------------------------

-- | SessionPersistence type matching the Idris2 ABI.
--
-- Tags 0-3 (4 constructors).
data SessionPersistence
  = None  -- ^ Tag 0.
  | Cookie  -- ^ Tag 1.
  | SourceIp  -- ^ Tag 2.
  | Header  -- ^ Tag 3.
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

-- | LbProtocol type matching the Idris2 ABI.
--
-- Tags 0-4 (5 constructors).
data LbProtocol
  = LbProtocol_Http  -- ^ Tag 0.
  | Https  -- ^ Tag 1.
  | LbProtocol_Tcp  -- ^ Tag 2.
  | Udp  -- ^ Tag 3.
  | LbProtocol_Grpc  -- ^ Tag 4.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'LbProtocol' to its ABI tag value.
lbProtocolToTag :: LbProtocol -> Word8
lbProtocolToTag = fromIntegral . fromEnum

-- | Decode a 'LbProtocol' from its ABI tag value.
lbProtocolFromTag :: Word8 -> Maybe LbProtocol
lbProtocolFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: LbProtocol)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing
