-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- | DoT protocol types for proven-servers.
--
-- DNS-over-TLS types (RFC 7858), mirroring the Idris2 ABI.
-- All tag values match the Idris2 ABI discriminants exactly.
--
-- This is a pure type-definition module with no FFI dependencies.

module ProvenServers.Dot
  ( -- * ADT types matching Idris2 ABI
      SessionState(..)
    , PaddingStrategy(..)
    , ErrorReason(..)
    , ServerState(..)
    , sessionStateToTag
    , sessionStateFromTag
    , paddingStrategyToTag
    , paddingStrategyFromTag
    , errorReasonToTag
    , errorReasonFromTag
    , serverStateToTag
    , serverStateFromTag
  ) where

import Data.Word (Word8)

-- ---------------------------------------------------------------------------
-- SessionState
-- ---------------------------------------------------------------------------

-- | SessionState type matching the Idris2 ABI.
--
-- Tags 0-4 (5 constructors).
data SessionState
  = Connecting  -- ^ Tag 0.
  | Handshaking  -- ^ Tag 1.
  | Established  -- ^ Tag 2.
  | Closing  -- ^ Tag 3.
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
-- PaddingStrategy
-- ---------------------------------------------------------------------------

-- | PaddingStrategy type matching the Idris2 ABI.
--
-- Tags 0-2 (3 constructors).
data PaddingStrategy
  = NoPadding  -- ^ Tag 0.
  | BlockPadding  -- ^ Tag 1.
  | RandomPadding  -- ^ Tag 2.
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

-- | ErrorReason type matching the Idris2 ABI.
--
-- Tags 0-3 (4 constructors).
data ErrorReason
  = HandshakeFailed  -- ^ Tag 0.
  | CertificateInvalid  -- ^ Tag 1.
  | Timeout  -- ^ Tag 2.
  | UpstreamError  -- ^ Tag 3.
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
