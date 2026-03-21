-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- | DoQ protocol types for proven-servers.
--
-- DNS-over-QUIC types (RFC 9250), mirroring the Idris2 ABI.
-- All tag values match the Idris2 ABI discriminants exactly.
--
-- This is a pure type-definition module with no FFI dependencies.

module ProvenServers.Doq
  ( -- * ADT types matching Idris2 ABI
      StreamType(..)
    , ErrorCode(..)
    , SessionState(..)
    , ServerState(..)
    , streamTypeToTag
    , streamTypeFromTag
    , errorCodeToTag
    , errorCodeFromTag
    , sessionStateToTag
    , sessionStateFromTag
    , serverStateToTag
    , serverStateFromTag
  ) where

import Data.Word (Word8)

-- ---------------------------------------------------------------------------
-- StreamType
-- ---------------------------------------------------------------------------

-- | StreamType type matching the Idris2 ABI.
--
-- Tags 0-1 (2 constructors).
data StreamType
  = Unidirectional  -- ^ Tag 0.
  | Bidirectional  -- ^ Tag 1.
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
-- ErrorCode
-- ---------------------------------------------------------------------------

-- | ErrorCode type matching the Idris2 ABI.
--
-- Tags 0-3 (4 constructors).
data ErrorCode
  = NoError  -- ^ Tag 0.
  | InternalError  -- ^ Tag 1.
  | ExcessiveLoad  -- ^ Tag 2.
  | ProtocolError  -- ^ Tag 3.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'ErrorCode' to its ABI tag value.
errorCodeToTag :: ErrorCode -> Word8
errorCodeToTag = fromIntegral . fromEnum

-- | Decode a 'ErrorCode' from its ABI tag value.
errorCodeFromTag :: Word8 -> Maybe ErrorCode
errorCodeFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: ErrorCode)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- SessionState
-- ---------------------------------------------------------------------------

-- | SessionState type matching the Idris2 ABI.
--
-- Tags 0-4 (5 constructors).
data SessionState
  = Initial  -- ^ Tag 0.
  | Handshaking  -- ^ Tag 1.
  | Ready  -- ^ Tag 2.
  | Draining  -- ^ Tag 3.
  | Closed  -- ^ Tag 4.
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
-- ServerState
-- ---------------------------------------------------------------------------

-- | ServerState type matching the Idris2 ABI.
--
-- Tags 0-4 (5 constructors).
data ServerState
  = Idle  -- ^ Tag 0.
  | Bound  -- ^ Tag 1.
  | Listening  -- ^ Tag 2.
  | Processing  -- ^ Tag 3.
  | Shutdown  -- ^ Tag 4.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'ServerState' to its ABI tag value.
serverStateToTag :: ServerState -> Word8
serverStateToTag = fromIntegral . fromEnum

-- | Decode a 'ServerState' from its ABI tag value.
serverStateFromTag :: Word8 -> Maybe ServerState
serverStateFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: ServerState)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing
