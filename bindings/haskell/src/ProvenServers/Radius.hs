-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- | RADIUS protocol types for proven-servers.
--
-- RADIUS authentication/accounting types, mirroring the Idris2 ABI.
-- All tag values match the Idris2 ABI discriminants exactly.
--
-- This is a pure type-definition module with no FFI dependencies.

module ProvenServers.Radius
  ( -- * ADT types matching Idris2 ABI
      PacketType(..)
    , AttributeType(..)
    , ServiceType(..)
    , AuthMethod(..)
    , SessionState(..)
    , RadiusResult(..)
    , packetTypeToTag
    , packetTypeFromTag
    , attributeTypeToTag
    , attributeTypeFromTag
    , serviceTypeToTag
    , serviceTypeFromTag
    , authMethodToTag
    , authMethodFromTag
    , sessionStateToTag
    , sessionStateFromTag
    , radiusResultToTag
    , radiusResultFromTag
  ) where

import Data.Word (Word8)

-- ---------------------------------------------------------------------------
-- PacketType
-- ---------------------------------------------------------------------------

-- | PacketType type matching the Idris2 ABI.
--
-- Tags 1-11 (6 constructors).
data PacketType
  = AccessRequest  -- ^ Tag 1.
  | AccessAccept  -- ^ Tag 2.
  | AccessReject  -- ^ Tag 3.
  | AccountingRequest  -- ^ Tag 4.
  | AccountingResponse  -- ^ Tag 5.
  | AccessChallenge  -- ^ Tag 11.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'PacketType' to its ABI tag value.
packetTypeToTag :: PacketType -> Word8
packetTypeToTag = fromIntegral . fromEnum

-- | Decode a 'PacketType' from its ABI tag value.
packetTypeFromTag :: Word8 -> Maybe PacketType
packetTypeFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: PacketType)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- AttributeType
-- ---------------------------------------------------------------------------

-- | AttributeType type matching the Idris2 ABI.
--
-- Tags 1-27 (9 constructors).
data AttributeType
  = UserName  -- ^ Tag 1.
  | UserPassword  -- ^ Tag 2.
  | NasIpAddress  -- ^ Tag 4.
  | NasPort  -- ^ Tag 5.
  | ServiceType  -- ^ Tag 6.
  | FramedProtocol  -- ^ Tag 7.
  | FramedIpAddress  -- ^ Tag 8.
  | ReplyMessage  -- ^ Tag 18.
  | SessionTimeout  -- ^ Tag 27.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'AttributeType' to its ABI tag value.
attributeTypeToTag :: AttributeType -> Word8
attributeTypeToTag = fromIntegral . fromEnum

-- | Decode a 'AttributeType' from its ABI tag value.
attributeTypeFromTag :: Word8 -> Maybe AttributeType
attributeTypeFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: AttributeType)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- ServiceType
-- ---------------------------------------------------------------------------

-- | ServiceType type matching the Idris2 ABI.
--
-- Tags 1-6 (6 constructors).
data ServiceType
  = Login  -- ^ Tag 1.
  | Framed  -- ^ Tag 2.
  | CallbackLogin  -- ^ Tag 3.
  | CallbackFramed  -- ^ Tag 4.
  | Outbound  -- ^ Tag 5.
  | Administrative  -- ^ Tag 6.
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

-- | AuthMethod type matching the Idris2 ABI.
--
-- Tags 0-4 (5 constructors).
data AuthMethod
  = Pap  -- ^ Tag 0.
  | Chap  -- ^ Tag 1.
  | Mschap  -- ^ Tag 2.
  | Mschapv2  -- ^ Tag 3.
  | Eap  -- ^ Tag 4.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'AuthMethod' to its ABI tag value.
authMethodToTag :: AuthMethod -> Word8
authMethodToTag = fromIntegral . fromEnum

-- | Decode a 'AuthMethod' from its ABI tag value.
authMethodFromTag :: Word8 -> Maybe AuthMethod
authMethodFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: AuthMethod)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- SessionState
-- ---------------------------------------------------------------------------

-- | SessionState type matching the Idris2 ABI.
--
-- Tags 0-6 (7 constructors).
data SessionState
  = Idle  -- ^ Tag 0.
  | Authenticating  -- ^ Tag 1.
  | Authorized  -- ^ Tag 2.
  | Rejected  -- ^ Tag 3.
  | Challenged  -- ^ Tag 4.
  | Accounting  -- ^ Tag 5.
  | Complete  -- ^ Tag 6.
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
-- RadiusResult
-- ---------------------------------------------------------------------------

-- | RadiusResult type matching the Idris2 ABI.
--
-- Tags 0-4 (5 constructors).
data RadiusResult
  = Ok  -- ^ Tag 0.
  | Err  -- ^ Tag 1.
  | InvalidParam  -- ^ Tag 2.
  | PoolExhausted  -- ^ Tag 3.
  | BadSecret  -- ^ Tag 4.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'RadiusResult' to its ABI tag value.
radiusResultToTag :: RadiusResult -> Word8
radiusResultToTag = fromIntegral . fromEnum

-- | Decode a 'RadiusResult' from its ABI tag value.
radiusResultFromTag :: Word8 -> Maybe RadiusResult
radiusResultFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: RadiusResult)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing
