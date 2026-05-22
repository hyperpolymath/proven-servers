-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- | gRPC protocol types for proven-servers.
--
-- gRPC protocol types, mirroring the Idris2 ABI.
-- All tag values match the Idris2 ABI discriminants exactly.
--
-- This is a pure type-definition module with no FFI dependencies.

module ProvenServers.GrpcTypes
  ( -- * ADT types matching Idris2 ABI
      StatusCode(..)
    , StreamType(..)
    , Compression(..)
    , GrpcContentType(..)
    , StreamState(..)
    , statusCodeToTag
    , statusCodeFromTag
    , streamTypeToTag
    , streamTypeFromTag
    , compressionToTag
    , compressionFromTag
    , grpcContentTypeToTag
    , grpcContentTypeFromTag
    , streamStateToTag
    , streamStateFromTag
  ) where

import Data.Word (Word8)

-- ---------------------------------------------------------------------------
-- StatusCode
-- ---------------------------------------------------------------------------

-- | StatusCode type matching the Idris2 ABI.
--
-- Tags 0-16 (17 constructors).
data StatusCode
  = Ok  -- ^ Tag 0.
  | Cancelled  -- ^ Tag 1.
  | Unknown  -- ^ Tag 2.
  | InvalidArgument  -- ^ Tag 3.
  | DeadlineExceeded  -- ^ Tag 4.
  | NotFound  -- ^ Tag 5.
  | AlreadyExists  -- ^ Tag 6.
  | PermissionDenied  -- ^ Tag 7.
  | ResourceExhausted  -- ^ Tag 8.
  | FailedPrecondition  -- ^ Tag 9.
  | Aborted  -- ^ Tag 10.
  | OutOfRange  -- ^ Tag 11.
  | Unimplemented  -- ^ Tag 12.
  | Internal  -- ^ Tag 13.
  | Unavailable  -- ^ Tag 14.
  | DataLoss  -- ^ Tag 15.
  | Unauthenticated  -- ^ Tag 16.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'StatusCode' to its ABI tag value.
statusCodeToTag :: StatusCode -> Word8
statusCodeToTag = fromIntegral . fromEnum

-- | Decode a 'StatusCode' from its ABI tag value.
statusCodeFromTag :: Word8 -> Maybe StatusCode
statusCodeFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: StatusCode)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- StreamType
-- ---------------------------------------------------------------------------

-- | StreamType type matching the Idris2 ABI.
--
-- Tags 0-3 (4 constructors).
data StreamType
  = Unary  -- ^ Tag 0.
  | ServerStreaming  -- ^ Tag 1.
  | ClientStreaming  -- ^ Tag 2.
  | BidiStreaming  -- ^ Tag 3.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'StreamType' to its ABI tag value.
streamTypeToTag :: StreamType -> Word8
streamTypeToTag = fromIntegral . fromEnum

-- | Decode a 'StreamType' from its ABI tag value.
streamTypeFromTag :: Word8 -> Maybe StreamType
streamTypeFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: StreamType)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- Compression
-- ---------------------------------------------------------------------------

-- | Compression type matching the Idris2 ABI.
--
-- Tags 0-4 (5 constructors).
data Compression
  = Identity  -- ^ Tag 0.
  | Gzip  -- ^ Tag 1.
  | Deflate  -- ^ Tag 2.
  | Snappy  -- ^ Tag 3.
  | Zstd  -- ^ Tag 4.
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

-- | GrpcContentType type matching the Idris2 ABI.
--
-- Tags 0-1 (2 constructors).
data GrpcContentType
  = Protobuf  -- ^ Tag 0.
  | Json  -- ^ Tag 1.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'GrpcContentType' to its ABI tag value.
grpcContentTypeToTag :: GrpcContentType -> Word8
grpcContentTypeToTag = fromIntegral . fromEnum

-- | Decode a 'GrpcContentType' from its ABI tag value.
grpcContentTypeFromTag :: Word8 -> Maybe GrpcContentType
grpcContentTypeFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: GrpcContentType)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- StreamState
-- ---------------------------------------------------------------------------

-- | StreamState type matching the Idris2 ABI.
--
-- Tags 0-5 (6 constructors).
data StreamState
  = Idle  -- ^ Tag 0.
  | Open  -- ^ Tag 1.
  | HalfClosedLocal  -- ^ Tag 2.
  | HalfClosedRemote  -- ^ Tag 3.
  | Reserved  -- ^ Tag 4.
  | Closed  -- ^ Tag 5.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'StreamState' to its ABI tag value.
streamStateToTag :: StreamState -> Word8
streamStateToTag = fromIntegral . fromEnum

-- | Decode a 'StreamState' from its ABI tag value.
streamStateFromTag :: Word8 -> Maybe StreamState
streamStateFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: StreamState)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing
