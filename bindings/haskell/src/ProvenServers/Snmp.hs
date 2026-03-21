-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- | SNMP protocol types for proven-servers.
--
-- SNMP (Simple Network Management Protocol) types, mirroring the Idris2 ABI.
-- All tag values match the Idris2 ABI discriminants exactly.
--
-- This is a pure type-definition module with no FFI dependencies.

module ProvenServers.Snmp
  ( -- * ADT types matching Idris2 ABI
      Version(..)
    , PduType(..)
    , ErrorStatus(..)
    , versionToTag
    , versionFromTag
    , pduTypeToTag
    , pduTypeFromTag
    , errorStatusToTag
    , errorStatusFromTag
  ) where

import Data.Word (Word8)

-- ---------------------------------------------------------------------------
-- Version
-- ---------------------------------------------------------------------------

-- | Version type matching the Idris2 ABI.
--
-- Tags 0-2 (3 constructors).
data Version
  = V1  -- ^ Tag 0.
  | V2c  -- ^ Tag 1.
  | V3  -- ^ Tag 2.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'Version' to its ABI tag value.
versionToTag :: Version -> Word8
versionToTag = fromIntegral . fromEnum

-- | Decode a 'Version' from its ABI tag value.
versionFromTag :: Word8 -> Maybe Version
versionFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: Version)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- PduType
-- ---------------------------------------------------------------------------

-- | PduType type matching the Idris2 ABI.
--
-- Tags 0-6 (7 constructors).
data PduType
  = GetRequest  -- ^ Tag 0.
  | GetNextRequest  -- ^ Tag 1.
  | GetResponse  -- ^ Tag 2.
  | SetRequest  -- ^ Tag 3.
  | GetBulkRequest  -- ^ Tag 4.
  | InformRequest  -- ^ Tag 5.
  | SnmpV2Trap  -- ^ Tag 6.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'PduType' to its ABI tag value.
pduTypeToTag :: PduType -> Word8
pduTypeToTag = fromIntegral . fromEnum

-- | Decode a 'PduType' from its ABI tag value.
pduTypeFromTag :: Word8 -> Maybe PduType
pduTypeFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: PduType)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- ErrorStatus
-- ---------------------------------------------------------------------------

-- | ErrorStatus type matching the Idris2 ABI.
--
-- Tags 0-15 (16 constructors).
data ErrorStatus
  = NoError  -- ^ Tag 0.
  | TooBig  -- ^ Tag 1.
  | NoSuchName  -- ^ Tag 2.
  | BadValue  -- ^ Tag 3.
  | ReadOnly  -- ^ Tag 4.
  | GenErr  -- ^ Tag 5.
  | NoAccess  -- ^ Tag 6.
  | WrongType  -- ^ Tag 7.
  | WrongLength  -- ^ Tag 8.
  | WrongValue  -- ^ Tag 9.
  | NoCreation  -- ^ Tag 10.
  | InconsistentValue  -- ^ Tag 11.
  | ResourceUnavailable  -- ^ Tag 12.
  | CommitFailed  -- ^ Tag 13.
  | UndoFailed  -- ^ Tag 14.
  | AuthorizationError  -- ^ Tag 15.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'ErrorStatus' to its ABI tag value.
errorStatusToTag :: ErrorStatus -> Word8
errorStatusToTag = fromIntegral . fromEnum

-- | Decode a 'ErrorStatus' from its ABI tag value.
errorStatusFromTag :: Word8 -> Maybe ErrorStatus
errorStatusFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: ErrorStatus)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing
