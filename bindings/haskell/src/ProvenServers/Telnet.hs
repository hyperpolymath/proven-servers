-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- | Telnet protocol types for proven-servers.
--
-- Telnet protocol types (legacy/insecure), mirroring the Idris2 ABI.
-- All tag values match the Idris2 ABI discriminants exactly.
--
-- This is a pure type-definition module with no FFI dependencies.

module ProvenServers.Telnet
  ( -- * ADT types matching Idris2 ABI
      Command(..)
    , TelnetOption(..)
    , NegotiationState(..)
    , SessionState(..)
    , commandToTag
    , commandFromTag
    , telnetOptionToTag
    , telnetOptionFromTag
    , negotiationStateToTag
    , negotiationStateFromTag
    , sessionStateToTag
    , sessionStateFromTag
  ) where

import Data.Word (Word8)

-- ---------------------------------------------------------------------------
-- Command
-- ---------------------------------------------------------------------------

-- | Command type matching the Idris2 ABI.
--
-- Tags 0-15 (16 constructors).
data Command
  = Se  -- ^ Tag 0.
  | Nop  -- ^ Tag 1.
  | DataMark  -- ^ Tag 2.
  | Break  -- ^ Tag 3.
  | InterruptProcess  -- ^ Tag 4.
  | AbortOutput  -- ^ Tag 5.
  | AreYouThere  -- ^ Tag 6.
  | EraseChar  -- ^ Tag 7.
  | EraseLine  -- ^ Tag 8.
  | GoAhead  -- ^ Tag 9.
  | Sb  -- ^ Tag 10.
  | Will  -- ^ Tag 11.
  | Wont  -- ^ Tag 12.
  | Do  -- ^ Tag 13.
  | Dont  -- ^ Tag 14.
  | Iac  -- ^ Tag 15.
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
-- TelnetOption
-- ---------------------------------------------------------------------------

-- | TelnetOption type matching the Idris2 ABI.
--
-- Tags 0-9 (10 constructors).
data TelnetOption
  = Echo  -- ^ Tag 0.
  | SuppressGoAhead  -- ^ Tag 1.
  | Status  -- ^ Tag 2.
  | TimingMark  -- ^ Tag 3.
  | TerminalType  -- ^ Tag 4.
  | WindowSize  -- ^ Tag 5.
  | TerminalSpeed  -- ^ Tag 6.
  | RemoteFlowControl  -- ^ Tag 7.
  | Linemode  -- ^ Tag 8.
  | Environment  -- ^ Tag 9.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'TelnetOption' to its ABI tag value.
telnetOptionToTag :: TelnetOption -> Word8
telnetOptionToTag = fromIntegral . fromEnum

-- | Decode a 'TelnetOption' from its ABI tag value.
telnetOptionFromTag :: Word8 -> Maybe TelnetOption
telnetOptionFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: TelnetOption)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- NegotiationState
-- ---------------------------------------------------------------------------

-- | NegotiationState type matching the Idris2 ABI.
--
-- Tags 0-3 (4 constructors).
data NegotiationState
  = Inactive  -- ^ Tag 0.
  | WillSent  -- ^ Tag 1.
  | DoSent  -- ^ Tag 2.
  | NegotiationState_Active  -- ^ Tag 3.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'NegotiationState' to its ABI tag value.
negotiationStateToTag :: NegotiationState -> Word8
negotiationStateToTag = fromIntegral . fromEnum

-- | Decode a 'NegotiationState' from its ABI tag value.
negotiationStateFromTag :: Word8 -> Maybe NegotiationState
negotiationStateFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: NegotiationState)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- SessionState
-- ---------------------------------------------------------------------------

-- | SessionState type matching the Idris2 ABI.
--
-- Tags 0-4 (5 constructors).
data SessionState
  = Idle  -- ^ Tag 0.
  | Negotiating  -- ^ Tag 1.
  | SessionState_Active  -- ^ Tag 2.
  | Subneg  -- ^ Tag 3.
  | Closing  -- ^ Tag 4.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'SessionState' to its ABI tag value.
sessionStateToTag :: SessionState -> Word8
sessionStateToTag = fromIntegral . fromEnum

-- | Decode a 'SessionState' from its ABI tag value.
sessionStateFromTag :: Word8 -> Maybe SessionState
sessionStateFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: SessionState)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing
