-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- | CoAP protocol types for proven-servers.
--
-- CoAP (Constrained Application Protocol) types, mirroring the Idris2 ABI.
-- All tag values match the Idris2 ABI discriminants exactly.
--
-- This is a pure type-definition module with no FFI dependencies.

module ProvenServers.Coap
  ( -- * ADT types matching Idris2 ABI
      Method(..)
    , MessageType(..)
    , ContentFormat(..)
    , ResponseClass(..)
    , SessionState(..)
    , methodToTag
    , methodFromTag
    , messageTypeToTag
    , messageTypeFromTag
    , contentFormatToTag
    , contentFormatFromTag
    , responseClassToTag
    , responseClassFromTag
    , sessionStateToTag
    , sessionStateFromTag
  ) where

import Data.Word (Word8)

-- ---------------------------------------------------------------------------
-- Method
-- ---------------------------------------------------------------------------

-- | Method type matching the Idris2 ABI.
--
-- Tags 0-3 (4 constructors).
data Method
  = Get  -- ^ Tag 0.
  | Post  -- ^ Tag 1.
  | Put  -- ^ Tag 2.
  | Delete  -- ^ Tag 3.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'Method' to its ABI tag value.
methodToTag :: Method -> Word8
methodToTag = fromIntegral . fromEnum

-- | Decode a 'Method' from its ABI tag value.
methodFromTag :: Word8 -> Maybe Method
methodFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: Method)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- MessageType
-- ---------------------------------------------------------------------------

-- | MessageType type matching the Idris2 ABI.
--
-- Tags 0-3 (4 constructors).
data MessageType
  = Confirmable  -- ^ Tag 0.
  | NonConfirmable  -- ^ Tag 1.
  | Acknowledgement  -- ^ Tag 2.
  | Reset  -- ^ Tag 3.
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
-- ContentFormat
-- ---------------------------------------------------------------------------

-- | ContentFormat type matching the Idris2 ABI.
--
-- Tags 0-6 (7 constructors).
data ContentFormat
  = TextPlain  -- ^ Tag 0.
  | LinkFormat  -- ^ Tag 1.
  | Xml  -- ^ Tag 2.
  | OctetStream  -- ^ Tag 3.
  | Exi  -- ^ Tag 4.
  | Json  -- ^ Tag 5.
  | Cbor  -- ^ Tag 6.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'ContentFormat' to its ABI tag value.
contentFormatToTag :: ContentFormat -> Word8
contentFormatToTag = fromIntegral . fromEnum

-- | Decode a 'ContentFormat' from its ABI tag value.
contentFormatFromTag :: Word8 -> Maybe ContentFormat
contentFormatFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: ContentFormat)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- ResponseClass
-- ---------------------------------------------------------------------------

-- | ResponseClass type matching the Idris2 ABI.
--
-- Tags 0-4 (5 constructors).
data ResponseClass
  = Success  -- ^ Tag 0.
  | ClientError  -- ^ Tag 1.
  | ServerError  -- ^ Tag 2.
  | Signaling  -- ^ Tag 3.
  | Empty  -- ^ Tag 4.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'ResponseClass' to its ABI tag value.
responseClassToTag :: ResponseClass -> Word8
responseClassToTag = fromIntegral . fromEnum

-- | Decode a 'ResponseClass' from its ABI tag value.
responseClassFromTag :: Word8 -> Maybe ResponseClass
responseClassFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: ResponseClass)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- SessionState
-- ---------------------------------------------------------------------------

-- | SessionState type matching the Idris2 ABI.
--
-- Tags 0-4 (5 constructors).
data SessionState
  = Idle  -- ^ Tag 0.
  | Bound  -- ^ Tag 1.
  | Serving  -- ^ Tag 2.
  | Observing  -- ^ Tag 3.
  | Shutdown  -- ^ Tag 4.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'SessionState' to its ABI tag value.
sessionStateToTag :: SessionState -> Word8
sessionStateToTag = fromIntegral . fromEnum

-- | Decode a 'SessionState' from its ABI tag value.
sessionStateFromTag :: Word8 -> Maybe SessionState
sessionStateFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: SessionState)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing
