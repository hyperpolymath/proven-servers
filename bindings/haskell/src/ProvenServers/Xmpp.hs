-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- | XMPP (Extensible Messaging and Presence Protocol) types for the
--
-- All tag values match the Idris2 ABI discriminants exactly.

module ProvenServers.Xmpp
  (
    xmppClientPort
  , xmppServerPort
  , xmppsPort
  , StanzaType(..)
  , stanzaTypeToTag
  , stanzaTypeFromTag
  , elementName
  , MessageType(..)
  , messageTypeToTag
  , messageTypeFromTag
  , expectsReply
  , isMultiParty
  , PresenceType(..)
  , presenceTypeToTag
  , presenceTypeFromTag
  , isOnline
  , isAvailable
  , IqType(..)
  , iqTypeToTag
  , iqTypeFromTag
  , isRequest
  , isResponse
  , StreamError(..)
  , streamErrorToTag
  , streamErrorFromTag
  , isSecurityError
  , isRetryable
  , conditionName
  ) where

import Data.Word (Word16, Word8)

-- | Standard XMPP client-to-server port (RFC 6120).
xmppClientPort :: Word16
xmppClientPort = 5222

-- | Standard XMPP server-to-server port (RFC 6120).
xmppServerPort :: Word16
xmppServerPort = 5269

-- | XMPP over TLS (XMPPS) port for direct TLS connections.
xmppsPort :: Word16
xmppsPort = 5223

-- ---------------------------------------------------------------------------
-- StanzaType
-- ---------------------------------------------------------------------------

-- | XMPP over TLS (XMPPS) port for direct TLS connections.
--
-- Tags 0-2 (3 constructors).
data StanzaType
  = Message  -- ^ Message stanza — asynchronous messaging (tag 0).
  | Presence  -- ^ Presence stanza — availability broadcasting (tag 1).
  | Iq  -- ^ IQ (Info/Query) stanza — request/response (tag 2).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'StanzaType' to its ABI tag value.
stanzaTypeToTag :: StanzaType -> Word8
stanzaTypeToTag = fromIntegral . fromEnum

-- | Decode a 'StanzaType' from its ABI tag value.
stanzaTypeFromTag :: Word8 -> Maybe StanzaType
stanzaTypeFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: StanzaType)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- | The XML element name for this stanza type.
elementName :: StanzaType -> String
elementName Message = "message"
elementName Presence = "presence"
elementName Iq = "iq"

-- ---------------------------------------------------------------------------
-- MessageType
-- ---------------------------------------------------------------------------

-- | XMPP message types (RFC 6121 Section 5.2.2).
--
-- Tags 0-4 (5 constructors).
data MessageType
  = Chat  -- ^ One-to-one chat message (tag 0).
  | Error  -- ^ Error message (tag 1).
  | Groupchat  -- ^ Multi-user chat / groupchat message (tag 2).
  | Headline  -- ^ Headline / news message (tag 3).
  | Normal  -- ^ Normal (standalone) message — default type (tag 4).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'MessageType' to its ABI tag value.
messageTypeToTag :: MessageType -> Word8
messageTypeToTag = fromIntegral . fromEnum

-- | Decode a 'MessageType' from its ABI tag value.
messageTypeFromTag :: Word8 -> Maybe MessageType
messageTypeFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: MessageType)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- | Whether this message type expects a reply.
expectsReply :: MessageType -> Bool
expectsReply Chat = True
expectsReply Normal = True
expectsReply _ = False

-- | Whether this message type is for multi-party communication.
isMultiParty :: MessageType -> Bool
isMultiParty Groupchat = True
isMultiParty _ = False

-- ---------------------------------------------------------------------------
-- PresenceType
-- ---------------------------------------------------------------------------

-- | XMPP presence show values (RFC 6121 Section 4.7.2.1).
--
-- Tags 0-4 (5 constructors).
data PresenceType
  = Available  -- ^ Available — online and ready to communicate (tag 0).
  | Away  -- ^ Away — temporarily absent (tag 1).
  | Dnd  -- ^ Do Not Disturb — busy, should not be interrupted (tag 2).
  | Xa  -- ^ Extended Away — away for a longer period (tag 3).
  | Unavailable  -- ^ Unavailable — offline (tag 4).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'PresenceType' to its ABI tag value.
presenceTypeToTag :: PresenceType -> Word8
presenceTypeToTag = fromIntegral . fromEnum

-- | Decode a 'PresenceType' from its ABI tag value.
presenceTypeFromTag :: Word8 -> Maybe PresenceType
presenceTypeFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: PresenceType)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- | Whether the entity is online (any form of availability).
isOnline :: PresenceType -> Bool
isOnline Unavailable = False
isOnline _ = True

-- | Whether the entity is actively available for communication.
isAvailable :: PresenceType -> Bool
isAvailable Available = True
isAvailable _ = False

-- ---------------------------------------------------------------------------
-- IqType
-- ---------------------------------------------------------------------------

-- | XMPP IQ (Info/Query) stanza types (RFC 6120 Section 8.2.3).
--
-- Tags 0-3 (4 constructors).
data IqType
  = Get  -- ^ Get — request information (tag 0).
  | Set  -- ^ Set — provide information or make a request (tag 1).
  | Result  -- ^ Result — successful response (tag 2).
  | Error  -- ^ Error — error response (tag 3).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'IqType' to its ABI tag value.
iqTypeToTag :: IqType -> Word8
iqTypeToTag = fromIntegral . fromEnum

-- | Decode a 'IqType' from its ABI tag value.
iqTypeFromTag :: Word8 -> Maybe IqType
iqTypeFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: IqType)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- | Whether this IQ type is a request (requires a response).
isRequest :: IqType -> Bool
isRequest Get = True
isRequest Set = True
isRequest _ = False

-- | Whether this IQ type is a response.
isResponse :: IqType -> Bool
isResponse Result = True
isResponse Error = True
isResponse _ = False

-- ---------------------------------------------------------------------------
-- StreamError
-- ---------------------------------------------------------------------------

-- | XMPP stream-level error conditions (RFC 6120 Section 4.9.3).
--
-- Tags 0-8 (9 constructors).
data StreamError
  = BadFormat  -- ^ Malformed XML or protocol violation (tag 0).
  | Conflict  -- ^ Resource conflict (tag 1).
  | ConnectionTimeout  -- ^ Connection timed out (tag 2).
  | HostGone  -- ^ Remote host is no longer available (tag 3).
  | HostUnknown  -- ^ Remote host is unknown (tag 4).
  | NotAuthorized  -- ^ Entity is not authorised (tag 5).
  | PolicyViolation  -- ^ Policy violation (tag 6).
  | ResourceConstraint  -- ^ Server resource constraint (tag 7).
  | SystemShutdown  -- ^ System is shutting down (tag 8).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'StreamError' to its ABI tag value.
streamErrorToTag :: StreamError -> Word8
streamErrorToTag = fromIntegral . fromEnum

-- | Decode a 'StreamError' from its ABI tag value.
streamErrorFromTag :: Word8 -> Maybe StreamError
streamErrorFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: StreamError)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- | Whether this error is related to security/authorisation.
isSecurityError :: StreamError -> Bool
isSecurityError NotAuthorized = True
isSecurityError PolicyViolation = True
isSecurityError _ = False

-- | Whether this error is likely transient and the connection can be retried.
isRetryable :: StreamError -> Bool
isRetryable ConnectionTimeout = True
isRetryable ResourceConstraint = True
isRetryable SystemShutdown = True
isRetryable _ = False

-- | The XMPP defined-condition element name.
conditionName :: StreamError -> String
conditionName BadFormat = "bad-format"
conditionName Conflict = "conflict"
conditionName ConnectionTimeout = "connection-timeout"
conditionName HostGone = "host-gone"
conditionName HostUnknown = "host-unknown"
conditionName NotAuthorized = "not-authorized"
conditionName PolicyViolation = "policy-violation"
conditionName ResourceConstraint = "resource-constraint"
conditionName SystemShutdown = "system-shutdown"
