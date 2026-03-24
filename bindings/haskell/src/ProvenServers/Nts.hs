-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- | Network Time Security types for the proven-servers ABI.
--
-- All tag values match the Idris2 ABI discriminants exactly.

module ProvenServers.Nts
  (
    ntsKePort
  , RecordType(..)
  , recordTypeToTag
  , recordTypeFromTag
  , ErrorCode(..)
  , errorCodeToTag
  , errorCodeFromTag
  , AeadAlgorithm(..)
  , aeadAlgorithmToTag
  , aeadAlgorithmFromTag
  , HandshakeState(..)
  , handshakeStateToTag
  , handshakeStateFromTag
  , SessionState(..)
  , sessionStateToTag
  , sessionStateFromTag
  ) where

import Data.Word (Word16, Word8)

-- | Standard NTS-KE port.
ntsKePort :: Word16
ntsKePort = 4460

-- ---------------------------------------------------------------------------
-- RecordType
-- ---------------------------------------------------------------------------

-- | Standard NTS-KE port.
--
-- Tags 0-8 (9 constructors).
data RecordType
  = EndOfMessage  -- ^ EndOfMessage (tag 0).
  | NextProtocol  -- ^ NextProtocol (tag 1).
  | Error  -- ^ Error (tag 2).
  | Warning  -- ^ Warning (tag 3).
  | AeadAlgorithm  -- ^ AEAD algorithm negotiation (tag 4).
  | Cookie  -- ^ Cookie (tag 5).
  | CookiePlaceholder  -- ^ CookiePlaceholder (tag 6).
  | NtskeServer  -- ^ NTS-KE server (tag 7).
  | NtskePort  -- ^ NTS-KE port (tag 8).
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

-- | NTS error codes.
--
-- Tags 0-2 (3 constructors).
data ErrorCode
  = UnrecognizedCritical  -- ^ UnrecognizedCritical (tag 0).
  | BadRequest  -- ^ BadRequest (tag 1).
  | InternalError  -- ^ InternalError (tag 2).
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

-- | AEAD algorithms for NTS.
--
-- Tags 0-2 (3 constructors).
data AeadAlgorithm
  = AeadAes128Gcm  -- ^ AEAD-AES-128-GCM (tag 0).
  | AeadAes256Gcm  -- ^ AEAD-AES-256-GCM (tag 1).
  | AeadAesSivCmac256  -- ^ AEAD-AES-SIV-CMAC-256 (tag 2).
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

-- | NTS handshake states.
--
-- Tags 0-3 (4 constructors).
data HandshakeState
  = Initial  -- ^ Initial (tag 0).
  | Negotiating  -- ^ Negotiating (tag 1).
  | Established  -- ^ Established (tag 2).
  | Failed  -- ^ Failed (tag 3).
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

-- | NTS session lifecycle states.
--
-- Tags 0-4 (5 constructors).
data SessionState
  = Idle  -- ^ Idle (tag 0).
  | Handshaking  -- ^ Handshaking (tag 1).
  | Negotiating  -- ^ Negotiating (tag 2).
  | Established  -- ^ Established (tag 3).
  | Closing  -- ^ Closing (tag 4).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'SessionState' to its ABI tag value.
sessionStateToTag :: SessionState -> Word8
sessionStateToTag = fromIntegral . fromEnum

-- | Decode a 'SessionState' from its ABI tag value.
sessionStateFromTag :: Word8 -> Maybe SessionState
sessionStateFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: SessionState)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing
