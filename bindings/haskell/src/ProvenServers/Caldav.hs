-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- | CalDAV protocol types for proven-servers.
--
-- CalDAV types (RFC 4791), mirroring the Idris2 ABI.
-- All tag values match the Idris2 ABI discriminants exactly.
--
-- This is a pure type-definition module with no FFI dependencies.

module ProvenServers.Caldav
  ( -- * ADT types matching Idris2 ABI
      ComponentType(..)
    , CalMethod(..)
    , ScheduleStatus(..)
    , CalError(..)
    , ServerState(..)
    , componentTypeToTag
    , componentTypeFromTag
    , calMethodToTag
    , calMethodFromTag
    , scheduleStatusToTag
    , scheduleStatusFromTag
    , calErrorToTag
    , calErrorFromTag
    , serverStateToTag
    , serverStateFromTag
  ) where

import Data.Word (Word8)

-- ---------------------------------------------------------------------------
-- ComponentType
-- ---------------------------------------------------------------------------

-- | ComponentType type matching the Idris2 ABI.
--
-- Tags 0-3 (4 constructors).
data ComponentType
  = Vevent  -- ^ Tag 0.
  | Vtodo  -- ^ Tag 1.
  | Vjournal  -- ^ Tag 2.
  | Vfreebusy  -- ^ Tag 3.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'ComponentType' to its ABI tag value.
componentTypeToTag :: ComponentType -> Word8
componentTypeToTag = fromIntegral . fromEnum

-- | Decode a 'ComponentType' from its ABI tag value.
componentTypeFromTag :: Word8 -> Maybe ComponentType
componentTypeFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: ComponentType)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- CalMethod
-- ---------------------------------------------------------------------------

-- | CalMethod type matching the Idris2 ABI.
--
-- Tags 0-6 (7 constructors).
data CalMethod
  = Get  -- ^ Tag 0.
  | Put  -- ^ Tag 1.
  | Delete  -- ^ Tag 2.
  | Propfind  -- ^ Tag 3.
  | Proppatch  -- ^ Tag 4.
  | Report  -- ^ Tag 5.
  | Mkcalendar  -- ^ Tag 6.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'CalMethod' to its ABI tag value.
calMethodToTag :: CalMethod -> Word8
calMethodToTag = fromIntegral . fromEnum

-- | Decode a 'CalMethod' from its ABI tag value.
calMethodFromTag :: Word8 -> Maybe CalMethod
calMethodFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: CalMethod)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- ScheduleStatus
-- ---------------------------------------------------------------------------

-- | ScheduleStatus type matching the Idris2 ABI.
--
-- Tags 0-4 (5 constructors).
data ScheduleStatus
  = NeedsAction  -- ^ Tag 0.
  | Accepted  -- ^ Tag 1.
  | Declined  -- ^ Tag 2.
  | Tentative  -- ^ Tag 3.
  | Delegated  -- ^ Tag 4.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'ScheduleStatus' to its ABI tag value.
scheduleStatusToTag :: ScheduleStatus -> Word8
scheduleStatusToTag = fromIntegral . fromEnum

-- | Decode a 'ScheduleStatus' from its ABI tag value.
scheduleStatusFromTag :: Word8 -> Maybe ScheduleStatus
scheduleStatusFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: ScheduleStatus)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- CalError
-- ---------------------------------------------------------------------------

-- | CalError type matching the Idris2 ABI.
--
-- Tags 0-5 (6 constructors).
data CalError
  = ValidCalendarData  -- ^ Tag 0.
  | NoResourceTypeChange  -- ^ Tag 1.
  | SupportedComponentMismatch  -- ^ Tag 2.
  | MaxResourceSize  -- ^ Tag 3.
  | UidConflict  -- ^ Tag 4.
  | PreconditionFailed  -- ^ Tag 5.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'CalError' to its ABI tag value.
calErrorToTag :: CalError -> Word8
calErrorToTag = fromIntegral . fromEnum

-- | Decode a 'CalError' from its ABI tag value.
calErrorFromTag :: Word8 -> Maybe CalError
calErrorFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: CalError)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- ServerState
-- ---------------------------------------------------------------------------

-- | ServerState type matching the Idris2 ABI.
--
-- Tags 0-4 (5 constructors).
data ServerState
  = Idle  -- ^ Tag 0.
  | Bound  -- ^ Tag 1.
  | Serving  -- ^ Tag 2.
  | Scheduling  -- ^ Tag 3.
  | Shutdown  -- ^ Tag 4.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'ServerState' to its ABI tag value.
serverStateToTag :: ServerState -> Word8
serverStateToTag = fromIntegral . fromEnum

-- | Decode a 'ServerState' from its ABI tag value.
serverStateFromTag :: Word8 -> Maybe ServerState
serverStateFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: ServerState)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing
