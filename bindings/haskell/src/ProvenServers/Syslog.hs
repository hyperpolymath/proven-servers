-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- | Syslog protocol types for proven-servers.
--
-- Syslog protocol types, mirroring the Idris2 ABI.
-- All tag values match the Idris2 ABI discriminants exactly.
--
-- This is a pure type-definition module with no FFI dependencies.

module ProvenServers.Syslog
  ( -- * ADT types matching Idris2 ABI
      Severity(..)
    , Facility(..)
    , Transport(..)
    , severityToTag
    , severityFromTag
    , facilityToTag
    , facilityFromTag
    , transportToTag
    , transportFromTag
  ) where

import Data.Word (Word8)

-- ---------------------------------------------------------------------------
-- Severity
-- ---------------------------------------------------------------------------

-- | Severity type matching the Idris2 ABI.
--
-- Tags 0-7 (8 constructors).
data Severity
  = Emergency  -- ^ Tag 0.
  | Severity_Alert  -- ^ Tag 1.
  | Critical  -- ^ Tag 2.
  | Error  -- ^ Tag 3.
  | Warning  -- ^ Tag 4.
  | Notice  -- ^ Tag 5.
  | Informational  -- ^ Tag 6.
  | Debug  -- ^ Tag 7.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'Severity' to its ABI tag value.
severityToTag :: Severity -> Word8
severityToTag = fromIntegral . fromEnum

-- | Decode a 'Severity' from its ABI tag value.
severityFromTag :: Word8 -> Maybe Severity
severityFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: Severity)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- Facility
-- ---------------------------------------------------------------------------

-- | Facility type matching the Idris2 ABI.
--
-- Tags 0-23 (24 constructors).
data Facility
  = Kern  -- ^ Tag 0.
  | User  -- ^ Tag 1.
  | Mail  -- ^ Tag 2.
  | Daemon  -- ^ Tag 3.
  | Auth  -- ^ Tag 4.
  | Syslog  -- ^ Tag 5.
  | Lpr  -- ^ Tag 6.
  | News  -- ^ Tag 7.
  | Uucp  -- ^ Tag 8.
  | Cron  -- ^ Tag 9.
  | AuthPriv  -- ^ Tag 10.
  | Ftp  -- ^ Tag 11.
  | Ntp  -- ^ Tag 12.
  | Audit  -- ^ Tag 13.
  | Facility_Alert  -- ^ Tag 14.
  | Clock  -- ^ Tag 15.
  | Local0  -- ^ Tag 16.
  | Local1  -- ^ Tag 17.
  | Local2  -- ^ Tag 18.
  | Local3  -- ^ Tag 19.
  | Local4  -- ^ Tag 20.
  | Local5  -- ^ Tag 21.
  | Local6  -- ^ Tag 22.
  | Local7  -- ^ Tag 23.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'Facility' to its ABI tag value.
facilityToTag :: Facility -> Word8
facilityToTag = fromIntegral . fromEnum

-- | Decode a 'Facility' from its ABI tag value.
facilityFromTag :: Word8 -> Maybe Facility
facilityFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: Facility)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- Transport
-- ---------------------------------------------------------------------------

-- | Transport type matching the Idris2 ABI.
--
-- Tags 0-2 (3 constructors).
data Transport
  = Udp514  -- ^ Tag 0.
  | Tcp514  -- ^ Tag 1.
  | Tls6514  -- ^ Tag 2.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'Transport' to its ABI tag value.
transportToTag :: Transport -> Word8
transportToTag = fromIntegral . fromEnum

-- | Decode a 'Transport' from its ABI tag value.
transportFromTag :: Word8 -> Maybe Transport
transportFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: Transport)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing
