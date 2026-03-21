-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- | Auth protocol types for proven-servers.
--
-- Authentication server types, mirroring the Idris2 ABI.
-- All tag values match the Idris2 ABI discriminants exactly.
--
-- This is a pure type-definition module with no FFI dependencies.

module ProvenServers.Authserver
  ( -- * ADT types matching Idris2 ABI
      AuthMethod(..)
    , TokenType(..)
    , AuthResult(..)
    , MfaMethod(..)
    , SessionState(..)
    , authMethodToTag
    , authMethodFromTag
    , tokenTypeToTag
    , tokenTypeFromTag
    , authResultToTag
    , authResultFromTag
    , mfaMethodToTag
    , mfaMethodFromTag
    , sessionStateToTag
    , sessionStateFromTag
  ) where

import Data.Word (Word8)

-- ---------------------------------------------------------------------------
-- AuthMethod
-- ---------------------------------------------------------------------------

-- | AuthMethod type matching the Idris2 ABI.
--
-- Tags 0-7 (8 constructors).
data AuthMethod
  = Password  -- ^ Tag 0.
  | Certificate  -- ^ Tag 1.
  | OAuth2  -- ^ Tag 2.
  | Saml  -- ^ Tag 3.
  | Fido2  -- ^ Tag 4.
  | Kerberos  -- ^ Tag 5.
  | Ldap  -- ^ Tag 6.
  | Radius  -- ^ Tag 7.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'AuthMethod' to its ABI tag value.
authMethodToTag :: AuthMethod -> Word8
authMethodToTag = fromIntegral . fromEnum

-- | Decode a 'AuthMethod' from its ABI tag value.
authMethodFromTag :: Word8 -> Maybe AuthMethod
authMethodFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: AuthMethod)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- TokenType
-- ---------------------------------------------------------------------------

-- | TokenType type matching the Idris2 ABI.
--
-- Tags 0-3 (4 constructors).
data TokenType
  = Access  -- ^ Tag 0.
  | Refresh  -- ^ Tag 1.
  | Id  -- ^ Tag 2.
  | Api  -- ^ Tag 3.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'TokenType' to its ABI tag value.
tokenTypeToTag :: TokenType -> Word8
tokenTypeToTag = fromIntegral . fromEnum

-- | Decode a 'TokenType' from its ABI tag value.
tokenTypeFromTag :: Word8 -> Maybe TokenType
tokenTypeFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: TokenType)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- AuthResult
-- ---------------------------------------------------------------------------

-- | AuthResult type matching the Idris2 ABI.
--
-- Tags 0-5 (6 constructors).
data AuthResult
  = Success  -- ^ Tag 0.
  | InvalidCredentials  -- ^ Tag 1.
  | AccountLocked  -- ^ Tag 2.
  | AccountExpired  -- ^ Tag 3.
  | MfaRequired  -- ^ Tag 4.
  | IpBlocked  -- ^ Tag 5.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'AuthResult' to its ABI tag value.
authResultToTag :: AuthResult -> Word8
authResultToTag = fromIntegral . fromEnum

-- | Decode a 'AuthResult' from its ABI tag value.
authResultFromTag :: Word8 -> Maybe AuthResult
authResultFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: AuthResult)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- MfaMethod
-- ---------------------------------------------------------------------------

-- | MfaMethod type matching the Idris2 ABI.
--
-- Tags 0-4 (5 constructors).
data MfaMethod
  = Totp  -- ^ Tag 0.
  | Sms  -- ^ Tag 1.
  | Push  -- ^ Tag 2.
  | Fido2Mfa  -- ^ Tag 3.
  | Email  -- ^ Tag 4.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'MfaMethod' to its ABI tag value.
mfaMethodToTag :: MfaMethod -> Word8
mfaMethodToTag = fromIntegral . fromEnum

-- | Decode a 'MfaMethod' from its ABI tag value.
mfaMethodFromTag :: Word8 -> Maybe MfaMethod
mfaMethodFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: MfaMethod)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- SessionState
-- ---------------------------------------------------------------------------

-- | SessionState type matching the Idris2 ABI.
--
-- Tags 0-3 (4 constructors).
data SessionState
  = Active  -- ^ Tag 0.
  | Expired  -- ^ Tag 1.
  | Revoked  -- ^ Tag 2.
  | Locked  -- ^ Tag 3.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'SessionState' to its ABI tag value.
sessionStateToTag :: SessionState -> Word8
sessionStateToTag = fromIntegral . fromEnum

-- | Decode a 'SessionState' from its ABI tag value.
sessionStateFromTag :: Word8 -> Maybe SessionState
sessionStateFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: SessionState)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing
