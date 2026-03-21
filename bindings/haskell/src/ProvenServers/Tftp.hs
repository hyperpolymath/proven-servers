-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- | TFTP protocol types for proven-servers.
--
-- TFTP (Trivial File Transfer Protocol) types, mirroring the Idris2 ABI.
-- All tag values match the Idris2 ABI discriminants exactly.
--
-- This is a pure type-definition module with no FFI dependencies.

module ProvenServers.Tftp
  ( -- * ADT types matching Idris2 ABI
      Opcode(..)
    , TransferMode(..)
    , TftpError(..)
    , TransferState(..)
    , opcodeToTag
    , opcodeFromTag
    , transferModeToTag
    , transferModeFromTag
    , tftpErrorToTag
    , tftpErrorFromTag
    , transferStateToTag
    , transferStateFromTag
  ) where

import Data.Word (Word8)

-- ---------------------------------------------------------------------------
-- Opcode
-- ---------------------------------------------------------------------------

-- | Opcode type matching the Idris2 ABI.
--
-- Tags 0-4 (5 constructors).
data Opcode
  = Rrq  -- ^ Tag 0.
  | Wrq  -- ^ Tag 1.
  | Data  -- ^ Tag 2.
  | Ack  -- ^ Tag 3.
  | Error  -- ^ Tag 4.
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
-- TransferMode
-- ---------------------------------------------------------------------------

-- | TransferMode type matching the Idris2 ABI.
--
-- Tags 0-2 (3 constructors).
data TransferMode
  = NetAscii  -- ^ Tag 0.
  | Octet  -- ^ Tag 1.
  | Mail  -- ^ Tag 2.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'TransferMode' to its ABI tag value.
transferModeToTag :: TransferMode -> Word8
transferModeToTag = fromIntegral . fromEnum

-- | Decode a 'TransferMode' from its ABI tag value.
transferModeFromTag :: Word8 -> Maybe TransferMode
transferModeFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: TransferMode)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- TftpError
-- ---------------------------------------------------------------------------

-- | TftpError type matching the Idris2 ABI.
--
-- Tags 0-7 (8 constructors).
data TftpError
  = NotDefined  -- ^ Tag 0.
  | FileNotFound  -- ^ Tag 1.
  | AccessViolation  -- ^ Tag 2.
  | DiskFull  -- ^ Tag 3.
  | IllegalOperation  -- ^ Tag 4.
  | UnknownTid  -- ^ Tag 5.
  | FileExists  -- ^ Tag 6.
  | NoSuchUser  -- ^ Tag 7.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'TftpError' to its ABI tag value.
tftpErrorToTag :: TftpError -> Word8
tftpErrorToTag = fromIntegral . fromEnum

-- | Decode a 'TftpError' from its ABI tag value.
tftpErrorFromTag :: Word8 -> Maybe TftpError
tftpErrorFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: TftpError)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- TransferState
-- ---------------------------------------------------------------------------

-- | TransferState type matching the Idris2 ABI.
--
-- Tags 0-4 (5 constructors).
data TransferState
  = Idle  -- ^ Tag 0.
  | Reading  -- ^ Tag 1.
  | Writing  -- ^ Tag 2.
  | InError  -- ^ Tag 3.
  | Complete  -- ^ Tag 4.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'TransferState' to its ABI tag value.
transferStateToTag :: TransferState -> Word8
transferStateToTag = fromIntegral . fromEnum

-- | Decode a 'TransferState' from its ABI tag value.
transferStateFromTag :: Word8 -> Maybe TransferState
transferStateFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: TransferState)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing
