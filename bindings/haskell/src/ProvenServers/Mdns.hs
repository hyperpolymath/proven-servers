-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- | mDNS protocol types for proven-servers.
--
-- mDNS (multicast DNS, RFC 6762) types, mirroring the Idris2 ABI.
-- All tag values match the Idris2 ABI discriminants exactly.
--
-- This is a pure type-definition module with no FFI dependencies.

module ProvenServers.Mdns
  ( -- * ADT types matching Idris2 ABI
      MdnsRecordType(..)
    , QueryType(..)
    , ConflictAction(..)
    , ServiceFlag(..)
    , ResponderState(..)
    , mdnsRecordTypeToTag
    , mdnsRecordTypeFromTag
    , queryTypeToTag
    , queryTypeFromTag
    , conflictActionToTag
    , conflictActionFromTag
    , serviceFlagToTag
    , serviceFlagFromTag
    , responderStateToTag
    , responderStateFromTag
  ) where

import Data.Word (Word8)

-- ---------------------------------------------------------------------------
-- MdnsRecordType
-- ---------------------------------------------------------------------------

-- | MdnsRecordType type matching the Idris2 ABI.
--
-- Tags 0-4 (5 constructors).
data MdnsRecordType
  = A  -- ^ Tag 0.
  | Aaaa  -- ^ Tag 1.
  | Ptr  -- ^ Tag 2.
  | Srv  -- ^ Tag 3.
  | Txt  -- ^ Tag 4.
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

-- | QueryType type matching the Idris2 ABI.
--
-- Tags 0-2 (3 constructors).
data QueryType
  = Standard  -- ^ Tag 0.
  | OneShot  -- ^ Tag 1.
  | Continuous  -- ^ Tag 2.
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

-- | ConflictAction type matching the Idris2 ABI.
--
-- Tags 0-2 (3 constructors).
data ConflictAction
  = Probe  -- ^ Tag 0.
  | Defend  -- ^ Tag 1.
  | Withdraw  -- ^ Tag 2.
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

-- | ServiceFlag type matching the Idris2 ABI.
--
-- Tags 0-1 (2 constructors).
data ServiceFlag
  = Unique  -- ^ Tag 0.
  | Shared  -- ^ Tag 1.
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

-- | ResponderState type matching the Idris2 ABI.
--
-- Tags 0-4 (5 constructors).
data ResponderState
  = Idle  -- ^ Tag 0.
  | Probing  -- ^ Tag 1.
  | Announcing  -- ^ Tag 2.
  | Running  -- ^ Tag 3.
  | ShuttingDown  -- ^ Tag 4.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'ResponderState' to its ABI tag value.
responderStateToTag :: ResponderState -> Word8
responderStateToTag = fromIntegral . fromEnum

-- | Decode a 'ResponderState' from its ABI tag value.
responderStateFromTag :: Word8 -> Maybe ResponderState
responderStateFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: ResponderState)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing
