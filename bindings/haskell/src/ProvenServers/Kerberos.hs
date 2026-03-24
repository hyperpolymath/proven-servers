-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- | Kerberos protocol types for the proven-servers ABI.
--
-- All tag values match the Idris2 ABI discriminants exactly.

module ProvenServers.Kerberos
  (
    kerberosPort
  , MessageType(..)
  , messageTypeToTag
  , messageTypeFromTag
  , isRequest
  , isReply
  , EncryptionType(..)
  , encryptionTypeToTag
  , encryptionTypeFromTag
  , isLegacy
  , PrincipalType(..)
  , principalTypeToTag
  , principalTypeFromTag
  , TicketFlag(..)
  , ticketFlagToTag
  , ticketFlagFromTag
  , isDelegation
  , ErrorCode(..)
  , errorCodeToTag
  , errorCodeFromTag
  , isSuccess
  , AuthState(..)
  , authStateToTag
  , authStateFromTag
  , authStateCanTransitionTo
  , EncStrength(..)
  , encStrengthToTag
  , encStrengthFromTag
  , PreAuthType(..)
  , preAuthTypeToTag
  , preAuthTypeFromTag
  , NegotiationState(..)
  , negotiationStateToTag
  , negotiationStateFromTag
  ) where

import Data.Word (Word16, Word8)

-- | Standard Kerberos KDC port (RFC 4120).
kerberosPort :: Word16
kerberosPort = 88

-- ---------------------------------------------------------------------------
-- MessageType
-- ---------------------------------------------------------------------------

-- | Standard Kerberos KDC port (RFC 4120).
--
-- Tags 0-9 (10 constructors).
data MessageType
  = AsReq  -- ^ AS-REQ — Authentication Service request (tag 0).
  | AsRep  -- ^ AS-REP — Authentication Service reply (tag 1).
  | TgsReq  -- ^ TGS-REQ — Ticket-Granting Service request (tag 2).
  | TgsRep  -- ^ TGS-REP — Ticket-Granting Service reply (tag 3).
  | ApReq  -- ^ AP-REQ — Application request (tag 4).
  | ApRep  -- ^ AP-REP — Application reply (tag 5).
  | KrbError  -- ^ KRB-ERROR — Error message (tag 6).
  | KrbSafe  -- ^ KRB-SAFE — Safe (authenticated) message (tag 7).
  | KrbPriv  -- ^ KRB-PRIV — Private (encrypted) message (tag 8).
  | KrbCred  -- ^ KRB-CRED — Credential forwarding (tag 9).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'MessageType' to its ABI tag value.
messageTypeToTag :: MessageType -> Word8
messageTypeToTag = fromIntegral . fromEnum

-- | Decode a 'MessageType' from its ABI tag value.
messageTypeFromTag :: Word8 -> Maybe MessageType
messageTypeFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: MessageType)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- | Whether this message is a request.
isRequest :: MessageType -> Bool
isRequest AsReq = True
isRequest TgsReq = True
isRequest ApReq = True
isRequest _ = False

-- | Whether this message is a reply.
isReply :: MessageType -> Bool
isReply AsRep = True
isReply TgsRep = True
isReply ApRep = True
isReply _ = False

-- ---------------------------------------------------------------------------
-- EncryptionType
-- ---------------------------------------------------------------------------

-- | Kerberos encryption types (RFC 3961).
--
-- Tags 0-4 (5 constructors).
data EncryptionType
  = Aes256CtsHmacSha1  -- ^ AES256-CTS-HMAC-SHA1-96 (tag 0).
  | Aes128CtsHmacSha1  -- ^ AES128-CTS-HMAC-SHA1-96 (tag 1).
  | Aes256CtsHmacSha384  -- ^ AES256-CTS-HMAC-SHA384-192 (tag 2).
  | Rc4Hmac  -- ^ RC4-HMAC (legacy, tag 3).
  | Des3CbcSha1  -- ^ DES3-CBC-SHA1 (legacy, tag 4).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'EncryptionType' to its ABI tag value.
encryptionTypeToTag :: EncryptionType -> Word8
encryptionTypeToTag = fromIntegral . fromEnum

-- | Decode a 'EncryptionType' from its ABI tag value.
encryptionTypeFromTag :: Word8 -> Maybe EncryptionType
encryptionTypeFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: EncryptionType)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- | Whether this encryption type is considered legacy/deprecated.
isLegacy :: EncryptionType -> Bool
isLegacy Rc4Hmac = True
isLegacy Des3CbcSha1 = True
isLegacy _ = False

-- ---------------------------------------------------------------------------
-- PrincipalType
-- ---------------------------------------------------------------------------

-- | Kerberos principal name types (RFC 4120).
--
-- Tags 0-6 (7 constructors).
data PrincipalType
  = NtUnknown  -- ^ NT-UNKNOWN (tag 0).
  | NtPrincipal  -- ^ NT-PRINCIPAL — general principal (tag 1).
  | NtSrvInst  -- ^ NT-SRV-INST — service instance (tag 2).
  | NtSrvHst  -- ^ NT-SRV-HST — service with host (tag 3).
  | NtUid  -- ^ NT-UID — unique ID (tag 4).
  | NtX500  -- ^ NT-X500-PRINCIPAL — X.500 principal (tag 5).
  | NtEnterprise  -- ^ NT-ENTERPRISE — enterprise principal (tag 6).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'PrincipalType' to its ABI tag value.
principalTypeToTag :: PrincipalType -> Word8
principalTypeToTag = fromIntegral . fromEnum

-- | Decode a 'PrincipalType' from its ABI tag value.
principalTypeFromTag :: Word8 -> Maybe PrincipalType
principalTypeFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: PrincipalType)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- TicketFlag
-- ---------------------------------------------------------------------------

-- | Kerberos ticket flags (RFC 4120).
--
-- Tags 0-6 (7 constructors).
data TicketFlag
  = Forwardable  -- ^ Ticket may be forwarded (tag 0).
  | Forwarded  -- ^ Ticket has been forwarded (tag 1).
  | Proxiable  -- ^ Ticket may be proxied (tag 2).
  | Proxy  -- ^ Ticket is a proxy (tag 3).
  | Renewable  -- ^ Ticket may be renewed (tag 4).
  | PreAuthent  -- ^ Client was pre-authenticated (tag 5).
  | HwAuthent  -- ^ Hardware authentication was used (tag 6).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'TicketFlag' to its ABI tag value.
ticketFlagToTag :: TicketFlag -> Word8
ticketFlagToTag = fromIntegral . fromEnum

-- | Decode a 'TicketFlag' from its ABI tag value.
ticketFlagFromTag :: Word8 -> Maybe TicketFlag
ticketFlagFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: TicketFlag)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- | Whether this flag relates to delegation.
isDelegation :: TicketFlag -> Bool
isDelegation Forwardable = True
isDelegation Forwarded = True
isDelegation Proxiable = True
isDelegation Proxy = True
isDelegation _ = False

-- ---------------------------------------------------------------------------
-- ErrorCode
-- ---------------------------------------------------------------------------

-- | Kerberos KDC error codes (RFC 4120).
--
-- Tags 0-9 (10 constructors).
data ErrorCode
  = KdcErrNone  -- ^ KDC_ERR_NONE — no error (tag 0).
  | KdcErrNameExp  -- ^ KDC_ERR_NAME_EXP — client name expired (tag 1).
  | KdcErrServiceExp  -- ^ KDC_ERR_SERVICE_EXP — service name expired (tag 2).
  | KdcErrBadPvno  -- ^ KDC_ERR_BAD_PVNO — bad protocol version (tag 3).
  | KdcErrCOldMastKvno  -- ^ KDC_ERR_C_OLD_MAST_KVNO — client key version too old (tag 4).
  | KdcErrSOldMastKvno  -- ^ KDC_ERR_S_OLD_MAST_KVNO — server key version too old (tag 5).
  | KdcErrCPrincipalUnknown  -- ^ KDC_ERR_C_PRINCIPAL_UNKNOWN — client principal not found (tag 6).
  | KdcErrSPrincipalUnknown  -- ^ KDC_ERR_S_PRINCIPAL_UNKNOWN — service principal not found (tag 7).
  | KdcErrPreauthFailed  -- ^ KDC_ERR_PREAUTH_FAILED — pre-authentication failed (tag 8).
  | KdcErrPreauthRequired  -- ^ KDC_ERR_PREAUTH_REQUIRED — pre-authentication required (tag 9).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'ErrorCode' to its ABI tag value.
errorCodeToTag :: ErrorCode -> Word8
errorCodeToTag = fromIntegral . fromEnum

-- | Decode a 'ErrorCode' from its ABI tag value.
errorCodeFromTag :: Word8 -> Maybe ErrorCode
errorCodeFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: ErrorCode)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- | Whether this code indicates success.
isSuccess :: ErrorCode -> Bool
isSuccess KdcErrNone = True
isSuccess _ = False

-- ---------------------------------------------------------------------------
-- AuthState
-- ---------------------------------------------------------------------------

-- | Kerberos authentication state machine.
--
-- Tags 0-4 (5 constructors).
data AuthState
  = Initial  -- ^ Initial — no tickets (tag 0).
  | TgtObtained  -- ^ TGT obtained from AS (tag 1).
  | ServiceTicketObtained  -- ^ Service ticket obtained from TGS (tag 2).
  | Authenticated  -- ^ Authenticated — AP-REP received (tag 3).
  | AuthFailed  -- ^ Authentication failed (tag 4).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'AuthState' to its ABI tag value.
authStateToTag :: AuthState -> Word8
authStateToTag = fromIntegral . fromEnum

-- | Decode a 'AuthState' from its ABI tag value.
authStateFromTag :: Word8 -> Maybe AuthState
authStateFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: AuthState)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- | Validate whether a state transition is allowed.
authStateCanTransitionTo :: AuthState -> AuthState -> Bool
authStateCanTransitionTo Initial TgtObtained = True
authStateCanTransitionTo TgtObtained ServiceTicketObtained = True
authStateCanTransitionTo ServiceTicketObtained Authenticated = True
authStateCanTransitionTo Initial AuthFailed = True
authStateCanTransitionTo TgtObtained AuthFailed = True
authStateCanTransitionTo ServiceTicketObtained AuthFailed = True
authStateCanTransitionTo _ _ = False

-- ---------------------------------------------------------------------------
-- EncStrength
-- ---------------------------------------------------------------------------

-- | Encryption strength classification.
--
-- Tags 0-2 (3 constructors).
data EncStrength
  = Strong  -- ^ Strong — recommended (tag 0).
  | Medium  -- ^ Medium — acceptable (tag 1).
  | Weak  -- ^ Weak — deprecated (tag 2).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'EncStrength' to its ABI tag value.
encStrengthToTag :: EncStrength -> Word8
encStrengthToTag = fromIntegral . fromEnum

-- | Decode a 'EncStrength' from its ABI tag value.
encStrengthFromTag :: Word8 -> Maybe EncStrength
encStrengthFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: EncStrength)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- PreAuthType
-- ---------------------------------------------------------------------------

-- | Kerberos pre-authentication types.
--
-- Tags 0-3 (4 constructors).
data PreAuthType
  = PaEncTimestamp  -- ^ PA-ENC-TIMESTAMP — encrypted timestamp (tag 0).
  | PaEtypeInfo2  -- ^ PA-ETYPE-INFO2 — encryption type info (tag 1).
  | PaFxFast  -- ^ PA-FX-FAST — Flexible Authentication (tag 2).
  | PaFxCookie  -- ^ PA-FX-COOKIE — FAST cookie (tag 3).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'PreAuthType' to its ABI tag value.
preAuthTypeToTag :: PreAuthType -> Word8
preAuthTypeToTag = fromIntegral . fromEnum

-- | Decode a 'PreAuthType' from its ABI tag value.
preAuthTypeFromTag :: Word8 -> Maybe PreAuthType
preAuthTypeFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: PreAuthType)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- NegotiationState
-- ---------------------------------------------------------------------------

-- | Kerberos encryption negotiation state.
--
-- Tags 0-3 (4 constructors).
data NegotiationState
  = NegIdle  -- ^ No negotiation started (tag 0).
  | Proposed  -- ^ Client proposed encryption types (tag 1).
  | Selected  -- ^ Server selected an encryption type (tag 2).
  | NegFailed  -- ^ Negotiation failed — no common type (tag 3).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'NegotiationState' to its ABI tag value.
negotiationStateToTag :: NegotiationState -> Word8
negotiationStateToTag = fromIntegral . fromEnum

-- | Decode a 'NegotiationState' from its ABI tag value.
negotiationStateFromTag :: Word8 -> Maybe NegotiationState
negotiationStateFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: NegotiationState)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing
