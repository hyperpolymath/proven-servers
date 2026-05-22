-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- | SNMP protocol types for the proven-servers ABI.
--
-- All tag values match the Idris2 ABI discriminants exactly.

module ProvenServers.Snmp
  (
    snmpPort
  , snmpTrapPort
  , Version(..)
  , versionToTag
  , versionFromTag
  , hasUsm
  , usesCommunityStrings
  , supportsGetBulk
  , PduType(..)
  , pduTypeToTag
  , pduTypeFromTag
  , isRequest
  , isNotification
  , isWrite
  , ErrorStatus(..)
  , errorStatusToTag
  , errorStatusFromTag
  , isSuccess
  , isV1Only
  , isAuthError
  ) where

import Data.Word (Word16, Word8)

-- | Standard SNMP agent port (RFC 3411).
snmpPort :: Word16
snmpPort = 161

-- | Standard SNMP trap port (RFC 3411).
snmpTrapPort :: Word16
snmpTrapPort = 162

-- ---------------------------------------------------------------------------
-- Version
-- ---------------------------------------------------------------------------

-- | Standard SNMP agent port (RFC 3411).
--
-- Tags 0-2 (3 constructors).
data Version
  = V1  -- ^ SNMPv1 (RFC 1157) (tag 0).
  | V2c  -- ^ SNMPv2c — community-based SNMPv2 (RFC 3584) (tag 1).
  | V3  -- ^ SNMPv3 — user-based security model (RFC 3414) (tag 2).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'Version' to its ABI tag value.
versionToTag :: Version -> Word8
versionToTag = fromIntegral . fromEnum

-- | Decode a 'Version' from its ABI tag value.
versionFromTag :: Word8 -> Maybe Version
versionFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: Version)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- | Whether this version supports the User-based Security Model (USM).
hasUsm :: Version -> Bool
hasUsm V3 = True
hasUsm _ = False

-- | Whether this version uses community strings for authentication.
usesCommunityStrings :: Version -> Bool
usesCommunityStrings V1 = True
usesCommunityStrings V2c = True
usesCommunityStrings _ = False

-- | Whether this version supports GetBulkRequest.
supportsGetBulk :: Version -> Bool
supportsGetBulk V1 = False
supportsGetBulk _ = True

-- ---------------------------------------------------------------------------
-- PduType
-- ---------------------------------------------------------------------------

-- | SNMP PDU (Protocol Data Unit) types.
--
-- Tags 0-6 (7 constructors).
data PduType
  = GetRequest  -- ^ Get value of specific OIDs (tag 0).
  | GetNextRequest  -- ^ Get next OID in MIB tree (tag 1).
  | GetResponse  -- ^ Response to a request (tag 2).
  | SetRequest  -- ^ Set value of specific OIDs (tag 3).
  | GetBulkRequest  -- ^ Bulk retrieval — SNMPv2c/v3 only (tag 4).
  | InformRequest  -- ^ Manager-to-manager notification (tag 5).
  | SnmpV2Trap  -- ^ SNMPv2 trap notification (tag 6).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'PduType' to its ABI tag value.
pduTypeToTag :: PduType -> Word8
pduTypeToTag = fromIntegral . fromEnum

-- | Decode a 'PduType' from its ABI tag value.
pduTypeFromTag :: Word8 -> Maybe PduType
pduTypeFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: PduType)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- | Whether this PDU is a request from manager to agent.
isRequest :: PduType -> Bool
isRequest GetRequest = True
isRequest GetNextRequest = True
isRequest SetRequest = True
isRequest GetBulkRequest = True
isRequest _ = False

-- | Whether this PDU is a notification (trap or inform).
isNotification :: PduType -> Bool
isNotification InformRequest = True
isNotification SnmpV2Trap = True
isNotification _ = False

-- | Whether this PDU modifies agent state.
isWrite :: PduType -> Bool
isWrite SetRequest = True
isWrite _ = False

-- ---------------------------------------------------------------------------
-- ErrorStatus
-- ---------------------------------------------------------------------------

-- | SNMP error status codes.
--
-- Tags 0-15 (16 constructors).
data ErrorStatus
  = NoError  -- ^ No error occurred (tag 0).
  | TooBig  -- ^ Response too large for transport (tag 1).
  | NoSuchName  -- ^ OID not found — SNMPv1 (tag 2).
  | BadValue  -- ^ Invalid value in set request — SNMPv1 (tag 3).
  | ReadOnly  -- ^ Object is read-only — SNMPv1 (tag 4).
  | GenErr  -- ^ Generic error (tag 5).
  | NoAccess  -- ^ No access to the object (tag 6).
  | WrongType  -- ^ Wrong ASN.1 type for the object (tag 7).
  | WrongLength  -- ^ Wrong value length (tag 8).
  | WrongValue  -- ^ Wrong encoding of value (tag 9).
  | NoCreation  -- ^ Object cannot be created (tag 10).
  | InconsistentValue  -- ^ Value inconsistent with other managed objects (tag 11).
  | ResourceUnavailable  -- ^ Required resource is unavailable (tag 12).
  | CommitFailed  -- ^ Set operation commit failed (tag 13).
  | UndoFailed  -- ^ Set operation undo failed (tag 14).
  | AuthorizationError  -- ^ Authorization error (tag 15).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'ErrorStatus' to its ABI tag value.
errorStatusToTag :: ErrorStatus -> Word8
errorStatusToTag = fromIntegral . fromEnum

-- | Decode a 'ErrorStatus' from its ABI tag value.
errorStatusFromTag :: Word8 -> Maybe ErrorStatus
errorStatusFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: ErrorStatus)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- | Whether this status indicates success.
isSuccess :: ErrorStatus -> Bool
isSuccess NoError = True
isSuccess _ = False

-- | Whether this is an SNMPv1-only error code.
isV1Only :: ErrorStatus -> Bool
isV1Only NoSuchName = True
isV1Only BadValue = True
isV1Only ReadOnly = True
isV1Only _ = False

-- | Whether this error relates to authorisation/access control.
isAuthError :: ErrorStatus -> Bool
isAuthError NoAccess = True
isAuthError AuthorizationError = True
isAuthError _ = False
