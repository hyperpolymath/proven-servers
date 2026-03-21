-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- | SDN protocol types for proven-servers.
--
-- SDN (Software-Defined Networking) types, mirroring the Idris2 ABI.
-- All tag values match the Idris2 ABI discriminants exactly.
--
-- This is a pure type-definition module with no FFI dependencies.

module ProvenServers.Sdn
  ( -- * ADT types matching Idris2 ABI
      SdnMessageType(..)
    , FlowAction(..)
    , MatchField(..)
    , PortState(..)
    , sdnMessageTypeToTag
    , sdnMessageTypeFromTag
    , flowActionToTag
    , flowActionFromTag
    , matchFieldToTag
    , matchFieldFromTag
    , portStateToTag
    , portStateFromTag
  ) where

import Data.Word (Word8)

-- ---------------------------------------------------------------------------
-- SdnMessageType
-- ---------------------------------------------------------------------------

-- | SdnMessageType type matching the Idris2 ABI.
--
-- Tags 0-11 (12 constructors).
data SdnMessageType
  = Hello  -- ^ Tag 0.
  | Error  -- ^ Tag 1.
  | EchoRequest  -- ^ Tag 2.
  | EchoReply  -- ^ Tag 3.
  | FeaturesRequest  -- ^ Tag 4.
  | FeaturesReply  -- ^ Tag 5.
  | FlowMod  -- ^ Tag 6.
  | PacketIn  -- ^ Tag 7.
  | PacketOut  -- ^ Tag 8.
  | PortStatus  -- ^ Tag 9.
  | BarrierRequest  -- ^ Tag 10.
  | BarrierReply  -- ^ Tag 11.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'SdnMessageType' to its ABI tag value.
sdnMessageTypeToTag :: SdnMessageType -> Word8
sdnMessageTypeToTag = fromIntegral . fromEnum

-- | Decode a 'SdnMessageType' from its ABI tag value.
sdnMessageTypeFromTag :: Word8 -> Maybe SdnMessageType
sdnMessageTypeFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: SdnMessageType)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- FlowAction
-- ---------------------------------------------------------------------------

-- | FlowAction type matching the Idris2 ABI.
--
-- Tags 0-6 (7 constructors).
data FlowAction
  = Output  -- ^ Tag 0.
  | SetField  -- ^ Tag 1.
  | Drop  -- ^ Tag 2.
  | PushVlan  -- ^ Tag 3.
  | PopVlan  -- ^ Tag 4.
  | SetQueue  -- ^ Tag 5.
  | Group  -- ^ Tag 6.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'FlowAction' to its ABI tag value.
flowActionToTag :: FlowAction -> Word8
flowActionToTag = fromIntegral . fromEnum

-- | Decode a 'FlowAction' from its ABI tag value.
flowActionFromTag :: Word8 -> Maybe FlowAction
flowActionFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: FlowAction)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- MatchField
-- ---------------------------------------------------------------------------

-- | MatchField type matching the Idris2 ABI.
--
-- Tags 0-10 (11 constructors).
data MatchField
  = InPort  -- ^ Tag 0.
  | EthDst  -- ^ Tag 1.
  | EthSrc  -- ^ Tag 2.
  | EthType  -- ^ Tag 3.
  | VlanId  -- ^ Tag 4.
  | IpSrc  -- ^ Tag 5.
  | IpDst  -- ^ Tag 6.
  | TcpSrc  -- ^ Tag 7.
  | TcpDst  -- ^ Tag 8.
  | UdpSrc  -- ^ Tag 9.
  | UdpDst  -- ^ Tag 10.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'MatchField' to its ABI tag value.
matchFieldToTag :: MatchField -> Word8
matchFieldToTag = fromIntegral . fromEnum

-- | Decode a 'MatchField' from its ABI tag value.
matchFieldFromTag :: Word8 -> Maybe MatchField
matchFieldFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: MatchField)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- PortState
-- ---------------------------------------------------------------------------

-- | PortState type matching the Idris2 ABI.
--
-- Tags 0-2 (3 constructors).
data PortState
  = Up  -- ^ Tag 0.
  | Down  -- ^ Tag 1.
  | Blocked  -- ^ Tag 2.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'PortState' to its ABI tag value.
portStateToTag :: PortState -> Word8
portStateToTag = fromIntegral . fromEnum

-- | Decode a 'PortState' from its ABI tag value.
portStateFromTag :: Word8 -> Maybe PortState
portStateFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: PortState)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing
