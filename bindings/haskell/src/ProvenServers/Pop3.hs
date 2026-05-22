-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- | POP3 protocol types for the proven-servers ABI.
--
-- All tag values match the Idris2 ABI discriminants exactly.

module ProvenServers.Pop3
  (
    pop3Port
  , pop3sPort
  , Command(..)
  , commandToTag
  , commandFromTag
  , isWrite
  , name
  , State(..)
  , stateToTag
  , stateFromTag
  , stateCanTransitionTo
  , Response(..)
  , responseToTag
  , responseFromTag
  , isSuccess
  , prefix
  , Pop3Error(..)
  , pop3ErrorToTag
  , pop3ErrorFromTag
  ) where

import Data.Word (Word16, Word8)

-- | Standard POP3 port (RFC 1939).
pop3Port :: Word16
pop3Port = 110

-- | Standard POP3S (POP3 over TLS) port.
pop3sPort :: Word16
pop3sPort = 995

-- ---------------------------------------------------------------------------
-- Command
-- ---------------------------------------------------------------------------

-- | Standard POP3 port (RFC 1939).
--
-- Tags 0-10 (11 constructors).
data Command
  = User  -- ^ USER — identify user for authentication (tag 0).
  | Pass  -- ^ PASS — supply password for authentication (tag 1).
  | Stat  -- ^ STAT — request mailbox status (tag 2).
  | List  -- ^ LIST — list message sizes (tag 3).
  | Retr  -- ^ RETR — retrieve a message (tag 4).
  | Dele  -- ^ DELE — mark a message for deletion (tag 5).
  | Noop  -- ^ NOOP — no operation (tag 6).
  | Rset  -- ^ RSET — reset deletion marks (tag 7).
  | Quit  -- ^ QUIT — end session (tag 8).
  | Top  -- ^ TOP — retrieve message headers plus N lines (tag 9).
  | Uidl  -- ^ UIDL — unique ID listing (tag 10).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'Command' to its ABI tag value.
commandToTag :: Command -> Word8
commandToTag = fromIntegral . fromEnum

-- | Decode a 'Command' from its ABI tag value.
commandFromTag :: Word8 -> Maybe Command
commandFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: Command)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- | Whether this command modifies mailbox state.
isWrite :: Command -> Bool
isWrite Dele = True
isWrite Rset = True
isWrite _ = False

-- | The POP3 command name string.
name :: Command -> String
name User = "USER"
name Pass = "PASS"
name Stat = "STAT"
name List = "LIST"
name Retr = "RETR"
name Dele = "DELE"
name Noop = "NOOP"
name Rset = "RSET"
name Quit = "QUIT"
name Top = "TOP"
name Uidl = "UIDL"

-- ---------------------------------------------------------------------------
-- State
-- ---------------------------------------------------------------------------

-- | POP3 session state machine (RFC 1939 Section 5).
--
-- Tags 0-2 (3 constructors).
data State
  = Authorization  -- ^ Authorization — awaiting USER/PASS (tag 0).
  | Transaction  -- ^ Transaction — mailbox open for commands (tag 1).
  | Update  -- ^ Update — QUIT received, deletions being committed (tag 2).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'State' to its ABI tag value.
stateToTag :: State -> Word8
stateToTag = fromIntegral . fromEnum

-- | Decode a 'State' from its ABI tag value.
stateFromTag :: Word8 -> Maybe State
stateFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: State)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- | Validate whether a state transition is allowed.
stateCanTransitionTo :: State -> State -> Bool
stateCanTransitionTo Authorization Transaction = True
stateCanTransitionTo Transaction Update = True
stateCanTransitionTo _ _ = False

-- ---------------------------------------------------------------------------
-- Response
-- ---------------------------------------------------------------------------

-- | POP3 response indicators (RFC 1939).
--
-- Tags 0-1 (2 constructors).
data Response
  = Ok  -- ^ +OK — command succeeded (tag 0).
  | Err  -- ^ -ERR — command failed (tag 1).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'Response' to its ABI tag value.
responseToTag :: Response -> Word8
responseToTag = fromIntegral . fromEnum

-- | Decode a 'Response' from its ABI tag value.
responseFromTag :: Word8 -> Maybe Response
responseFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: Response)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- | Whether this response indicates success.
isSuccess :: Response -> Bool
isSuccess Ok = True
isSuccess _ = False

-- | The POP3 response prefix string.
prefix :: Response -> String
prefix Ok = "+OK"
prefix Err = "-ERR"

-- ---------------------------------------------------------------------------
-- Pop3Error
-- ---------------------------------------------------------------------------

-- | POP3 FFI error codes.
--
-- Tags 0-5 (6 constructors).
data Pop3Error
  = Ok  -- ^ No error (tag 0).
  | InvalidSlot  -- ^ Invalid slot index (tag 1).
  | NotActive  -- ^ Session not active (tag 2).
  | InvalidTransition  -- ^ Invalid state transition (tag 3).
  | InvalidCommand  -- ^ Command not allowed in current state (tag 4).
  | AuthFailed  -- ^ Authentication failed (tag 5).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'Pop3Error' to its ABI tag value.
pop3ErrorToTag :: Pop3Error -> Word8
pop3ErrorToTag = fromIntegral . fromEnum

-- | Decode a 'Pop3Error' from its ABI tag value.
pop3ErrorFromTag :: Word8 -> Maybe Pop3Error
pop3ErrorFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: Pop3Error)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- | Whether this error code indicates success.
isSuccess :: Pop3Error -> Bool
isSuccess Ok = True
isSuccess _ = False
