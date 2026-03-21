-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- | Hardened protocol types for proven-servers.
--
-- Hardened server types, mirroring the Idris2 ABI.
-- All tag values match the Idris2 ABI discriminants exactly.
--
-- This is a pure type-definition module with no FFI dependencies.

module ProvenServers.Hardened
  ( -- * ADT types matching Idris2 ABI
      HardeningLevel(..)
    , SecurityControl(..)
    , ComplianceStandard(..)
    , AuditEvent(..)
    , HardenedHealthStatus(..)
    , ServerState(..)
    , hardeningLevelToTag
    , hardeningLevelFromTag
    , securityControlToTag
    , securityControlFromTag
    , complianceStandardToTag
    , complianceStandardFromTag
    , auditEventToTag
    , auditEventFromTag
    , hardenedHealthStatusToTag
    , hardenedHealthStatusFromTag
    , serverStateToTag
    , serverStateFromTag
  ) where

import Data.Word (Word8)

-- ---------------------------------------------------------------------------
-- HardeningLevel
-- ---------------------------------------------------------------------------

-- | HardeningLevel type matching the Idris2 ABI.
--
-- Tags 0-3 (4 constructors).
data HardeningLevel
  = Minimal  -- ^ Tag 0.
  | Standard  -- ^ Tag 1.
  | High  -- ^ Tag 2.
  | Maximum  -- ^ Tag 3.
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

-- | SecurityControl type matching the Idris2 ABI.
--
-- Tags 0-6 (7 constructors).
data SecurityControl
  = Aslr  -- ^ Tag 0.
  | Dep  -- ^ Tag 1.
  | StackCanary  -- ^ Tag 2.
  | Cfi  -- ^ Tag 3.
  | Sandboxing  -- ^ Tag 4.
  | SecureBoot  -- ^ Tag 5.
  | AuditLog  -- ^ Tag 6.
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

-- | ComplianceStandard type matching the Idris2 ABI.
--
-- Tags 0-4 (5 constructors).
data ComplianceStandard
  = Cis  -- ^ Tag 0.
  | Stig  -- ^ Tag 1.
  | Nist80053  -- ^ Tag 2.
  | PciDss  -- ^ Tag 3.
  | Fips140  -- ^ Tag 4.
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

-- | AuditEvent type matching the Idris2 ABI.
--
-- Tags 0-5 (6 constructors).
data AuditEvent
  = ProcessStart  -- ^ Tag 0.
  | FileAccess  -- ^ Tag 1.
  | NetworkConn  -- ^ Tag 2.
  | PrivilegeEscalation  -- ^ Tag 3.
  | ConfigChange  -- ^ Tag 4.
  | AuthAttempt  -- ^ Tag 5.
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

-- | HardenedHealthStatus type matching the Idris2 ABI.
--
-- Tags 0-3 (4 constructors).
data HardenedHealthStatus
  = Healthy  -- ^ Tag 0.
  | Degraded  -- ^ Tag 1.
  | Compromised  -- ^ Tag 2.
  | Unresponsive  -- ^ Tag 3.
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

-- | ServerState type matching the Idris2 ABI.
--
-- Tags 0-4 (5 constructors).
data ServerState
  = Idle  -- ^ Tag 0.
  | Hardening  -- ^ Tag 1.
  | Active  -- ^ Tag 2.
  | Auditing  -- ^ Tag 3.
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
