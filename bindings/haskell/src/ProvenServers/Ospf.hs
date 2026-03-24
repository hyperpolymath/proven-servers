-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- | OSPF protocol types for the proven-servers ABI.
--
-- All tag values match the Idris2 ABI discriminants exactly.

module ProvenServers.Ospf
  (
    ospfProtocol
  , PacketType(..)
  , packetTypeToTag
  , packetTypeFromTag
  , isDbSync
  , NeighborState(..)
  , neighborStateToTag
  , neighborStateFromTag
  , isAdjacent
  , isSyncing
  , isBidirectional
  , LsaType(..)
  , lsaTypeToTag
  , lsaTypeFromTag
  , isAreaScope
  , isAsScope
  , AreaType(..)
  , areaTypeToTag
  , areaTypeFromTag
  , blocksExternal
  , OspfError(..)
  , ospfErrorToTag
  , ospfErrorFromTag
  , isSuccess
  ) where

import Data.Word (Word8)

-- | OSPF protocol number (IP protocol 89).
ospfProtocol :: Word8
ospfProtocol = 89

-- ---------------------------------------------------------------------------
-- PacketType
-- ---------------------------------------------------------------------------

-- | OSPF AllDRouters multicast address.
--
-- Tags 0-4 (5 constructors).
data PacketType
  = Hello  -- ^ Hello — discover and maintain neighbors (tag 0).
  | DatabaseDescription  -- ^ Database Description — summarize LSDB contents (tag 1).
  | LinkStateRequest  -- ^ Link State Request — request specific LSAs (tag 2).
  | LinkStateUpdate  -- ^ Link State Update — flood LSAs (tag 3).
  | LinkStateAck  -- ^ Link State Acknowledgment — confirm LSA receipt (tag 4).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'PacketType' to its ABI tag value.
packetTypeToTag :: PacketType -> Word8
packetTypeToTag = fromIntegral . fromEnum

-- | Decode a 'PacketType' from its ABI tag value.
packetTypeFromTag :: Word8 -> Maybe PacketType
packetTypeFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: PacketType)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- | Whether this packet is part of database synchronization.
isDbSync :: PacketType -> Bool
isDbSync DatabaseDescription = True
isDbSync LinkStateRequest = True
isDbSync LinkStateUpdate = True
isDbSync LinkStateAck = True
isDbSync _ = False

-- ---------------------------------------------------------------------------
-- NeighborState
-- ---------------------------------------------------------------------------

-- | OSPF neighbor state machine (RFC 2328 Section 10.1).
--
-- Tags 0-7 (8 constructors).
data NeighborState
  = Down  -- ^ Down — no recent Hello received (tag 0).
  | Attempt  -- ^ Attempt — NBMA networks, Hello sent (tag 1).
  | Init  -- ^ Init — Hello received, no bidirectional (tag 2).
  | TwoWay  -- ^ 2-Way — bidirectional communication established (tag 3).
  | ExStart  -- ^ ExStart — master/slave negotiation (tag 4).
  | Exchange  -- ^ Exchange — DD packets being exchanged (tag 5).
  | Loading  -- ^ Loading — LSAs being requested (tag 6).
  | Full  -- ^ Full — fully adjacent (tag 7).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'NeighborState' to its ABI tag value.
neighborStateToTag :: NeighborState -> Word8
neighborStateToTag = fromIntegral . fromEnum

-- | Decode a 'NeighborState' from its ABI tag value.
neighborStateFromTag :: Word8 -> Maybe NeighborState
neighborStateFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: NeighborState)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- | Whether the neighbor has achieved full adjacency.
isAdjacent :: NeighborState -> Bool
isAdjacent Full = True
isAdjacent _ = False

-- | Whether database synchronization is in progress.
isSyncing :: NeighborState -> Bool
isSyncing ExStart = True
isSyncing Exchange = True
isSyncing Loading = True
isSyncing _ = False

-- | Whether bidirectional communication exists.
isBidirectional :: NeighborState -> Bool
isBidirectional TwoWay = True
isBidirectional ExStart = True
isBidirectional Exchange = True
isBidirectional Loading = True
isBidirectional Full = True
isBidirectional _ = False

-- ---------------------------------------------------------------------------
-- LsaType
-- ---------------------------------------------------------------------------

-- | OSPF LSA types (RFC 2328 Section A.4).
--
-- Tags 0-4 (5 constructors).
data LsaType
  = RouterLsa  -- ^ Router LSA — describes router's links (tag 0).
  | NetworkLsa  -- ^ Network LSA — describes multi-access network (tag 1).
  | SummaryLsa  -- ^ Summary LSA — inter-area routes (tag 2).
  | AsbrSummaryLsa  -- ^ ASBR Summary LSA — routes to ASBRs (tag 3).
  | AsExternalLsa  -- ^ AS External LSA — external routes (tag 4).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'LsaType' to its ABI tag value.
lsaTypeToTag :: LsaType -> Word8
lsaTypeToTag = fromIntegral . fromEnum

-- | Decode a 'LsaType' from its ABI tag value.
lsaTypeFromTag :: Word8 -> Maybe LsaType
lsaTypeFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: LsaType)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- | Whether this LSA has area-wide scope.
isAreaScope :: LsaType -> Bool
isAreaScope RouterLsa = True
isAreaScope NetworkLsa = True
isAreaScope SummaryLsa = True
isAreaScope AsbrSummaryLsa = True
isAreaScope _ = False

-- | Whether this LSA has AS-wide scope.
isAsScope :: LsaType -> Bool
isAsScope AsExternalLsa = True
isAsScope _ = False

-- ---------------------------------------------------------------------------
-- AreaType
-- ---------------------------------------------------------------------------

-- | OSPF area types (RFC 2328, RFC 3101).
--
-- Tags 0-3 (4 constructors).
data AreaType
  = Normal  -- ^ Normal area (tag 0).
  | Stub  -- ^ Stub area — no external LSAs (tag 1).
  | TotallyStub  -- ^ Totally stubby area — no external or inter-area LSAs (tag 2).
  | Nssa  -- ^ Not-So-Stubby Area — limited external routes (tag 3).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'AreaType' to its ABI tag value.
areaTypeToTag :: AreaType -> Word8
areaTypeToTag = fromIntegral . fromEnum

-- | Decode a 'AreaType' from its ABI tag value.
areaTypeFromTag :: Word8 -> Maybe AreaType
areaTypeFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: AreaType)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- | Whether this area type blocks external LSAs.
blocksExternal :: AreaType -> Bool
blocksExternal Stub = True
blocksExternal TotallyStub = True
blocksExternal _ = False

-- ---------------------------------------------------------------------------
-- OspfError
-- ---------------------------------------------------------------------------

-- | OSPF FFI error codes.
--
-- Tags 0-6 (7 constructors).
data OspfError
  = Ok  -- ^ No error (tag 0).
  | InvalidSlot  -- ^ Invalid slot index (tag 1).
  | NotActive  -- ^ Neighbor not active (tag 2).
  | InvalidTransition  -- ^ Invalid state transition (tag 3).
  | InvalidPacket  -- ^ Invalid packet type for current state (tag 4).
  | AreaError  -- ^ Area configuration error (tag 5).
  | FloodLimit  -- ^ LSA flooding limit exceeded (tag 6).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'OspfError' to its ABI tag value.
ospfErrorToTag :: OspfError -> Word8
ospfErrorToTag = fromIntegral . fromEnum

-- | Decode a 'OspfError' from its ABI tag value.
ospfErrorFromTag :: Word8 -> Maybe OspfError
ospfErrorFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: OspfError)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- | Whether this error code indicates success.
isSuccess :: OspfError -> Bool
isSuccess Ok = True
isSuccess _ = False
