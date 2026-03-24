-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- | WebSocket protocol types for the proven-servers ABI.
--
-- All tag values match the Idris2 ABI discriminants exactly.

module ProvenServers.Websocket
  (
    maxControlPayload
  , Opcode(..)
  , opcodeToTag
  , opcodeFromTag
  , isData
  , isControl
  , isMessageStart
  , requiresResponse
  , name
  , CloseCode(..)
  , closeCodeToTag
  , closeCodeFromTag
  , isNormal
  , isError
  , isSendable
  , reason
  ) where

import Data.Word (Word8)

-- | /// Matches `maxControlPayload` in `WS.Frame`.
maxControlPayload :: usize
maxControlPayload = 125

-- ---------------------------------------------------------------------------
-- Opcode
-- ---------------------------------------------------------------------------

-- | WebSocket frame opcodes (RFC 6455 Section 11.8).
--
-- Tags 0-0 (6 constructors).
data Opcode
  = Continuation  -- ^ 0x0 -- Continuation frame (follows a fragmented message).
  | Text  -- ^ 0x1 -- Text frame (payload is UTF-8 encoded text).
  | Binary  -- ^ 0x2 -- Binary frame (payload is arbitrary binary data).
  | Close  -- ^ 0x8 -- Close frame (initiates or acknowledges connection close).
  | Ping  -- ^ 0x9 -- Ping frame (heartbeat request).
  | Pong  -- ^ 0xA -- Pong frame (heartbeat response).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'Opcode' to its ABI tag value.
opcodeToTag :: Opcode -> Word8
opcodeToTag = fromIntegral . fromEnum

-- | Decode a 'Opcode' from its ABI tag value.
opcodeFromTag :: Word8 -> Maybe Opcode
opcodeFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: Opcode)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- | Matches `isData` in `WS.Opcode`.
isData :: Opcode -> Bool
isData Continuation = True
isData Text = True
isData Binary = True
isData _ = False

-- | Matches `isControl` in `WS.Opcode`.
isControl :: Opcode -> Bool
isControl Continuation = False
isControl Text = False
isControl Binary = False
isControl _ = True

-- | /// Matches `isMessageStart` in `WS.Opcode`.
isMessageStart :: Opcode -> Bool
isMessageStart Text = True
isMessageStart Binary = True
isMessageStart _ = False

-- | Matches `requiresResponse` in `WS.Opcode`.
requiresResponse :: Opcode -> Bool
requiresResponse Ping = True
requiresResponse Close = True
requiresResponse _ = False

-- | /// Matches `opcodeName` in `WS.Opcode`.
name :: Opcode -> String
name Continuation = "continuation"
name Text = "text"
name Binary = "binary"
name Close = "close"
name Ping = "ping"
name Pong = "pong"

-- ---------------------------------------------------------------------------
-- CloseCode
-- ---------------------------------------------------------------------------

-- | WebSocket close status codes (RFC 6455 Section 7.4.1).
--
-- Tags 0-1011 (11 constructors).
data CloseCode
  = Normal  -- ^ 1000 -- Normal closure.
  | GoingAway  -- ^ 1001 -- Endpoint is going away.
  | ProtocolError  -- ^ 1002 -- Protocol error.
  | UnsupportedData  -- ^ 1003 -- Unsupported data type received.
  | NoStatus  -- ^ 1005 -- No status code present (internal only, MUST NOT be sent).
  | Abnormal  -- ^ 1006 -- Abnormal closure (internal only, MUST NOT be sent).
  | InvalidPayload  -- ^ 1007 -- Invalid payload data (e.g. non-UTF-8 in text message).
  | PolicyViolation  -- ^ 1008 -- Policy violation.
  | MessageTooBig  -- ^ 1009 -- Message too big.
  | MandatoryExtension  -- ^ 1010 -- Mandatory extension missing.
  | InternalError  -- ^ 1011 -- Internal server error.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'CloseCode' to its ABI tag value.
closeCodeToTag :: CloseCode -> Word8
closeCodeToTag = fromIntegral . fromEnum

-- | Decode a 'CloseCode' from its ABI tag value.
closeCodeFromTag :: Word8 -> Maybe CloseCode
closeCodeFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: CloseCode)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- | /// Matches `isNormalClose` in `WS.CloseCode`.
isNormal :: CloseCode -> Bool
isNormal Normal = True
isNormal GoingAway = True
isNormal _ = False

-- | /// Matches `isErrorClose` in `WS.CloseCode`.
isError :: CloseCode -> Bool
isError NoStatus = True
isError _ = False

-- | Matches `isSendable` in `WS.CloseCode`.
isSendable :: CloseCode -> Bool
isSendable NoStatus = False
isSendable Abnormal = False
isSendable _ = True

-- | /// Matches `closeReason` in `WS.CloseCode`.
reason :: CloseCode -> String
reason Normal = "Normal closure"
reason GoingAway = "Endpoint going away"
reason ProtocolError = "Protocol error"
reason UnsupportedData = "Unsupported data type"
reason NoStatus = "No status code present"
reason Abnormal = "Abnormal closure (no close frame)"
reason InvalidPayload = "Invalid payload data"
reason PolicyViolation = "Policy violation"
reason MessageTooBig = "Message too big"
reason MandatoryExtension = "Mandatory extension missing"
reason InternalError = "Internal server error"
