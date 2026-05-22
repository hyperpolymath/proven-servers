-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- | IMAP protocol types for the proven-servers ABI.
--
-- All tag values match the Idris2 ABI discriminants exactly.

module ProvenServers.Imap
  (
    imapPort
  , imapsPort
  , Command(..)
  , commandToTag
  , commandFromTag
  , isWrite
  , name
  , State(..)
  , stateToTag
  , stateFromTag
  , stateCanTransitionTo
  , Flag(..)
  , flagToTag
  , flagFromTag
  , isClientSettable
  , imapName
  ) where

import Data.Word (Word16, Word8)

-- | Standard IMAP port (RFC 3501).
imapPort :: Word16
imapPort = 143

-- | Standard IMAPS (IMAP over TLS) port.
imapsPort :: Word16
imapsPort = 993

-- ---------------------------------------------------------------------------
-- Command
-- ---------------------------------------------------------------------------

-- | Standard IMAP port (RFC 3501).
--
-- Tags 0-13 (14 constructors).
data Command
  = Login  -- ^ LOGIN — authenticate with username/password (tag 0).
  | Logout  -- ^ LOGOUT — end session (tag 1).
  | Select  -- ^ SELECT — select a mailbox for access (tag 2).
  | Examine  -- ^ EXAMINE — select a mailbox read-only (tag 3).
  | Create  -- ^ CREATE — create a new mailbox (tag 4).
  | Delete  -- ^ DELETE — remove a mailbox (tag 5).
  | Rename  -- ^ RENAME — rename a mailbox (tag 6).
  | List  -- ^ LIST — list available mailboxes (tag 7).
  | Fetch  -- ^ FETCH — retrieve message data (tag 8).
  | Store  -- ^ STORE — modify message flags (tag 9).
  | Search  -- ^ SEARCH — search for messages (tag 10).
  | Copy  -- ^ COPY — copy messages to another mailbox (tag 11).
  | Noop  -- ^ NOOP — no operation / check for updates (tag 12).
  | Capability  -- ^ CAPABILITY — list server capabilities (tag 13).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'Command' to its ABI tag value.
commandToTag :: Command -> Word8
commandToTag = fromIntegral . fromEnum

-- | Decode a 'Command' from its ABI tag value.
commandFromTag :: Word8 -> Maybe Command
commandFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: Command)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- | Whether this command modifies mailbox or message state.
isWrite :: Command -> Bool
isWrite Create = True
isWrite Delete = True
isWrite Rename = True
isWrite Store = True
isWrite Copy = True
isWrite _ = False

-- | The IMAP command name string.
name :: Command -> String
name Login = "LOGIN"
name Logout = "LOGOUT"
name Select = "SELECT"
name Examine = "EXAMINE"
name Create = "CREATE"
name Delete = "DELETE"
name Rename = "RENAME"
name List = "LIST"
name Fetch = "FETCH"
name Store = "STORE"
name Search = "SEARCH"
name Copy = "COPY"
name Noop = "NOOP"
name Capability = "CAPABILITY"

-- ---------------------------------------------------------------------------
-- State
-- ---------------------------------------------------------------------------

-- | IMAP session state machine (RFC 3501 Section 3).
--
-- Tags 0-3 (4 constructors).
data State
  = NotAuthenticated  -- ^ Not authenticated — awaiting LOGIN or AUTHENTICATE (tag 0).
  | Authenticated  -- ^ Authenticated — can select mailboxes (tag 1).
  | Selected  -- ^ Selected — a mailbox is open for message operations (tag 2).
  | Logout  -- ^ Logout — session is ending (tag 3).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'State' to its ABI tag value.
stateToTag :: State -> Word8
stateToTag = fromIntegral . fromEnum

-- | Decode a 'State' from its ABI tag value.
stateFromTag :: Word8 -> Maybe State
stateFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: State)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- | that NotAuthenticated -> Selected is impossible.
stateCanTransitionTo :: State -> State -> Bool
stateCanTransitionTo NotAuthenticated Authenticated = True
stateCanTransitionTo Authenticated Selected = True
stateCanTransitionTo Selected Authenticated = True
stateCanTransitionTo NotAuthenticated Logout = True
stateCanTransitionTo Authenticated Logout = True
stateCanTransitionTo Selected Logout = True
stateCanTransitionTo _ _ = False

-- ---------------------------------------------------------------------------
-- Flag
-- ---------------------------------------------------------------------------

-- | IMAP message flags (RFC 3501 Section 2.3.2).
--
-- Tags 0-5 (6 constructors).
data Flag
  = Seen  -- ^ \Seen — message has been read (tag 0).
  | Answered  -- ^ \Answered — message has been replied to (tag 1).
  | Flagged  -- ^ \Flagged — message is flagged for attention (tag 2).
  | Deleted  -- ^ \Deleted — message is marked for deletion (tag 3).
  | Draft  -- ^ \Draft — message is a draft (tag 4).
  | Recent  -- ^ \Recent — message recently arrived (server-managed) (tag 5).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'Flag' to its ABI tag value.
flagToTag :: Flag -> Word8
flagToTag = fromIntegral . fromEnum

-- | Decode a 'Flag' from its ABI tag value.
flagFromTag :: Word8 -> Maybe Flag
flagFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: Flag)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- | /// The \Recent flag is server-managed and cannot be set by clients.
isClientSettable :: Flag -> Bool
isClientSettable Recent = False
isClientSettable _ = True

-- | The IMAP flag string including the backslash prefix.
imapName :: Flag -> String
imapName Seen = "\\Seen"
imapName Answered = "\\Answered"
imapName Flagged = "\\Flagged"
imapName Deleted = "\\Deleted"
imapName Draft = "\\Draft"
imapName Recent = "\\Recent"
