-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- | DNS-over-QUIC types for the proven-servers ABI.
--
-- All tag values match the Idris2 ABI discriminants exactly.

module ProvenServers.Doq
  (
    doqPort
  , StreamType(..)
  , streamTypeToTag
  , streamTypeFromTag
  , ErrorCode(..)
  , errorCodeToTag
  , errorCodeFromTag
  , SessionState(..)
  , sessionStateToTag
  , sessionStateFromTag
  , ServerState(..)
  , serverStateToTag
  , serverStateFromTag
  ) where

import Data.Word (Word16, Word8)

-- | Standard DoQ port.
doqPort :: Word16
doqPort = 853

-- ---------------------------------------------------------------------------
-- StreamType
-- ---------------------------------------------------------------------------

-- | Standard DoQ port.
--
-- Tags 0-1 (2 constructors).
data StreamType
  = Unidirectional  -- ^ Unidirectional (tag 0).
  | Bidirectional  -- ^ Bidirectional (tag 1).
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

-- | DoQ error codes.
--
-- Tags 0-3 (4 constructors).
data ErrorCode
  = NoError  -- ^ NoError (tag 0).
  | InternalError  -- ^ InternalError (tag 1).
  | ExcessiveLoad  -- ^ ExcessiveLoad (tag 2).
  | ProtocolError  -- ^ ProtocolError (tag 3).
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

-- | DoQ session lifecycle states.
--
-- Tags 0-4 (5 constructors).
data SessionState
  = Initial  -- ^ Initial (tag 0).
  | Handshaking  -- ^ Handshaking (tag 1).
  | Ready  -- ^ Ready (tag 2).
  | Draining  -- ^ Draining (tag 3).
  | Closed  -- ^ Closed (tag 4).
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

-- | DoQ server lifecycle states.
--
-- Tags 0-4 (5 constructors).
data ServerState
  = Idle  -- ^ Idle (tag 0).
  | Bound  -- ^ Bound (tag 1).
  | Listening  -- ^ Listening (tag 2).
  | Processing  -- ^ Processing (tag 3).
  | Shutdown  -- ^ Shutdown (tag 4).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'ServerState' to its ABI tag value.
serverStateToTag :: ServerState -> Word8
serverStateToTag = fromIntegral . fromEnum

-- | Decode a 'ServerState' from its ABI tag value.
serverStateFromTag :: Word8 -> Maybe ServerState
serverStateFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: ServerState)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing
