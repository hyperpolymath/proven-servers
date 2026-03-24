-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- | SMB (Server Message Block) protocol types for the proven-servers ABI.
--
-- All tag values match the Idris2 ABI discriminants exactly.

module ProvenServers.Smb
  (
    smbPort
  , smbNetbiosPort
  , Command(..)
  , commandToTag
  , commandFromTag
  , isSessionManagement
  , isFileIo
  , isWrite
  , Dialect(..)
  , dialectToTag
  , dialectFromTag
  , supportsEncryption
  , isSmb3
  , revision
  , ShareType(..)
  , shareTypeToTag
  , shareTypeFromTag
  , isFilesystem
  , SessionState(..)
  , sessionStateToTag
  , sessionStateFromTag
  , isAuthenticated
  , canDoFileIo
  ) where

import Data.Word (Word16, Word8)

-- | Standard SMB port (TCP).
smbPort :: Word16
smbPort = 445

-- | Legacy NetBIOS over TCP port (used by older SMB implementations).
smbNetbiosPort :: Word16
smbNetbiosPort = 139

-- ---------------------------------------------------------------------------
-- Command
-- ---------------------------------------------------------------------------

-- | Legacy NetBIOS over TCP port (used by older SMB implementations).
--
-- Tags 0-15 (16 constructors).
data Command
  = Negotiate  -- ^ Negotiate protocol dialect (tag 0).
  | SessionSetup  -- ^ Set up an authenticated session (tag 1).
  | Logoff  -- ^ Log off a session (tag 2).
  | TreeConnect  -- ^ Connect to a share (tag 3).
  | TreeDisconnect  -- ^ Disconnect from a share (tag 4).
  | Create  -- ^ Create or open a file/directory (tag 5).
  | Close  -- ^ Close a file handle (tag 6).
  | Read  -- ^ Read from a file (tag 7).
  | Write  -- ^ Write to a file (tag 8).
  | Lock  -- ^ Lock a byte range (tag 9).
  | Ioctl  -- ^ Send an I/O control code (tag 10).
  | Cancel  -- ^ Cancel a pending request (tag 11).
  | QueryDirectory  -- ^ List directory contents (tag 12).
  | ChangeNotify  -- ^ Register for change notifications (tag 13).
  | QueryInfo  -- ^ Query file or filesystem information (tag 14).
  | SetInfo  -- ^ Set file or filesystem information (tag 15).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'Command' to its ABI tag value.
commandToTag :: Command -> Word8
commandToTag = fromIntegral . fromEnum

-- | Decode a 'Command' from its ABI tag value.
commandFromTag :: Word8 -> Maybe Command
commandFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: Command)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- | Whether this command is a session/connection management operation.
isSessionManagement :: Command -> Bool
isSessionManagement Negotiate = True
isSessionManagement SessionSetup = True
isSessionManagement Logoff = True
isSessionManagement TreeConnect = True
isSessionManagement TreeDisconnect = True
isSessionManagement _ = False

-- | Whether this command operates on file data.
isFileIo :: Command -> Bool
isFileIo Read = True
isFileIo Write = True
isFileIo Lock = True
isFileIo Ioctl = True
isFileIo _ = False

-- | Whether this command modifies server state.
isWrite :: Command -> Bool
isWrite Create = True
isWrite Write = True
isWrite SetInfo = True
isWrite Lock = True
isWrite _ = False

-- ---------------------------------------------------------------------------
-- Dialect
-- ---------------------------------------------------------------------------

-- | SMB protocol dialect versions (MS-SMB2 Section 3.3.5.4).
--
-- Tags 0-4 (5 constructors).
data Dialect
  = Smb2_0_2  -- ^ SMB 2.0.2 (tag 0).
  | Smb2_1  -- ^ SMB 2.1 (tag 1).
  | Smb3_0  -- ^ SMB 3.0 (tag 2).
  | Smb3_0_2  -- ^ SMB 3.0.2 (tag 3).
  | Smb3_1_1  -- ^ SMB 3.1.1 (tag 4).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'Dialect' to its ABI tag value.
dialectToTag :: Dialect -> Word8
dialectToTag = fromIntegral . fromEnum

-- | Decode a 'Dialect' from its ABI tag value.
dialectFromTag :: Word8 -> Maybe Dialect
dialectFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: Dialect)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- | Whether this dialect supports encryption.
supportsEncryption :: Dialect -> Bool
supportsEncryption Smb3_0 = True
supportsEncryption Smb3_0_2 = True
supportsEncryption Smb3_1_1 = True
supportsEncryption _ = False

-- | Whether this is an SMB3 dialect.
isSmb3 :: Dialect -> Bool
isSmb3 Smb3_0 = True
isSmb3 Smb3_0_2 = True
isSmb3 Smb3_1_1 = True
isSmb3 _ = False

-- | The dialect revision string.
revision :: Dialect -> String
revision Smb2_0_2 = "2.0.2"
revision Smb2_1 = "2.1"
revision Smb3_0 = "3.0"
revision Smb3_0_2 = "3.0.2"
revision Smb3_1_1 = "3.1.1"

-- ---------------------------------------------------------------------------
-- ShareType
-- ---------------------------------------------------------------------------

-- | SMB share types (MS-SMB2 Section 2.2.10).
--
-- Tags 0-2 (3 constructors).
data ShareType
  = Disk  -- ^ Disk share — file system access (tag 0).
  | Pipe  -- ^ Named pipe share — IPC (tag 1).
  | Print  -- ^ Print share — printer access (tag 2).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'ShareType' to its ABI tag value.
shareTypeToTag :: ShareType -> Word8
shareTypeToTag = fromIntegral . fromEnum

-- | Decode a 'ShareType' from its ABI tag value.
shareTypeFromTag :: Word8 -> Maybe ShareType
shareTypeFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: ShareType)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- | Whether this share provides file system access.
isFilesystem :: ShareType -> Bool
isFilesystem Disk = True
isFilesystem _ = False

-- ---------------------------------------------------------------------------
-- SessionState
-- ---------------------------------------------------------------------------

-- | SMB session lifecycle states for the FFI layer.
--
-- Tags 0-5 (6 constructors).
data SessionState
  = Idle  -- ^ No connection established (tag 0).
  | Negotiated  -- ^ Dialect negotiated, session not yet authenticated (tag 1).
  | Authenticated  -- ^ Session authenticated, no tree connections (tag 2).
  | TreeConnected  -- ^ At least one tree connection is active (tag 3).
  | FileOpen  -- ^ At least one file handle is open (tag 4).
  | Disconnecting  -- ^ Connection closing (logoff in progress) (tag 5).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'SessionState' to its ABI tag value.
sessionStateToTag :: SessionState -> Word8
sessionStateToTag = fromIntegral . fromEnum

-- | Decode a 'SessionState' from its ABI tag value.
sessionStateFromTag :: Word8 -> Maybe SessionState
sessionStateFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: SessionState)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- | Whether the session is authenticated (can perform operations).
isAuthenticated :: SessionState -> Bool
isAuthenticated Authenticated = True
isAuthenticated TreeConnected = True
isAuthenticated FileOpen = True
isAuthenticated _ = False

-- | Whether file operations are possible.
canDoFileIo :: SessionState -> Bool
canDoFileIo FileOpen = True
canDoFileIo _ = False
