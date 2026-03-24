-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- | Hardened Server types for the proven-servers ABI.
--
-- All tag values match the Idris2 ABI discriminants exactly.

module ProvenServers.Hardened
  (
    HardeningLevel(..)
  , hardeningLevelToTag
  , hardeningLevelFromTag
  , SecurityControl(..)
  , securityControlToTag
  , securityControlFromTag
  , ComplianceStandard(..)
  , complianceStandardToTag
  , complianceStandardFromTag
  , AuditEvent(..)
  , auditEventToTag
  , auditEventFromTag
  , HardenedHealthStatus(..)
  , hardenedHealthStatusToTag
  , hardenedHealthStatusFromTag
  , ServerState(..)
  , serverStateToTag
  , serverStateFromTag
  ) where

import Data.Word (Word8)

-- ---------------------------------------------------------------------------
-- HardeningLevel
-- ---------------------------------------------------------------------------

-- | System hardening levels.
--
-- Tags 0-3 (4 constructors).
data HardeningLevel
  = Minimal  -- ^ Minimal (tag 0).
  | Standard  -- ^ Standard (tag 1).
  | High  -- ^ High (tag 2).
  | Maximum  -- ^ Maximum (tag 3).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'HardeningLevel' to its ABI tag value.
hardeningLevelToTag :: HardeningLevel -> Word8
hardeningLevelToTag = fromIntegral . fromEnum

-- | Decode a 'HardeningLevel' from its ABI tag value.
hardeningLevelFromTag :: Word8 -> Maybe HardeningLevel
hardeningLevelFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: HardeningLevel)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- SecurityControl
-- ---------------------------------------------------------------------------

-- | Security controls.
--
-- Tags 0-6 (7 constructors).
data SecurityControl
  = Aslr  -- ^ ASLR (tag 0).
  | Dep  -- ^ DEP (tag 1).
  | StackCanary  -- ^ StackCanary (tag 2).
  | Cfi  -- ^ CFI (tag 3).
  | Sandboxing  -- ^ Sandboxing (tag 4).
  | SecureBoot  -- ^ SecureBoot (tag 5).
  | AuditLog  -- ^ AuditLog (tag 6).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'SecurityControl' to its ABI tag value.
securityControlToTag :: SecurityControl -> Word8
securityControlToTag = fromIntegral . fromEnum

-- | Decode a 'SecurityControl' from its ABI tag value.
securityControlFromTag :: Word8 -> Maybe SecurityControl
securityControlFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: SecurityControl)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- ComplianceStandard
-- ---------------------------------------------------------------------------

-- | Security compliance standards.
--
-- Tags 0-4 (5 constructors).
data ComplianceStandard
  = Cis  -- ^ CIS Benchmark (tag 0).
  | Stig  -- ^ DISA STIG (tag 1).
  | Nist80053  -- ^ NIST 800-53 (tag 2).
  | PciDss  -- ^ PCI-DSS (tag 3).
  | Fips140  -- ^ FIPS 140 (tag 4).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'ComplianceStandard' to its ABI tag value.
complianceStandardToTag :: ComplianceStandard -> Word8
complianceStandardToTag = fromIntegral . fromEnum

-- | Decode a 'ComplianceStandard' from its ABI tag value.
complianceStandardFromTag :: Word8 -> Maybe ComplianceStandard
complianceStandardFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: ComplianceStandard)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- AuditEvent
-- ---------------------------------------------------------------------------

-- | Audit event types.
--
-- Tags 0-5 (6 constructors).
data AuditEvent
  = ProcessStart  -- ^ ProcessStart (tag 0).
  | FileAccess  -- ^ FileAccess (tag 1).
  | NetworkConn  -- ^ NetworkConn (tag 2).
  | PrivilegeEscalation  -- ^ PrivilegeEscalation (tag 3).
  | ConfigChange  -- ^ ConfigChange (tag 4).
  | AuthAttempt  -- ^ AuthAttempt (tag 5).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'AuditEvent' to its ABI tag value.
auditEventToTag :: AuditEvent -> Word8
auditEventToTag = fromIntegral . fromEnum

-- | Decode a 'AuditEvent' from its ABI tag value.
auditEventFromTag :: Word8 -> Maybe AuditEvent
auditEventFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: AuditEvent)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- HardenedHealthStatus
-- ---------------------------------------------------------------------------

-- | Hardened system health.
--
-- Tags 0-3 (4 constructors).
data HardenedHealthStatus
  = Healthy  -- ^ Healthy (tag 0).
  | Degraded  -- ^ Degraded (tag 1).
  | Compromised  -- ^ Compromised (tag 2).
  | Unresponsive  -- ^ Unresponsive (tag 3).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'HardenedHealthStatus' to its ABI tag value.
hardenedHealthStatusToTag :: HardenedHealthStatus -> Word8
hardenedHealthStatusToTag = fromIntegral . fromEnum

-- | Decode a 'HardenedHealthStatus' from its ABI tag value.
hardenedHealthStatusFromTag :: Word8 -> Maybe HardenedHealthStatus
hardenedHealthStatusFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: HardenedHealthStatus)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- ServerState
-- ---------------------------------------------------------------------------

-- | Hardened server states.
--
-- Tags 0-4 (5 constructors).
data ServerState
  = Idle  -- ^ Idle (tag 0).
  | Hardening  -- ^ Hardening (tag 1).
  | Active  -- ^ Active (tag 2).
  | Auditing  -- ^ Auditing (tag 3).
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
