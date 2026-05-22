-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- | Authentication server types for the proven-servers ABI.
--
-- All tag values match the Idris2 ABI discriminants exactly.

module ProvenServers.Authserver
  (
    authHttpsPort
  , AuthMethod(..)
  , authMethodToTag
  , authMethodFromTag
  , isPasswordless
  , TokenType(..)
  , tokenTypeToTag
  , tokenTypeFromTag
  , AuthResult(..)
  , authResultToTag
  , authResultFromTag
  , isSuccess
  , requiresAction
  , MfaMethod(..)
  , mfaMethodToTag
  , mfaMethodFromTag
  , SessionState(..)
  , sessionStateToTag
  , sessionStateFromTag
  , isValid
  ) where

import Data.Word (Word16, Word8)

-- | Standard HTTPS port for auth.
authHttpsPort :: Word16
authHttpsPort = 443

-- ---------------------------------------------------------------------------
-- AuthMethod
-- ---------------------------------------------------------------------------

-- | Standard HTTPS port for auth.
--
-- Tags 0-7 (8 constructors).
data AuthMethod
  = Password  -- ^ Password (tag 0).
  | Certificate  -- ^ Certificate (tag 1).
  | OAuth2  -- ^ OAuth2 (tag 2).
  | Saml  -- ^ SAML (tag 3).
  | Fido2  -- ^ FIDO2/WebAuthn (tag 4).
  | Kerberos  -- ^ Kerberos (tag 5).
  | Ldap  -- ^ LDAP (tag 6).
  | Radius  -- ^ RADIUS (tag 7).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'AuthMethod' to its ABI tag value.
authMethodToTag :: AuthMethod -> Word8
authMethodToTag = fromIntegral . fromEnum

-- | Decode a 'AuthMethod' from its ABI tag value.
authMethodFromTag :: Word8 -> Maybe AuthMethod
authMethodFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: AuthMethod)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- | Whether this method is passwordless.
isPasswordless :: AuthMethod -> Bool
isPasswordless Certificate = True
isPasswordless Fido2 = True
isPasswordless _ = False

-- ---------------------------------------------------------------------------
-- TokenType
-- ---------------------------------------------------------------------------

-- | Authentication token types.
--
-- Tags 0-3 (4 constructors).
data TokenType
  = Access  -- ^ Access (tag 0).
  | Refresh  -- ^ Refresh (tag 1).
  | Id  -- ^ ID token (tag 2).
  | Api  -- ^ API key (tag 3).
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

-- | Authentication attempt result codes.
--
-- Tags 0-5 (6 constructors).
data AuthResult
  = Success  -- ^ Success (tag 0).
  | InvalidCredentials  -- ^ InvalidCredentials (tag 1).
  | AccountLocked  -- ^ AccountLocked (tag 2).
  | AccountExpired  -- ^ AccountExpired (tag 3).
  | MfaRequired  -- ^ MFA required (tag 4).
  | IpBlocked  -- ^ IP address blocked (tag 5).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'AuthResult' to its ABI tag value.
authResultToTag :: AuthResult -> Word8
authResultToTag = fromIntegral . fromEnum

-- | Decode a 'AuthResult' from its ABI tag value.
authResultFromTag :: Word8 -> Maybe AuthResult
authResultFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: AuthResult)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- | Whether authentication succeeded.
isSuccess :: AuthResult -> Bool
isSuccess Success = True
isSuccess _ = False

-- | Whether the result requires further user action.
requiresAction :: AuthResult -> Bool
requiresAction MfaRequired = True
requiresAction _ = False

-- ---------------------------------------------------------------------------
-- MfaMethod
-- ---------------------------------------------------------------------------

-- | Multi-factor authentication methods.
--
-- Tags 0-4 (5 constructors).
data MfaMethod
  = Totp  -- ^ TOTP (tag 0).
  | Sms  -- ^ SMS (tag 1).
  | Push  -- ^ Push (tag 2).
  | Fido2Mfa  -- ^ FIDO2 MFA (tag 3).
  | Email  -- ^ Email (tag 4).
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

-- | Auth session lifecycle states.
--
-- Tags 0-3 (4 constructors).
data SessionState
  = Active  -- ^ Active (tag 0).
  | Expired  -- ^ Expired (tag 1).
  | Revoked  -- ^ Revoked (tag 2).
  | Locked  -- ^ Locked (tag 3).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'SessionState' to its ABI tag value.
sessionStateToTag :: SessionState -> Word8
sessionStateToTag = fromIntegral . fromEnum

-- | Decode a 'SessionState' from its ABI tag value.
sessionStateFromTag :: Word8 -> Maybe SessionState
sessionStateFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: SessionState)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- | Whether the session is still usable.
isValid :: SessionState -> Bool
isValid Active = True
isValid _ = False
