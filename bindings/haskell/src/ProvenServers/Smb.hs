-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- | SMB protocol types for proven-servers.
--
-- SMB (Server Message Block) types, mirroring the Idris2 ABI.
-- All tag values match the Idris2 ABI discriminants exactly.
--
-- This is a pure type-definition module with no FFI dependencies.

module ProvenServers.Smb
  ( -- * ADT types matching Idris2 ABI
      Command(..)
    , Dialect(..)
    , ShareType(..)
    , SessionState(..)
    , commandToTag
    , commandFromTag
    , dialectToTag
    , dialectFromTag
    , shareTypeToTag
    , shareTypeFromTag
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
  = Negotiate  -- ^ Tag 0.
  | SessionSetup  -- ^ Tag 1.
  | Logoff  -- ^ Tag 2.
  | TreeConnect  -- ^ Tag 3.
  | TreeDisconnect  -- ^ Tag 4.
  | Create  -- ^ Tag 5.
  | Close  -- ^ Tag 6.
  | Read  -- ^ Tag 7.
  | Write  -- ^ Tag 8.
  | Lock  -- ^ Tag 9.
  | Ioctl  -- ^ Tag 10.
  | Cancel  -- ^ Tag 11.
  | QueryDirectory  -- ^ Tag 12.
  | ChangeNotify  -- ^ Tag 13.
  | QueryInfo  -- ^ Tag 14.
  | SetInfo  -- ^ Tag 15.
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
-- Dialect
-- ---------------------------------------------------------------------------

-- | Dialect type matching the Idris2 ABI.
--
-- Tags 0-4 (5 constructors).
data Dialect
  = Smb2_0_2  -- ^ Tag 0.
  | Smb2_1  -- ^ Tag 1.
  | Smb3_0  -- ^ Tag 2.
  | Smb3_0_2  -- ^ Tag 3.
  | Smb3_1_1  -- ^ Tag 4.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'Dialect' to its ABI tag value.
dialectToTag :: Dialect -> Word8
dialectToTag = fromIntegral . fromEnum

-- | Decode a 'Dialect' from its ABI tag value.
dialectFromTag :: Word8 -> Maybe Dialect
dialectFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: Dialect)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- ShareType
-- ---------------------------------------------------------------------------

-- | ShareType type matching the Idris2 ABI.
--
-- Tags 0-2 (3 constructors).
data ShareType
  = Disk  -- ^ Tag 0.
  | Pipe  -- ^ Tag 1.
  | Print  -- ^ Tag 2.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'ShareType' to its ABI tag value.
shareTypeToTag :: ShareType -> Word8
shareTypeToTag = fromIntegral . fromEnum

-- | Decode a 'ShareType' from its ABI tag value.
shareTypeFromTag :: Word8 -> Maybe ShareType
shareTypeFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: ShareType)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- SessionState
-- ---------------------------------------------------------------------------

-- | SessionState type matching the Idris2 ABI.
--
-- Tags 0-5 (6 constructors).
data SessionState
  = Idle  -- ^ Tag 0.
  | Negotiated  -- ^ Tag 1.
  | Authenticated  -- ^ Tag 2.
  | TreeConnected  -- ^ Tag 3.
  | FileOpen  -- ^ Tag 4.
  | Disconnecting  -- ^ Tag 5.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'SessionState' to its ABI tag value.
sessionStateToTag :: SessionState -> Word8
sessionStateToTag = fromIntegral . fromEnum

-- | Decode a 'SessionState' from its ABI tag value.
sessionStateFromTag :: Word8 -> Maybe SessionState
sessionStateFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: SessionState)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing
