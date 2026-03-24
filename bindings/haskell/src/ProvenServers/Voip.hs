-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- | VoIP (Voice over IP / SIP) types for the proven-servers ABI.
--
-- All tag values match the Idris2 ABI discriminants exactly.

module ProvenServers.Voip
  (
    sipPort
  , sipsPort
  , Method(..)
  , methodToTag
  , methodFromTag
  , isDialogCreating
  , isSessionRelated
  , isEventRelated
  , name
  , ResponseCode(..)
  , responseCodeToTag
  , responseCodeFromTag
  , isProvisional
  , isSuccess
  , isRedirect
  , isClientError
  , isServerError
  , isGlobalFailure
  , isFinal
  , DialogState(..)
  , dialogStateToTag
  , dialogStateFromTag
  , canCarryMedia
  , isActive
  ) where

import Data.Word (Word16, Word8)

-- | Standard SIP port (RFC 3261).
sipPort :: Word16
sipPort = 5060

-- | Standard SIP over TLS (SIPS) port (RFC 3261).
sipsPort :: Word16
sipsPort = 5061

-- ---------------------------------------------------------------------------
-- Method
-- ---------------------------------------------------------------------------

-- | Standard SIP port (RFC 3261).
--
-- Tags 0-12 (13 constructors).
data Method
  = Invite  -- ^ INVITE — initiate a session (tag 0).
  | Ack  -- ^ ACK — confirm INVITE reception (tag 1).
  | Bye  -- ^ BYE — terminate a session (tag 2).
  | Cancel  -- ^ CANCEL — cancel a pending request (tag 3).
  | Register  -- ^ REGISTER — register contact URI (tag 4).
  | Options  -- ^ OPTIONS — query capabilities (tag 5).
  | Info  -- ^ INFO — send mid-session information (tag 6).
  | Update  -- ^ UPDATE — modify session parameters (tag 7).
  | Subscribe  -- ^ SUBSCRIBE — request event notification (tag 8).
  | Notify  -- ^ NOTIFY — deliver event notification (tag 9).
  | Refer  -- ^ REFER — ask recipient to issue a request (tag 10).
  | Message  -- ^ MESSAGE — instant messaging (tag 11).
  | Prack  -- ^ PRACK — provisional response acknowledgement (tag 12).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'Method' to its ABI tag value.
methodToTag :: Method -> Word8
methodToTag = fromIntegral . fromEnum

-- | Decode a 'Method' from its ABI tag value.
methodFromTag :: Word8 -> Maybe Method
methodFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: Method)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- | Whether this method creates or modifies a dialog.
isDialogCreating :: Method -> Bool
isDialogCreating Invite = True
isDialogCreating Subscribe = True
isDialogCreating _ = False

-- | Whether this method is related to session management.
isSessionRelated :: Method -> Bool
isSessionRelated Invite = True
isSessionRelated Ack = True
isSessionRelated Bye = True
isSessionRelated Cancel = True
isSessionRelated Update = True
isSessionRelated Prack = True
isSessionRelated _ = False

-- | Whether this method is related to event notification.
isEventRelated :: Method -> Bool
isEventRelated Subscribe = True
isEventRelated Notify = True
isEventRelated _ = False

-- | The SIP method name string.
name :: Method -> String
name Invite = "INVITE"
name Ack = "ACK"
name Bye = "BYE"
name Cancel = "CANCEL"
name Register = "REGISTER"
name Options = "OPTIONS"
name Info = "INFO"
name Update = "UPDATE"
name Subscribe = "SUBSCRIBE"
name Notify = "NOTIFY"
name Refer = "REFER"
name Message = "MESSAGE"
name Prack = "PRACK"

-- ---------------------------------------------------------------------------
-- ResponseCode
-- ---------------------------------------------------------------------------

-- | SIP response codes (RFC 3261).
--
-- Tags 0-16 (17 constructors).
data ResponseCode
  = Trying  -- ^ 100 Trying (tag 0).
  | Ringing  -- ^ 180 Ringing (tag 1).
  | SessionProgress  -- ^ 183 Session Progress (tag 2).
  | Ok  -- ^ 200 OK (tag 3).
  | MultipleChoices  -- ^ 300 Multiple Choices (tag 4).
  | MovedPermanently  -- ^ 301 Moved Permanently (tag 5).
  | MovedTemporarily  -- ^ 302 Moved Temporarily (tag 6).
  | BadRequest  -- ^ 400 Bad Request (tag 7).
  | Unauthorized  -- ^ 401 Unauthorized (tag 8).
  | Forbidden  -- ^ 403 Forbidden (tag 9).
  | NotFound  -- ^ 404 Not Found (tag 10).
  | MethodNotAllowed  -- ^ 405 Method Not Allowed (tag 11).
  | RequestTimeout  -- ^ 408 Request Timeout (tag 12).
  | BusyHere  -- ^ 486 Busy Here (tag 13).
  | Decline  -- ^ 603 Decline (tag 14).
  | ServerInternalError  -- ^ 500 Server Internal Error (tag 15).
  | ServiceUnavailable  -- ^ 503 Service Unavailable (tag 16).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'ResponseCode' to its ABI tag value.
responseCodeToTag :: ResponseCode -> Word8
responseCodeToTag = fromIntegral . fromEnum

-- | Decode a 'ResponseCode' from its ABI tag value.
responseCodeFromTag :: Word8 -> Maybe ResponseCode
responseCodeFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: ResponseCode)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- | Whether this is a provisional (1xx) response.
isProvisional :: ResponseCode -> Bool
isProvisional Trying = True
isProvisional Ringing = True
isProvisional SessionProgress = True
isProvisional _ = False

-- | Whether this is a success (2xx) response.
isSuccess :: ResponseCode -> Bool
isSuccess Ok = True
isSuccess _ = False

-- | Whether this is a redirection (3xx) response.
isRedirect :: ResponseCode -> Bool
isRedirect MultipleChoices = True
isRedirect MovedPermanently = True
isRedirect MovedTemporarily = True
isRedirect _ = False

-- | Whether this is a client error (4xx) response.
isClientError :: ResponseCode -> Bool
isClientError BadRequest = True
isClientError Unauthorized = True
isClientError Forbidden = True
isClientError NotFound = True
isClientError MethodNotAllowed = True
isClientError RequestTimeout = True
isClientError BusyHere = True
isClientError _ = False

-- | Whether this is a server error (5xx) response.
isServerError :: ResponseCode -> Bool
isServerError ServerInternalError = True
isServerError ServiceUnavailable = True
isServerError _ = False

-- | Whether this is a global failure (6xx) response.
isGlobalFailure :: ResponseCode -> Bool
isGlobalFailure Decline = True
isGlobalFailure _ = False

-- | Whether this response is a final response (non-provisional).
isFinal :: ResponseCode -> Bool
isFinal Trying = False
isFinal Ringing = False
isFinal SessionProgress = False
isFinal _ = True

-- ---------------------------------------------------------------------------
-- DialogState
-- ---------------------------------------------------------------------------

-- | SIP dialog state machine (RFC 3261 Section 12).
--
-- Tags 0-2 (3 constructors).
data DialogState
  = Early  -- ^ Early dialog — provisional response received (tag 0).
  | Confirmed  -- ^ Confirmed dialog — final 2xx response received (tag 1).
  | Terminated  -- ^ Terminated — BYE sent or received (tag 2).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'DialogState' to its ABI tag value.
dialogStateToTag :: DialogState -> Word8
dialogStateToTag = fromIntegral . fromEnum

-- | Decode a 'DialogState' from its ABI tag value.
dialogStateFromTag :: Word8 -> Maybe DialogState
dialogStateFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: DialogState)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- | Whether media can flow in this state.
canCarryMedia :: DialogState -> Bool
canCarryMedia Early = True
canCarryMedia Confirmed = True
canCarryMedia _ = False

-- | Whether the dialog is active (not terminated).
isActive :: DialogState -> Bool
isActive Terminated = False
isActive _ = True
