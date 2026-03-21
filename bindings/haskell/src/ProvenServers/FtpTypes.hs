-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- | FTP protocol types for proven-servers.
--
-- FTP protocol types, mirroring the Idris2 ABI.
-- All tag values match the Idris2 ABI discriminants exactly.
--
-- This is a pure type-definition module with no FFI dependencies.

module ProvenServers.FtpTypes
  ( -- * ADT types matching Idris2 ABI
      SessionState(..)
    , TransferType(..)
    , DataMode(..)
    , TransferState(..)
    , ReplyCategory(..)
    , Command(..)
    , sessionStateToTag
    , sessionStateFromTag
    , transferTypeToTag
    , transferTypeFromTag
    , dataModeToTag
    , dataModeFromTag
    , transferStateToTag
    , transferStateFromTag
    , replyCategoryToTag
    , replyCategoryFromTag
    , commandToTag
    , commandFromTag
  ) where

import Data.Word (Word8)

-- ---------------------------------------------------------------------------
-- SessionState
-- ---------------------------------------------------------------------------

-- | SessionState type matching the Idris2 ABI.
--
-- Tags 0-4 (5 constructors).
data SessionState
  = Connected  -- ^ Tag 0.
  | UserOk  -- ^ Tag 1.
  | Authenticated  -- ^ Tag 2.
  | Renaming  -- ^ Tag 3.
  | SessionState_Quit  -- ^ Tag 4.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'SessionState' to its ABI tag value.
sessionStateToTag :: SessionState -> Word8
sessionStateToTag = fromIntegral . fromEnum

-- | Decode a 'SessionState' from its ABI tag value.
sessionStateFromTag :: Word8 -> Maybe SessionState
sessionStateFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: SessionState)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- TransferType
-- ---------------------------------------------------------------------------

-- | TransferType type matching the Idris2 ABI.
--
-- Tags 0-1 (2 constructors).
data TransferType
  = Ascii  -- ^ Tag 0.
  | Binary  -- ^ Tag 1.
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

-- | DataMode type matching the Idris2 ABI.
--
-- Tags 0-1 (2 constructors).
data DataMode
  = Active  -- ^ Tag 0.
  | Passive  -- ^ Tag 1.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'DataMode' to its ABI tag value.
dataModeToTag :: DataMode -> Word8
dataModeToTag = fromIntegral . fromEnum

-- | Decode a 'DataMode' from its ABI tag value.
dataModeFromTag :: Word8 -> Maybe DataMode
dataModeFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: DataMode)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- TransferState
-- ---------------------------------------------------------------------------

-- | TransferState type matching the Idris2 ABI.
--
-- Tags 0-3 (4 constructors).
data TransferState
  = Idle  -- ^ Tag 0.
  | InProgress  -- ^ Tag 1.
  | Completed  -- ^ Tag 2.
  | Aborted  -- ^ Tag 3.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'TransferState' to its ABI tag value.
transferStateToTag :: TransferState -> Word8
transferStateToTag = fromIntegral . fromEnum

-- | Decode a 'TransferState' from its ABI tag value.
transferStateFromTag :: Word8 -> Maybe TransferState
transferStateFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: TransferState)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- ReplyCategory
-- ---------------------------------------------------------------------------

-- | ReplyCategory type matching the Idris2 ABI.
--
-- Tags 0-4 (5 constructors).
data ReplyCategory
  = Preliminary  -- ^ Tag 0.
  | Completion  -- ^ Tag 1.
  | Intermediate  -- ^ Tag 2.
  | TransientNeg  -- ^ Tag 3.
  | PermanentNeg  -- ^ Tag 4.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'ReplyCategory' to its ABI tag value.
replyCategoryToTag :: ReplyCategory -> Word8
replyCategoryToTag = fromIntegral . fromEnum

-- | Decode a 'ReplyCategory' from its ABI tag value.
replyCategoryFromTag :: Word8 -> Maybe ReplyCategory
replyCategoryFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: ReplyCategory)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- Command
-- ---------------------------------------------------------------------------

-- | Command type matching the Idris2 ABI.
--
-- Tags 0-22 (23 constructors).
data Command
  = User  -- ^ Tag 0.
  | Pass  -- ^ Tag 1.
  | Acct  -- ^ Tag 2.
  | Cwd  -- ^ Tag 3.
  | Cdup  -- ^ Tag 4.
  | Command_Quit  -- ^ Tag 5.
  | Pasv  -- ^ Tag 6.
  | Port  -- ^ Tag 7.
  | TypeCmd  -- ^ Tag 8.
  | Retr  -- ^ Tag 9.
  | Stor  -- ^ Tag 10.
  | Dele  -- ^ Tag 11.
  | Rmd  -- ^ Tag 12.
  | Mkd  -- ^ Tag 13.
  | Pwd  -- ^ Tag 14.
  | List  -- ^ Tag 15.
  | Nlst  -- ^ Tag 16.
  | Syst  -- ^ Tag 17.
  | Stat  -- ^ Tag 18.
  | Noop  -- ^ Tag 19.
  | Rnfr  -- ^ Tag 20.
  | Rnto  -- ^ Tag 21.
  | Size  -- ^ Tag 22.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'Command' to its ABI tag value.
commandToTag :: Command -> Word8
commandToTag = fromIntegral . fromEnum

-- | Decode a 'Command' from its ABI tag value.
commandFromTag :: Word8 -> Maybe Command
commandFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: Command)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing
