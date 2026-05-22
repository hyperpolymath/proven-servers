-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- | DNS-over-TLS types for the proven-servers ABI.
--
-- All tag values match the Idris2 ABI discriminants exactly.

module ProvenServers.Dot
  (
    dotPort
  , SessionState(..)
  , sessionStateToTag
  , sessionStateFromTag
  , PaddingStrategy(..)
  , paddingStrategyToTag
  , paddingStrategyFromTag
  , ErrorReason(..)
  , errorReasonToTag
  , errorReasonFromTag
  , ServerState(..)
  , serverStateToTag
  , serverStateFromTag
  ) where

import Data.Word (Word16, Word8)

-- | Standard DoT port.
dotPort :: Word16
dotPort = 853

-- ---------------------------------------------------------------------------
-- SessionState
-- ---------------------------------------------------------------------------

-- | Standard DoT port.
--
-- Tags 0-4 (5 constructors).
data SessionState
  = Connecting  -- ^ Connecting (tag 0).
  | Handshaking  -- ^ Handshaking (tag 1).
  | Established  -- ^ Established (tag 2).
  | Closing  -- ^ Closing (tag 3).
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
-- PaddingStrategy
-- ---------------------------------------------------------------------------

-- | DoT padding strategies (RFC 7830).
--
-- Tags 0-2 (3 constructors).
data PaddingStrategy
  = NoPadding  -- ^ NoPadding (tag 0).
  | BlockPadding  -- ^ BlockPadding (tag 1).
  | RandomPadding  -- ^ RandomPadding (tag 2).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'PaddingStrategy' to its ABI tag value.
paddingStrategyToTag :: PaddingStrategy -> Word8
paddingStrategyToTag = fromIntegral . fromEnum

-- | Decode a 'PaddingStrategy' from its ABI tag value.
paddingStrategyFromTag :: Word8 -> Maybe PaddingStrategy
paddingStrategyFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: PaddingStrategy)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- ErrorReason
-- ---------------------------------------------------------------------------

-- | DoT error reasons.
--
-- Tags 0-3 (4 constructors).
data ErrorReason
  = HandshakeFailed  -- ^ HandshakeFailed (tag 0).
  | CertificateInvalid  -- ^ CertificateInvalid (tag 1).
  | Timeout  -- ^ Timeout (tag 2).
  | UpstreamError  -- ^ UpstreamError (tag 3).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'ErrorReason' to its ABI tag value.
errorReasonToTag :: ErrorReason -> Word8
errorReasonToTag = fromIntegral . fromEnum

-- | Decode a 'ErrorReason' from its ABI tag value.
errorReasonFromTag :: Word8 -> Maybe ErrorReason
errorReasonFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: ErrorReason)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- ServerState
-- ---------------------------------------------------------------------------

-- | DoT server lifecycle states.
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
