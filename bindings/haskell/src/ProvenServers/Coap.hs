-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- | CoAP (Constrained Application Protocol) types for the proven-servers ABI.
--
-- All tag values match the Idris2 ABI discriminants exactly.

module ProvenServers.Coap
  (
    coapPort
  , coapsPort
  , coapDefaultBlockSize
  , Method(..)
  , methodToTag
  , methodFromTag
  , isSafe
  , isIdempotent
  , MessageType(..)
  , messageTypeToTag
  , messageTypeFromTag
  , requiresResponse
  , isResponse
  , ContentFormat(..)
  , contentFormatToTag
  , contentFormatFromTag
  , isTextBased
  , mediaType
  , ResponseClass(..)
  , responseClassToTag
  , responseClassFromTag
  , isSuccess
  , isError
  , SessionState(..)
  , sessionStateToTag
  , sessionStateFromTag
  , isActive
  ) where

import Data.Word (Word16, Word8)

-- | Standard CoAP port (RFC 7252).
coapPort :: Word16
coapPort = 5683

-- | Standard CoAPS (CoAP over DTLS) port (RFC 7252).
coapsPort :: Word16
coapsPort = 5684

-- | Default CoAP block size (RFC 7959).
coapDefaultBlockSize :: Word16
coapDefaultBlockSize = 1024

-- ---------------------------------------------------------------------------
-- Method
-- ---------------------------------------------------------------------------

-- | Default CoAP block size (RFC 7959).
--
-- Tags 0-3 (4 constructors).
data Method
  = Get  -- ^ GET — retrieve a resource representation (tag 0).
  | Post  -- ^ POST — process a resource representation (tag 1).
  | Put  -- ^ PUT — update or create a resource (tag 2).
  | Delete  -- ^ DELETE — remove a resource (tag 3).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'Method' to its ABI tag value.
methodToTag :: Method -> Word8
methodToTag = fromIntegral . fromEnum

-- | Decode a 'Method' from its ABI tag value.
methodFromTag :: Word8 -> Maybe Method
methodFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: Method)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- | Whether this method is safe (does not alter server state).
isSafe :: Method -> Bool
isSafe Get = True
isSafe _ = False

-- | Whether this method is idempotent.
isIdempotent :: Method -> Bool
isIdempotent Get = True
isIdempotent Put = True
isIdempotent Delete = True
isIdempotent _ = False

-- ---------------------------------------------------------------------------
-- MessageType
-- ---------------------------------------------------------------------------

-- | CoAP message types (RFC 7252 Section 4.1).
--
-- Tags 0-3 (4 constructors).
data MessageType
  = Confirmable  -- ^ Confirmable — requires acknowledgement (tag 0).
  | NonConfirmable  -- ^ Non-confirmable — fire-and-forget (tag 1).
  | Acknowledgement  -- ^ Acknowledgement — reply to a confirmable (tag 2).
  | Reset  -- ^ Reset — reject a message (tag 3).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'MessageType' to its ABI tag value.
messageTypeToTag :: MessageType -> Word8
messageTypeToTag = fromIntegral . fromEnum

-- | Decode a 'MessageType' from its ABI tag value.
messageTypeFromTag :: Word8 -> Maybe MessageType
messageTypeFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: MessageType)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- | Whether this message type requires a response.
requiresResponse :: MessageType -> Bool
requiresResponse Confirmable = True
requiresResponse _ = False

-- | Whether this message type is a response.
isResponse :: MessageType -> Bool
isResponse Acknowledgement = True
isResponse Reset = True
isResponse _ = False

-- ---------------------------------------------------------------------------
-- ContentFormat
-- ---------------------------------------------------------------------------

-- | CoAP content formats (RFC 7252 Section 12.3).
--
-- Tags 0-6 (7 constructors).
data ContentFormat
  = TextPlain  -- ^ text/plain; charset=utf-8 (tag 0).
  | LinkFormat  -- ^ application/link-format (tag 1).
  | Xml  -- ^ application/xml (tag 2).
  | OctetStream  -- ^ application/octet-stream (tag 3).
  | Exi  -- ^ application/exi (tag 4).
  | Json  -- ^ application/json (tag 5).
  | Cbor  -- ^ application/cbor (tag 6).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'ContentFormat' to its ABI tag value.
contentFormatToTag :: ContentFormat -> Word8
contentFormatToTag = fromIntegral . fromEnum

-- | Decode a 'ContentFormat' from its ABI tag value.
contentFormatFromTag :: Word8 -> Maybe ContentFormat
contentFormatFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: ContentFormat)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- | Whether this format is text-based (human-readable).
isTextBased :: ContentFormat -> Bool
isTextBased TextPlain = True
isTextBased LinkFormat = True
isTextBased Xml = True
isTextBased Json = True
isTextBased _ = False

-- | The IANA media type string for this content format.
mediaType :: ContentFormat -> String
mediaType TextPlain = "text/plain; charset=utf-8"
mediaType LinkFormat = "application/link-format"
mediaType Xml = "application/xml"
mediaType OctetStream = "application/octet-stream"
mediaType Exi = "application/exi"
mediaType Json = "application/json"
mediaType Cbor = "application/cbor"

-- ---------------------------------------------------------------------------
-- ResponseClass
-- ---------------------------------------------------------------------------

-- | CoAP response class codes (RFC 7252 Section 5.9).
--
-- Tags 0-4 (5 constructors).
data ResponseClass
  = Success  -- ^ 2.xx Success (tag 0).
  | ClientError  -- ^ 4.xx Client Error (tag 1).
  | ServerError  -- ^ 5.xx Server Error (tag 2).
  | Signaling  -- ^ Signaling codes — CSM, Ping, Pong, Release, Abort (tag 3).
  | Empty  -- ^ Empty message (tag 4).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'ResponseClass' to its ABI tag value.
responseClassToTag :: ResponseClass -> Word8
responseClassToTag = fromIntegral . fromEnum

-- | Decode a 'ResponseClass' from its ABI tag value.
responseClassFromTag :: Word8 -> Maybe ResponseClass
responseClassFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: ResponseClass)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- | Whether this response class indicates success.
isSuccess :: ResponseClass -> Bool
isSuccess Success = True
isSuccess _ = False

-- | Whether this response class indicates an error.
isError :: ResponseClass -> Bool
isError ClientError = True
isError ServerError = True
isError _ = False

-- ---------------------------------------------------------------------------
-- SessionState
-- ---------------------------------------------------------------------------

-- | CoAP server lifecycle states for the FFI layer.
--
-- Tags 0-4 (5 constructors).
data SessionState
  = Idle  -- ^ No server active (tag 0).
  | Bound  -- ^ Socket bound to a port (tag 1).
  | Serving  -- ^ Actively serving CoAP requests (tag 2).
  | Observing  -- ^ Observing resources (RFC 7641) (tag 3).
  | Shutdown  -- ^ Server shutting down (tag 4).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'SessionState' to its ABI tag value.
sessionStateToTag :: SessionState -> Word8
sessionStateToTag = fromIntegral . fromEnum

-- | Decode a 'SessionState' from its ABI tag value.
sessionStateFromTag :: Word8 -> Maybe SessionState
sessionStateFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: SessionState)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- | Whether the server is ready to handle requests.
isActive :: SessionState -> Bool
isActive Serving = True
isActive Observing = True
isActive _ = False
