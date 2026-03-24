-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- | Firewall types for the proven-servers ABI.
--
-- All tag values match the Idris2 ABI discriminants exactly.

module ProvenServers.Firewall
  (
    Action(..)
  , actionToTag
  , actionFromTag
  , isPermissive
  , Protocol(..)
  , protocolToTag
  , protocolFromTag
  , ChainType(..)
  , chainTypeToTag
  , chainTypeFromTag
  , RuleMatchType(..)
  , ruleMatchTypeToTag
  , ruleMatchTypeFromTag
  , ConnState(..)
  , connStateToTag
  , connStateFromTag
  ) where

import Data.Word (Word8)

-- ---------------------------------------------------------------------------
-- Action
-- ---------------------------------------------------------------------------

-- | Firewall rule actions.
--
-- Tags 0-7 (8 constructors).
data Action
  = Accept  -- ^ Accept (tag 0).
  | Drop  -- ^ Drop (tag 1).
  | Reject  -- ^ Reject (tag 2).
  | Log  -- ^ Log (tag 3).
  | Redirect  -- ^ Redirect (tag 4).
  | Dnat  -- ^ DNAT (tag 5).
  | Snat  -- ^ SNAT (tag 6).
  | Masquerade  -- ^ Masquerade (tag 7).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'Action' to its ABI tag value.
actionToTag :: Action -> Word8
actionToTag = fromIntegral . fromEnum

-- | Decode a 'Action' from its ABI tag value.
actionFromTag :: Word8 -> Maybe Action
actionFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: Action)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- | Whether this action allows traffic.
isPermissive :: Action -> Bool
isPermissive Accept = True
isPermissive Redirect = True
isPermissive Dnat = True
isPermissive Snat = True
isPermissive Masquerade = True
isPermissive _ = False

-- ---------------------------------------------------------------------------
-- Protocol
-- ---------------------------------------------------------------------------

-- | Network protocols.
--
-- Tags 0-7 (8 constructors).
data Protocol
  = Tcp  -- ^ TCP (tag 0).
  | Udp  -- ^ UDP (tag 1).
  | Icmp  -- ^ ICMP (tag 2).
  | Icmpv6  -- ^ ICMPv6 (tag 3).
  | Gre  -- ^ GRE (tag 4).
  | Esp  -- ^ ESP (tag 5).
  | Ah  -- ^ AH (tag 6).
  | Any  -- ^ Any (tag 7).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'Protocol' to its ABI tag value.
protocolToTag :: Protocol -> Word8
protocolToTag = fromIntegral . fromEnum

-- | Decode a 'Protocol' from its ABI tag value.
protocolFromTag :: Word8 -> Maybe Protocol
protocolFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: Protocol)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- ChainType
-- ---------------------------------------------------------------------------

-- | Firewall chain types (netfilter).
--
-- Tags 0-4 (5 constructors).
data ChainType
  = Input  -- ^ Input (tag 0).
  | Output  -- ^ Output (tag 1).
  | Forward  -- ^ Forward (tag 2).
  | PreRouting  -- ^ PreRouting (tag 3).
  | PostRouting  -- ^ PostRouting (tag 4).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'ChainType' to its ABI tag value.
chainTypeToTag :: ChainType -> Word8
chainTypeToTag = fromIntegral . fromEnum

-- | Decode a 'ChainType' from its ABI tag value.
chainTypeFromTag :: Word8 -> Maybe ChainType
chainTypeFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: ChainType)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- RuleMatchType
-- ---------------------------------------------------------------------------

-- | Firewall rule match criteria.
--
-- Tags 0-7 (8 constructors).
data RuleMatchType
  = SourceIp  -- ^ SourceIp (tag 0).
  | DestIp  -- ^ DestIp (tag 1).
  | SourcePort  -- ^ SourcePort (tag 2).
  | DestPort  -- ^ DestPort (tag 3).
  | MatchProto  -- ^ Protocol match (tag 4).
  | Interface  -- ^ Interface (tag 5).
  | State  -- ^ State (tag 6).
  | Mark  -- ^ Mark (tag 7).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'RuleMatchType' to its ABI tag value.
ruleMatchTypeToTag :: RuleMatchType -> Word8
ruleMatchTypeToTag = fromIntegral . fromEnum

-- | Decode a 'RuleMatchType' from its ABI tag value.
ruleMatchTypeFromTag :: Word8 -> Maybe RuleMatchType
ruleMatchTypeFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: RuleMatchType)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- ConnState
-- ---------------------------------------------------------------------------

-- | Connection tracking states.
--
-- Tags 0-3 (4 constructors).
data ConnState
  = New  -- ^ New (tag 0).
  | Established  -- ^ Established (tag 1).
  | Related  -- ^ Related (tag 2).
  | Invalid  -- ^ Invalid (tag 3).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'ConnState' to its ABI tag value.
connStateToTag :: ConnState -> Word8
connStateToTag = fromIntegral . fromEnum

-- | Decode a 'ConnState' from its ABI tag value.
connStateFromTag :: Word8 -> Maybe ConnState
connStateFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: ConnState)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing
