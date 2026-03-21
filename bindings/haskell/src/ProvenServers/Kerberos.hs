-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- | Kerberos protocol types for proven-servers.
--
-- Kerberos authentication types, mirroring the Idris2 ABI.
-- All tag values match the Idris2 ABI discriminants exactly.
--
-- This is a pure type-definition module with no FFI dependencies.

module ProvenServers.Kerberos
  ( -- * ADT types matching Idris2 ABI
      MessageType(..)
    , EncryptionType(..)
    , PrincipalType(..)
    , TicketFlag(..)
    , ErrorCode(..)
    , AuthState(..)
    , EncStrength(..)
    , PreAuthType(..)
    , NegotiationState(..)
    , messageTypeToTag
    , messageTypeFromTag
    , encryptionTypeToTag
    , encryptionTypeFromTag
    , principalTypeToTag
    , principalTypeFromTag
    , ticketFlagToTag
    , ticketFlagFromTag
    , errorCodeToTag
    , errorCodeFromTag
    , authStateToTag
    , authStateFromTag
    , encStrengthToTag
    , encStrengthFromTag
    , preAuthTypeToTag
    , preAuthTypeFromTag
    , negotiationStateToTag
    , negotiationStateFromTag
  ) where

import Data.Word (Word8)

-- ---------------------------------------------------------------------------
-- MessageType
-- ---------------------------------------------------------------------------

-- | MessageType type matching the Idris2 ABI.
--
-- Tags 0-9 (10 constructors).
data MessageType
  = AsReq  -- ^ Tag 0.
  | AsRep  -- ^ Tag 1.
  | TgsReq  -- ^ Tag 2.
  | TgsRep  -- ^ Tag 3.
  | ApReq  -- ^ Tag 4.
  | ApRep  -- ^ Tag 5.
  | KrbError  -- ^ Tag 6.
  | KrbSafe  -- ^ Tag 7.
  | KrbPriv  -- ^ Tag 8.
  | KrbCred  -- ^ Tag 9.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'MessageType' to its ABI tag value.
messageTypeToTag :: MessageType -> Word8
messageTypeToTag = fromIntegral . fromEnum

-- | Decode a 'MessageType' from its ABI tag value.
messageTypeFromTag :: Word8 -> Maybe MessageType
messageTypeFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: MessageType)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- EncryptionType
-- ---------------------------------------------------------------------------

-- | EncryptionType type matching the Idris2 ABI.
--
-- Tags 0-4 (5 constructors).
data EncryptionType
  = Aes256CtsHmacSha1  -- ^ Tag 0.
  | Aes128CtsHmacSha1  -- ^ Tag 1.
  | Aes256CtsHmacSha384  -- ^ Tag 2.
  | Rc4Hmac  -- ^ Tag 3.
  | Des3CbcSha1  -- ^ Tag 4.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'EncryptionType' to its ABI tag value.
encryptionTypeToTag :: EncryptionType -> Word8
encryptionTypeToTag = fromIntegral . fromEnum

-- | Decode a 'EncryptionType' from its ABI tag value.
encryptionTypeFromTag :: Word8 -> Maybe EncryptionType
encryptionTypeFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: EncryptionType)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- PrincipalType
-- ---------------------------------------------------------------------------

-- | PrincipalType type matching the Idris2 ABI.
--
-- Tags 0-6 (7 constructors).
data PrincipalType
  = NtUnknown  -- ^ Tag 0.
  | NtPrincipal  -- ^ Tag 1.
  | NtSrvInst  -- ^ Tag 2.
  | NtSrvHst  -- ^ Tag 3.
  | NtUid  -- ^ Tag 4.
  | NtX500  -- ^ Tag 5.
  | NtEnterprise  -- ^ Tag 6.
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

-- | TicketFlag type matching the Idris2 ABI.
--
-- Tags 0-6 (7 constructors).
data TicketFlag
  = Forwardable  -- ^ Tag 0.
  | Forwarded  -- ^ Tag 1.
  | Proxiable  -- ^ Tag 2.
  | Proxy  -- ^ Tag 3.
  | Renewable  -- ^ Tag 4.
  | PreAuthent  -- ^ Tag 5.
  | HwAuthent  -- ^ Tag 6.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'TicketFlag' to its ABI tag value.
ticketFlagToTag :: TicketFlag -> Word8
ticketFlagToTag = fromIntegral . fromEnum

-- | Decode a 'TicketFlag' from its ABI tag value.
ticketFlagFromTag :: Word8 -> Maybe TicketFlag
ticketFlagFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: TicketFlag)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- ErrorCode
-- ---------------------------------------------------------------------------

-- | ErrorCode type matching the Idris2 ABI.
--
-- Tags 0-9 (10 constructors).
data ErrorCode
  = KdcErrNone  -- ^ Tag 0.
  | KdcErrNameExp  -- ^ Tag 1.
  | KdcErrServiceExp  -- ^ Tag 2.
  | KdcErrBadPvno  -- ^ Tag 3.
  | KdcErrCOldMastKvno  -- ^ Tag 4.
  | KdcErrSOldMastKvno  -- ^ Tag 5.
  | KdcErrCPrincipalUnknown  -- ^ Tag 6.
  | KdcErrSPrincipalUnknown  -- ^ Tag 7.
  | KdcErrPreauthFailed  -- ^ Tag 8.
  | KdcErrPreauthRequired  -- ^ Tag 9.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'ErrorCode' to its ABI tag value.
errorCodeToTag :: ErrorCode -> Word8
errorCodeToTag = fromIntegral . fromEnum

-- | Decode a 'ErrorCode' from its ABI tag value.
errorCodeFromTag :: Word8 -> Maybe ErrorCode
errorCodeFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: ErrorCode)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- AuthState
-- ---------------------------------------------------------------------------

-- | AuthState type matching the Idris2 ABI.
--
-- Tags 0-4 (5 constructors).
data AuthState
  = Initial  -- ^ Tag 0.
  | TgtObtained  -- ^ Tag 1.
  | ServiceTicketObtained  -- ^ Tag 2.
  | Authenticated  -- ^ Tag 3.
  | AuthFailed  -- ^ Tag 4.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'AuthState' to its ABI tag value.
authStateToTag :: AuthState -> Word8
authStateToTag = fromIntegral . fromEnum

-- | Decode a 'AuthState' from its ABI tag value.
authStateFromTag :: Word8 -> Maybe AuthState
authStateFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: AuthState)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- EncStrength
-- ---------------------------------------------------------------------------

-- | EncStrength type matching the Idris2 ABI.
--
-- Tags 0-2 (3 constructors).
data EncStrength
  = Strong  -- ^ Tag 0.
  | Medium  -- ^ Tag 1.
  | Weak  -- ^ Tag 2.
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

-- | PreAuthType type matching the Idris2 ABI.
--
-- Tags 0-3 (4 constructors).
data PreAuthType
  = PaEncTimestamp  -- ^ Tag 0.
  | PaEtypeInfo2  -- ^ Tag 1.
  | PaFxFast  -- ^ Tag 2.
  | PaFxCookie  -- ^ Tag 3.
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

-- | NegotiationState type matching the Idris2 ABI.
--
-- Tags 0-3 (4 constructors).
data NegotiationState
  = NegIdle  -- ^ Tag 0.
  | Proposed  -- ^ Tag 1.
  | Selected  -- ^ Tag 2.
  | NegFailed  -- ^ Tag 3.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'NegotiationState' to its ABI tag value.
negotiationStateToTag :: NegotiationState -> Word8
negotiationStateToTag = fromIntegral . fromEnum

-- | Decode a 'NegotiationState' from its ABI tag value.
negotiationStateFromTag :: Word8 -> Maybe NegotiationState
negotiationStateFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: NegotiationState)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing
