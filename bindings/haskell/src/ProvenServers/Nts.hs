-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- | NTS protocol types for proven-servers.
--
-- Network Time Security types (RFC 8915), mirroring the Idris2 ABI.
-- All tag values match the Idris2 ABI discriminants exactly.
--
-- This is a pure type-definition module with no FFI dependencies.

module ProvenServers.Nts
  ( -- * ADT types matching Idris2 ABI
      RecordType(..)
    , ErrorCode(..)
    , AeadAlgorithm(..)
    , HandshakeState(..)
    , SessionState(..)
    , recordTypeToTag
    , recordTypeFromTag
    , errorCodeToTag
    , errorCodeFromTag
    , aeadAlgorithmToTag
    , aeadAlgorithmFromTag
    , handshakeStateToTag
    , handshakeStateFromTag
    , sessionStateToTag
    , sessionStateFromTag
  ) where

import Data.Word (Word8)

-- ---------------------------------------------------------------------------
-- RecordType
-- ---------------------------------------------------------------------------

-- | RecordType type matching the Idris2 ABI.
--
-- Tags 0-8 (9 constructors).
data RecordType
  = EndOfMessage  -- ^ Tag 0.
  | NextProtocol  -- ^ Tag 1.
  | Error  -- ^ Tag 2.
  | Warning  -- ^ Tag 3.
  | AeadAlgorithm  -- ^ Tag 4.
  | Cookie  -- ^ Tag 5.
  | CookiePlaceholder  -- ^ Tag 6.
  | NtskeServer  -- ^ Tag 7.
  | NtskePort  -- ^ Tag 8.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'RecordType' to its ABI tag value.
recordTypeToTag :: RecordType -> Word8
recordTypeToTag = fromIntegral . fromEnum

-- | Decode a 'RecordType' from its ABI tag value.
recordTypeFromTag :: Word8 -> Maybe RecordType
recordTypeFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: RecordType)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- ErrorCode
-- ---------------------------------------------------------------------------

-- | ErrorCode type matching the Idris2 ABI.
--
-- Tags 0-2 (3 constructors).
data ErrorCode
  = UnrecognizedCritical  -- ^ Tag 0.
  | BadRequest  -- ^ Tag 1.
  | InternalError  -- ^ Tag 2.
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
-- AeadAlgorithm
-- ---------------------------------------------------------------------------

-- | AeadAlgorithm type matching the Idris2 ABI.
--
-- Tags 0-2 (3 constructors).
data AeadAlgorithm
  = AeadAes128Gcm  -- ^ Tag 0.
  | AeadAes256Gcm  -- ^ Tag 1.
  | AeadAesSivCmac256  -- ^ Tag 2.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'AeadAlgorithm' to its ABI tag value.
aeadAlgorithmToTag :: AeadAlgorithm -> Word8
aeadAlgorithmToTag = fromIntegral . fromEnum

-- | Decode a 'AeadAlgorithm' from its ABI tag value.
aeadAlgorithmFromTag :: Word8 -> Maybe AeadAlgorithm
aeadAlgorithmFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: AeadAlgorithm)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- HandshakeState
-- ---------------------------------------------------------------------------

-- | HandshakeState type matching the Idris2 ABI.
--
-- Tags 0-3 (4 constructors).
data HandshakeState
  = Initial  -- ^ Tag 0.
  | HandshakeState_Negotiating  -- ^ Tag 1.
  | HandshakeState_Established  -- ^ Tag 2.
  | Failed  -- ^ Tag 3.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'HandshakeState' to its ABI tag value.
handshakeStateToTag :: HandshakeState -> Word8
handshakeStateToTag = fromIntegral . fromEnum

-- | Decode a 'HandshakeState' from its ABI tag value.
handshakeStateFromTag :: Word8 -> Maybe HandshakeState
handshakeStateFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: HandshakeState)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- SessionState
-- ---------------------------------------------------------------------------

-- | SessionState type matching the Idris2 ABI.
--
-- Tags 0-4 (5 constructors).
data SessionState
  = Idle  -- ^ Tag 0.
  | Handshaking  -- ^ Tag 1.
  | SessionState_Negotiating  -- ^ Tag 2.
  | SessionState_Established  -- ^ Tag 3.
  | Closing  -- ^ Tag 4.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'SessionState' to its ABI tag value.
sessionStateToTag :: SessionState -> Word8
sessionStateToTag = fromIntegral . fromEnum

-- | Decode a 'SessionState' from its ABI tag value.
sessionStateFromTag :: Word8 -> Maybe SessionState
sessionStateFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: SessionState)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing
