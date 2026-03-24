-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- | FTP protocol types for the proven-servers ABI.
--
-- All tag values match the Idris2 ABI discriminants exactly.

module ProvenServers.Ftp
  (
    ftpControlPort
  , ftpDataPort
  , ftpsPort
  , SessionState(..)
  , sessionStateToTag
  , sessionStateFromTag
  , sessionStateCanTransitionTo
  , TransferType(..)
  , transferTypeToTag
  , transferTypeFromTag
  , DataMode(..)
  , dataModeToTag
  , dataModeFromTag
  , isFirewallFriendly
  , TransferState(..)
  , transferStateToTag
  , transferStateFromTag
  , isTerminal
  , transferStateCanTransitionTo
  , ReplyCategory(..)
  , replyCategoryToTag
  , replyCategoryFromTag
  , isPositive
  , isError
  , Command(..)
  , commandToTag
  , commandFromTag
  , requiresDataConnection
  , requiresAuth
  , verb
  ) where

import Data.Word (Word16, Word8)

-- | Standard FTP control port (RFC 959).
ftpControlPort :: Word16
ftpControlPort = 21

-- | Standard FTP data port (RFC 959).
ftpDataPort :: Word16
ftpDataPort = 20

-- | FTPS (implicit TLS) control port.
ftpsPort :: Word16
ftpsPort = 990

-- ---------------------------------------------------------------------------
-- SessionState
-- ---------------------------------------------------------------------------

-- | Standard FTP data port (RFC 959).
--
-- Tags 0-4 (5 constructors).
data SessionState
  = Connected  -- ^ TCP connection established, awaiting USER (tag 0).
  | UserOk  -- ^ USER accepted, awaiting PASS (tag 1).
  | Authenticated  -- ^ Fully authenticated and ready (tag 2).
  | Renaming  -- ^ RNFR sent, awaiting RNTO (tag 3).
  | Quit  -- ^ QUIT sent, session ending (tag 4).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'SessionState' to its ABI tag value.
sessionStateToTag :: SessionState -> Word8
sessionStateToTag = fromIntegral . fromEnum

-- | Decode a 'SessionState' from its ABI tag value.
sessionStateFromTag :: Word8 -> Maybe SessionState
sessionStateFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: SessionState)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- | Validate whether a state transition is allowed.
sessionStateCanTransitionTo :: SessionState -> SessionState -> Bool
sessionStateCanTransitionTo Connected UserOk = True
sessionStateCanTransitionTo UserOk Authenticated = True
sessionStateCanTransitionTo UserOk Connected = True
sessionStateCanTransitionTo Authenticated Renaming = True
sessionStateCanTransitionTo Renaming Authenticated = True
sessionStateCanTransitionTo _ Quit = True
sessionStateCanTransitionTo _ _ = False

-- ---------------------------------------------------------------------------
-- TransferType
-- ---------------------------------------------------------------------------

-- | FTP data transfer type (RFC 959 Section 3.1.1).
--
-- Tags 0-1 (2 constructors).
data TransferType
  = Ascii  -- ^ ASCII mode — text with CRLF line endings (tag 0).
  | Binary  -- ^ Binary (Image) mode — raw byte transfer (tag 1).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'TransferType' to its ABI tag value.
transferTypeToTag :: TransferType -> Word8
transferTypeToTag = fromIntegral . fromEnum

-- | Decode a 'TransferType' from its ABI tag value.
transferTypeFromTag :: Word8 -> Maybe TransferType
transferTypeFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: TransferType)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- DataMode
-- ---------------------------------------------------------------------------

-- | FTP data connection mode (RFC 959).
--
-- Tags 0-1 (2 constructors).
data DataMode
  = Active  -- ^ Active mode — server connects to client (tag 0).
  | Passive  -- ^ Passive mode — client connects to server (tag 1).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'DataMode' to its ABI tag value.
dataModeToTag :: DataMode -> Word8
dataModeToTag = fromIntegral . fromEnum

-- | Decode a 'DataMode' from its ABI tag value.
dataModeFromTag :: Word8 -> Maybe DataMode
dataModeFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: DataMode)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- | Whether this mode is firewall-friendly (passive allows NAT traversal).
isFirewallFriendly :: DataMode -> Bool
isFirewallFriendly Passive = True
isFirewallFriendly _ = False

-- ---------------------------------------------------------------------------
-- TransferState
-- ---------------------------------------------------------------------------

-- | FTP file transfer state machine.
--
-- Tags 0-3 (4 constructors).
data TransferState
  = Idle  -- ^ No transfer in progress (tag 0).
  | InProgress  -- ^ Transfer is actively in progress (tag 1).
  | Completed  -- ^ Transfer completed successfully (tag 2).
  | Aborted  -- ^ Transfer was aborted (tag 3).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'TransferState' to its ABI tag value.
transferStateToTag :: TransferState -> Word8
transferStateToTag = fromIntegral . fromEnum

-- | Decode a 'TransferState' from its ABI tag value.
transferStateFromTag :: Word8 -> Maybe TransferState
transferStateFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: TransferState)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- | Whether the transfer has finished (completed or aborted).
isTerminal :: TransferState -> Bool
isTerminal Completed = True
isTerminal Aborted = True
isTerminal _ = False

-- | Validate whether a state transition is allowed.
transferStateCanTransitionTo :: TransferState -> TransferState -> Bool
transferStateCanTransitionTo Idle InProgress = True
transferStateCanTransitionTo InProgress Completed = True
transferStateCanTransitionTo InProgress Aborted = True
transferStateCanTransitionTo Completed Idle = True
transferStateCanTransitionTo Aborted Idle = True
transferStateCanTransitionTo _ _ = False

-- ---------------------------------------------------------------------------
-- ReplyCategory
-- ---------------------------------------------------------------------------

-- | FTP reply categories (RFC 959 Section 4.2).
--
-- Tags 0-4 (5 constructors).
data ReplyCategory
  = Preliminary  -- ^ 1xx — Preliminary positive reply (tag 0).
  | Completion  -- ^ 2xx — Completion positive reply (tag 1).
  | Intermediate  -- ^ 3xx — Intermediate positive reply (tag 2).
  | TransientNeg  -- ^ 4xx — Transient negative reply (tag 3).
  | PermanentNeg  -- ^ 5xx — Permanent negative reply (tag 4).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'ReplyCategory' to its ABI tag value.
replyCategoryToTag :: ReplyCategory -> Word8
replyCategoryToTag = fromIntegral . fromEnum

-- | Decode a 'ReplyCategory' from its ABI tag value.
replyCategoryFromTag :: Word8 -> Maybe ReplyCategory
replyCategoryFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: ReplyCategory)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- | Whether this category indicates a positive outcome.
isPositive :: ReplyCategory -> Bool
isPositive Preliminary = True
isPositive Completion = True
isPositive Intermediate = True
isPositive _ = False

-- | Whether this category indicates an error.
isError :: ReplyCategory -> Bool
isError TransientNeg = True
isError PermanentNeg = True
isError _ = False

-- ---------------------------------------------------------------------------
-- Command
-- ---------------------------------------------------------------------------

-- | FTP protocol commands (RFC 959, RFC 2389, RFC 3659).
--
-- Tags 0-22 (23 constructors).
data Command
  = User  -- ^ USER — specify username (tag 0).
  | Pass  -- ^ PASS — specify password (tag 1).
  | Acct  -- ^ ACCT — specify account (tag 2).
  | Cwd  -- ^ CWD — change working directory (tag 3).
  | Cdup  -- ^ CDUP — change to parent directory (tag 4).
  | Quit  -- ^ QUIT — logout (tag 5).
  | Pasv  -- ^ PASV — enter passive mode (tag 6).
  | Port  -- ^ PORT — specify data port (tag 7).
  | TypeCmd  -- ^ TYPE — set transfer type (tag 8).
  | Retr  -- ^ RETR — retrieve (download) file (tag 9).
  | Stor  -- ^ STOR — store (upload) file (tag 10).
  | Dele  -- ^ DELE — delete file (tag 11).
  | Rmd  -- ^ RMD — remove directory (tag 12).
  | Mkd  -- ^ MKD — make directory (tag 13).
  | Pwd  -- ^ PWD — print working directory (tag 14).
  | List  -- ^ LIST — list directory contents (tag 15).
  | Nlst  -- ^ NLST — name list (tag 16).
  | Syst  -- ^ SYST — system type (tag 17).
  | Stat  -- ^ STAT — server status (tag 18).
  | Noop  -- ^ NOOP — no operation (tag 19).
  | Rnfr  -- ^ RNFR — rename from (tag 20).
  | Rnto  -- ^ RNTO — rename to (tag 21).
  | Size  -- ^ SIZE — file size (RFC 3659) (tag 22).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'Command' to its ABI tag value.
commandToTag :: Command -> Word8
commandToTag = fromIntegral . fromEnum

-- | Decode a 'Command' from its ABI tag value.
commandFromTag :: Word8 -> Maybe Command
commandFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: Command)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- | Whether this command initiates a data transfer.
requiresDataConnection :: Command -> Bool
requiresDataConnection Retr = True
requiresDataConnection Stor = True
requiresDataConnection List = True
requiresDataConnection Nlst = True
requiresDataConnection _ = False

-- | Whether this command requires authentication.
requiresAuth :: Command -> Bool
requiresAuth User = False
requiresAuth Pass = False
requiresAuth Acct = False
requiresAuth Quit = False
requiresAuth _ = True

-- | The FTP command verb as a string.
verb :: Command -> String
verb User = "USER"
verb Pass = "PASS"
verb Acct = "ACCT"
verb Cwd = "CWD"
verb Cdup = "CDUP"
verb Quit = "QUIT"
verb Pasv = "PASV"
verb Port = "PORT"
verb TypeCmd = "TYPE"
verb Retr = "RETR"
verb Stor = "STOR"
verb Dele = "DELE"
verb Rmd = "RMD"
verb Mkd = "MKD"
verb Pwd = "PWD"
verb List = "LIST"
verb Nlst = "NLST"
verb Syst = "SYST"
verb Stat = "STAT"
verb Noop = "NOOP"
verb Rnfr = "RNFR"
verb Rnto = "RNTO"
verb Size = "SIZE"
