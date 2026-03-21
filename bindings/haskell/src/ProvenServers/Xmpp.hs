-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- | XMPP protocol types for proven-servers.
--
-- XMPP (Extensible Messaging and Presence Protocol) types, mirroring the Idris2 ABI.
-- All tag values match the Idris2 ABI discriminants exactly.
--
-- This is a pure type-definition module with no FFI dependencies.

module ProvenServers.Xmpp
  ( -- * ADT types matching Idris2 ABI
      StanzaType(..)
    , MessageType(..)
    , PresenceType(..)
    , IqType(..)
    , StreamError(..)
    , stanzaTypeToTag
    , stanzaTypeFromTag
    , messageTypeToTag
    , messageTypeFromTag
    , presenceTypeToTag
    , presenceTypeFromTag
    , iqTypeToTag
    , iqTypeFromTag
    , streamErrorToTag
    , streamErrorFromTag
  ) where

import Data.Word (Word8)

-- ---------------------------------------------------------------------------
-- StanzaType
-- ---------------------------------------------------------------------------

-- | StanzaType type matching the Idris2 ABI.
--
-- Tags 0-2 (3 constructors).
data StanzaType
  = Message  -- ^ Tag 0.
  | Presence  -- ^ Tag 1.
  | Iq  -- ^ Tag 2.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'StanzaType' to its ABI tag value.
stanzaTypeToTag :: StanzaType -> Word8
stanzaTypeToTag = fromIntegral . fromEnum

-- | Decode a 'StanzaType' from its ABI tag value.
stanzaTypeFromTag :: Word8 -> Maybe StanzaType
stanzaTypeFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: StanzaType)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- MessageType
-- ---------------------------------------------------------------------------

-- | MessageType type matching the Idris2 ABI.
--
-- Tags 0-4 (5 constructors).
data MessageType
  = Chat  -- ^ Tag 0.
  | MessageType_Error  -- ^ Tag 1.
  | Groupchat  -- ^ Tag 2.
  | Headline  -- ^ Tag 3.
  | Normal  -- ^ Tag 4.
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
-- PresenceType
-- ---------------------------------------------------------------------------

-- | PresenceType type matching the Idris2 ABI.
--
-- Tags 0-4 (5 constructors).
data PresenceType
  = Available  -- ^ Tag 0.
  | Away  -- ^ Tag 1.
  | Dnd  -- ^ Tag 2.
  | Xa  -- ^ Tag 3.
  | Unavailable  -- ^ Tag 4.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'PresenceType' to its ABI tag value.
presenceTypeToTag :: PresenceType -> Word8
presenceTypeToTag = fromIntegral . fromEnum

-- | Decode a 'PresenceType' from its ABI tag value.
presenceTypeFromTag :: Word8 -> Maybe PresenceType
presenceTypeFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: PresenceType)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- IqType
-- ---------------------------------------------------------------------------

-- | IqType type matching the Idris2 ABI.
--
-- Tags 0-3 (4 constructors).
data IqType
  = Get  -- ^ Tag 0.
  | Set  -- ^ Tag 1.
  | Result  -- ^ Tag 2.
  | IqType_Error  -- ^ Tag 3.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'IqType' to its ABI tag value.
iqTypeToTag :: IqType -> Word8
iqTypeToTag = fromIntegral . fromEnum

-- | Decode a 'IqType' from its ABI tag value.
iqTypeFromTag :: Word8 -> Maybe IqType
iqTypeFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: IqType)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- StreamError
-- ---------------------------------------------------------------------------

-- | StreamError type matching the Idris2 ABI.
--
-- Tags 0-8 (9 constructors).
data StreamError
  = BadFormat  -- ^ Tag 0.
  | Conflict  -- ^ Tag 1.
  | ConnectionTimeout  -- ^ Tag 2.
  | HostGone  -- ^ Tag 3.
  | HostUnknown  -- ^ Tag 4.
  | NotAuthorized  -- ^ Tag 5.
  | PolicyViolation  -- ^ Tag 6.
  | ResourceConstraint  -- ^ Tag 7.
  | SystemShutdown  -- ^ Tag 8.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'StreamError' to its ABI tag value.
streamErrorToTag :: StreamError -> Word8
streamErrorToTag = fromIntegral . fromEnum

-- | Decode a 'StreamError' from its ABI tag value.
streamErrorFromTag :: Word8 -> Maybe StreamError
streamErrorFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: StreamError)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing
