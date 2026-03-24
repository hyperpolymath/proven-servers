-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- | DHCP protocol types for the proven-servers ABI.
--
-- All tag values match the Idris2 ABI discriminants exactly.

module ProvenServers.Dhcp
  (
    dhcpServerPort
  , dhcpClientPort
  , MessageType(..)
  , messageTypeToTag
  , messageTypeFromTag
  , isClientMessage
  , isServerMessage
  , OptionCode(..)
  , optionCodeToTag
  , optionCodeFromTag
  , HardwareType(..)
  , hardwareTypeToTag
  , hardwareTypeFromTag
  , DhcpState(..)
  , dhcpStateToTag
  , dhcpStateFromTag
  , dhcpStateCanTransitionTo
  , LeaseState(..)
  , leaseStateToTag
  , leaseStateFromTag
  , isActive
  , RelaySubOption(..)
  , relaySubOptionToTag
  , relaySubOptionFromTag
  ) where

import Data.Word (Word16, Word8)

-- | Standard DHCP server port (RFC 2131).
dhcpServerPort :: Word16
dhcpServerPort = 67

-- | Standard DHCP client port (RFC 2131).
dhcpClientPort :: Word16
dhcpClientPort = 68

-- ---------------------------------------------------------------------------
-- MessageType
-- ---------------------------------------------------------------------------

-- | Standard DHCP client port (RFC 2131).
--
-- Tags 0-7 (8 constructors).
data MessageType
  = Discover  -- ^ DHCPDISCOVER — client broadcasts to find servers (tag 0).
  | Offer  -- ^ DHCPOFFER — server response with address offer (tag 1).
  | Request  -- ^ DHCPREQUEST — client requests offered address (tag 2).
  | Ack  -- ^ DHCPACK — server confirms address assignment (tag 3).
  | Nak  -- ^ DHCPNAK — server rejects request (tag 4).
  | Release  -- ^ DHCPRELEASE — client releases address (tag 5).
  | Inform  -- ^ DHCPINFORM — client requests config without address (tag 6).
  | Decline  -- ^ DHCPDECLINE — client rejects offered address (tag 7).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'MessageType' to its ABI tag value.
messageTypeToTag :: MessageType -> Word8
messageTypeToTag = fromIntegral . fromEnum

-- | Decode a 'MessageType' from its ABI tag value.
messageTypeFromTag :: Word8 -> Maybe MessageType
messageTypeFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: MessageType)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- | Whether this message is sent by a client.
isClientMessage :: MessageType -> Bool
isClientMessage Discover = True
isClientMessage Request = True
isClientMessage Release = True
isClientMessage Inform = True
isClientMessage Decline = True
isClientMessage _ = False

-- | Whether this message is sent by a server.
isServerMessage :: MessageType -> Bool
isServerMessage Offer = True
isServerMessage Ack = True
isServerMessage Nak = True
isServerMessage _ = False

-- ---------------------------------------------------------------------------
-- OptionCode
-- ---------------------------------------------------------------------------

-- | DHCP option codes (RFC 2132).
--
-- Tags 0-7 (8 constructors).
data OptionCode
  = SubnetMask  -- ^ Subnet Mask (option 1) (tag 0).
  | Router  -- ^ Router (option 3) (tag 1).
  | Dns  -- ^ DNS Server (option 6) (tag 2).
  | DomainName  -- ^ Domain Name (option 15) (tag 3).
  | LeaseTime  -- ^ IP Address Lease Time (option 51) (tag 4).
  | ServerId  -- ^ Server Identifier (option 54) (tag 5).
  | RequestedIp  -- ^ Requested IP Address (option 50) (tag 6).
  | MsgType  -- ^ DHCP Message Type (option 53) (tag 7).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'OptionCode' to its ABI tag value.
optionCodeToTag :: OptionCode -> Word8
optionCodeToTag = fromIntegral . fromEnum

-- | Decode a 'OptionCode' from its ABI tag value.
optionCodeFromTag :: Word8 -> Maybe OptionCode
optionCodeFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: OptionCode)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- HardwareType
-- ---------------------------------------------------------------------------

-- | Hardware address types (RFC 1700).
--
-- Tags 0-3 (4 constructors).
data HardwareType
  = Ethernet  -- ^ Ethernet (10Mb) (tag 0).
  | Ieee802  -- ^ IEEE 802 Networks (tag 1).
  | Arcnet  -- ^ ARCNET (tag 2).
  | FrameRelay  -- ^ Frame Relay (tag 3).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'HardwareType' to its ABI tag value.
hardwareTypeToTag :: HardwareType -> Word8
hardwareTypeToTag = fromIntegral . fromEnum

-- | Decode a 'HardwareType' from its ABI tag value.
hardwareTypeFromTag :: Word8 -> Maybe HardwareType
hardwareTypeFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: HardwareType)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- DhcpState
-- ---------------------------------------------------------------------------

-- | DHCP server state machine.
--
-- Tags 0-5 (6 constructors).
data DhcpState
  = Idle  -- ^ Idle — awaiting DHCPDISCOVER (tag 0).
  | DiscoverReceived  -- ^ DHCPDISCOVER received (tag 1).
  | OfferSent  -- ^ DHCPOFFER sent (tag 2).
  | RequestReceived  -- ^ DHCPREQUEST received (tag 3).
  | AckSent  -- ^ DHCPACK sent (tag 4).
  | NakSent  -- ^ DHCPNAK sent (tag 5).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'DhcpState' to its ABI tag value.
dhcpStateToTag :: DhcpState -> Word8
dhcpStateToTag = fromIntegral . fromEnum

-- | Decode a 'DhcpState' from its ABI tag value.
dhcpStateFromTag :: Word8 -> Maybe DhcpState
dhcpStateFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: DhcpState)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- | Validate whether a state transition is allowed.
dhcpStateCanTransitionTo :: DhcpState -> DhcpState -> Bool
dhcpStateCanTransitionTo Idle DiscoverReceived = True
dhcpStateCanTransitionTo DiscoverReceived OfferSent = True
dhcpStateCanTransitionTo OfferSent RequestReceived = True
dhcpStateCanTransitionTo RequestReceived AckSent = True
dhcpStateCanTransitionTo RequestReceived NakSent = True
dhcpStateCanTransitionTo AckSent Idle = True
dhcpStateCanTransitionTo NakSent Idle = True
dhcpStateCanTransitionTo _ _ = False

-- ---------------------------------------------------------------------------
-- LeaseState
-- ---------------------------------------------------------------------------

-- | DHCP lease lifecycle states.
--
-- Tags 0-5 (6 constructors).
data LeaseState
  = Available  -- ^ Available in pool (tag 0).
  | Offered  -- ^ Offered to a client (tag 1).
  | Bound  -- ^ Bound — client actively using (tag 2).
  | Renewing  -- ^ Renewing — client requesting lease extension (tag 3).
  | Rebinding  -- ^ Rebinding — broadcast renewal attempt (tag 4).
  | Expired  -- ^ Expired — lease no longer valid (tag 5).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'LeaseState' to its ABI tag value.
leaseStateToTag :: LeaseState -> Word8
leaseStateToTag = fromIntegral . fromEnum

-- | Decode a 'LeaseState' from its ABI tag value.
leaseStateFromTag :: Word8 -> Maybe LeaseState
leaseStateFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: LeaseState)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- | Whether this state means the address is in use.
isActive :: LeaseState -> Bool
isActive Bound = True
isActive Renewing = True
isActive Rebinding = True
isActive _ = False

-- ---------------------------------------------------------------------------
-- RelaySubOption
-- ---------------------------------------------------------------------------

-- | DHCP relay agent sub-options (RFC 3046).
--
-- Tags 0-1 (2 constructors).
data RelaySubOption
  = CircuitId  -- ^ Circuit ID — identifies the relay agent port (tag 0).
  | RemoteId  -- ^ Remote ID — identifies the remote host (tag 1).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'RelaySubOption' to its ABI tag value.
relaySubOptionToTag :: RelaySubOption -> Word8
relaySubOptionToTag = fromIntegral . fromEnum

-- | Decode a 'RelaySubOption' from its ABI tag value.
relaySubOptionFromTag :: Word8 -> Maybe RelaySubOption
relaySubOptionFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: RelaySubOption)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing
