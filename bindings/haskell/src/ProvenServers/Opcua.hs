-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- | OPC UA protocol types for proven-servers.
--
-- OPC UA (Unified Architecture) types, mirroring the Idris2 ABI.
-- All tag values match the Idris2 ABI discriminants exactly.
--
-- This is a pure type-definition module with no FFI dependencies.

module ProvenServers.Opcua
  ( -- * ADT types matching Idris2 ABI
      ServiceType(..)
    , NodeClass(..)
    , StatusCode(..)
    , SecurityMode(..)
    , SessionState(..)
    , serviceTypeToTag
    , serviceTypeFromTag
    , nodeClassToTag
    , nodeClassFromTag
    , statusCodeToTag
    , statusCodeFromTag
    , securityModeToTag
    , securityModeFromTag
    , sessionStateToTag
    , sessionStateFromTag
  ) where

import Data.Word (Word8)

-- ---------------------------------------------------------------------------
-- ServiceType
-- ---------------------------------------------------------------------------

-- | ServiceType type matching the Idris2 ABI.
--
-- Tags 0-10 (11 constructors).
data ServiceType
  = Read  -- ^ Tag 0.
  | Write  -- ^ Tag 1.
  | Browse  -- ^ Tag 2.
  | Subscribe  -- ^ Tag 3.
  | Publish  -- ^ Tag 4.
  | Call  -- ^ Tag 5.
  | CreateSession  -- ^ Tag 6.
  | ActivateSession  -- ^ Tag 7.
  | CloseSession  -- ^ Tag 8.
  | CreateSubscription  -- ^ Tag 9.
  | DeleteSubscription  -- ^ Tag 10.
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
-- NodeClass
-- ---------------------------------------------------------------------------

-- | NodeClass type matching the Idris2 ABI.
--
-- Tags 0-7 (8 constructors).
data NodeClass
  = Object  -- ^ Tag 0.
  | Variable  -- ^ Tag 1.
  | Method  -- ^ Tag 2.
  | ObjectType  -- ^ Tag 3.
  | VariableType  -- ^ Tag 4.
  | ReferenceType  -- ^ Tag 5.
  | DataType  -- ^ Tag 6.
  | View  -- ^ Tag 7.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'NodeClass' to its ABI tag value.
nodeClassToTag :: NodeClass -> Word8
nodeClassToTag = fromIntegral . fromEnum

-- | Decode a 'NodeClass' from its ABI tag value.
nodeClassFromTag :: Word8 -> Maybe NodeClass
nodeClassFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: NodeClass)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- StatusCode
-- ---------------------------------------------------------------------------

-- | StatusCode type matching the Idris2 ABI.
--
-- Tags 0-11 (12 constructors).
data StatusCode
  = Good  -- ^ Tag 0.
  | Uncertain  -- ^ Tag 1.
  | Bad  -- ^ Tag 2.
  | BadNodeIdUnknown  -- ^ Tag 3.
  | BadAttributeIdInvalid  -- ^ Tag 4.
  | BadNotReadable  -- ^ Tag 5.
  | BadNotWritable  -- ^ Tag 6.
  | BadOutOfRange  -- ^ Tag 7.
  | BadTypeMismatch  -- ^ Tag 8.
  | BadSessionIdInvalid  -- ^ Tag 9.
  | BadSubscriptionIdInvalid  -- ^ Tag 10.
  | BadTimeout  -- ^ Tag 11.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'StatusCode' to its ABI tag value.
statusCodeToTag :: StatusCode -> Word8
statusCodeToTag = fromIntegral . fromEnum

-- | Decode a 'StatusCode' from its ABI tag value.
statusCodeFromTag :: Word8 -> Maybe StatusCode
statusCodeFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: StatusCode)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- SecurityMode
-- ---------------------------------------------------------------------------

-- | SecurityMode type matching the Idris2 ABI.
--
-- Tags 0-2 (3 constructors).
data SecurityMode
  = None  -- ^ Tag 0.
  | Sign  -- ^ Tag 1.
  | SignAndEncrypt  -- ^ Tag 2.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'SecurityMode' to its ABI tag value.
securityModeToTag :: SecurityMode -> Word8
securityModeToTag = fromIntegral . fromEnum

-- | Decode a 'SecurityMode' from its ABI tag value.
securityModeFromTag :: Word8 -> Maybe SecurityMode
securityModeFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: SecurityMode)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- SessionState
-- ---------------------------------------------------------------------------

-- | SessionState type matching the Idris2 ABI.
--
-- Tags 0-5 (6 constructors).
data SessionState
  = Idle  -- ^ Tag 0.
  | Connected  -- ^ Tag 1.
  | Created  -- ^ Tag 2.
  | Activated  -- ^ Tag 3.
  | Monitoring  -- ^ Tag 4.
  | Closing  -- ^ Tag 5.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'SessionState' to its ABI tag value.
sessionStateToTag :: SessionState -> Word8
sessionStateToTag = fromIntegral . fromEnum

-- | Decode a 'SessionState' from its ABI tag value.
sessionStateFromTag :: Word8 -> Maybe SessionState
sessionStateFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: SessionState)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing
