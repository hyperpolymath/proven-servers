-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- | mDNS types for the proven-servers ABI.
--
-- All tag values match the Idris2 ABI discriminants exactly.

module ProvenServers.Mdns
  (
    mdnsPort
  , MdnsRecordType(..)
  , mdnsRecordTypeToTag
  , mdnsRecordTypeFromTag
  , QueryType(..)
  , queryTypeToTag
  , queryTypeFromTag
  , ConflictAction(..)
  , conflictActionToTag
  , conflictActionFromTag
  , ServiceFlag(..)
  , serviceFlagToTag
  , serviceFlagFromTag
  , ResponderState(..)
  , responderStateToTag
  , responderStateFromTag
  ) where

import Data.Word (Word16, Word8)

-- | Standard mDNS port.
mdnsPort :: Word16
mdnsPort = 5353

-- ---------------------------------------------------------------------------
-- MdnsRecordType
-- ---------------------------------------------------------------------------

-- | Standard mDNS port.
--
-- Tags 0-4 (5 constructors).
data MdnsRecordType
  = A  -- ^ IPv4 address (tag 0).
  | Aaaa  -- ^ IPv6 address (tag 1).
  | Ptr  -- ^ Pointer (tag 2).
  | Srv  -- ^ Service (tag 3).
  | Txt  -- ^ Text (tag 4).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'MdnsRecordType' to its ABI tag value.
mdnsRecordTypeToTag :: MdnsRecordType -> Word8
mdnsRecordTypeToTag = fromIntegral . fromEnum

-- | Decode a 'MdnsRecordType' from its ABI tag value.
mdnsRecordTypeFromTag :: Word8 -> Maybe MdnsRecordType
mdnsRecordTypeFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: MdnsRecordType)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- QueryType
-- ---------------------------------------------------------------------------

-- | mDNS query types.
--
-- Tags 0-2 (3 constructors).
data QueryType
  = Standard  -- ^ Standard (tag 0).
  | OneShot  -- ^ OneShot (tag 1).
  | Continuous  -- ^ Continuous (tag 2).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'QueryType' to its ABI tag value.
queryTypeToTag :: QueryType -> Word8
queryTypeToTag = fromIntegral . fromEnum

-- | Decode a 'QueryType' from its ABI tag value.
queryTypeFromTag :: Word8 -> Maybe QueryType
queryTypeFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: QueryType)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- ConflictAction
-- ---------------------------------------------------------------------------

-- | mDNS conflict resolution actions.
--
-- Tags 0-2 (3 constructors).
data ConflictAction
  = Probe  -- ^ Probe (tag 0).
  | Defend  -- ^ Defend (tag 1).
  | Withdraw  -- ^ Withdraw (tag 2).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'ConflictAction' to its ABI tag value.
conflictActionToTag :: ConflictAction -> Word8
conflictActionToTag = fromIntegral . fromEnum

-- | Decode a 'ConflictAction' from its ABI tag value.
conflictActionFromTag :: Word8 -> Maybe ConflictAction
conflictActionFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: ConflictAction)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- ServiceFlag
-- ---------------------------------------------------------------------------

-- | mDNS service flags.
--
-- Tags 0-1 (2 constructors).
data ServiceFlag
  = Unique  -- ^ Unique (tag 0).
  | Shared  -- ^ Shared (tag 1).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'ServiceFlag' to its ABI tag value.
serviceFlagToTag :: ServiceFlag -> Word8
serviceFlagToTag = fromIntegral . fromEnum

-- | Decode a 'ServiceFlag' from its ABI tag value.
serviceFlagFromTag :: Word8 -> Maybe ServiceFlag
serviceFlagFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: ServiceFlag)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- ResponderState
-- ---------------------------------------------------------------------------

-- | mDNS responder states.
--
-- Tags 0-4 (5 constructors).
data ResponderState
  = Idle  -- ^ Idle (tag 0).
  | Probing  -- ^ Probing (tag 1).
  | Announcing  -- ^ Announcing (tag 2).
  | Running  -- ^ Running (tag 3).
  | ShuttingDown  -- ^ ShuttingDown (tag 4).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'ResponderState' to its ABI tag value.
responderStateToTag :: ResponderState -> Word8
responderStateToTag = fromIntegral . fromEnum

-- | Decode a 'ResponderState' from its ABI tag value.
responderStateFromTag :: Word8 -> Maybe ResponderState
responderStateFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: ResponderState)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing
