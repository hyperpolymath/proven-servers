-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- | FTP protocol bindings for proven-servers.
--
-- Wraps the C-ABI functions from @protocols\/proven-ftp\/ffi\/zig\/src\/ftp.zig@.
-- Provides Haskell ADTs for FTP session states and transfer states.

{-# LANGUAGE ForeignFunctionInterface #-}

module ProvenServers.Ftp
  ( -- * ADTs matching Idris2 ABI
    FtpSessionState(..)
  , TransferState(..)
    -- * Context lifecycle
  , abiVersion
  , create
  , destroy
    -- * State queries
  , getState
  , transferType
  , dataMode
  , getTransferState
  , bytesTransferred
  , fileCount
  , lastReplyCode
    -- * Authentication
  , user
  , pass
  , quitSession
    -- * Directory operations
  , changeDir
  , changeDirUp
    -- * Transfer configuration
  , setType
  , setPassive
  , setActive
    -- * Transfer operations
  , beginTransfer
  , addBytes
  , completeTransfer
  , abortTransfer
    -- * Rename operations
  , beginRename
  , completeRename
    -- * Transition queries
  , canTransfer
  , canTransition
  ) where

import Data.Word (Word8, Word16, Word32, Word64)
import Foreign.C.Types (CInt(..))
import Foreign.Ptr (Ptr)
import ProvenServers.Error (ProvenError, fromSlot, fromStatus)

-- ---------------------------------------------------------------------------
-- ADTs matching Idris2 ABI enums
-- ---------------------------------------------------------------------------

-- | FTP session states matching @SessionState@ in ftp.zig.
data FtpSessionState
  = FtpConnected     -- ^ TCP connection established.
  | FtpUserOk        -- ^ USER accepted, password required.
  | FtpAuthenticated -- ^ Fully authenticated.
  | FtpRenaming      -- ^ Rename in progress (RNFR sent).
  | FtpQuit          -- ^ Session ended.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert to ABI tag.
ftpStateToTag :: FtpSessionState -> Word8
ftpStateToTag = fromIntegral . fromEnum

-- | Decode from ABI tag.
ftpStateFromTag :: Word8 -> Maybe FtpSessionState
ftpStateFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: FtpSessionState)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- | FTP transfer states matching @TransferStateTag@ in ftp.zig.
data TransferState
  = TransferIdle       -- ^ No transfer in progress.
  | TransferInProgress -- ^ Transfer active.
  | TransferCompleted  -- ^ Transfer completed successfully.
  | TransferAborted    -- ^ Transfer was aborted.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Decode from ABI tag.
transferStateFromTag :: Word8 -> Maybe TransferState
transferStateFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: TransferState)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- Foreign imports
-- ---------------------------------------------------------------------------

foreign import ccall unsafe "ftp_abi_version"       c_ftp_abi_version       :: IO Word32
foreign import ccall unsafe "ftp_create"            c_ftp_create            :: IO CInt
foreign import ccall unsafe "ftp_destroy"           c_ftp_destroy           :: CInt -> IO ()
foreign import ccall unsafe "ftp_state"             c_ftp_state             :: CInt -> IO Word8
foreign import ccall unsafe "ftp_transfer_type"     c_ftp_transfer_type     :: CInt -> IO Word8
foreign import ccall unsafe "ftp_data_mode"         c_ftp_data_mode         :: CInt -> IO Word8
foreign import ccall unsafe "ftp_transfer_state"    c_ftp_transfer_state    :: CInt -> IO Word8
foreign import ccall unsafe "ftp_bytes_transferred" c_ftp_bytes_transferred :: CInt -> IO Word64
foreign import ccall unsafe "ftp_file_count"        c_ftp_file_count        :: CInt -> IO Word32
foreign import ccall unsafe "ftp_last_reply_code"   c_ftp_last_reply_code   :: CInt -> IO Word16
foreign import ccall unsafe "ftp_user"              c_ftp_user              :: CInt -> Ptr Word8 -> Word32 -> IO Word8
foreign import ccall unsafe "ftp_pass"              c_ftp_pass              :: CInt -> Ptr Word8 -> Word32 -> IO Word8
foreign import ccall unsafe "ftp_quit"              c_ftp_quit              :: CInt -> IO Word8
foreign import ccall unsafe "ftp_cwd_cmd"           c_ftp_cwd_cmd           :: CInt -> Ptr Word8 -> Word32 -> IO Word8
foreign import ccall unsafe "ftp_cdup"              c_ftp_cdup              :: CInt -> IO Word8
foreign import ccall unsafe "ftp_set_type"          c_ftp_set_type          :: CInt -> Word8 -> IO Word8
foreign import ccall unsafe "ftp_set_passive"       c_ftp_set_passive       :: CInt -> IO Word8
foreign import ccall unsafe "ftp_set_active"        c_ftp_set_active        :: CInt -> Word16 -> IO Word8
foreign import ccall unsafe "ftp_begin_transfer"    c_ftp_begin_transfer    :: CInt -> IO Word8
foreign import ccall unsafe "ftp_add_bytes"         c_ftp_add_bytes         :: CInt -> Word64 -> IO Word8
foreign import ccall unsafe "ftp_complete_transfer" c_ftp_complete_transfer :: CInt -> IO Word8
foreign import ccall unsafe "ftp_abort_transfer"    c_ftp_abort_transfer    :: CInt -> IO Word8
foreign import ccall unsafe "ftp_begin_rename"      c_ftp_begin_rename      :: CInt -> IO Word8
foreign import ccall unsafe "ftp_complete_rename"   c_ftp_complete_rename   :: CInt -> IO Word8
foreign import ccall unsafe "ftp_can_transfer"      c_ftp_can_transfer      :: Word8 -> IO Word8
foreign import ccall unsafe "ftp_can_transition"    c_ftp_can_transition    :: Word8 -> Word8 -> IO Word8

-- ---------------------------------------------------------------------------
-- Safe wrappers
-- ---------------------------------------------------------------------------

-- | Return the ABI version.
abiVersion :: IO Word32
abiVersion = c_ftp_abi_version

-- | Create a new FTP session in the Connected state.
create :: IO (Either ProvenError CInt)
create = fromSlot . fromIntegral <$> c_ftp_create

-- | Destroy an FTP context, releasing its slot.
destroy :: CInt -> IO ()
destroy = c_ftp_destroy

-- | Get the current session state.
getState :: CInt -> IO (Maybe FtpSessionState)
getState slot = ftpStateFromTag <$> c_ftp_state slot

-- | Get the transfer type tag (0=ASCII, 1=binary).
transferType :: CInt -> IO Word8
transferType = c_ftp_transfer_type

-- | Get the data mode tag (0=active, 1=passive, 255=unset).
dataMode :: CInt -> IO Word8
dataMode = c_ftp_data_mode

-- | Get the transfer state.
getTransferState :: CInt -> IO (Maybe TransferState)
getTransferState slot = transferStateFromTag <$> c_ftp_transfer_state slot

-- | Get bytes transferred in the current\/last transfer.
bytesTransferred :: CInt -> IO Word64
bytesTransferred = c_ftp_bytes_transferred

-- | Get total file count.
fileCount :: CInt -> IO Word32
fileCount = c_ftp_file_count

-- | Get the last FTP numeric reply code (e.g. 220, 331, 230).
lastReplyCode :: CInt -> IO Word16
lastReplyCode = c_ftp_last_reply_code

-- | USER command. Transitions Connected -> UserOk.
user :: CInt -> Ptr Word8 -> Word32 -> IO (Either ProvenError ())
user slot namePtr nameLen = fromStatus <$> c_ftp_user slot namePtr nameLen

-- | PASS command. Transitions UserOk -> Authenticated.
pass :: CInt -> Ptr Word8 -> Word32 -> IO (Either ProvenError ())
pass slot passPtr passLen = fromStatus <$> c_ftp_pass slot passPtr passLen

-- | QUIT command.
quitSession :: CInt -> IO (Either ProvenError ())
quitSession slot = fromStatus <$> c_ftp_quit slot

-- | CWD command. Changes directory.
changeDir :: CInt -> Ptr Word8 -> Word32 -> IO (Either ProvenError ())
changeDir slot pathPtr pathLen = fromStatus <$> c_ftp_cwd_cmd slot pathPtr pathLen

-- | CDUP command. Changes to parent directory.
changeDirUp :: CInt -> IO (Either ProvenError ())
changeDirUp slot = fromStatus <$> c_ftp_cdup slot

-- | TYPE command. Sets transfer type (0=ASCII, 1=binary).
setType :: CInt -> Word8 -> IO (Either ProvenError ())
setType slot typeTag = fromStatus <$> c_ftp_set_type slot typeTag

-- | PASV command. Sets passive data mode.
setPassive :: CInt -> IO (Either ProvenError ())
setPassive slot = fromStatus <$> c_ftp_set_passive slot

-- | PORT command. Sets active data mode with the given port.
setActive :: CInt -> Word16 -> IO (Either ProvenError ())
setActive slot port = fromStatus <$> c_ftp_set_active slot port

-- | Begin a data transfer.
beginTransfer :: CInt -> IO (Either ProvenError ())
beginTransfer slot = fromStatus <$> c_ftp_begin_transfer slot

-- | Add bytes to the transfer counter.
addBytes :: CInt -> Word64 -> IO (Either ProvenError ())
addBytes slot count = fromStatus <$> c_ftp_add_bytes slot count

-- | Complete a data transfer.
completeTransfer :: CInt -> IO (Either ProvenError ())
completeTransfer slot = fromStatus <$> c_ftp_complete_transfer slot

-- | Abort a data transfer.
abortTransfer :: CInt -> IO (Either ProvenError ())
abortTransfer slot = fromStatus <$> c_ftp_abort_transfer slot

-- | RNFR: begin rename operation. Transitions Authenticated -> Renaming.
beginRename :: CInt -> IO (Either ProvenError ())
beginRename slot = fromStatus <$> c_ftp_begin_rename slot

-- | RNTO: complete rename operation. Transitions Renaming -> Authenticated.
completeRename :: CInt -> IO (Either ProvenError ())
completeRename slot = fromStatus <$> c_ftp_complete_rename slot

-- | Stateless query: check if transfers are allowed from the given state.
canTransfer :: FtpSessionState -> IO Bool
canTransfer st = (== 1) <$> c_ftp_can_transfer (ftpStateToTag st)

-- | Stateless query: check whether a session state transition is valid.
canTransition :: FtpSessionState -> FtpSessionState -> IO Bool
canTransition from to =
  (== 1) <$> c_ftp_can_transition (ftpStateToTag from) (ftpStateToTag to)
