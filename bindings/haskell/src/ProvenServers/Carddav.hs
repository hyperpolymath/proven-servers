-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- | CardDAV types for the proven-servers ABI.
--
-- All tag values match the Idris2 ABI discriminants exactly.

module ProvenServers.Carddav
  (
    carddavPort
  , PropertyType(..)
  , propertyTypeToTag
  , propertyTypeFromTag
  , CardMethod(..)
  , cardMethodToTag
  , cardMethodFromTag
  , VCardVersion(..)
  , vCardVersionToTag
  , vCardVersionFromTag
  , CardError(..)
  , cardErrorToTag
  , cardErrorFromTag
  , ServerState(..)
  , serverStateToTag
  , serverStateFromTag
  ) where

import Data.Word (Word16, Word8)

-- | Standard CardDAV HTTPS port.
carddavPort :: Word16
carddavPort = 443

-- ---------------------------------------------------------------------------
-- PropertyType
-- ---------------------------------------------------------------------------

-- | Standard CardDAV HTTPS port.
--
-- Tags 0-8 (9 constructors).
data PropertyType
  = FnName  -- ^ FN (full name) (tag 0).
  | N  -- ^ Structured name (tag 1).
  | Email  -- ^ Email (tag 2).
  | Tel  -- ^ Telephone (tag 3).
  | Adr  -- ^ Address (tag 4).
  | Org  -- ^ Organization (tag 5).
  | Photo  -- ^ Photo (tag 6).
  | Url  -- ^ URL (tag 7).
  | Note  -- ^ Note (tag 8).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'PropertyType' to its ABI tag value.
propertyTypeToTag :: PropertyType -> Word8
propertyTypeToTag = fromIntegral . fromEnum

-- | Decode a 'PropertyType' from its ABI tag value.
propertyTypeFromTag :: Word8 -> Maybe PropertyType
propertyTypeFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: PropertyType)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- CardMethod
-- ---------------------------------------------------------------------------

-- | CardDAV methods.
--
-- Tags 0-6 (7 constructors).
data CardMethod
  = Get  -- ^ Get (tag 0).
  | Put  -- ^ Put (tag 1).
  | Delete  -- ^ Delete (tag 2).
  | Propfind  -- ^ PROPFIND (tag 3).
  | Proppatch  -- ^ PROPPATCH (tag 4).
  | Report  -- ^ REPORT (tag 5).
  | Mkcol  -- ^ MKCOL (tag 6).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'CardMethod' to its ABI tag value.
cardMethodToTag :: CardMethod -> Word8
cardMethodToTag = fromIntegral . fromEnum

-- | Decode a 'CardMethod' from its ABI tag value.
cardMethodFromTag :: Word8 -> Maybe CardMethod
cardMethodFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: CardMethod)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- VCardVersion
-- ---------------------------------------------------------------------------

-- | vCard versions.
--
-- Tags 0-1 (2 constructors).
data VCardVersion
  = Vcard3  -- ^ vCard 3.0 (tag 0).
  | Vcard4  -- ^ vCard 4.0 (tag 1).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'VCardVersion' to its ABI tag value.
vCardVersionToTag :: VCardVersion -> Word8
vCardVersionToTag = fromIntegral . fromEnum

-- | Decode a 'VCardVersion' from its ABI tag value.
vCardVersionFromTag :: Word8 -> Maybe VCardVersion
vCardVersionFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: VCardVersion)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- CardError
-- ---------------------------------------------------------------------------

-- | CardDAV error codes.
--
-- Tags 0-5 (6 constructors).
data CardError
  = ValidAddressData  -- ^ ValidAddressData (tag 0).
  | NoResourceType  -- ^ NoResourceType (tag 1).
  | MaxResourceSize  -- ^ MaxResourceSize (tag 2).
  | UidConflict  -- ^ UidConflict (tag 3).
  | SupportedAddressData  -- ^ SupportedAddressData (tag 4).
  | PreconditionFailed  -- ^ PreconditionFailed (tag 5).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'CardError' to its ABI tag value.
cardErrorToTag :: CardError -> Word8
cardErrorToTag = fromIntegral . fromEnum

-- | Decode a 'CardError' from its ABI tag value.
cardErrorFromTag :: Word8 -> Maybe CardError
cardErrorFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: CardError)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- ServerState
-- ---------------------------------------------------------------------------

-- | CardDAV server lifecycle states.
--
-- Tags 0-3 (4 constructors).
data ServerState
  = Idle  -- ^ Idle (tag 0).
  | Bound  -- ^ Bound (tag 1).
  | Serving  -- ^ Serving (tag 2).
  | Shutdown  -- ^ Shutdown (tag 3).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'ServerState' to its ABI tag value.
serverStateToTag :: ServerState -> Word8
serverStateToTag = fromIntegral . fromEnum

-- | Decode a 'ServerState' from its ABI tag value.
serverStateFromTag :: Word8 -> Maybe ServerState
serverStateFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: ServerState)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing
