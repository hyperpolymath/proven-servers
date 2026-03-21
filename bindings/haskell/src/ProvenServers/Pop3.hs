-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- | POP3 protocol types for proven-servers.
--
-- POP3 (Post Office Protocol v3) types, mirroring the Idris2 ABI.
-- All tag values match the Idris2 ABI discriminants exactly.
--
-- This is a pure type-definition module with no FFI dependencies.

module ProvenServers.Pop3
  ( -- * ADT types matching Idris2 ABI
      Command(..)
    , State(..)
    , Response(..)
    , Pop3Error(..)
    , commandToTag
    , commandFromTag
    , stateToTag
    , stateFromTag
    , responseToTag
    , responseFromTag
    , pop3ErrorToTag
    , pop3ErrorFromTag
  ) where

import Data.Word (Word8)

-- ---------------------------------------------------------------------------
-- Command
-- ---------------------------------------------------------------------------

-- | Command type matching the Idris2 ABI.
--
-- Tags 0-10 (11 constructors).
data Command
  = User  -- ^ Tag 0.
  | Pass  -- ^ Tag 1.
  | Stat  -- ^ Tag 2.
  | List  -- ^ Tag 3.
  | Retr  -- ^ Tag 4.
  | Dele  -- ^ Tag 5.
  | Noop  -- ^ Tag 6.
  | Rset  -- ^ Tag 7.
  | Quit  -- ^ Tag 8.
  | Top  -- ^ Tag 9.
  | Uidl  -- ^ Tag 10.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'Command' to its ABI tag value.
commandToTag :: Command -> Word8
commandToTag = fromIntegral . fromEnum

-- | Decode a 'Command' from its ABI tag value.
commandFromTag :: Word8 -> Maybe Command
commandFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: Command)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- State
-- ---------------------------------------------------------------------------

-- | State type matching the Idris2 ABI.
--
-- Tags 0-2 (3 constructors).
data State
  = Authorization  -- ^ Tag 0.
  | Transaction  -- ^ Tag 1.
  | Update  -- ^ Tag 2.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'State' to its ABI tag value.
stateToTag :: State -> Word8
stateToTag = fromIntegral . fromEnum

-- | Decode a 'State' from its ABI tag value.
stateFromTag :: Word8 -> Maybe State
stateFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: State)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- Response
-- ---------------------------------------------------------------------------

-- | Response type matching the Idris2 ABI.
--
-- Tags 0-1 (2 constructors).
data Response
  = Response_Ok  -- ^ Tag 0.
  | Err  -- ^ Tag 1.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'Response' to its ABI tag value.
responseToTag :: Response -> Word8
responseToTag = fromIntegral . fromEnum

-- | Decode a 'Response' from its ABI tag value.
responseFromTag :: Word8 -> Maybe Response
responseFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: Response)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- Pop3Error
-- ---------------------------------------------------------------------------

-- | Pop3Error type matching the Idris2 ABI.
--
-- Tags 0-5 (6 constructors).
data Pop3Error
  = Pop3Error_Ok  -- ^ Tag 0.
  | InvalidSlot  -- ^ Tag 1.
  | NotActive  -- ^ Tag 2.
  | InvalidTransition  -- ^ Tag 3.
  | InvalidCommand  -- ^ Tag 4.
  | AuthFailed  -- ^ Tag 5.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'Pop3Error' to its ABI tag value.
pop3ErrorToTag :: Pop3Error -> Word8
pop3ErrorToTag = fromIntegral . fromEnum

-- | Decode a 'Pop3Error' from its ABI tag value.
pop3ErrorFromTag :: Word8 -> Maybe Pop3Error
pop3ErrorFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: Pop3Error)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing
