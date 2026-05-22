-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- | SDN types for the proven-servers ABI.
--
-- All tag values match the Idris2 ABI discriminants exactly.

module ProvenServers.Sdn
  (
    sdnPort
  , SdnMessageType(..)
  , sdnMessageTypeToTag
  , sdnMessageTypeFromTag
  , FlowAction(..)
  , flowActionToTag
  , flowActionFromTag
  , MatchField(..)
  , matchFieldToTag
  , matchFieldFromTag
  , PortState(..)
  , portStateToTag
  , portStateFromTag
  ) where

import Data.Word (Word16, Word8)

-- | Standard OpenFlow port.
sdnPort :: Word16
sdnPort = 6653

-- ---------------------------------------------------------------------------
-- SdnMessageType
-- ---------------------------------------------------------------------------

-- | Standard OpenFlow port.
--
-- Tags 0-11 (12 constructors).
data SdnMessageType
  = Hello  -- ^ Hello (tag 0).
  | Error  -- ^ Error (tag 1).
  | EchoRequest  -- ^ EchoRequest (tag 2).
  | EchoReply  -- ^ EchoReply (tag 3).
  | FeaturesRequest  -- ^ FeaturesRequest (tag 4).
  | FeaturesReply  -- ^ FeaturesReply (tag 5).
  | FlowMod  -- ^ FlowMod (tag 6).
  | PacketIn  -- ^ PacketIn (tag 7).
  | PacketOut  -- ^ PacketOut (tag 8).
  | PortStatus  -- ^ PortStatus (tag 9).
  | BarrierRequest  -- ^ BarrierRequest (tag 10).
  | BarrierReply  -- ^ BarrierReply (tag 11).
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

-- | OpenFlow flow actions.
--
-- Tags 0-6 (7 constructors).
data FlowAction
  = Output  -- ^ Output (tag 0).
  | SetField  -- ^ SetField (tag 1).
  | Drop  -- ^ Drop (tag 2).
  | PushVlan  -- ^ Push VLAN (tag 3).
  | PopVlan  -- ^ Pop VLAN (tag 4).
  | SetQueue  -- ^ SetQueue (tag 5).
  | Group  -- ^ Group (tag 6).
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

-- | OpenFlow match fields.
--
-- Tags 0-10 (11 constructors).
data MatchField
  = InPort  -- ^ InPort (tag 0).
  | EthDst  -- ^ EthDst (tag 1).
  | EthSrc  -- ^ EthSrc (tag 2).
  | EthType  -- ^ EthType (tag 3).
  | VlanId  -- ^ VLAN ID (tag 4).
  | IpSrc  -- ^ IP source (tag 5).
  | IpDst  -- ^ IP destination (tag 6).
  | TcpSrc  -- ^ TCP source (tag 7).
  | TcpDst  -- ^ TCP destination (tag 8).
  | UdpSrc  -- ^ UDP source (tag 9).
  | UdpDst  -- ^ UDP destination (tag 10).
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

-- | SDN port states.
--
-- Tags 0-2 (3 constructors).
data PortState
  = Up  -- ^ Up (tag 0).
  | Down  -- ^ Down (tag 1).
  | Blocked  -- ^ Blocked (tag 2).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'PortState' to its ABI tag value.
portStateToTag :: PortState -> Word8
portStateToTag = fromIntegral . fromEnum

-- | Decode a 'PortState' from its ABI tag value.
portStateFromTag :: Word8 -> Maybe PortState
portStateFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: PortState)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing
