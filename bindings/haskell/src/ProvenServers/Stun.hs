-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- | STUN/TURN types for the proven-servers ABI.
--
-- All tag values match the Idris2 ABI discriminants exactly.

module ProvenServers.Stun
  (
    stunPort
  , stunTlsPort
  , MessageType(..)
  , messageTypeToTag
  , messageTypeFromTag
  , isRequest
  , isTurn
  , TransportProtocol(..)
  , transportProtocolToTag
  , transportProtocolFromTag
  , ErrorCode(..)
  , errorCodeToTag
  , errorCodeFromTag
  ) where

import Data.Word (Word16, Word8)

-- | Standard STUN port.
stunPort :: Word16
stunPort = 3478

-- | Standard STUN TLS port.
stunTlsPort :: Word16
stunTlsPort = 5349

-- ---------------------------------------------------------------------------
-- MessageType
-- ---------------------------------------------------------------------------

-- | Standard STUN port.
--
-- Tags 0-11 (12 constructors).
data MessageType
  = BindingRequest  -- ^ BindingRequest (tag 0).
  | BindingResponse  -- ^ BindingResponse (tag 1).
  | BindingError  -- ^ BindingError (tag 2).
  | AllocateRequest  -- ^ AllocateRequest (tag 3).
  | AllocateResponse  -- ^ AllocateResponse (tag 4).
  | AllocateError  -- ^ AllocateError (tag 5).
  | RefreshRequest  -- ^ RefreshRequest (tag 6).
  | RefreshResponse  -- ^ RefreshResponse (tag 7).
  | SendIndication  -- ^ SendIndication (tag 8).
  | DataIndication  -- ^ DataIndication (tag 9).
  | CreatePermission  -- ^ CreatePermission (tag 10).
  | ChannelBind  -- ^ ChannelBind (tag 11).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'MessageType' to its ABI tag value.
messageTypeToTag :: MessageType -> Word8
messageTypeToTag = fromIntegral . fromEnum

-- | Decode a 'MessageType' from its ABI tag value.
messageTypeFromTag :: Word8 -> Maybe MessageType
messageTypeFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: MessageType)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- | Whether this is a request message.
isRequest :: MessageType -> Bool
isRequest BindingRequest = True
isRequest AllocateRequest = True
isRequest RefreshRequest = True
isRequest CreatePermission = True
isRequest ChannelBind = True
isRequest _ = False

-- | Whether this is a TURN-specific message.
isTurn :: MessageType -> Bool
isTurn AllocateRequest = True
isTurn AllocateResponse = True
isTurn AllocateError = True
isTurn RefreshRequest = True
isTurn RefreshResponse = True
isTurn SendIndication = True
isTurn DataIndication = True
isTurn CreatePermission = True
isTurn ChannelBind = True
isTurn _ = False

-- ---------------------------------------------------------------------------
-- TransportProtocol
-- ---------------------------------------------------------------------------

-- | STUN transport protocols.
--
-- Tags 0-3 (4 constructors).
data TransportProtocol
  = Udp  -- ^ UDP (tag 0).
  | Tcp  -- ^ TCP (tag 1).
  | Tls  -- ^ TLS (tag 2).
  | Dtls  -- ^ DTLS (tag 3).
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

-- | STUN error codes.
--
-- Tags 0-7 (8 constructors).
data ErrorCode
  = TryAlternate  -- ^ TryAlternate (tag 0).
  | BadRequest  -- ^ BadRequest (tag 1).
  | Unauthorized  -- ^ Unauthorized (tag 2).
  | Forbidden  -- ^ Forbidden (tag 3).
  | MobilityForbidden  -- ^ MobilityForbidden (tag 4).
  | StaleNonce  -- ^ StaleNonce (tag 5).
  | ServerError  -- ^ ServerError (tag 6).
  | InsufficientCapacity  -- ^ InsufficientCapacity (tag 7).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'ErrorCode' to its ABI tag value.
errorCodeToTag :: ErrorCode -> Word8
errorCodeToTag = fromIntegral . fromEnum

-- | Decode a 'ErrorCode' from its ABI tag value.
errorCodeFromTag :: Word8 -> Maybe ErrorCode
errorCodeFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: ErrorCode)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing
