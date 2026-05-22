-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- | SSH Bastion protocol bindings for proven-servers.
--
-- Wraps the C-ABI functions from
-- @protocols\/proven-ssh-bastion\/ffi\/zig\/src\/ssh_bastion.zig@.
-- Provides Haskell ADTs for bastion states, key exchange methods,
-- authentication methods, channel types, and disconnect reasons.

{-# LANGUAGE ForeignFunctionInterface #-}

module ProvenServers.SshBastion
  ( -- * ADTs matching Idris2 ABI
    BastionState(..)
  , KexMethod(..)
  , AuthMethod(..)
  , ChannelType(..)
  , ChannelState(..)
  , DisconnectReason(..)
    -- * Context lifecycle
  , abiVersion
  , create
  , destroy
    -- * State queries
  , getState
  , getKexMethod
  , getAuthMethod
  , canTransferData
  , getDisconnectReason
  , authFailures
  , channelCount
    -- * Session operations
  , completeKex
  , authenticate
  , recordAuthFailure
    -- * Channel operations
  , openChannel
  , confirmChannel
  , closeChannel
  , channelState
  , channelType
    -- * Session management
  , rekey
  , disconnect
    -- * Audit
  , auditCount
  , setRecording
  , isRecording
    -- * Transition queries
  , canTransition
  ) where

import Data.Word (Word8, Word16, Word32)
import Foreign.C.Types (CInt(..))
import ProvenServers.Error (ProvenError, fromSlot, fromStatus)

-- ---------------------------------------------------------------------------
-- ADTs matching Idris2 ABI enums
-- ---------------------------------------------------------------------------

-- | SSH bastion lifecycle states.
data BastionState
  = BastionConnected     -- ^ TCP connection established.
  | BastionKeyExchanged  -- ^ Key exchange completed.
  | BastionAuthenticated -- ^ User authenticated.
  | BastionChannelOpen   -- ^ At least one channel opening.
  | BastionActive        -- ^ Session fully active.
  | BastionClosed        -- ^ Session closed.
  deriving (Show, Eq, Ord, Enum, Bounded)

bastionStateToTag :: BastionState -> Word8
bastionStateToTag = fromIntegral . fromEnum

bastionStateFromTag :: Word8 -> Maybe BastionState
bastionStateFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: BastionState)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- | Key exchange methods.
data KexMethod
  = KexCurve25519  -- ^ curve25519-sha256.
  | KexDhGroup14   -- ^ diffie-hellman-group14-sha256.
  | KexDhGroup16   -- ^ diffie-hellman-group16-sha512.
  | KexEcdhP256    -- ^ ecdh-sha2-nistp256.
  | KexEcdhP384    -- ^ ecdh-sha2-nistp384.
  deriving (Show, Eq, Ord, Enum, Bounded)

kexMethodToTag :: KexMethod -> Word8
kexMethodToTag = fromIntegral . fromEnum

-- | Authentication methods.
data AuthMethod
  = AuthPublicKey  -- ^ Public key authentication.
  | AuthPassword   -- ^ Password authentication.
  | AuthKeyboard   -- ^ Keyboard-interactive authentication.
  | AuthCertificate -- ^ Certificate authentication.
  deriving (Show, Eq, Ord, Enum, Bounded)

authMethodToTag :: AuthMethod -> Word8
authMethodToTag = fromIntegral . fromEnum

authMethodFromTag :: Word8 -> Maybe AuthMethod
authMethodFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: AuthMethod)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- | SSH channel types.
data ChannelType
  = ChannelSession      -- ^ Interactive shell session.
  | ChannelDirectTcpIp  -- ^ TCP/IP forwarding.
  | ChannelForwardedTcpIp -- ^ Forwarded TCP/IP.
  | ChannelSubsystem    -- ^ Subsystem (e.g. sftp).
  deriving (Show, Eq, Ord, Enum, Bounded)

channelTypeToTag :: ChannelType -> Word8
channelTypeToTag = fromIntegral . fromEnum

-- | SSH channel states.
data ChannelState
  = ChannelOpening -- ^ Channel opening.
  | ChannelOpen    -- ^ Channel open and active.
  | ChannelClosing -- ^ Channel closing.
  | ChannelClosed  -- ^ Channel closed.
  deriving (Show, Eq, Ord, Enum, Bounded)

channelStateFromTag :: Word8 -> Maybe ChannelState
channelStateFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: ChannelState)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

channelTypeFromTag :: Word8 -> Maybe ChannelType
channelTypeFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: ChannelType)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- | SSH disconnect reasons (RFC 4253).
data DisconnectReason
  = DisconnectHostNotAllowed       -- ^ Host not allowed to connect.
  | DisconnectProtocolError        -- ^ Protocol error.
  | DisconnectKeyExchangeFailed    -- ^ Key exchange failed.
  | DisconnectAuthFailed           -- ^ Authentication failed.
  | DisconnectServiceNotAvailable  -- ^ Service not available.
  | DisconnectByApplication        -- ^ Disconnect by application.
  | DisconnectTooManyConnections   -- ^ Too many connections.
  deriving (Show, Eq, Ord, Enum, Bounded)

disconnectReasonToTag :: DisconnectReason -> Word8
disconnectReasonToTag = fromIntegral . fromEnum

disconnectReasonFromTag :: Word8 -> Maybe DisconnectReason
disconnectReasonFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: DisconnectReason)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- Foreign imports
-- ---------------------------------------------------------------------------

foreign import ccall unsafe "ssh_bastion_abi_version"     c_ssh_bastion_abi_version     :: IO Word32
foreign import ccall unsafe "ssh_bastion_create"          c_ssh_bastion_create          :: Word8 -> Word8 -> IO CInt
foreign import ccall unsafe "ssh_bastion_destroy"         c_ssh_bastion_destroy         :: CInt -> IO ()
foreign import ccall unsafe "ssh_bastion_state"           c_ssh_bastion_state           :: CInt -> IO Word8
foreign import ccall unsafe "ssh_bastion_kex_method"      c_ssh_bastion_kex_method      :: CInt -> IO Word8
foreign import ccall unsafe "ssh_bastion_auth_method"     c_ssh_bastion_auth_method     :: CInt -> IO Word8
foreign import ccall unsafe "ssh_bastion_can_transfer"    c_ssh_bastion_can_transfer    :: CInt -> IO Word8
foreign import ccall unsafe "ssh_bastion_disconnect_reason" c_ssh_bastion_disconnect_reason :: CInt -> IO Word8
foreign import ccall unsafe "ssh_bastion_auth_failures"   c_ssh_bastion_auth_failures   :: CInt -> IO Word8
foreign import ccall unsafe "ssh_bastion_complete_kex"    c_ssh_bastion_complete_kex    :: CInt -> IO Word8
foreign import ccall unsafe "ssh_bastion_authenticate"    c_ssh_bastion_authenticate    :: CInt -> Word16 -> IO Word8
foreign import ccall unsafe "ssh_bastion_record_auth_failure" c_ssh_bastion_record_auth_failure :: CInt -> IO Word8
foreign import ccall unsafe "ssh_bastion_open_channel"    c_ssh_bastion_open_channel    :: CInt -> Word8 -> IO CInt
foreign import ccall unsafe "ssh_bastion_confirm_channel" c_ssh_bastion_confirm_channel :: CInt -> Word8 -> IO Word8
foreign import ccall unsafe "ssh_bastion_close_channel"   c_ssh_bastion_close_channel   :: CInt -> Word8 -> IO Word8
foreign import ccall unsafe "ssh_bastion_channel_state"   c_ssh_bastion_channel_state   :: CInt -> Word8 -> IO Word8
foreign import ccall unsafe "ssh_bastion_channel_type"    c_ssh_bastion_channel_type    :: CInt -> Word8 -> IO Word8
foreign import ccall unsafe "ssh_bastion_channel_count"   c_ssh_bastion_channel_count   :: CInt -> IO Word8
foreign import ccall unsafe "ssh_bastion_rekey"           c_ssh_bastion_rekey           :: CInt -> IO Word8
foreign import ccall unsafe "ssh_bastion_disconnect"      c_ssh_bastion_disconnect      :: CInt -> Word8 -> IO Word8
foreign import ccall unsafe "ssh_bastion_can_transition"  c_ssh_bastion_can_transition  :: Word8 -> Word8 -> IO Word8
foreign import ccall unsafe "ssh_bastion_audit_count"     c_ssh_bastion_audit_count     :: CInt -> IO Word32
foreign import ccall unsafe "ssh_bastion_set_recording"   c_ssh_bastion_set_recording   :: CInt -> Word8 -> IO Word8
foreign import ccall unsafe "ssh_bastion_is_recording"    c_ssh_bastion_is_recording    :: CInt -> IO Word8

-- ---------------------------------------------------------------------------
-- Safe wrappers
-- ---------------------------------------------------------------------------

-- | Return the ABI version.
abiVersion :: IO Word32
abiVersion = c_ssh_bastion_abi_version

-- | Create a new SSH bastion session with the given key exchange and auth methods.
create :: KexMethod -> AuthMethod -> IO (Either ProvenError CInt)
create kex auth =
  fromSlot . fromIntegral <$> c_ssh_bastion_create (kexMethodToTag kex) (authMethodToTag auth)

-- | Destroy an SSH bastion context, releasing its slot.
destroy :: CInt -> IO ()
destroy = c_ssh_bastion_destroy

-- | Get the current bastion state.
getState :: CInt -> IO (Maybe BastionState)
getState slot = bastionStateFromTag <$> c_ssh_bastion_state slot

-- | Get the configured key exchange method.
getKexMethod :: CInt -> IO (Maybe KexMethod)
getKexMethod slot = do
  tag <- c_ssh_bastion_kex_method slot
  pure $ if tag <= fromIntegral (fromEnum (maxBound :: KexMethod))
         then Just (toEnum (fromIntegral tag))
         else Nothing

-- | Get the configured authentication method.
getAuthMethod :: CInt -> IO (Maybe AuthMethod)
getAuthMethod slot = authMethodFromTag <$> c_ssh_bastion_auth_method slot

-- | Check if data transfer is allowed (session must be Active).
canTransferData :: CInt -> IO Bool
canTransferData slot = (== 1) <$> c_ssh_bastion_can_transfer slot

-- | Get the disconnect reason (Nothing if not disconnected).
getDisconnectReason :: CInt -> IO (Maybe DisconnectReason)
getDisconnectReason slot = disconnectReasonFromTag <$> c_ssh_bastion_disconnect_reason slot

-- | Get the number of failed auth attempts.
authFailures :: CInt -> IO Word8
authFailures = c_ssh_bastion_auth_failures

-- | Complete key exchange. Transitions Connected -> KeyExchanged.
completeKex :: CInt -> IO (Either ProvenError ())
completeKex slot = fromStatus <$> c_ssh_bastion_complete_kex slot

-- | Authenticate the user. Transitions KeyExchanged -> Authenticated.
authenticate :: CInt -> IO (Either ProvenError ())
authenticate slot = fromStatus <$> c_ssh_bastion_authenticate slot 0

-- | Record a failed auth attempt. Returns @True@ if locked out (3+ failures).
recordAuthFailure :: CInt -> IO Bool
recordAuthFailure slot = (== 1) <$> c_ssh_bastion_record_auth_failure slot

-- | Open a channel. Returns the channel ID (0-9).
openChannel :: CInt -> ChannelType -> IO (Either ProvenError Word8)
openChannel slot chType = do
  chId <- c_ssh_bastion_open_channel slot (channelTypeToTag chType)
  case fromSlot (fromIntegral chId) of
    Left err -> pure (Left err)
    Right i  -> pure (Right (fromIntegral i))

-- | Confirm a channel (Opening -> Open).
confirmChannel :: CInt -> Word8 -> IO (Either ProvenError ())
confirmChannel slot chId = fromStatus <$> c_ssh_bastion_confirm_channel slot chId

-- | Close a specific channel.
closeChannel :: CInt -> Word8 -> IO (Either ProvenError ())
closeChannel slot chId = fromStatus <$> c_ssh_bastion_close_channel slot chId

-- | Get the state of a specific channel.
channelState :: CInt -> Word8 -> IO (Maybe ChannelState)
channelState slot chId = channelStateFromTag <$> c_ssh_bastion_channel_state slot chId

-- | Get the type of a specific channel.
channelType :: CInt -> Word8 -> IO (Maybe ChannelType)
channelType slot chId = channelTypeFromTag <$> c_ssh_bastion_channel_type slot chId

-- | Get the count of active (non-closed) channels.
channelCount :: CInt -> IO Word8
channelCount = c_ssh_bastion_channel_count

-- | Re-key the session. Only valid in Active state.
rekey :: CInt -> IO (Either ProvenError ())
rekey slot = fromStatus <$> c_ssh_bastion_rekey slot

-- | Disconnect with a reason.
disconnect :: CInt -> DisconnectReason -> IO (Either ProvenError ())
disconnect slot reason = fromStatus <$> c_ssh_bastion_disconnect slot (disconnectReasonToTag reason)

-- | Stateless query: check whether a bastion state transition is valid.
canTransition :: BastionState -> BastionState -> IO Bool
canTransition from to =
  (== 1) <$> c_ssh_bastion_can_transition (bastionStateToTag from) (bastionStateToTag to)

-- | Get the number of audit log entries.
auditCount :: CInt -> IO Word32
auditCount = c_ssh_bastion_audit_count

-- | Enable or disable session recording.
setRecording :: CInt -> Bool -> IO (Either ProvenError ())
setRecording slot enabled = fromStatus <$> c_ssh_bastion_set_recording slot (if enabled then 1 else 0)

-- | Check whether session recording is active.
isRecording :: CInt -> IO Bool
isRecording slot = (== 1) <$> c_ssh_bastion_is_recording slot
