-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- | RADIUS protocol types for the proven-servers ABI.
--
-- All tag values match the Idris2 ABI discriminants exactly.

module ProvenServers.Radius
  (
    radiusAuthPort
  , radiusAcctPort
  , PacketType(..)
  , packetTypeToTag
  , packetTypeFromTag
  , isAuth
  , isAccounting
  , isRequest
  , AttributeType(..)
  , attributeTypeToTag
  , attributeTypeFromTag
  , isSensitive
  , ServiceType(..)
  , serviceTypeToTag
  , serviceTypeFromTag
  , AuthMethod(..)
  , authMethodToTag
  , authMethodFromTag
  , isLegacy
  , SessionState(..)
  , sessionStateToTag
  , sessionStateFromTag
  , isTerminal
  , RadiusResult(..)
  , radiusResultToTag
  , radiusResultFromTag
  , isSuccess
  ) where

import Data.Word (Word16, Word8)

-- | Standard RADIUS authentication port (RFC 2865).
radiusAuthPort :: Word16
radiusAuthPort = 1812

-- | Standard RADIUS accounting port (RFC 2866).
radiusAcctPort :: Word16
radiusAcctPort = 1813

-- ---------------------------------------------------------------------------
-- PacketType
-- ---------------------------------------------------------------------------

-- | RADIUS packet types (RFC 2865).
--
-- Tags 0-11 (6 constructors).
data PacketType
  = AccessRequest  -- ^ Access-Request (Code 1) (tag 1).
  | AccessAccept  -- ^ Access-Accept (Code 2) (tag 2).
  | AccessReject  -- ^ Access-Reject (Code 3) (tag 3).
  | AccountingRequest  -- ^ Accounting-Request (Code 4) (tag 4).
  | AccountingResponse  -- ^ Accounting-Response (Code 5) (tag 5).
  | AccessChallenge  -- ^ Access-Challenge (Code 11) (tag 11).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'PacketType' to its ABI tag value.
packetTypeToTag :: PacketType -> Word8
packetTypeToTag = fromIntegral . fromEnum

-- | Decode a 'PacketType' from its ABI tag value.
packetTypeFromTag :: Word8 -> Maybe PacketType
packetTypeFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: PacketType)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- | Whether this packet is an authentication request/response.
isAuth :: PacketType -> Bool
isAuth AccessRequest = True
isAuth AccessAccept = True
isAuth AccessReject = True
isAuth AccessChallenge = True
isAuth _ = False

-- | Whether this packet is an accounting request/response.
isAccounting :: PacketType -> Bool
isAccounting AccountingRequest = True
isAccounting AccountingResponse = True
isAccounting _ = False

-- | Whether this packet is a request (client -> server).
isRequest :: PacketType -> Bool
isRequest AccessRequest = True
isRequest AccountingRequest = True
isRequest _ = False

-- ---------------------------------------------------------------------------
-- AttributeType
-- ---------------------------------------------------------------------------

-- | RADIUS attribute types (RFC 2865).
--
-- Tags 0-27 (9 constructors).
data AttributeType
  = UserName  -- ^ User-Name (Type 1) (tag 1).
  | UserPassword  -- ^ User-Password (Type 2) (tag 2).
  | NasIpAddress  -- ^ NAS-IP-Address (Type 4) (tag 4).
  | NasPort  -- ^ NAS-Port (Type 5) (tag 5).
  | ServiceType  -- ^ Service-Type (Type 6) (tag 6).
  | FramedProtocol  -- ^ Framed-Protocol (Type 7) (tag 7).
  | FramedIpAddress  -- ^ Framed-IP-Address (Type 8) (tag 8).
  | ReplyMessage  -- ^ Reply-Message (Type 18) (tag 18).
  | SessionTimeout  -- ^ Session-Timeout (Type 27) (tag 27).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'AttributeType' to its ABI tag value.
attributeTypeToTag :: AttributeType -> Word8
attributeTypeToTag = fromIntegral . fromEnum

-- | Decode a 'AttributeType' from its ABI tag value.
attributeTypeFromTag :: Word8 -> Maybe AttributeType
attributeTypeFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: AttributeType)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- | Whether this attribute contains sensitive data.
isSensitive :: AttributeType -> Bool
isSensitive UserPassword = True
isSensitive _ = False

-- ---------------------------------------------------------------------------
-- ServiceType
-- ---------------------------------------------------------------------------

-- | RADIUS Service-Type values (RFC 2865).
--
-- Tags 0-6 (6 constructors).
data ServiceType
  = Login  -- ^ Login (tag 1).
  | Framed  -- ^ Framed (tag 2).
  | CallbackLogin  -- ^ Callback Login (tag 3).
  | CallbackFramed  -- ^ Callback Framed (tag 4).
  | Outbound  -- ^ Outbound (tag 5).
  | Administrative  -- ^ Administrative (tag 6).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'ServiceType' to its ABI tag value.
serviceTypeToTag :: ServiceType -> Word8
serviceTypeToTag = fromIntegral . fromEnum

-- | Decode a 'ServiceType' from its ABI tag value.
serviceTypeFromTag :: Word8 -> Maybe ServiceType
serviceTypeFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: ServiceType)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- AuthMethod
-- ---------------------------------------------------------------------------

-- | RADIUS authentication methods.
--
-- Tags 0-4 (5 constructors).
data AuthMethod
  = Pap  -- ^ PAP — Password Authentication Protocol (tag 0).
  | Chap  -- ^ CHAP — Challenge Handshake Authentication Protocol (tag 1).
  | Mschap  -- ^ MS-CHAP — Microsoft CHAP v1 (tag 2).
  | Mschapv2  -- ^ MS-CHAPv2 — Microsoft CHAP v2 (tag 3).
  | Eap  -- ^ EAP — Extensible Authentication Protocol (tag 4).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'AuthMethod' to its ABI tag value.
authMethodToTag :: AuthMethod -> Word8
authMethodToTag = fromIntegral . fromEnum

-- | Decode a 'AuthMethod' from its ABI tag value.
authMethodFromTag :: Word8 -> Maybe AuthMethod
authMethodFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: AuthMethod)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- | Whether this method is considered legacy/weak.
isLegacy :: AuthMethod -> Bool
isLegacy Pap = True
isLegacy Mschap = True
isLegacy _ = False

-- ---------------------------------------------------------------------------
-- SessionState
-- ---------------------------------------------------------------------------

-- | RADIUS session state machine.
--
-- Tags 0-6 (7 constructors).
data SessionState
  = Idle  -- ^ Idle — no active session (tag 0).
  | Authenticating  -- ^ Authenticating — processing auth request (tag 1).
  | Authorized  -- ^ Authorized — access granted (tag 2).
  | Rejected  -- ^ Rejected — access denied (tag 3).
  | Challenged  -- ^ Challenged — additional auth step required (tag 4).
  | Accounting  -- ^ Accounting — session accounting in progress (tag 5).
  | Complete  -- ^ Complete — session fully processed (tag 6).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'SessionState' to its ABI tag value.
sessionStateToTag :: SessionState -> Word8
sessionStateToTag = fromIntegral . fromEnum

-- | Decode a 'SessionState' from its ABI tag value.
sessionStateFromTag :: Word8 -> Maybe SessionState
sessionStateFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: SessionState)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- | Whether this is a terminal state.
isTerminal :: SessionState -> Bool
isTerminal Rejected = True
isTerminal Complete = True
isTerminal _ = False

-- ---------------------------------------------------------------------------
-- RadiusResult
-- ---------------------------------------------------------------------------

-- | RADIUS FFI result codes.
--
-- Tags 0-4 (5 constructors).
data RadiusResult
  = Ok  -- ^ Success (tag 0).
  | Err  -- ^ Generic error (tag 1).
  | InvalidParam  -- ^ Invalid parameter (tag 2).
  | PoolExhausted  -- ^ Address pool exhausted (tag 3).
  | BadSecret  -- ^ Shared secret mismatch (tag 4).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'RadiusResult' to its ABI tag value.
radiusResultToTag :: RadiusResult -> Word8
radiusResultToTag = fromIntegral . fromEnum

-- | Decode a 'RadiusResult' from its ABI tag value.
radiusResultFromTag :: Word8 -> Maybe RadiusResult
radiusResultFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: RadiusResult)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- | Whether this result indicates success.
isSuccess :: RadiusResult -> Bool
isSuccess Ok = True
isSuccess _ = False
