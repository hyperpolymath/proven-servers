-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- | DHCP protocol types for proven-servers.
--
-- DHCP (Dynamic Host Configuration Protocol) types, mirroring the Idris2 ABI.
-- All tag values match the Idris2 ABI discriminants exactly.
--
-- This is a pure type-definition module with no FFI dependencies.

module ProvenServers.Dhcp
  ( -- * ADT types matching Idris2 ABI
      MessageType(..)
    , OptionCode(..)
    , HardwareType(..)
    , DhcpState(..)
    , LeaseState(..)
    , RelaySubOption(..)
    , messageTypeToTag
    , messageTypeFromTag
    , optionCodeToTag
    , optionCodeFromTag
    , hardwareTypeToTag
    , hardwareTypeFromTag
    , dhcpStateToTag
    , dhcpStateFromTag
    , leaseStateToTag
    , leaseStateFromTag
    , relaySubOptionToTag
    , relaySubOptionFromTag
  ) where

import Data.Word (Word8)

-- ---------------------------------------------------------------------------
-- MessageType
-- ---------------------------------------------------------------------------

-- | MessageType type matching the Idris2 ABI.
--
-- Tags 0-7 (8 constructors).
data MessageType
  = Discover  -- ^ Tag 0.
  | Offer  -- ^ Tag 1.
  | Request  -- ^ Tag 2.
  | Ack  -- ^ Tag 3.
  | Nak  -- ^ Tag 4.
  | Release  -- ^ Tag 5.
  | Inform  -- ^ Tag 6.
  | Decline  -- ^ Tag 7.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'MessageType' to its ABI tag value.
messageTypeToTag :: MessageType -> Word8
messageTypeToTag = fromIntegral . fromEnum

-- | Decode a 'MessageType' from its ABI tag value.
messageTypeFromTag :: Word8 -> Maybe MessageType
messageTypeFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: MessageType)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- OptionCode
-- ---------------------------------------------------------------------------

-- | OptionCode type matching the Idris2 ABI.
--
-- Tags 0-7 (8 constructors).
data OptionCode
  = SubnetMask  -- ^ Tag 0.
  | Router  -- ^ Tag 1.
  | Dns  -- ^ Tag 2.
  | DomainName  -- ^ Tag 3.
  | LeaseTime  -- ^ Tag 4.
  | ServerId  -- ^ Tag 5.
  | RequestedIp  -- ^ Tag 6.
  | MsgType  -- ^ Tag 7.
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

-- | HardwareType type matching the Idris2 ABI.
--
-- Tags 0-3 (4 constructors).
data HardwareType
  = Ethernet  -- ^ Tag 0.
  | Ieee802  -- ^ Tag 1.
  | Arcnet  -- ^ Tag 2.
  | FrameRelay  -- ^ Tag 3.
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

-- | DhcpState type matching the Idris2 ABI.
--
-- Tags 0-5 (6 constructors).
data DhcpState
  = Idle  -- ^ Tag 0.
  | DiscoverReceived  -- ^ Tag 1.
  | OfferSent  -- ^ Tag 2.
  | RequestReceived  -- ^ Tag 3.
  | AckSent  -- ^ Tag 4.
  | NakSent  -- ^ Tag 5.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'DhcpState' to its ABI tag value.
dhcpStateToTag :: DhcpState -> Word8
dhcpStateToTag = fromIntegral . fromEnum

-- | Decode a 'DhcpState' from its ABI tag value.
dhcpStateFromTag :: Word8 -> Maybe DhcpState
dhcpStateFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: DhcpState)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- LeaseState
-- ---------------------------------------------------------------------------

-- | LeaseState type matching the Idris2 ABI.
--
-- Tags 0-5 (6 constructors).
data LeaseState
  = Available  -- ^ Tag 0.
  | Offered  -- ^ Tag 1.
  | Bound  -- ^ Tag 2.
  | Renewing  -- ^ Tag 3.
  | Rebinding  -- ^ Tag 4.
  | Expired  -- ^ Tag 5.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'LeaseState' to its ABI tag value.
leaseStateToTag :: LeaseState -> Word8
leaseStateToTag = fromIntegral . fromEnum

-- | Decode a 'LeaseState' from its ABI tag value.
leaseStateFromTag :: Word8 -> Maybe LeaseState
leaseStateFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: LeaseState)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- RelaySubOption
-- ---------------------------------------------------------------------------

-- | RelaySubOption type matching the Idris2 ABI.
--
-- Tags 0-1 (2 constructors).
data RelaySubOption
  = CircuitId  -- ^ Tag 0.
  | RemoteId  -- ^ Tag 1.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'RelaySubOption' to its ABI tag value.
relaySubOptionToTag :: RelaySubOption -> Word8
relaySubOptionToTag = fromIntegral . fromEnum

-- | Decode a 'RelaySubOption' from its ABI tag value.
relaySubOptionFromTag :: Word8 -> Maybe RelaySubOption
relaySubOptionFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: RelaySubOption)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing
