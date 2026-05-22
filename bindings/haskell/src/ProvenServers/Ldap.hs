-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- | LDAP protocol types for the proven-servers ABI.
--
-- All tag values match the Idris2 ABI discriminants exactly.

module ProvenServers.Ldap
  (
    ldapPort
  , ldapsPort
  , SessionState(..)
  , sessionStateToTag
  , sessionStateFromTag
  , isAuthenticated
  , sessionStateCanTransitionTo
  , Operation(..)
  , operationToTag
  , operationFromTag
  , isWrite
  , requiresBind
  , SearchScope(..)
  , searchScopeToTag
  , searchScopeFromTag
  , ResultCode(..)
  , resultCodeToTag
  , resultCodeFromTag
  , isSuccess
  , isAuthFailure
  , isTransient
  ) where

import Data.Word (Word16, Word8)

-- | Standard LDAP port (RFC 4511).
ldapPort :: Word16
ldapPort = 389

-- | Standard LDAPS (LDAP over TLS) port.
ldapsPort :: Word16
ldapsPort = 636

-- ---------------------------------------------------------------------------
-- SessionState
-- ---------------------------------------------------------------------------

-- | Standard LDAP port (RFC 4511).
--
-- Tags 0-3 (4 constructors).
data SessionState
  = Anonymous  -- ^ Connected but not authenticated (tag 0).
  | Bound  -- ^ Successfully bound (authenticated) (tag 1).
  | Closed  -- ^ Session is closed (tag 2).
  | Binding  -- ^ Bind operation in progress (tag 3).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'SessionState' to its ABI tag value.
sessionStateToTag :: SessionState -> Word8
sessionStateToTag = fromIntegral . fromEnum

-- | Decode a 'SessionState' from its ABI tag value.
sessionStateFromTag :: Word8 -> Maybe SessionState
sessionStateFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: SessionState)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- | Whether operations requiring authentication can be performed.
isAuthenticated :: SessionState -> Bool
isAuthenticated Bound = True
isAuthenticated _ = False

-- | Validate whether a state transition is allowed.
sessionStateCanTransitionTo :: SessionState -> SessionState -> Bool
sessionStateCanTransitionTo Anonymous Binding = True
sessionStateCanTransitionTo Binding Bound = True
sessionStateCanTransitionTo Binding Anonymous = True
sessionStateCanTransitionTo Bound Anonymous = True
sessionStateCanTransitionTo _ Closed = True
sessionStateCanTransitionTo _ _ = False

-- ---------------------------------------------------------------------------
-- Operation
-- ---------------------------------------------------------------------------

-- | LDAP protocol operations (RFC 4511).
--
-- Tags 0-9 (10 constructors).
data Operation
  = Bind  -- ^ Bind (authenticate) to the directory (tag 0).
  | Unbind  -- ^ Unbind (close session) (tag 1).
  | Search  -- ^ Search for directory entries (tag 2).
  | Modify  -- ^ Modify an existing entry (tag 3).
  | Add  -- ^ Add a new entry (tag 4).
  | Delete  -- ^ Delete an entry (tag 5).
  | ModDn  -- ^ Modify the DN (rename/move) of an entry (tag 6).
  | Compare  -- ^ Compare an attribute value (tag 7).
  | Abandon  -- ^ Abandon a pending operation (tag 8).
  | Extended  -- ^ Extended operation (tag 9).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'Operation' to its ABI tag value.
operationToTag :: Operation -> Word8
operationToTag = fromIntegral . fromEnum

-- | Decode a 'Operation' from its ABI tag value.
operationFromTag :: Word8 -> Maybe Operation
operationFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: Operation)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- | Whether this operation modifies directory data.
isWrite :: Operation -> Bool
isWrite Modify = True
isWrite Add = True
isWrite Delete = True
isWrite ModDn = True
isWrite _ = False

-- | Whether this operation requires the session to be bound.
requiresBind :: Operation -> Bool
requiresBind Bind = False
requiresBind Unbind = False
requiresBind Abandon = False
requiresBind _ = True

-- ---------------------------------------------------------------------------
-- SearchScope
-- ---------------------------------------------------------------------------

-- | LDAP search scope levels (RFC 4511 Section 4.5.1.2).
--
-- Tags 0-2 (3 constructors).
data SearchScope
  = BaseObject  -- ^ Search only the base object itself (tag 0).
  | SingleLevel  -- ^ Search one level below the base object (tag 1).
  | WholeSubtree  -- ^ Search the entire subtree below the base object (tag 2).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'SearchScope' to its ABI tag value.
searchScopeToTag :: SearchScope -> Word8
searchScopeToTag = fromIntegral . fromEnum

-- | Decode a 'SearchScope' from its ABI tag value.
searchScopeFromTag :: Word8 -> Maybe SearchScope
searchScopeFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: SearchScope)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- ResultCode
-- ---------------------------------------------------------------------------

-- | LDAP result codes (RFC 4511 Appendix A).
--
-- Tags 0-10 (11 constructors).
data ResultCode
  = Success  -- ^ Operation completed successfully (tag 0).
  | OperationsError  -- ^ An internal error occurred (tag 1).
  | ProtocolError  -- ^ Protocol violation detected (tag 2).
  | TimeLimitExceeded  -- ^ Time limit for the operation was exceeded (tag 3).
  | SizeLimitExceeded  -- ^ Size limit for the operation was exceeded (tag 4).
  | AuthMethodNotSupported  -- ^ Requested auth method not supported (tag 5).
  | NoSuchObject  -- ^ The target entry does not exist (tag 6).
  | InvalidCredentials  -- ^ Provided credentials are invalid (tag 7).
  | InsufficientAccessRights  -- ^ Caller lacks sufficient access rights (tag 8).
  | Busy  -- ^ Server is too busy to handle the request (tag 9).
  | Unavailable  -- ^ Server is unavailable (tag 10).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'ResultCode' to its ABI tag value.
resultCodeToTag :: ResultCode -> Word8
resultCodeToTag = fromIntegral . fromEnum

-- | Decode a 'ResultCode' from its ABI tag value.
resultCodeFromTag :: Word8 -> Maybe ResultCode
resultCodeFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: ResultCode)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- | Whether this result code indicates success.
isSuccess :: ResultCode -> Bool
isSuccess Success = True
isSuccess _ = False

-- | Whether this result code indicates an authentication/authorisation failure.
isAuthFailure :: ResultCode -> Bool
isAuthFailure AuthMethodNotSupported = True
isAuthFailure InvalidCredentials = True
isAuthFailure InsufficientAccessRights = True
isAuthFailure _ = False

-- | Whether this is a transient error that may succeed on retry.
isTransient :: ResultCode -> Bool
isTransient Busy = True
isTransient Unavailable = True
isTransient _ = False
