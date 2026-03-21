-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- | Chat protocol types for proven-servers.
--
-- Real-time chat server types, mirroring the Idris2 ABI.
-- All tag values match the Idris2 ABI discriminants exactly.
--
-- This is a pure type-definition module with no FFI dependencies.

module ProvenServers.Chat
  ( -- * ADT types matching Idris2 ABI
      MessageType(..)
    , PresenceStatus(..)
    , RoomType(..)
    , Permission(..)
    , Event(..)
    , messageTypeToTag
    , messageTypeFromTag
    , presenceStatusToTag
    , presenceStatusFromTag
    , roomTypeToTag
    , roomTypeFromTag
    , permissionToTag
    , permissionFromTag
    , eventToTag
    , eventFromTag
  ) where

import Data.Word (Word8)

-- ---------------------------------------------------------------------------
-- MessageType
-- ---------------------------------------------------------------------------

-- | MessageType type matching the Idris2 ABI.
--
-- Tags 0-8 (9 constructors).
data MessageType
  = Text  -- ^ Tag 0.
  | Image  -- ^ Tag 1.
  | File  -- ^ Tag 2.
  | System  -- ^ Tag 3.
  | Reaction  -- ^ Tag 4.
  | Edit  -- ^ Tag 5.
  | Delete  -- ^ Tag 6.
  | Reply  -- ^ Tag 7.
  | Thread  -- ^ Tag 8.
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
-- PresenceStatus
-- ---------------------------------------------------------------------------

-- | PresenceStatus type matching the Idris2 ABI.
--
-- Tags 0-4 (5 constructors).
data PresenceStatus
  = Online  -- ^ Tag 0.
  | Away  -- ^ Tag 1.
  | Dnd  -- ^ Tag 2.
  | Invisible  -- ^ Tag 3.
  | Offline  -- ^ Tag 4.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'PresenceStatus' to its ABI tag value.
presenceStatusToTag :: PresenceStatus -> Word8
presenceStatusToTag = fromIntegral . fromEnum

-- | Decode a 'PresenceStatus' from its ABI tag value.
presenceStatusFromTag :: Word8 -> Maybe PresenceStatus
presenceStatusFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: PresenceStatus)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- RoomType
-- ---------------------------------------------------------------------------

-- | RoomType type matching the Idris2 ABI.
--
-- Tags 0-3 (4 constructors).
data RoomType
  = Direct  -- ^ Tag 0.
  | Group  -- ^ Tag 1.
  | Channel  -- ^ Tag 2.
  | Broadcast  -- ^ Tag 3.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'RoomType' to its ABI tag value.
roomTypeToTag :: RoomType -> Word8
roomTypeToTag = fromIntegral . fromEnum

-- | Decode a 'RoomType' from its ABI tag value.
roomTypeFromTag :: Word8 -> Maybe RoomType
roomTypeFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: RoomType)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- Permission
-- ---------------------------------------------------------------------------

-- | Permission type matching the Idris2 ABI.
--
-- Tags 0-7 (8 constructors).
data Permission
  = Read  -- ^ Tag 0.
  | Write  -- ^ Tag 1.
  | Admin  -- ^ Tag 2.
  | Invite  -- ^ Tag 3.
  | Kick  -- ^ Tag 4.
  | Ban  -- ^ Tag 5.
  | Pin  -- ^ Tag 6.
  | DeleteOthers  -- ^ Tag 7.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'Permission' to its ABI tag value.
permissionToTag :: Permission -> Word8
permissionToTag = fromIntegral . fromEnum

-- | Decode a 'Permission' from its ABI tag value.
permissionFromTag :: Word8 -> Maybe Permission
permissionFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: Permission)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- Event
-- ---------------------------------------------------------------------------

-- | Event type matching the Idris2 ABI.
--
-- Tags 0-6 (7 constructors).
data Event
  = MessageSent  -- ^ Tag 0.
  | MessageDelivered  -- ^ Tag 1.
  | MessageRead  -- ^ Tag 2.
  | UserJoined  -- ^ Tag 3.
  | UserLeft  -- ^ Tag 4.
  | Typing  -- ^ Tag 5.
  | RoomCreated  -- ^ Tag 6.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'Event' to its ABI tag value.
eventToTag :: Event -> Word8
eventToTag = fromIntegral . fromEnum

-- | Decode a 'Event' from its ABI tag value.
eventFromTag :: Word8 -> Maybe Event
eventFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: Event)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing
