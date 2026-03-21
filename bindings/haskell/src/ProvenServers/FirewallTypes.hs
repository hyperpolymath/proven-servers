-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- | Firewall protocol types for proven-servers.
--
-- Firewall types, mirroring the Idris2 ABI.
-- All tag values match the Idris2 ABI discriminants exactly.
--
-- This is a pure type-definition module with no FFI dependencies.

module ProvenServers.FirewallTypes
  ( -- * ADT types matching Idris2 ABI
      Action(..)
    , Protocol(..)
    , ChainType(..)
    , RuleMatchType(..)
    , ConnState(..)
    , actionToTag
    , actionFromTag
    , protocolToTag
    , protocolFromTag
    , chainTypeToTag
    , chainTypeFromTag
    , ruleMatchTypeToTag
    , ruleMatchTypeFromTag
    , connStateToTag
    , connStateFromTag
  ) where

import Data.Word (Word8)

-- ---------------------------------------------------------------------------
-- Action
-- ---------------------------------------------------------------------------

-- | Action type matching the Idris2 ABI.
--
-- Tags 0-7 (8 constructors).
data Action
  = Accept  -- ^ Tag 0.
  | Drop  -- ^ Tag 1.
  | Reject  -- ^ Tag 2.
  | Log  -- ^ Tag 3.
  | Redirect  -- ^ Tag 4.
  | Dnat  -- ^ Tag 5.
  | Snat  -- ^ Tag 6.
  | Masquerade  -- ^ Tag 7.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'Action' to its ABI tag value.
actionToTag :: Action -> Word8
actionToTag = fromIntegral . fromEnum

-- | Decode a 'Action' from its ABI tag value.
actionFromTag :: Word8 -> Maybe Action
actionFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: Action)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- Protocol
-- ---------------------------------------------------------------------------

-- | Protocol type matching the Idris2 ABI.
--
-- Tags 0-7 (8 constructors).
data Protocol
  = Tcp  -- ^ Tag 0.
  | Udp  -- ^ Tag 1.
  | Icmp  -- ^ Tag 2.
  | Icmpv6  -- ^ Tag 3.
  | Gre  -- ^ Tag 4.
  | Esp  -- ^ Tag 5.
  | Ah  -- ^ Tag 6.
  | Any  -- ^ Tag 7.
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

-- | ChainType type matching the Idris2 ABI.
--
-- Tags 0-4 (5 constructors).
data ChainType
  = Input  -- ^ Tag 0.
  | Output  -- ^ Tag 1.
  | Forward  -- ^ Tag 2.
  | PreRouting  -- ^ Tag 3.
  | PostRouting  -- ^ Tag 4.
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

-- | RuleMatchType type matching the Idris2 ABI.
--
-- Tags 0-7 (8 constructors).
data RuleMatchType
  = SourceIp  -- ^ Tag 0.
  | DestIp  -- ^ Tag 1.
  | SourcePort  -- ^ Tag 2.
  | DestPort  -- ^ Tag 3.
  | MatchProto  -- ^ Tag 4.
  | Interface  -- ^ Tag 5.
  | State  -- ^ Tag 6.
  | Mark  -- ^ Tag 7.
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

-- | ConnState type matching the Idris2 ABI.
--
-- Tags 0-3 (4 constructors).
data ConnState
  = New  -- ^ Tag 0.
  | Established  -- ^ Tag 1.
  | Related  -- ^ Tag 2.
  | Invalid  -- ^ Tag 3.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'ConnState' to its ABI tag value.
connStateToTag :: ConnState -> Word8
connStateToTag = fromIntegral . fromEnum

-- | Decode a 'ConnState' from its ABI tag value.
connStateFromTag :: Word8 -> Maybe ConnState
connStateFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: ConnState)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing
