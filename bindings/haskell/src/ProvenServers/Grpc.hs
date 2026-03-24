-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- | gRPC protocol types for the proven-servers ABI.
--
-- All tag values match the Idris2 ABI discriminants exactly.

module ProvenServers.Grpc
  (
    StatusCode(..)
  , statusCodeToTag
  , statusCodeFromTag
  , isOk
  , StreamType(..)
  , streamTypeToTag
  , streamTypeFromTag
  , isClientStreaming
  , isServerStreaming
  , Compression(..)
  , compressionToTag
  , compressionFromTag
  , GrpcContentType(..)
  , grpcContentTypeToTag
  , grpcContentTypeFromTag
  , contentTypeHeader
  , StreamState(..)
  , streamStateToTag
  , streamStateFromTag
  , canSendData
  , canReceiveData
  , canUpdateWindow
  , isTerminal
  ) where

import Data.Word (Word8)

-- ---------------------------------------------------------------------------
-- StatusCode
-- ---------------------------------------------------------------------------

-- | gRPC status codes per the gRPC specification.
--
-- Tags 0-16 (17 constructors).
data StatusCode
  = Ok  -- ^ The operation completed successfully.
  | Cancelled  -- ^ The operation was cancelled.
  | Unknown  -- ^ Unknown error.
  | InvalidArgument  -- ^ The client specified an invalid argument.
  | DeadlineExceeded  -- ^ The deadline expired before the operation completed.
  | NotFound  -- ^ The requested entity was not found.
  | AlreadyExists  -- ^ The entity that the client attempted to create already exists.
  | PermissionDenied  -- ^ The caller does not have permission.
  | ResourceExhausted  -- ^ Some resource has been exhausted (e.g. per-user quota).
  | FailedPrecondition  -- ^ The system is not in a state required for the operation.
  | Aborted  -- ^ The operation was aborted (e.g. concurrency conflict).
  | OutOfRange  -- ^ The operation was attempted past the valid range.
  | Unimplemented  -- ^ The operation is not implemented or supported.
  | Internal  -- ^ Internal error.
  | Unavailable  -- ^ The service is currently unavailable (transient).
  | DataLoss  -- ^ Unrecoverable data loss or corruption.
  | Unauthenticated  -- ^ The request does not have valid authentication credentials.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'StatusCode' to its ABI tag value.
statusCodeToTag :: StatusCode -> Word8
statusCodeToTag = fromIntegral . fromEnum

-- | Decode a 'StatusCode' from its ABI tag value.
statusCodeFromTag :: Word8 -> Maybe StatusCode
statusCodeFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: StatusCode)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- | Whether this status represents success.
isOk :: StatusCode -> Bool
isOk Ok = True
isOk _ = False

-- ---------------------------------------------------------------------------
-- StreamType
-- ---------------------------------------------------------------------------

-- | gRPC stream cardinality types.
--
-- Tags 0-3 (4 constructors).
data StreamType
  = Unary  -- ^ Single request, single response.
  | ServerStreaming  -- ^ Single request, stream of responses.
  | ClientStreaming  -- ^ Stream of requests, single response.
  | BidiStreaming  -- ^ Bidirectional streaming.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'StreamType' to its ABI tag value.
streamTypeToTag :: StreamType -> Word8
streamTypeToTag = fromIntegral . fromEnum

-- | Decode a 'StreamType' from its ABI tag value.
streamTypeFromTag :: Word8 -> Maybe StreamType
streamTypeFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: StreamType)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- | Whether the client sends a stream of messages.
isClientStreaming :: StreamType -> Bool
isClientStreaming ClientStreaming = True
isClientStreaming BidiStreaming = True
isClientStreaming _ = False

-- | Whether the server sends a stream of messages.
isServerStreaming :: StreamType -> Bool
isServerStreaming ServerStreaming = True
isServerStreaming BidiStreaming = True
isServerStreaming _ = False

-- ---------------------------------------------------------------------------
-- Compression
-- ---------------------------------------------------------------------------

-- | gRPC message compression algorithms.
--
-- Tags 0-4 (5 constructors).
data Compression
  = Identity  -- ^ No compression (identity encoding).
  | Gzip  -- ^ gzip compression.
  | Deflate  -- ^ DEFLATE compression.
  | Snappy  -- ^ Snappy compression.
  | Zstd  -- ^ Zstandard compression.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'Compression' to its ABI tag value.
compressionToTag :: Compression -> Word8
compressionToTag = fromIntegral . fromEnum

-- | Decode a 'Compression' from its ABI tag value.
compressionFromTag :: Word8 -> Maybe Compression
compressionFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: Compression)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- GrpcContentType
-- ---------------------------------------------------------------------------

-- | gRPC content type encodings.
--
-- Tags 0-1 (2 constructors).
data GrpcContentType
  = Protobuf  -- ^ Protocol Buffers (default).
  | Json  -- ^ JSON encoding.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'GrpcContentType' to its ABI tag value.
grpcContentTypeToTag :: GrpcContentType -> Word8
grpcContentTypeToTag = fromIntegral . fromEnum

-- | Decode a 'GrpcContentType' from its ABI tag value.
grpcContentTypeFromTag :: Word8 -> Maybe GrpcContentType
grpcContentTypeFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: GrpcContentType)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- | The gRPC content-type header value.
contentTypeHeader :: GrpcContentType -> String
contentTypeHeader Protobuf = "application/grpc+proto"
contentTypeHeader Json = "application/grpc+json"

-- ---------------------------------------------------------------------------
-- StreamState
-- ---------------------------------------------------------------------------

-- | HTTP/2 stream states (RFC 7540 Section 5.1).
--
-- Tags 0-5 (6 constructors).
data StreamState
  = Idle  -- ^ Stream has not been opened.
  | Open  -- ^ Stream is open in both directions.
  | HalfClosedLocal  -- ^ Local side has sent END_STREAM; remote can still send.
  | HalfClosedRemote  -- ^ Remote side has sent END_STREAM; local can still send.
  | Reserved  -- ^ Reserved via PUSH_PROMISE.
  | Closed  -- ^ Stream is closed (terminal state).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'StreamState' to its ABI tag value.
streamStateToTag :: StreamState -> Word8
streamStateToTag = fromIntegral . fromEnum

-- | Decode a 'StreamState' from its ABI tag value.
streamStateFromTag :: Word8 -> Maybe StreamState
streamStateFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: StreamState)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- | /// Matches `CanSendData` witnesses in `GRPCABI.Transitions`.
canSendData :: StreamState -> Bool
canSendData Open = True
canSendData HalfClosedRemote = True
canSendData _ = False

-- | /// Matches `CanReceiveData` witnesses in `GRPCABI.Transitions`.
canReceiveData :: StreamState -> Bool
canReceiveData Open = True
canReceiveData HalfClosedLocal = True
canReceiveData _ = False

-- | /// Matches `CanUpdateWindow` witnesses in `GRPCABI.Transitions`.
canUpdateWindow :: StreamState -> Bool
canUpdateWindow Open = True
canUpdateWindow HalfClosedLocal = True
canUpdateWindow HalfClosedRemote = True
canUpdateWindow _ = False

-- | `GRPCABI.Transitions`.
isTerminal :: StreamState -> Bool
isTerminal Closed = True
isTerminal _ = False
