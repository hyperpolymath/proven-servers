-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- | TACACS+ (Terminal Access Controller Access-Control System Plus) types
--
-- All tag values match the Idris2 ABI discriminants exactly.

module ProvenServers.Tacacs
  (
    tacacsPort
  , PacketType(..)
  , packetTypeToTag
  , packetTypeFromTag
  , aaaLabel
  , AuthenType(..)
  , authenTypeToTag
  , authenTypeFromTag
  , isChallengeResponse
  , isInteractive
  , AuthenAction(..)
  , authenActionToTag
  , authenActionFromTag
  , AuthenStatus(..)
  , authenStatusToTag
  , authenStatusFromTag
  , isSuccess
  , needsMoreData
  , isTerminal
  , AuthorStatus(..)
  , authorStatusToTag
  , authorStatusFromTag
  , isAuthorized
  , AcctStatus(..)
  , acctStatusToTag
  , acctStatusFromTag
  , AcctFlag(..)
  , acctFlagToTag
  , acctFlagFromTag
  , isBoundary
  , SessionState(..)
  , sessionStateToTag
  , sessionStateFromTag
  , isProcessing
  , isActive
  ) where

import Data.Word (Word16, Word8)

-- | Standard TACACS+ port (RFC 8907).
tacacsPort :: Word16
tacacsPort = 49

-- ---------------------------------------------------------------------------
-- PacketType
-- ---------------------------------------------------------------------------

-- | TACACS+ packet types (RFC 8907 Section 4.1).
--
-- Tags 0-2 (3 constructors).
data PacketType
  = Authentication  -- ^ Authentication packet (tag 0).
  | Authorization  -- ^ Authorization packet (tag 1).
  | Accounting  -- ^ Accounting packet (tag 2).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'PacketType' to its ABI tag value.
packetTypeToTag :: PacketType -> Word8
packetTypeToTag = fromIntegral . fromEnum

-- | Decode a 'PacketType' from its ABI tag value.
packetTypeFromTag :: Word8 -> Maybe PacketType
packetTypeFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: PacketType)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- | The short AAA label for this packet type.
aaaLabel :: PacketType -> String
aaaLabel Authentication = "authen"
aaaLabel Authorization = "author"
aaaLabel Accounting = "acct"

-- ---------------------------------------------------------------------------
-- AuthenType
-- ---------------------------------------------------------------------------

-- | TACACS+ authentication types (RFC 8907 Section 4.4.2).
--
-- Tags 0-4 (5 constructors).
data AuthenType
  = Ascii  -- ^ ASCII interactive login (tag 0).
  | Pap  -- ^ PAP — Password Authentication Protocol (tag 1).
  | Chap  -- ^ CHAP — Challenge-Handshake Authentication Protocol (tag 2).
  | MsChapV1  -- ^ MS-CHAPv1 (tag 3).
  | MsChapV2  -- ^ MS-CHAPv2 (tag 4).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'AuthenType' to its ABI tag value.
authenTypeToTag :: AuthenType -> Word8
authenTypeToTag = fromIntegral . fromEnum

-- | Decode a 'AuthenType' from its ABI tag value.
authenTypeFromTag :: Word8 -> Maybe AuthenType
authenTypeFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: AuthenType)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- | Whether this authentication type uses challenge-response.
isChallengeResponse :: AuthenType -> Bool
isChallengeResponse Chap = True
isChallengeResponse MsChapV1 = True
isChallengeResponse MsChapV2 = True
isChallengeResponse _ = False

-- | Whether this authentication type is interactive (multi-round).
isInteractive :: AuthenType -> Bool
isInteractive Ascii = True
isInteractive _ = False

-- ---------------------------------------------------------------------------
-- AuthenAction
-- ---------------------------------------------------------------------------

-- | TACACS+ authentication actions (RFC 8907 Section 4.4.1).
--
-- Tags 0-2 (3 constructors).
data AuthenAction
  = Login  -- ^ Login — authenticate a user (tag 0).
  | ChangePass  -- ^ ChangePass — change user password (tag 1).
  | SendAuth  -- ^ SendAuth — send authentication data (tag 2).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'AuthenAction' to its ABI tag value.
authenActionToTag :: AuthenAction -> Word8
authenActionToTag = fromIntegral . fromEnum

-- | Decode a 'AuthenAction' from its ABI tag value.
authenActionFromTag :: Word8 -> Maybe AuthenAction
authenActionFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: AuthenAction)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- AuthenStatus
-- ---------------------------------------------------------------------------

-- | TACACS+ authentication reply statuses (RFC 8907 Section 4.4.2).
--
-- Tags 0-7 (8 constructors).
data AuthenStatus
  = Pass  -- ^ Authentication passed (tag 0).
  | Fail  -- ^ Authentication failed (tag 1).
  | GetData  -- ^ Server requests additional data (tag 2).
  | GetUser  -- ^ Server requests username (tag 3).
  | GetPass  -- ^ Server requests password (tag 4).
  | Restart  -- ^ Restart authentication (tag 5).
  | Error  -- ^ Authentication error (tag 6).
  | Follow  -- ^ Follow — redirect to another server (tag 7).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'AuthenStatus' to its ABI tag value.
authenStatusToTag :: AuthenStatus -> Word8
authenStatusToTag = fromIntegral . fromEnum

-- | Decode a 'AuthenStatus' from its ABI tag value.
authenStatusFromTag :: Word8 -> Maybe AuthenStatus
authenStatusFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: AuthenStatus)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- | Whether authentication succeeded.
isSuccess :: AuthenStatus -> Bool
isSuccess Pass = True
isSuccess _ = False

-- | Whether the server needs more information from the client.
needsMoreData :: AuthenStatus -> Bool
needsMoreData GetData = True
needsMoreData GetUser = True
needsMoreData GetPass = True
needsMoreData _ = False

-- | Whether this status indicates a terminal (final) state.
isTerminal :: AuthenStatus -> Bool
isTerminal Pass = True
isTerminal Fail = True
isTerminal Error = True
isTerminal _ = False

-- ---------------------------------------------------------------------------
-- AuthorStatus
-- ---------------------------------------------------------------------------

-- | TACACS+ authorization reply statuses (RFC 8907 Section 4.5).
--
-- Tags 0-4 (5 constructors).
data AuthorStatus
  = PassAdd  -- ^ Authorized, server added attributes (tag 0).
  | PassRepl  -- ^ Authorized, server replaced attributes (tag 1).
  | Fail  -- ^ Authorization failed (tag 2).
  | Error  -- ^ Authorization error (tag 3).
  | Follow  -- ^ Follow — redirect to another server (tag 4).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'AuthorStatus' to its ABI tag value.
authorStatusToTag :: AuthorStatus -> Word8
authorStatusToTag = fromIntegral . fromEnum

-- | Decode a 'AuthorStatus' from its ABI tag value.
authorStatusFromTag :: Word8 -> Maybe AuthorStatus
authorStatusFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: AuthorStatus)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- | Whether authorization was granted.
isAuthorized :: AuthorStatus -> Bool
isAuthorized PassAdd = True
isAuthorized PassRepl = True
isAuthorized _ = False

-- ---------------------------------------------------------------------------
-- AcctStatus
-- ---------------------------------------------------------------------------

-- | TACACS+ accounting reply statuses (RFC 8907 Section 4.6).
--
-- Tags 0-2 (3 constructors).
data AcctStatus
  = Success  -- ^ Accounting record accepted (tag 0).
  | Error  -- ^ Accounting error (tag 1).
  | Follow  -- ^ Follow — redirect to another server (tag 2).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'AcctStatus' to its ABI tag value.
acctStatusToTag :: AcctStatus -> Word8
acctStatusToTag = fromIntegral . fromEnum

-- | Decode a 'AcctStatus' from its ABI tag value.
acctStatusFromTag :: Word8 -> Maybe AcctStatus
acctStatusFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: AcctStatus)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- | Whether the accounting record was accepted.
isSuccess :: AcctStatus -> Bool
isSuccess Success = True
isSuccess _ = False

-- ---------------------------------------------------------------------------
-- AcctFlag
-- ---------------------------------------------------------------------------

-- | TACACS+ accounting record flags (RFC 8907 Section 4.6.1).
--
-- Tags 0-2 (3 constructors).
data AcctFlag
  = Start  -- ^ Start of a session (tag 0).
  | Stop  -- ^ End of a session (tag 1).
  | Watchdog  -- ^ Interim update / watchdog (tag 2).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'AcctFlag' to its ABI tag value.
acctFlagToTag :: AcctFlag -> Word8
acctFlagToTag = fromIntegral . fromEnum

-- | Decode a 'AcctFlag' from its ABI tag value.
acctFlagFromTag :: Word8 -> Maybe AcctFlag
acctFlagFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: AcctFlag)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- | Whether this flag marks a session boundary (start or stop).
isBoundary :: AcctFlag -> Bool
isBoundary Start = True
isBoundary Stop = True
isBoundary _ = False

-- ---------------------------------------------------------------------------
-- SessionState
-- ---------------------------------------------------------------------------

-- | TACACS+ session lifecycle states for the FFI layer.
--
-- Tags 0-4 (5 constructors).
data SessionState
  = Idle  -- ^ No session active (tag 0).
  | Authenticating  -- ^ Authentication in progress (tag 1).
  | Authorizing  -- ^ Authorization in progress (tag 2).
  | Active  -- ^ Session active, accounting records may be generated (tag 3).
  | Closing  -- ^ Session ending, final accounting being sent (tag 4).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'SessionState' to its ABI tag value.
sessionStateToTag :: SessionState -> Word8
sessionStateToTag = fromIntegral . fromEnum

-- | Decode a 'SessionState' from its ABI tag value.
sessionStateFromTag :: Word8 -> Maybe SessionState
sessionStateFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: SessionState)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- | Whether the session is in an AAA processing phase.
isProcessing :: SessionState -> Bool
isProcessing Authenticating = True
isProcessing Authorizing = True
isProcessing _ = False

-- | Whether the session has been fully authorised and is active.
isActive :: SessionState -> Bool
isActive Active = True
isActive _ = False
