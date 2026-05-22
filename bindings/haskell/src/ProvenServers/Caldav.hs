-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- | CalDAV types for the proven-servers ABI.
--
-- All tag values match the Idris2 ABI discriminants exactly.

module ProvenServers.Caldav
  (
    caldavPort
  , ComponentType(..)
  , componentTypeToTag
  , componentTypeFromTag
  , CalMethod(..)
  , calMethodToTag
  , calMethodFromTag
  , ScheduleStatus(..)
  , scheduleStatusToTag
  , scheduleStatusFromTag
  , CalError(..)
  , calErrorToTag
  , calErrorFromTag
  , ServerState(..)
  , serverStateToTag
  , serverStateFromTag
  ) where

import Data.Word (Word16, Word8)

-- | Standard CalDAV HTTPS port.
caldavPort :: Word16
caldavPort = 443

-- ---------------------------------------------------------------------------
-- ComponentType
-- ---------------------------------------------------------------------------

-- | Standard CalDAV HTTPS port.
--
-- Tags 0-3 (4 constructors).
data ComponentType
  = Vevent  -- ^ VEVENT (tag 0).
  | Vtodo  -- ^ VTODO (tag 1).
  | Vjournal  -- ^ VJOURNAL (tag 2).
  | Vfreebusy  -- ^ VFREEBUSY (tag 3).
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

-- | CalDAV methods.
--
-- Tags 0-6 (7 constructors).
data CalMethod
  = Get  -- ^ Get (tag 0).
  | Put  -- ^ Put (tag 1).
  | Delete  -- ^ Delete (tag 2).
  | Propfind  -- ^ PROPFIND (tag 3).
  | Proppatch  -- ^ PROPPATCH (tag 4).
  | Report  -- ^ REPORT (tag 5).
  | Mkcalendar  -- ^ MKCALENDAR (tag 6).
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

-- | CalDAV scheduling statuses.
--
-- Tags 0-4 (5 constructors).
data ScheduleStatus
  = NeedsAction  -- ^ NeedsAction (tag 0).
  | Accepted  -- ^ Accepted (tag 1).
  | Declined  -- ^ Declined (tag 2).
  | Tentative  -- ^ Tentative (tag 3).
  | Delegated  -- ^ Delegated (tag 4).
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

-- | CalDAV error codes.
--
-- Tags 0-5 (6 constructors).
data CalError
  = ValidCalendarData  -- ^ ValidCalendarData (tag 0).
  | NoResourceTypeChange  -- ^ NoResourceTypeChange (tag 1).
  | SupportedComponentMismatch  -- ^ SupportedComponentMismatch (tag 2).
  | MaxResourceSize  -- ^ MaxResourceSize (tag 3).
  | UidConflict  -- ^ UidConflict (tag 4).
  | PreconditionFailed  -- ^ PreconditionFailed (tag 5).
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

-- | CalDAV server lifecycle states.
--
-- Tags 0-4 (5 constructors).
data ServerState
  = Idle  -- ^ Idle (tag 0).
  | Bound  -- ^ Bound (tag 1).
  | Serving  -- ^ Serving (tag 2).
  | Scheduling  -- ^ Scheduling (tag 3).
  | Shutdown  -- ^ Shutdown (tag 4).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'ServerState' to its ABI tag value.
serverStateToTag :: ServerState -> Word8
serverStateToTag = fromIntegral . fromEnum

-- | Decode a 'ServerState' from its ABI tag value.
serverStateFromTag :: Word8 -> Maybe ServerState
serverStateFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: ServerState)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing
