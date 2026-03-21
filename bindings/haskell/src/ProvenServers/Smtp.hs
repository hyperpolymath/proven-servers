-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- | SMTP protocol bindings for proven-servers.
--
-- Wraps the C-ABI functions from @protocols\/proven-smtp\/ffi\/zig\/src\/smtp.zig@.
-- Provides Haskell ADTs for SMTP session states and AUTH mechanisms.

{-# LANGUAGE ForeignFunctionInterface #-}

module ProvenServers.Smtp
  ( -- * ADTs matching Idris2 ABI
    SmtpSessionState(..)
  , AuthMechanism(..)
    -- * Context lifecycle
  , abiVersion
  , createContext
  , destroyContext
    -- * State queries
  , getState
  , getReplyCode
  , getRecipientCount
  , getDataSize
  , getAuthMechanism
  , isAuthenticated
  , isTlsActive
    -- * Session commands
  , greet
  , authenticate
  , authComplete
  , setSender
  , addRecipient
  , startData
  , appendData
  , finishData
  , reset
  , quit
  , enableTls
    -- * Transition queries
  , canTransition
  ) where

import Data.Word (Word8, Word32)
import Foreign.C.Types (CInt(..))
import ProvenServers.Error (ProvenError, fromSlot, fromStatus)

-- ---------------------------------------------------------------------------
-- ADTs matching Idris2 ABI enums
-- ---------------------------------------------------------------------------

-- | SMTP session states matching the Zig FFI.
data SmtpSessionState
  = SmtpConnected      -- ^ TCP connection established.
  | SmtpGreeted        -- ^ HELO/EHLO completed.
  | SmtpAuthStarted    -- ^ AUTH exchange in progress.
  | SmtpAuthenticated  -- ^ Successfully authenticated.
  | SmtpMailFrom       -- ^ MAIL FROM accepted.
  | SmtpRcptTo         -- ^ RCPT TO accepted (at least one recipient).
  | SmtpData           -- ^ DATA transfer in progress.
  | SmtpMessageReceived -- ^ End-of-data received.
  | SmtpQuit           -- ^ Session ended.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert to ABI tag.
smtpStateToTag :: SmtpSessionState -> Word8
smtpStateToTag = fromIntegral . fromEnum

-- | Decode from ABI tag.
smtpStateFromTag :: Word8 -> Maybe SmtpSessionState
smtpStateFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: SmtpSessionState)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- | SMTP AUTH mechanisms.
data AuthMechanism
  = AuthPlain     -- ^ PLAIN mechanism.
  | AuthLogin     -- ^ LOGIN mechanism.
  | AuthCramMd5   -- ^ CRAM-MD5 mechanism.
  | AuthXOAuth2   -- ^ XOAUTH2 mechanism.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert to ABI tag.
authMechToTag :: AuthMechanism -> Word8
authMechToTag = fromIntegral . fromEnum

-- | Decode from ABI tag.
authMechFromTag :: Word8 -> Maybe AuthMechanism
authMechFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: AuthMechanism)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- Foreign imports
-- ---------------------------------------------------------------------------

foreign import ccall unsafe "smtp_abi_version"       c_smtp_abi_version       :: IO Word32
foreign import ccall unsafe "smtp_create_context"    c_smtp_create_context    :: IO CInt
foreign import ccall unsafe "smtp_destroy_context"   c_smtp_destroy_context   :: CInt -> IO ()
foreign import ccall unsafe "smtp_get_state"         c_smtp_get_state         :: CInt -> IO Word8
foreign import ccall unsafe "smtp_get_reply_code"    c_smtp_get_reply_code    :: CInt -> IO Word8
foreign import ccall unsafe "smtp_get_recipient_count" c_smtp_get_recipient_count :: CInt -> IO Word8
foreign import ccall unsafe "smtp_get_data_size"     c_smtp_get_data_size     :: CInt -> IO Word32
foreign import ccall unsafe "smtp_get_auth_mechanism" c_smtp_get_auth_mechanism :: CInt -> IO Word8
foreign import ccall unsafe "smtp_is_authenticated"  c_smtp_is_authenticated  :: CInt -> IO Word8
foreign import ccall unsafe "smtp_is_tls_active"     c_smtp_is_tls_active     :: CInt -> IO Word8
foreign import ccall unsafe "smtp_greet"             c_smtp_greet             :: CInt -> Word8 -> IO Word8
foreign import ccall unsafe "smtp_authenticate"      c_smtp_authenticate      :: CInt -> Word8 -> IO Word8
foreign import ccall unsafe "smtp_auth_complete"     c_smtp_auth_complete     :: CInt -> Word8 -> IO Word8
foreign import ccall unsafe "smtp_set_sender"        c_smtp_set_sender        :: CInt -> IO Word8
foreign import ccall unsafe "smtp_add_recipient"     c_smtp_add_recipient     :: CInt -> IO Word8
foreign import ccall unsafe "smtp_start_data"        c_smtp_start_data        :: CInt -> IO Word8
foreign import ccall unsafe "smtp_append_data"       c_smtp_append_data       :: CInt -> Word32 -> IO Word8
foreign import ccall unsafe "smtp_finish_data"       c_smtp_finish_data       :: CInt -> IO Word8
foreign import ccall unsafe "smtp_reset"             c_smtp_reset             :: CInt -> IO Word8
foreign import ccall unsafe "smtp_quit"              c_smtp_quit              :: CInt -> IO Word8
foreign import ccall unsafe "smtp_enable_tls"        c_smtp_enable_tls        :: CInt -> IO Word8
foreign import ccall unsafe "smtp_can_transition"    c_smtp_can_transition    :: Word8 -> Word8 -> IO Word8

-- ---------------------------------------------------------------------------
-- Safe wrappers
-- ---------------------------------------------------------------------------

-- | Return the ABI version of the linked SMTP library.
abiVersion :: IO Word32
abiVersion = c_smtp_abi_version

-- | Create a new SMTP session in the Connected state.
createContext :: IO (Either ProvenError CInt)
createContext = fromSlot . fromIntegral <$> c_smtp_create_context

-- | Destroy an SMTP context, releasing its slot.
destroyContext :: CInt -> IO ()
destroyContext = c_smtp_destroy_context

-- | Get the current session state.
getState :: CInt -> IO (Maybe SmtpSessionState)
getState slot = smtpStateFromTag <$> c_smtp_get_state slot

-- | Get the last reply code tag (0-16, maps to ReplyCode).
getReplyCode :: CInt -> IO Word8
getReplyCode = c_smtp_get_reply_code

-- | Get the number of recipients in the current transaction.
getRecipientCount :: CInt -> IO Word8
getRecipientCount = c_smtp_get_recipient_count

-- | Get the accumulated message data size in bytes.
getDataSize :: CInt -> IO Word32
getDataSize = c_smtp_get_data_size

-- | Get the current AUTH mechanism (Nothing if unset).
getAuthMechanism :: CInt -> IO (Maybe AuthMechanism)
getAuthMechanism slot = authMechFromTag <$> c_smtp_get_auth_mechanism slot

-- | Check if the session is authenticated.
isAuthenticated :: CInt -> IO Bool
isAuthenticated slot = (== 1) <$> c_smtp_is_authenticated slot

-- | Check if TLS is active.
isTlsActive :: CInt -> IO Bool
isTlsActive slot = (== 1) <$> c_smtp_is_tls_active slot

-- | HELO\/EHLO: greet the server. @ehlo@ selects EHLO (True) vs HELO (False).
greet :: CInt -> Bool -> IO (Either ProvenError ())
greet slot ehlo = fromStatus <$> c_smtp_greet slot (if ehlo then 1 else 0)

-- | Begin AUTH exchange. Transitions Greeted -> AuthStarted.
authenticate :: CInt -> AuthMechanism -> IO (Either ProvenError ())
authenticate slot mech = fromStatus <$> c_smtp_authenticate slot (authMechToTag mech)

-- | Complete AUTH exchange. @success = True@ transitions to Authenticated.
authComplete :: CInt -> Bool -> IO (Either ProvenError ())
authComplete slot success = fromStatus <$> c_smtp_auth_complete slot (if success then 1 else 0)

-- | MAIL FROM: set the sender.
setSender :: CInt -> IO (Either ProvenError ())
setSender slot = fromStatus <$> c_smtp_set_sender slot

-- | RCPT TO: add a recipient.
addRecipient :: CInt -> IO (Either ProvenError ())
addRecipient slot = fromStatus <$> c_smtp_add_recipient slot

-- | DATA: begin message body transfer.
startData :: CInt -> IO (Either ProvenError ())
startData slot = fromStatus <$> c_smtp_start_data slot

-- | Append data bytes to the message.
appendData :: CInt -> Word32 -> IO (Either ProvenError ())
appendData slot len = fromStatus <$> c_smtp_append_data slot len

-- | Finish data transfer. Transitions Data -> MessageReceived.
finishData :: CInt -> IO (Either ProvenError ())
finishData slot = fromStatus <$> c_smtp_finish_data slot

-- | RSET: reset the mail transaction.
reset :: CInt -> IO (Either ProvenError ())
reset slot = fromStatus <$> c_smtp_reset slot

-- | QUIT: end the session.
quit :: CInt -> IO (Either ProvenError ())
quit slot = fromStatus <$> c_smtp_quit slot

-- | STARTTLS: enable TLS on the connection.
enableTls :: CInt -> IO (Either ProvenError ())
enableTls slot = fromStatus <$> c_smtp_enable_tls slot

-- | Stateless query: check whether a session state transition is valid.
canTransition :: SmtpSessionState -> SmtpSessionState -> IO Bool
canTransition from to =
  (== 1) <$> c_smtp_can_transition (smtpStateToTag from) (smtpStateToTag to)
