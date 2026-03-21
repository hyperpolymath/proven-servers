-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- | WebSocket protocol types for proven-servers.
--
-- WebSocket protocol types, mirroring the Idris2 ABI.
-- All tag values match the Idris2 ABI discriminants exactly.
--
-- This is a pure type-definition module with no FFI dependencies.

module ProvenServers.Websocket
  ( -- * ADT types matching Idris2 ABI
      Opcode(..)
    , CloseCode(..)
    , opcodeToTag
    , opcodeFromTag
    , closeCodeToTag
    , closeCodeFromTag
  ) where

import Data.Word (Word8)

-- ---------------------------------------------------------------------------
-- Opcode
-- ---------------------------------------------------------------------------

-- | Opcode type matching the Idris2 ABI.
--
-- Tags 0-0 (6 constructors).
data Opcode
  = Continuation  -- ^ Tag 0.
  | Text  -- ^ Tag 0.
  | Binary  -- ^ Tag 0.
  | Close  -- ^ Tag 0.
  | Ping  -- ^ Tag 0.
  | Pong  -- ^ Tag 0.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'Opcode' to its ABI tag value.
opcodeToTag :: Opcode -> Word8
opcodeToTag = fromIntegral . fromEnum

-- | Decode a 'Opcode' from its ABI tag value.
opcodeFromTag :: Word8 -> Maybe Opcode
opcodeFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: Opcode)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- CloseCode
-- ---------------------------------------------------------------------------

-- | CloseCode type matching the Idris2 ABI.
--
-- Tags 1000-1011 (11 constructors).
data CloseCode
  = Normal  -- ^ Tag 1000.
  | GoingAway  -- ^ Tag 1001.
  | ProtocolError  -- ^ Tag 1002.
  | UnsupportedData  -- ^ Tag 1003.
  | NoStatus  -- ^ Tag 1005.
  | Abnormal  -- ^ Tag 1006.
  | InvalidPayload  -- ^ Tag 1007.
  | PolicyViolation  -- ^ Tag 1008.
  | MessageTooBig  -- ^ Tag 1009.
  | MandatoryExtension  -- ^ Tag 1010.
  | InternalError  -- ^ Tag 1011.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'CloseCode' to its ABI tag value.
closeCodeToTag :: CloseCode -> Word8
closeCodeToTag = fromIntegral . fromEnum

-- | Decode a 'CloseCode' from its ABI tag value.
closeCodeFromTag :: Word8 -> Maybe CloseCode
closeCodeFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: CloseCode)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing
