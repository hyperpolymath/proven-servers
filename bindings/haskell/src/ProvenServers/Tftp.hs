-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- | TFTP (Trivial File Transfer Protocol) types for the proven-servers ABI.
--
-- All tag values match the Idris2 ABI discriminants exactly.

module ProvenServers.Tftp
  (
    tftpPort
  , tftpBlockSize
  , Opcode(..)
  , opcodeToTag
  , opcodeFromTag
  , isRequest
  , isData
  , TransferMode(..)
  , transferModeToTag
  , transferModeFromTag
  , isTextMode
  , isDeprecated
  , modeString
  , TftpError(..)
  , tftpErrorToTag
  , tftpErrorFromTag
  , isAccessError
  , isStorageError
  , TransferState(..)
  , transferStateToTag
  , transferStateFromTag
  , isActive
  , isTerminal
  ) where

import Data.Word (Word16, Word8)

-- | Standard TFTP port (RFC 1350).
tftpPort :: Word16
tftpPort = 69

-- | TFTP data block size (RFC 1350).
tftpBlockSize :: Word16
tftpBlockSize = 512

-- ---------------------------------------------------------------------------
-- Opcode
-- ---------------------------------------------------------------------------

-- | Standard TFTP port (RFC 1350).
--
-- Tags 0-4 (5 constructors).
data Opcode
  = Rrq  -- ^ Read Request (tag 0).
  | Wrq  -- ^ Write Request (tag 1).
  | Data  -- ^ Data packet (tag 2).
  | Ack  -- ^ Acknowledgement (tag 3).
  | Error  -- ^ Error packet (tag 4).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'Opcode' to its ABI tag value.
opcodeToTag :: Opcode -> Word8
opcodeToTag = fromIntegral . fromEnum

-- | Decode a 'Opcode' from its ABI tag value.
opcodeFromTag :: Word8 -> Maybe Opcode
opcodeFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: Opcode)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- | Whether this opcode initiates a transfer.
isRequest :: Opcode -> Bool
isRequest Rrq = True
isRequest Wrq = True
isRequest _ = False

-- | Whether this opcode carries payload data.
isData :: Opcode -> Bool
isData Data = True
isData _ = False

-- ---------------------------------------------------------------------------
-- TransferMode
-- ---------------------------------------------------------------------------

-- | TFTP transfer modes (RFC 1350 Section 5).
--
-- Tags 0-2 (3 constructors).
data TransferMode
  = NetAscii  -- ^ NetASCII — 7-bit ASCII with CR/LF line endings (tag 0).
  | Octet  -- ^ Octet — raw binary transfer (tag 1).
  | Mail  -- ^ Mail — deprecated, sends to a user's mailbox (tag 2).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'TransferMode' to its ABI tag value.
transferModeToTag :: TransferMode -> Word8
transferModeToTag = fromIntegral . fromEnum

-- | Decode a 'TransferMode' from its ABI tag value.
transferModeFromTag :: Word8 -> Maybe TransferMode
transferModeFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: TransferMode)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- | Whether this mode performs character set conversion.
isTextMode :: TransferMode -> Bool
isTextMode NetAscii = True
isTextMode _ = False

-- | Whether this transfer mode is deprecated.
isDeprecated :: TransferMode -> Bool
isDeprecated Mail = True
isDeprecated _ = False

-- | The TFTP mode string (case-insensitive per RFC).
modeString :: TransferMode -> String
modeString NetAscii = "netascii"
modeString Octet = "octet"
modeString Mail = "mail"

-- ---------------------------------------------------------------------------
-- TftpError
-- ---------------------------------------------------------------------------

-- | TFTP error codes (RFC 1350 Section 5).
--
-- Tags 0-7 (8 constructors).
data TftpError
  = NotDefined  -- ^ Not defined — see error message (tag 0).
  | FileNotFound  -- ^ File not found (tag 1).
  | AccessViolation  -- ^ Access violation (tag 2).
  | DiskFull  -- ^ Disk full or allocation exceeded (tag 3).
  | IllegalOperation  -- ^ Illegal TFTP operation (tag 4).
  | UnknownTid  -- ^ Unknown transfer ID (tag 5).
  | FileExists  -- ^ File already exists (tag 6).
  | NoSuchUser  -- ^ No such user (tag 7).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'TftpError' to its ABI tag value.
tftpErrorToTag :: TftpError -> Word8
tftpErrorToTag = fromIntegral . fromEnum

-- | Decode a 'TftpError' from its ABI tag value.
tftpErrorFromTag :: Word8 -> Maybe TftpError
tftpErrorFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: TftpError)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- | Whether this error relates to access control.
isAccessError :: TftpError -> Bool
isAccessError AccessViolation = True
isAccessError NoSuchUser = True
isAccessError _ = False

-- | Whether this error relates to storage capacity.
isStorageError :: TftpError -> Bool
isStorageError DiskFull = True
isStorageError FileExists = True
isStorageError _ = False

-- ---------------------------------------------------------------------------
-- TransferState
-- ---------------------------------------------------------------------------

-- | TFTP transfer lifecycle states.
--
-- Tags 0-4 (5 constructors).
data TransferState
  = Idle  -- ^ No transfer in progress (tag 0).
  | Reading  -- ^ Reading from server (RRQ in progress) (tag 1).
  | Writing  -- ^ Writing to server (WRQ in progress) (tag 2).
  | InError  -- ^ Transfer encountered an error (tag 3).
  | Complete  -- ^ Transfer completed successfully (tag 4).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'TransferState' to its ABI tag value.
transferStateToTag :: TransferState -> Word8
transferStateToTag = fromIntegral . fromEnum

-- | Decode a 'TransferState' from its ABI tag value.
transferStateFromTag :: Word8 -> Maybe TransferState
transferStateFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: TransferState)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- | Whether a transfer is actively in progress.
isActive :: TransferState -> Bool
isActive Reading = True
isActive Writing = True
isActive _ = False

-- | Whether the transfer has reached a terminal state.
isTerminal :: TransferState -> Bool
isTerminal InError = True
isTerminal Complete = True
isTerminal _ = False
