-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- | CardDAV protocol types for proven-servers.
--
-- CardDAV types (RFC 6352), mirroring the Idris2 ABI.
-- All tag values match the Idris2 ABI discriminants exactly.
--
-- This is a pure type-definition module with no FFI dependencies.

module ProvenServers.Carddav
  ( -- * ADT types matching Idris2 ABI
      PropertyType(..)
    , CardMethod(..)
    , VCardVersion(..)
    , CardError(..)
    , ServerState(..)
    , propertyTypeToTag
    , propertyTypeFromTag
    , cardMethodToTag
    , cardMethodFromTag
    , vCardVersionToTag
    , vCardVersionFromTag
    , cardErrorToTag
    , cardErrorFromTag
    , serverStateToTag
    , serverStateFromTag
  ) where

import Data.Word (Word8)

-- ---------------------------------------------------------------------------
-- PropertyType
-- ---------------------------------------------------------------------------

-- | PropertyType type matching the Idris2 ABI.
--
-- Tags 0-8 (9 constructors).
data PropertyType
  = FnName  -- ^ Tag 0.
  | N  -- ^ Tag 1.
  | Email  -- ^ Tag 2.
  | Tel  -- ^ Tag 3.
  | Adr  -- ^ Tag 4.
  | Org  -- ^ Tag 5.
  | Photo  -- ^ Tag 6.
  | Url  -- ^ Tag 7.
  | Note  -- ^ Tag 8.
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

-- | CardMethod type matching the Idris2 ABI.
--
-- Tags 0-6 (7 constructors).
data CardMethod
  = Get  -- ^ Tag 0.
  | Put  -- ^ Tag 1.
  | Delete  -- ^ Tag 2.
  | Propfind  -- ^ Tag 3.
  | Proppatch  -- ^ Tag 4.
  | Report  -- ^ Tag 5.
  | Mkcol  -- ^ Tag 6.
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

-- | VCardVersion type matching the Idris2 ABI.
--
-- Tags 0-1 (2 constructors).
data VCardVersion
  = Vcard3  -- ^ Tag 0.
  | Vcard4  -- ^ Tag 1.
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

-- | CardError type matching the Idris2 ABI.
--
-- Tags 0-5 (6 constructors).
data CardError
  = ValidAddressData  -- ^ Tag 0.
  | NoResourceType  -- ^ Tag 1.
  | MaxResourceSize  -- ^ Tag 2.
  | UidConflict  -- ^ Tag 3.
  | SupportedAddressData  -- ^ Tag 4.
  | PreconditionFailed  -- ^ Tag 5.
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

-- | ServerState type matching the Idris2 ABI.
--
-- Tags 0-3 (4 constructors).
data ServerState
  = Idle  -- ^ Tag 0.
  | Bound  -- ^ Tag 1.
  | Serving  -- ^ Tag 2.
  | Shutdown  -- ^ Tag 3.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'ServerState' to its ABI tag value.
serverStateToTag :: ServerState -> Word8
serverStateToTag = fromIntegral . fromEnum

-- | Decode a 'ServerState' from its ABI tag value.
serverStateFromTag :: Word8 -> Maybe ServerState
serverStateFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: ServerState)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing
