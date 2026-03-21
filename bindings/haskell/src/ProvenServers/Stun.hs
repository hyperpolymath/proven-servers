-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- | STUN/TURN protocol types for proven-servers.
--
-- STUN/TURN types (RFC 8489/8656), mirroring the Idris2 ABI.
-- All tag values match the Idris2 ABI discriminants exactly.
--
-- This is a pure type-definition module with no FFI dependencies.

module ProvenServers.Stun
  ( -- * ADT types matching Idris2 ABI
      MessageType(..)
    , TransportProtocol(..)
    , ErrorCode(..)
    , messageTypeToTag
    , messageTypeFromTag
    , transportProtocolToTag
    , transportProtocolFromTag
    , errorCodeToTag
    , errorCodeFromTag
  ) where

import Data.Word (Word8)

-- ---------------------------------------------------------------------------
-- MessageType
-- ---------------------------------------------------------------------------

-- | MessageType type matching the Idris2 ABI.
--
-- Tags 0-11 (12 constructors).
data MessageType
  = BindingRequest  -- ^ Tag 0.
  | BindingResponse  -- ^ Tag 1.
  | BindingError  -- ^ Tag 2.
  | AllocateRequest  -- ^ Tag 3.
  | AllocateResponse  -- ^ Tag 4.
  | AllocateError  -- ^ Tag 5.
  | RefreshRequest  -- ^ Tag 6.
  | RefreshResponse  -- ^ Tag 7.
  | SendIndication  -- ^ Tag 8.
  | DataIndication  -- ^ Tag 9.
  | CreatePermission  -- ^ Tag 10.
  | ChannelBind  -- ^ Tag 11.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'MessageType' to its ABI tag value.
messageTypeToTag :: MessageType -> Word8
messageTypeToTag = fromIntegral . fromEnum

-- | Decode a 'MessageType' from its ABI tag value.
messageTypeFromTag :: Word8 -> Maybe MessageType
messageTypeFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: MessageType)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- TransportProtocol
-- ---------------------------------------------------------------------------

-- | TransportProtocol type matching the Idris2 ABI.
--
-- Tags 0-3 (4 constructors).
data TransportProtocol
  = Udp  -- ^ Tag 0.
  | Tcp  -- ^ Tag 1.
  | Tls  -- ^ Tag 2.
  | Dtls  -- ^ Tag 3.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'TransportProtocol' to its ABI tag value.
transportProtocolToTag :: TransportProtocol -> Word8
transportProtocolToTag = fromIntegral . fromEnum

-- | Decode a 'TransportProtocol' from its ABI tag value.
transportProtocolFromTag :: Word8 -> Maybe TransportProtocol
transportProtocolFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: TransportProtocol)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- ErrorCode
-- ---------------------------------------------------------------------------

-- | ErrorCode type matching the Idris2 ABI.
--
-- Tags 0-7 (8 constructors).
data ErrorCode
  = TryAlternate  -- ^ Tag 0.
  | BadRequest  -- ^ Tag 1.
  | Unauthorized  -- ^ Tag 2.
  | Forbidden  -- ^ Tag 3.
  | MobilityForbidden  -- ^ Tag 4.
  | StaleNonce  -- ^ Tag 5.
  | ServerError  -- ^ Tag 6.
  | InsufficientCapacity  -- ^ Tag 7.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'ErrorCode' to its ABI tag value.
errorCodeToTag :: ErrorCode -> Word8
errorCodeToTag = fromIntegral . fromEnum

-- | Decode a 'ErrorCode' from its ABI tag value.
errorCodeFromTag :: Word8 -> Maybe ErrorCode
errorCodeFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: ErrorCode)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing
