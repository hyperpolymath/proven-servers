-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- | OSPF protocol types for proven-servers.
--
-- OSPF (Open Shortest Path First) types, mirroring the Idris2 ABI.
-- All tag values match the Idris2 ABI discriminants exactly.
--
-- This is a pure type-definition module with no FFI dependencies.

module ProvenServers.Ospf
  ( -- * ADT types matching Idris2 ABI
      PacketType(..)
    , NeighborState(..)
    , LsaType(..)
    , AreaType(..)
    , OspfError(..)
    , packetTypeToTag
    , packetTypeFromTag
    , neighborStateToTag
    , neighborStateFromTag
    , lsaTypeToTag
    , lsaTypeFromTag
    , areaTypeToTag
    , areaTypeFromTag
    , ospfErrorToTag
    , ospfErrorFromTag
  ) where

import Data.Word (Word8)

-- ---------------------------------------------------------------------------
-- PacketType
-- ---------------------------------------------------------------------------

-- | PacketType type matching the Idris2 ABI.
--
-- Tags 0-4 (5 constructors).
data PacketType
  = Hello  -- ^ Tag 0.
  | DatabaseDescription  -- ^ Tag 1.
  | LinkStateRequest  -- ^ Tag 2.
  | LinkStateUpdate  -- ^ Tag 3.
  | LinkStateAck  -- ^ Tag 4.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'PacketType' to its ABI tag value.
packetTypeToTag :: PacketType -> Word8
packetTypeToTag = fromIntegral . fromEnum

-- | Decode a 'PacketType' from its ABI tag value.
packetTypeFromTag :: Word8 -> Maybe PacketType
packetTypeFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: PacketType)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- NeighborState
-- ---------------------------------------------------------------------------

-- | NeighborState type matching the Idris2 ABI.
--
-- Tags 0-7 (8 constructors).
data NeighborState
  = Down  -- ^ Tag 0.
  | Attempt  -- ^ Tag 1.
  | Init  -- ^ Tag 2.
  | TwoWay  -- ^ Tag 3.
  | ExStart  -- ^ Tag 4.
  | Exchange  -- ^ Tag 5.
  | Loading  -- ^ Tag 6.
  | Full  -- ^ Tag 7.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'NeighborState' to its ABI tag value.
neighborStateToTag :: NeighborState -> Word8
neighborStateToTag = fromIntegral . fromEnum

-- | Decode a 'NeighborState' from its ABI tag value.
neighborStateFromTag :: Word8 -> Maybe NeighborState
neighborStateFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: NeighborState)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- LsaType
-- ---------------------------------------------------------------------------

-- | LsaType type matching the Idris2 ABI.
--
-- Tags 0-4 (5 constructors).
data LsaType
  = RouterLsa  -- ^ Tag 0.
  | NetworkLsa  -- ^ Tag 1.
  | SummaryLsa  -- ^ Tag 2.
  | AsbrSummaryLsa  -- ^ Tag 3.
  | AsExternalLsa  -- ^ Tag 4.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'LsaType' to its ABI tag value.
lsaTypeToTag :: LsaType -> Word8
lsaTypeToTag = fromIntegral . fromEnum

-- | Decode a 'LsaType' from its ABI tag value.
lsaTypeFromTag :: Word8 -> Maybe LsaType
lsaTypeFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: LsaType)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- AreaType
-- ---------------------------------------------------------------------------

-- | AreaType type matching the Idris2 ABI.
--
-- Tags 0-3 (4 constructors).
data AreaType
  = Normal  -- ^ Tag 0.
  | Stub  -- ^ Tag 1.
  | TotallyStub  -- ^ Tag 2.
  | Nssa  -- ^ Tag 3.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'AreaType' to its ABI tag value.
areaTypeToTag :: AreaType -> Word8
areaTypeToTag = fromIntegral . fromEnum

-- | Decode a 'AreaType' from its ABI tag value.
areaTypeFromTag :: Word8 -> Maybe AreaType
areaTypeFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: AreaType)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- OspfError
-- ---------------------------------------------------------------------------

-- | OspfError type matching the Idris2 ABI.
--
-- Tags 0-6 (7 constructors).
data OspfError
  = Ok  -- ^ Tag 0.
  | InvalidSlot  -- ^ Tag 1.
  | NotActive  -- ^ Tag 2.
  | InvalidTransition  -- ^ Tag 3.
  | InvalidPacket  -- ^ Tag 4.
  | AreaError  -- ^ Tag 5.
  | FloodLimit  -- ^ Tag 6.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'OspfError' to its ABI tag value.
ospfErrorToTag :: OspfError -> Word8
ospfErrorToTag = fromIntegral . fromEnum

-- | Decode a 'OspfError' from its ABI tag value.
ospfErrorFromTag :: Word8 -> Maybe OspfError
ospfErrorFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: OspfError)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing
