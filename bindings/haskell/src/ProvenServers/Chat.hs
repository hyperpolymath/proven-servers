-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- | Chat Server types for the proven-servers ABI.
--
-- All tag values match the Idris2 ABI discriminants exactly.

module ProvenServers.Chat
  (
    MessageType(..)
  , messageTypeToTag
  , messageTypeFromTag
  , PresenceStatus(..)
  , presenceStatusToTag
  , presenceStatusFromTag
  , RoomType(..)
  , roomTypeToTag
  , roomTypeFromTag
  , Permission(..)
  , permissionToTag
  , permissionFromTag
  , Event(..)
  , eventToTag
  , eventFromTag
  ) where

import Data.Word (Word8)

-- ---------------------------------------------------------------------------
-- MessageType
-- ---------------------------------------------------------------------------

-- | Chat message types.
--
-- Tags 0-8 (9 constructors).
data MessageType
  = Text  -- ^ Text (tag 0).
  | Image  -- ^ Image (tag 1).
  | File  -- ^ File (tag 2).
  | System  -- ^ System (tag 3).
  | Reaction  -- ^ Reaction (tag 4).
  | Edit  -- ^ Edit (tag 5).
  | Delete  -- ^ Delete (tag 6).
  | Reply  -- ^ Reply (tag 7).
  | Thread  -- ^ Thread (tag 8).
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

-- | User presence statuses.
--
-- Tags 0-4 (5 constructors).
data PresenceStatus
  = Online  -- ^ Online (tag 0).
  | Away  -- ^ Away (tag 1).
  | Dnd  -- ^ Do Not Disturb (tag 2).
  | Invisible  -- ^ Invisible (tag 3).
  | Offline  -- ^ Offline (tag 4).
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

-- | Chat room types.
--
-- Tags 0-3 (4 constructors).
data RoomType
  = Direct  -- ^ Direct (tag 0).
  | Group  -- ^ Group (tag 1).
  | Channel  -- ^ Channel (tag 2).
  | Broadcast  -- ^ Broadcast (tag 3).
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

-- | Chat permissions.
--
-- Tags 0-7 (8 constructors).
data Permission
  = Read  -- ^ Read (tag 0).
  | Write  -- ^ Write (tag 1).
  | Admin  -- ^ Admin (tag 2).
  | Invite  -- ^ Invite (tag 3).
  | Kick  -- ^ Kick (tag 4).
  | Ban  -- ^ Ban (tag 5).
  | Pin  -- ^ Pin (tag 6).
  | DeleteOthers  -- ^ DeleteOthers (tag 7).
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

-- | Chat events.
--
-- Tags 0-6 (7 constructors).
data Event
  = MessageSent  -- ^ MessageSent (tag 0).
  | MessageDelivered  -- ^ MessageDelivered (tag 1).
  | MessageRead  -- ^ MessageRead (tag 2).
  | UserJoined  -- ^ UserJoined (tag 3).
  | UserLeft  -- ^ UserLeft (tag 4).
  | Typing  -- ^ Typing (tag 5).
  | RoomCreated  -- ^ RoomCreated (tag 6).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'Event' to its ABI tag value.
eventToTag :: Event -> Word8
eventToTag = fromIntegral . fromEnum

-- | Decode a 'Event' from its ABI tag value.
eventFromTag :: Word8 -> Maybe Event
eventFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: Event)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing
