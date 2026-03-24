-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- | Telnet protocol types for the proven-servers ABI.
--
-- All tag values match the Idris2 ABI discriminants exactly.

module ProvenServers.Telnet
  (
    telnetPort
  , Command(..)
  , commandToTag
  , commandFromTag
  , isNegotiation
  , TelnetOption(..)
  , telnetOptionToTag
  , telnetOptionFromTag
  , NegotiationState(..)
  , negotiationStateToTag
  , negotiationStateFromTag
  , SessionState(..)
  , sessionStateToTag
  , sessionStateFromTag
  ) where

import Data.Word (Word16, Word8)

-- | Standard Telnet port (RFC 854).
telnetPort :: Word16
telnetPort = 23

-- ---------------------------------------------------------------------------
-- Command
-- ---------------------------------------------------------------------------

-- | Standard Telnet port (RFC 854).
--
-- Tags 0-15 (16 constructors).
data Command
  = Se  -- ^ SE — End of subnegotiation (tag 0).
  | Nop  -- ^ NOP — No operation (tag 1).
  | DataMark  -- ^ Data Mark (tag 2).
  | Break  -- ^ Break (tag 3).
  | InterruptProcess  -- ^ Interrupt Process (tag 4).
  | AbortOutput  -- ^ Abort Output (tag 5).
  | AreYouThere  -- ^ Are You There (tag 6).
  | EraseChar  -- ^ Erase Character (tag 7).
  | EraseLine  -- ^ Erase Line (tag 8).
  | GoAhead  -- ^ Go Ahead (tag 9).
  | Sb  -- ^ SB — Begin subnegotiation (tag 10).
  | Will  -- ^ WILL — sender wants to enable option (tag 11).
  | Wont  -- ^ WONT — sender refuses to enable option (tag 12).
  | Do  -- ^ DO — sender wants receiver to enable option (tag 13).
  | Dont  -- ^ DONT — sender wants receiver to disable option (tag 14).
  | Iac  -- ^ IAC — Interpret As Command escape (tag 15).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'Command' to its ABI tag value.
commandToTag :: Command -> Word8
commandToTag = fromIntegral . fromEnum

-- | Decode a 'Command' from its ABI tag value.
commandFromTag :: Word8 -> Maybe Command
commandFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: Command)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- | Whether this command is a negotiation command (WILL/WONT/DO/DONT).
isNegotiation :: Command -> Bool
isNegotiation Will = True
isNegotiation Wont = True
isNegotiation Do = True
isNegotiation Dont = True
isNegotiation _ = False

-- ---------------------------------------------------------------------------
-- TelnetOption
-- ---------------------------------------------------------------------------

-- | Telnet options (RFC 854, RFC 1091, RFC 1073, etc.).
--
-- Tags 0-9 (10 constructors).
data TelnetOption
  = Echo  -- ^ Echo (tag 0).
  | SuppressGoAhead  -- ^ Suppress Go Ahead (tag 1).
  | Status  -- ^ Status (tag 2).
  | TimingMark  -- ^ Timing Mark (tag 3).
  | TerminalType  -- ^ Terminal Type (tag 4).
  | WindowSize  -- ^ Window Size — NAWS (tag 5).
  | TerminalSpeed  -- ^ Terminal Speed (tag 6).
  | RemoteFlowControl  -- ^ Remote Flow Control (tag 7).
  | Linemode  -- ^ Linemode (tag 8).
  | Environment  -- ^ Environment Variables (tag 9).
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

-- | Telnet option negotiation state.
--
-- Tags 0-3 (4 constructors).
data NegotiationState
  = Inactive  -- ^ Option inactive (tag 0).
  | WillSent  -- ^ WILL sent, awaiting response (tag 1).
  | DoSent  -- ^ DO sent, awaiting response (tag 2).
  | Active  -- ^ Option active (tag 3).
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

-- | Telnet session lifecycle states.
--
-- Tags 0-4 (5 constructors).
data SessionState
  = Idle  -- ^ No connection (tag 0).
  | Negotiating  -- ^ Connection established, negotiation in progress (tag 1).
  | Active  -- ^ Negotiation complete, data transfer active (tag 2).
  | Subneg  -- ^ Subnegotiation in progress (tag 3).
  | Closing  -- ^ Connection closing (tag 4).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'SessionState' to its ABI tag value.
sessionStateToTag :: SessionState -> Word8
sessionStateToTag = fromIntegral . fromEnum

-- | Decode a 'SessionState' from its ABI tag value.
sessionStateFromTag :: Word8 -> Maybe SessionState
sessionStateFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: SessionState)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing
