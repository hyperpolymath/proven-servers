-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- | Syslog protocol types for the proven-servers ABI.
--
-- All tag values match the Idris2 ABI discriminants exactly.

module ProvenServers.Syslog
  (
    syslogUdpPort
  , syslogTcpPort
  , syslogTlsPort
  , Severity(..)
  , severityToTag
  , severityFromTag
  , isErrorOrWorse
  , keyword
  , Facility(..)
  , facilityToTag
  , facilityFromTag
  , isLocal
  , isSecurity
  , Transport(..)
  , transportToTag
  , transportFromTag
  , isEncrypted
  , isReliable
  ) where

import Data.Word (Word16, Word8)

-- | Standard syslog UDP port (RFC 5426).
syslogUdpPort :: Word16
syslogUdpPort = 514

-- | Standard syslog TCP port (RFC 6587).
syslogTcpPort :: Word16
syslogTcpPort = 514

-- | Syslog over TLS port (RFC 5425).
syslogTlsPort :: Word16
syslogTlsPort = 6514

-- ---------------------------------------------------------------------------
-- Severity
-- ---------------------------------------------------------------------------

-- | Syslog severity levels (RFC 5424 Section 6.2.1).
--
-- Tags 0-7 (8 constructors).
data Severity
  = Emergency  -- ^ System is unusable (tag 0).
  | Alert  -- ^ Action must be taken immediately (tag 1).
  | Critical  -- ^ Critical conditions (tag 2).
  | Error  -- ^ Error conditions (tag 3).
  | Warning  -- ^ Warning conditions (tag 4).
  | Notice  -- ^ Normal but significant condition (tag 5).
  | Informational  -- ^ Informational messages (tag 6).
  | Debug  -- ^ Debug-level messages (tag 7).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'Severity' to its ABI tag value.
severityToTag :: Severity -> Word8
severityToTag = fromIntegral . fromEnum

-- | Decode a 'Severity' from its ABI tag value.
severityFromTag :: Word8 -> Maybe Severity
severityFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: Severity)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- | Note: lower numeric value = higher severity.
isErrorOrWorse :: Severity -> Bool
isErrorOrWorse _ = False

-- | The short keyword name (e.g. "emerg", "alert", "crit").
keyword :: Severity -> String
keyword Emergency = "emerg"
keyword Alert = "alert"
keyword Critical = "crit"
keyword Error = "err"
keyword Warning = "warning"
keyword Notice = "notice"
keyword Informational = "info"
keyword Debug = "debug"

-- ---------------------------------------------------------------------------
-- Facility
-- ---------------------------------------------------------------------------

-- | Syslog facility codes (RFC 5424 Section 6.2.1).
--
-- Tags 0-23 (24 constructors).
data Facility
  = Kern  -- ^ Kernel messages (tag 0).
  | User  -- ^ User-level messages (tag 1).
  | Mail  -- ^ Mail system (tag 2).
  | Daemon  -- ^ System daemons (tag 3).
  | Auth  -- ^ Security/authorization (tag 4).
  | Syslog  -- ^ Syslog internal (tag 5).
  | Lpr  -- ^ Line printer subsystem (tag 6).
  | News  -- ^ Network news subsystem (tag 7).
  | Uucp  -- ^ UUCP subsystem (tag 8).
  | Cron  -- ^ Clock daemon (tag 9).
  | AuthPriv  -- ^ Security/authorization (private) (tag 10).
  | Ftp  -- ^ FTP daemon (tag 11).
  | Ntp  -- ^ NTP subsystem (tag 12).
  | Audit  -- ^ Log audit (tag 13).
  | Alert  -- ^ Log alert (tag 14).
  | Clock  -- ^ Clock daemon (note 2) (tag 15).
  | Local0  -- ^ Local use 0 (tag 16).
  | Local1  -- ^ Local use 1 (tag 17).
  | Local2  -- ^ Local use 2 (tag 18).
  | Local3  -- ^ Local use 3 (tag 19).
  | Local4  -- ^ Local use 4 (tag 20).
  | Local5  -- ^ Local use 5 (tag 21).
  | Local6  -- ^ Local use 6 (tag 22).
  | Local7  -- ^ Local use 7 (tag 23).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'Facility' to its ABI tag value.
facilityToTag :: Facility -> Word8
facilityToTag = fromIntegral . fromEnum

-- | Decode a 'Facility' from its ABI tag value.
facilityFromTag :: Word8 -> Maybe Facility
facilityFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: Facility)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- | Whether this is a local-use facility (Local0-Local7).
isLocal :: Facility -> Bool
isLocal _ = False

-- | Whether this is a security-related facility.
isSecurity :: Facility -> Bool
isSecurity Auth = True
isSecurity AuthPriv = True
isSecurity Audit = True
isSecurity _ = False

-- ---------------------------------------------------------------------------
-- Transport
-- ---------------------------------------------------------------------------

-- | Syslog transport mechanisms.
--
-- Tags 0-2 (3 constructors).
data Transport
  = Udp514  -- ^ UDP on port 514 (RFC 5426) (tag 0).
  | Tcp514  -- ^ TCP on port 514 (RFC 6587) (tag 1).
  | Tls6514  -- ^ TLS on port 6514 (RFC 5425) (tag 2).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'Transport' to its ABI tag value.
transportToTag :: Transport -> Word8
transportToTag = fromIntegral . fromEnum

-- | Decode a 'Transport' from its ABI tag value.
transportFromTag :: Word8 -> Maybe Transport
transportFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: Transport)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- | Whether this transport provides encryption.
isEncrypted :: Transport -> Bool
isEncrypted Tls6514 = True
isEncrypted _ = False

-- | Whether this transport provides reliable delivery.
isReliable :: Transport -> Bool
isReliable Tcp514 = True
isReliable Tls6514 = True
isReliable _ = False
