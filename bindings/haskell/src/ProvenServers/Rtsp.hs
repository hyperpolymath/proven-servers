-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- | RTSP (Real Time Streaming Protocol) types for the proven-servers ABI.
--
-- All tag values match the Idris2 ABI discriminants exactly.

module ProvenServers.Rtsp
  (
    rtspPort
  , rtspsPort
  , Method(..)
  , methodToTag
  , methodFromTag
  , requiresSession
  , name
  , TransportProtocol(..)
  , transportProtocolToTag
  , transportProtocolFromTag
  , isTcp
  , isMulticast
  , SessionState(..)
  , sessionStateToTag
  , sessionStateFromTag
  , isActive
  , sessionStateCanTransitionTo
  , StatusCode(..)
  , statusCodeToTag
  , statusCodeFromTag
  , isSuccess
  , isClientError
  , isServerError
  , RtspError(..)
  , rtspErrorToTag
  , rtspErrorFromTag
  , isOk
  ) where

import Data.Word (Word16, Word8)

-- | Standard RTSP port (RFC 7826).
rtspPort :: Word16
rtspPort = 554

-- | Standard RTSPS (RTSP over TLS) port.
rtspsPort :: Word16
rtspsPort = 322

-- ---------------------------------------------------------------------------
-- Method
-- ---------------------------------------------------------------------------

-- | Standard RTSP port (RFC 7826).
--
-- Tags 0-10 (11 constructors).
data Method
  = Describe  -- ^ Retrieve media description (tag 0).
  | Setup  -- ^ Set up transport for a media stream (tag 1).
  | Play  -- ^ Start playback of a media stream (tag 2).
  | Pause  -- ^ Pause playback (tag 3).
  | Teardown  -- ^ Tear down a session and release resources (tag 4).
  | GetParameter  -- ^ Retrieve server/session parameter (tag 5).
  | SetParameter  -- ^ Set server/session parameter (tag 6).
  | Options  -- ^ Query server capabilities (tag 7).
  | Announce  -- ^ Post media description to the server (tag 8).
  | Record  -- ^ Start recording a media stream (tag 9).
  | Redirect  -- ^ Redirect client to a new server (tag 10).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'Method' to its ABI tag value.
methodToTag :: Method -> Word8
methodToTag = fromIntegral . fromEnum

-- | Decode a 'Method' from its ABI tag value.
methodFromTag :: Word8 -> Maybe Method
methodFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: Method)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- | Whether this method requires an active session.
requiresSession :: Method -> Bool
requiresSession Play = True
requiresSession Pause = True
requiresSession Teardown = True
requiresSession GetParameter = True
requiresSession SetParameter = True
requiresSession Record = True
requiresSession _ = False

-- | The RTSP method name string.
name :: Method -> String
name Describe = "DESCRIBE"
name Setup = "SETUP"
name Play = "PLAY"
name Pause = "PAUSE"
name Teardown = "TEARDOWN"
name GetParameter = "GET_PARAMETER"
name SetParameter = "SET_PARAMETER"
name Options = "OPTIONS"
name Announce = "ANNOUNCE"
name Record = "RECORD"
name Redirect = "REDIRECT"

-- ---------------------------------------------------------------------------
-- TransportProtocol
-- ---------------------------------------------------------------------------

-- | RTP transport protocol variants used in RTSP SETUP.
--
-- Tags 0-2 (3 constructors).
data TransportProtocol
  = RtpAvpUdp  -- ^ RTP/AVP over UDP unicast (tag 0).
  | RtpAvpTcp  -- ^ RTP/AVP interleaved over TCP (tag 1).
  | RtpAvpUdpMulticast  -- ^ RTP/AVP over UDP multicast (tag 2).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'TransportProtocol' to its ABI tag value.
transportProtocolToTag :: TransportProtocol -> Word8
transportProtocolToTag = fromIntegral . fromEnum

-- | Decode a 'TransportProtocol' from its ABI tag value.
transportProtocolFromTag :: Word8 -> Maybe TransportProtocol
transportProtocolFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: TransportProtocol)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- | Whether this transport uses TCP.
isTcp :: TransportProtocol -> Bool
isTcp RtpAvpTcp = True
isTcp _ = False

-- | Whether this transport uses multicast.
isMulticast :: TransportProtocol -> Bool
isMulticast RtpAvpUdpMulticast = True
isMulticast _ = False

-- ---------------------------------------------------------------------------
-- SessionState
-- ---------------------------------------------------------------------------

-- | RTSP session state machine.
--
-- Tags 0-3 (4 constructors).
data SessionState
  = Init  -- ^ Initial state, no session established (tag 0).
  | Ready  -- ^ Session set up, ready for playback commands (tag 1).
  | Playing  -- ^ Media is being played back (tag 2).
  | Recording  -- ^ Media is being recorded (tag 3).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'SessionState' to its ABI tag value.
sessionStateToTag :: SessionState -> Word8
sessionStateToTag = fromIntegral . fromEnum

-- | Decode a 'SessionState' from its ABI tag value.
sessionStateFromTag :: Word8 -> Maybe SessionState
sessionStateFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: SessionState)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- | Whether media is actively streaming (playing or recording).
isActive :: SessionState -> Bool
isActive Playing = True
isActive Recording = True
isActive _ = False

-- | Validate whether a state transition is allowed.
sessionStateCanTransitionTo :: SessionState -> SessionState -> Bool
sessionStateCanTransitionTo Init Ready = True
sessionStateCanTransitionTo Ready Playing = True
sessionStateCanTransitionTo Ready Recording = True
sessionStateCanTransitionTo Playing Ready = True
sessionStateCanTransitionTo Recording Ready = True
sessionStateCanTransitionTo Ready Init = True
sessionStateCanTransitionTo Playing Init = True
sessionStateCanTransitionTo Recording Init = True
sessionStateCanTransitionTo _ _ = False

-- ---------------------------------------------------------------------------
-- StatusCode
-- ---------------------------------------------------------------------------

-- | RTSP response status codes (RFC 7826).
--
-- Tags 0-11 (12 constructors).
data StatusCode
  = Ok  -- ^ 200 OK (tag 0).
  | MovedPermanently  -- ^ 301 Moved Permanently (tag 1).
  | MovedTemporarily  -- ^ 302 Moved Temporarily (tag 2).
  | BadRequest  -- ^ 400 Bad Request (tag 3).
  | Unauthorized  -- ^ 401 Unauthorized (tag 4).
  | NotFound  -- ^ 404 Not Found (tag 5).
  | MethodNotAllowed  -- ^ 405 Method Not Allowed (tag 6).
  | NotAcceptable  -- ^ 406 Not Acceptable (tag 7).
  | SessionNotFound  -- ^ 454 Session Not Found (tag 8).
  | InternalServerError  -- ^ 500 Internal Server Error (tag 9).
  | NotImplemented  -- ^ 501 Not Implemented (tag 10).
  | ServiceUnavailable  -- ^ 503 Service Unavailable (tag 11).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'StatusCode' to its ABI tag value.
statusCodeToTag :: StatusCode -> Word8
statusCodeToTag = fromIntegral . fromEnum

-- | Decode a 'StatusCode' from its ABI tag value.
statusCodeFromTag :: Word8 -> Maybe StatusCode
statusCodeFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: StatusCode)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- | Whether this status code indicates success (2xx).
isSuccess :: StatusCode -> Bool
isSuccess Ok = True
isSuccess _ = False

-- | Whether this status code indicates a client error (4xx).
isClientError :: StatusCode -> Bool
isClientError BadRequest = True
isClientError Unauthorized = True
isClientError NotFound = True
isClientError MethodNotAllowed = True
isClientError NotAcceptable = True
isClientError SessionNotFound = True
isClientError _ = False

-- | Whether this status code indicates a server error (5xx).
isServerError :: StatusCode -> Bool
isServerError InternalServerError = True
isServerError NotImplemented = True
isServerError ServiceUnavailable = True
isServerError _ = False

-- ---------------------------------------------------------------------------
-- RtspError
-- ---------------------------------------------------------------------------

-- | RTSP FFI error codes.
--
-- Tags 0-6 (7 constructors).
data RtspError
  = Ok  -- ^ No error (tag 0).
  | InvalidSlot  -- ^ Invalid slot index (tag 1).
  | NotActive  -- ^ Session not active (tag 2).
  | InvalidTransition  -- ^ Invalid session state transition (tag 3).
  | MethodNotAllowed  -- ^ Method not allowed in current state (tag 4).
  | TransportError  -- ^ Transport setup failed (tag 5).
  | SessionExpired  -- ^ Session expired (tag 6).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'RtspError' to its ABI tag value.
rtspErrorToTag :: RtspError -> Word8
rtspErrorToTag = fromIntegral . fromEnum

-- | Decode a 'RtspError' from its ABI tag value.
rtspErrorFromTag :: Word8 -> Maybe RtspError
rtspErrorFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: RtspError)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- | Whether this represents a successful outcome.
isOk :: RtspError -> Bool
isOk Ok = True
isOk _ = False
