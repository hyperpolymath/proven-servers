-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- | gRPC protocol bindings for proven-servers.
--
-- Wraps the C-ABI functions from @protocols\/proven-grpc\/ffi\/zig\/src\/grpc.zig@.
-- Provides Haskell ADTs for HTTP\/2 stream states, gRPC status codes,
-- and compression algorithms.

{-# LANGUAGE ForeignFunctionInterface #-}

module ProvenServers.Grpc
  ( -- * ADTs matching Idris2 ABI
    StreamState(..)
  , GrpcStatusCode(..)
  , Compression(..)
    -- * Context lifecycle
  , abiVersion
  , create
  , destroy
    -- * State queries
  , streamState
  , compression
  , statusCode
  , streamId
  , canSend
  , canReceive
  , sendWindow
  , recvWindow
    -- * Stream operations
  , setStatus
  , sendHeaders
  , localEndStream
  , remoteEndStream
  , resetStream
  , closeHalfLocal
  , closeHalfRemote
  , pushPromise
  , reservedToHalf
    -- * Flow control
  , updateSendWindow
  , updateRecvWindow
    -- * Transition queries
  , canTransition
  ) where

import Data.Int (Int32)
import Data.Word (Word8, Word32)
import Foreign.C.Types (CInt(..))
import ProvenServers.Error (ProvenError, fromSlot, fromStatus)

-- ---------------------------------------------------------------------------
-- ADTs matching Idris2 ABI enums
-- ---------------------------------------------------------------------------

-- | HTTP/2 stream states (RFC 7540 Section 5.1).
data StreamState
  = StreamIdle             -- ^ Stream not yet started.
  | StreamReserved         -- ^ Reserved via PUSH_PROMISE.
  | StreamOpen             -- ^ Stream open, data flowing.
  | StreamHalfClosedLocal  -- ^ Local side closed (END_STREAM sent).
  | StreamHalfClosedRemote -- ^ Remote side closed (END_STREAM received).
  | StreamClosed           -- ^ Stream fully closed.
  deriving (Show, Eq, Ord, Enum, Bounded)

streamStateToTag :: StreamState -> Word8
streamStateToTag = fromIntegral . fromEnum

streamStateFromTag :: Word8 -> Maybe StreamState
streamStateFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: StreamState)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- | gRPC status codes (matching grpc.zig).
data GrpcStatusCode
  = GrpcOk | GrpcCancelled | GrpcUnknown | GrpcInvalidArgument
  | GrpcDeadlineExceeded | GrpcNotFound | GrpcAlreadyExists
  | GrpcPermissionDenied | GrpcResourceExhausted | GrpcFailedPrecondition
  | GrpcAborted | GrpcOutOfRange | GrpcUnimplemented | GrpcInternal
  | GrpcUnavailable | GrpcDataLoss | GrpcUnauthenticated
  deriving (Show, Eq, Ord, Enum, Bounded)

grpcStatusToCode :: GrpcStatusCode -> Word8
grpcStatusToCode = fromIntegral . fromEnum

grpcStatusFromCode :: Word8 -> Maybe GrpcStatusCode
grpcStatusFromCode n
  | n <= fromIntegral (fromEnum (maxBound :: GrpcStatusCode)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- | Compression algorithms for gRPC.
data Compression
  = CompNone   -- ^ No compression.
  | CompGzip   -- ^ gzip compression.
  | CompDeflate -- ^ deflate compression.
  deriving (Show, Eq, Ord, Enum, Bounded)

compressionToTag :: Compression -> Word8
compressionToTag = fromIntegral . fromEnum

-- ---------------------------------------------------------------------------
-- Foreign imports
-- ---------------------------------------------------------------------------

foreign import ccall unsafe "grpc_abi_version"        c_grpc_abi_version        :: IO Word32
foreign import ccall unsafe "grpc_create"             c_grpc_create             :: Word8 -> IO CInt
foreign import ccall unsafe "grpc_destroy"            c_grpc_destroy            :: CInt -> IO ()
foreign import ccall unsafe "grpc_stream_state"       c_grpc_stream_state       :: CInt -> IO Word8
foreign import ccall unsafe "grpc_compression"        c_grpc_compression        :: CInt -> IO Word8
foreign import ccall unsafe "grpc_status_code"        c_grpc_status_code        :: CInt -> IO Word8
foreign import ccall unsafe "grpc_set_status"         c_grpc_set_status         :: CInt -> Word8 -> IO Word8
foreign import ccall unsafe "grpc_stream_id"          c_grpc_stream_id          :: CInt -> IO Word32
foreign import ccall unsafe "grpc_send_headers"       c_grpc_send_headers       :: CInt -> IO Word8
foreign import ccall unsafe "grpc_local_end_stream"   c_grpc_local_end_stream   :: CInt -> IO Word8
foreign import ccall unsafe "grpc_remote_end_stream"  c_grpc_remote_end_stream  :: CInt -> IO Word8
foreign import ccall unsafe "grpc_reset_stream"       c_grpc_reset_stream       :: CInt -> Word8 -> IO Word8
foreign import ccall unsafe "grpc_close_half_local"   c_grpc_close_half_local   :: CInt -> IO Word8
foreign import ccall unsafe "grpc_close_half_remote"  c_grpc_close_half_remote  :: CInt -> IO Word8
foreign import ccall unsafe "grpc_push_promise"       c_grpc_push_promise       :: CInt -> IO Word8
foreign import ccall unsafe "grpc_reserved_to_half"   c_grpc_reserved_to_half   :: CInt -> IO Word8
foreign import ccall unsafe "grpc_can_send"           c_grpc_can_send           :: CInt -> IO Word8
foreign import ccall unsafe "grpc_can_receive"        c_grpc_can_receive        :: CInt -> IO Word8
foreign import ccall unsafe "grpc_send_window"        c_grpc_send_window        :: CInt -> IO Int32
foreign import ccall unsafe "grpc_recv_window"        c_grpc_recv_window        :: CInt -> IO Int32
foreign import ccall unsafe "grpc_update_send_window" c_grpc_update_send_window :: CInt -> Int32 -> IO Word8
foreign import ccall unsafe "grpc_update_recv_window" c_grpc_update_recv_window :: CInt -> Int32 -> IO Word8
foreign import ccall unsafe "grpc_can_transition"     c_grpc_can_transition     :: Word8 -> Word8 -> IO Word8

-- ---------------------------------------------------------------------------
-- Safe wrappers
-- ---------------------------------------------------------------------------

-- | Return the ABI version.
abiVersion :: IO Word32
abiVersion = c_grpc_abi_version

-- | Create a new gRPC stream context with the given compression algorithm.
create :: Compression -> IO (Either ProvenError CInt)
create comp = fromSlot . fromIntegral <$> c_grpc_create (compressionToTag comp)

-- | Destroy a gRPC context.
destroy :: CInt -> IO ()
destroy = c_grpc_destroy

-- | Get the current HTTP\/2 stream state.
streamState :: CInt -> IO (Maybe StreamState)
streamState slot = streamStateFromTag <$> c_grpc_stream_state slot

-- | Get the compression algorithm tag.
compression :: CInt -> IO Word8
compression = c_grpc_compression

-- | Get the gRPC status code.
statusCode :: CInt -> IO (Maybe GrpcStatusCode)
statusCode slot = grpcStatusFromCode <$> c_grpc_status_code slot

-- | Set the gRPC status code.
setStatus :: CInt -> GrpcStatusCode -> IO (Either ProvenError ())
setStatus slot status = fromStatus <$> c_grpc_set_status slot (grpcStatusToCode status)

-- | Get the HTTP\/2 stream ID.
streamId :: CInt -> IO Word32
streamId = c_grpc_stream_id

-- | Send HEADERS frame. Transitions Idle -> Open.
sendHeaders :: CInt -> IO (Either ProvenError ())
sendHeaders slot = fromStatus <$> c_grpc_send_headers slot

-- | Local END_STREAM. Transitions Open -> HalfClosedLocal.
localEndStream :: CInt -> IO (Either ProvenError ())
localEndStream slot = fromStatus <$> c_grpc_local_end_stream slot

-- | Remote END_STREAM. Transitions Open -> HalfClosedRemote.
remoteEndStream :: CInt -> IO (Either ProvenError ())
remoteEndStream slot = fromStatus <$> c_grpc_remote_end_stream slot

-- | RST_STREAM. Transitions Open -> Closed with the given status code.
resetStream :: CInt -> GrpcStatusCode -> IO (Either ProvenError ())
resetStream slot status = fromStatus <$> c_grpc_reset_stream slot (grpcStatusToCode status)

-- | Close from HalfClosedLocal -> Closed.
closeHalfLocal :: CInt -> IO (Either ProvenError ())
closeHalfLocal slot = fromStatus <$> c_grpc_close_half_local slot

-- | Close from HalfClosedRemote -> Closed.
closeHalfRemote :: CInt -> IO (Either ProvenError ())
closeHalfRemote slot = fromStatus <$> c_grpc_close_half_remote slot

-- | PUSH_PROMISE. Transitions Idle -> Reserved.
pushPromise :: CInt -> IO (Either ProvenError ())
pushPromise slot = fromStatus <$> c_grpc_push_promise slot

-- | Reserved -> HalfClosedRemote (server sends HEADERS on push).
reservedToHalf :: CInt -> IO (Either ProvenError ())
reservedToHalf slot = fromStatus <$> c_grpc_reserved_to_half slot

-- | Check if DATA frames can be sent from this state.
canSend :: CInt -> IO Bool
canSend slot = (== 1) <$> c_grpc_can_send slot

-- | Check if DATA frames can be received in this state.
canReceive :: CInt -> IO Bool
canReceive slot = (== 1) <$> c_grpc_can_receive slot

-- | Get the send-side flow control window.
sendWindow :: CInt -> IO Int32
sendWindow = c_grpc_send_window

-- | Get the receive-side flow control window.
recvWindow :: CInt -> IO Int32
recvWindow = c_grpc_recv_window

-- | Update the send-side flow control window by @delta@.
updateSendWindow :: CInt -> Int32 -> IO (Either ProvenError ())
updateSendWindow slot delta = fromStatus <$> c_grpc_update_send_window slot delta

-- | Update the receive-side flow control window by @delta@.
updateRecvWindow :: CInt -> Int32 -> IO (Either ProvenError ())
updateRecvWindow slot delta = fromStatus <$> c_grpc_update_recv_window slot delta

-- | Stateless query: check whether a stream state transition is valid.
canTransition :: StreamState -> StreamState -> IO Bool
canTransition from to =
  (== 1) <$> c_grpc_can_transition (streamStateToTag from) (streamStateToTag to)
