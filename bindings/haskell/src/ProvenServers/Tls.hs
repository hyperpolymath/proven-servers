-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- | TLS protocol bindings for proven-servers.
--
-- Wraps the C-ABI functions for TLS handshake and session management.
-- The TLS state machine models the handshake lifecycle (ClientHello ->
-- ServerHello -> ... -> Established) and provides cipher suite and
-- protocol version negotiation.

{-# LANGUAGE ForeignFunctionInterface #-}

module ProvenServers.Tls
  ( -- * ADTs matching Idris2 ABI
    TlsState(..)
  , TlsVersion(..)
  , CipherSuite(..)
    -- * Context lifecycle
  , abiVersion
  , createContext
  , destroyContext
    -- * State queries
  , getState
  , getVersion
  , getCipherSuite
  , isHandshakeComplete
    -- * Handshake operations
  , beginHandshake
  , completeHandshake
  , renegotiate
  , shutdown
    -- * Transition queries
  , canTransition
  ) where

import Data.Word (Word8, Word32)
import Foreign.C.Types (CInt(..))
import ProvenServers.Error (ProvenError, fromSlot, fromStatus)

-- ---------------------------------------------------------------------------
-- ADTs matching Idris2 ABI enums
-- ---------------------------------------------------------------------------

-- | TLS handshake lifecycle states.
data TlsState
  = TlsIdle           -- ^ No handshake initiated.
  | TlsClientHello    -- ^ ClientHello sent\/received.
  | TlsServerHello    -- ^ ServerHello sent\/received.
  | TlsNegotiating    -- ^ Certificate and key exchange in progress.
  | TlsEstablished    -- ^ Handshake complete, secure channel active.
  | TlsRenegotiating  -- ^ Renegotiation in progress.
  | TlsShutdown       -- ^ TLS shutdown (close_notify sent).
  deriving (Show, Eq, Ord, Enum, Bounded)

tlsStateToTag :: TlsState -> Word8
tlsStateToTag = fromIntegral . fromEnum

tlsStateFromTag :: Word8 -> Maybe TlsState
tlsStateFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: TlsState)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- | TLS protocol versions.
data TlsVersion
  = Tls12 -- ^ TLS 1.2 (RFC 5246).
  | Tls13 -- ^ TLS 1.3 (RFC 8446).
  deriving (Show, Eq, Ord, Enum, Bounded)

tlsVersionToTag :: TlsVersion -> Word8
tlsVersionToTag = fromIntegral . fromEnum

tlsVersionFromTag :: Word8 -> Maybe TlsVersion
tlsVersionFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: TlsVersion)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- | TLS cipher suites (subset of common suites).
data CipherSuite
  = AesGcm128Sha256       -- ^ TLS_AES_128_GCM_SHA256.
  | AesGcm256Sha384       -- ^ TLS_AES_256_GCM_SHA384.
  | ChaCha20Poly1305Sha256 -- ^ TLS_CHACHA20_POLY1305_SHA256.
  | AesCcm128Sha256       -- ^ TLS_AES_128_CCM_SHA256.
  deriving (Show, Eq, Ord, Enum, Bounded)

cipherSuiteToTag :: CipherSuite -> Word8
cipherSuiteToTag = fromIntegral . fromEnum

cipherSuiteFromTag :: Word8 -> Maybe CipherSuite
cipherSuiteFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: CipherSuite)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- Foreign imports
-- ---------------------------------------------------------------------------

foreign import ccall unsafe "tls_abi_version"
  c_tls_abi_version :: IO Word32

foreign import ccall unsafe "tls_create_context"
  c_tls_create_context :: Word8 -> Word8 -> IO CInt

foreign import ccall unsafe "tls_destroy_context"
  c_tls_destroy_context :: CInt -> IO ()

foreign import ccall unsafe "tls_state"
  c_tls_state :: CInt -> IO Word8

foreign import ccall unsafe "tls_version"
  c_tls_version :: CInt -> IO Word8

foreign import ccall unsafe "tls_cipher_suite"
  c_tls_cipher_suite :: CInt -> IO Word8

foreign import ccall unsafe "tls_is_handshake_complete"
  c_tls_is_handshake_complete :: CInt -> IO Word8

foreign import ccall unsafe "tls_begin_handshake"
  c_tls_begin_handshake :: CInt -> IO Word8

foreign import ccall unsafe "tls_complete_handshake"
  c_tls_complete_handshake :: CInt -> IO Word8

foreign import ccall unsafe "tls_renegotiate"
  c_tls_renegotiate :: CInt -> IO Word8

foreign import ccall unsafe "tls_shutdown"
  c_tls_shutdown :: CInt -> IO Word8

foreign import ccall unsafe "tls_can_transition"
  c_tls_can_transition :: Word8 -> Word8 -> IO Word8

-- ---------------------------------------------------------------------------
-- Safe wrappers
-- ---------------------------------------------------------------------------

-- | Return the ABI version of the linked TLS library.
abiVersion :: IO Word32
abiVersion = c_tls_abi_version

-- | Create a new TLS context with the given version and cipher suite.
createContext :: TlsVersion -> CipherSuite -> IO (Either ProvenError CInt)
createContext ver suite =
  fromSlot . fromIntegral <$> c_tls_create_context (tlsVersionToTag ver) (cipherSuiteToTag suite)

-- | Destroy a TLS context, releasing its slot.
destroyContext :: CInt -> IO ()
destroyContext = c_tls_destroy_context

-- | Get the current handshake state.
getState :: CInt -> IO (Maybe TlsState)
getState slot = tlsStateFromTag <$> c_tls_state slot

-- | Get the negotiated TLS version.
getVersion :: CInt -> IO (Maybe TlsVersion)
getVersion slot = tlsVersionFromTag <$> c_tls_version slot

-- | Get the negotiated cipher suite.
getCipherSuite :: CInt -> IO (Maybe CipherSuite)
getCipherSuite slot = cipherSuiteFromTag <$> c_tls_cipher_suite slot

-- | Check if the handshake is complete and a secure channel is active.
isHandshakeComplete :: CInt -> IO Bool
isHandshakeComplete slot = (== 1) <$> c_tls_is_handshake_complete slot

-- | Begin the TLS handshake. Transitions Idle -> ClientHello.
beginHandshake :: CInt -> IO (Either ProvenError ())
beginHandshake slot = fromStatus <$> c_tls_begin_handshake slot

-- | Complete the TLS handshake. Transitions Negotiating -> Established.
completeHandshake :: CInt -> IO (Either ProvenError ())
completeHandshake slot = fromStatus <$> c_tls_complete_handshake slot

-- | Initiate renegotiation. Transitions Established -> Renegotiating.
renegotiate :: CInt -> IO (Either ProvenError ())
renegotiate slot = fromStatus <$> c_tls_renegotiate slot

-- | Send close_notify and shut down the TLS session.
shutdown :: CInt -> IO (Either ProvenError ())
shutdown slot = fromStatus <$> c_tls_shutdown slot

-- | Stateless query: check whether a TLS state transition is valid.
canTransition :: TlsState -> TlsState -> IO Bool
canTransition from to =
  (== 1) <$> c_tls_can_transition (tlsStateToTag from) (tlsStateToTag to)
