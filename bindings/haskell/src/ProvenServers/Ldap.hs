-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- | LDAP protocol types for proven-servers.
--
-- LDAP directory protocol types, mirroring the Idris2 ABI.
-- All tag values match the Idris2 ABI discriminants exactly.
--
-- This is a pure type-definition module with no FFI dependencies.

module ProvenServers.Ldap
  ( -- * ADT types matching Idris2 ABI
      SessionState(..)
    , Operation(..)
    , SearchScope(..)
    , ResultCode(..)
    , sessionStateToTag
    , sessionStateFromTag
    , operationToTag
    , operationFromTag
    , searchScopeToTag
    , searchScopeFromTag
    , resultCodeToTag
    , resultCodeFromTag
  ) where

import Data.Word (Word8)

-- ---------------------------------------------------------------------------
-- SessionState
-- ---------------------------------------------------------------------------

-- | SessionState type matching the Idris2 ABI.
--
-- Tags 0-3 (4 constructors).
data SessionState
  = Anonymous  -- ^ Tag 0.
  | Bound  -- ^ Tag 1.
  | Closed  -- ^ Tag 2.
  | Binding  -- ^ Tag 3.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'SessionState' to its ABI tag value.
sessionStateToTag :: SessionState -> Word8
sessionStateToTag = fromIntegral . fromEnum

-- | Decode a 'SessionState' from its ABI tag value.
sessionStateFromTag :: Word8 -> Maybe SessionState
sessionStateFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: SessionState)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- Operation
-- ---------------------------------------------------------------------------

-- | Operation type matching the Idris2 ABI.
--
-- Tags 0-9 (10 constructors).
data Operation
  = Bind  -- ^ Tag 0.
  | Unbind  -- ^ Tag 1.
  | Search  -- ^ Tag 2.
  | Modify  -- ^ Tag 3.
  | Add  -- ^ Tag 4.
  | Delete  -- ^ Tag 5.
  | ModDn  -- ^ Tag 6.
  | Compare  -- ^ Tag 7.
  | Abandon  -- ^ Tag 8.
  | Extended  -- ^ Tag 9.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'Operation' to its ABI tag value.
operationToTag :: Operation -> Word8
operationToTag = fromIntegral . fromEnum

-- | Decode a 'Operation' from its ABI tag value.
operationFromTag :: Word8 -> Maybe Operation
operationFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: Operation)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- SearchScope
-- ---------------------------------------------------------------------------

-- | SearchScope type matching the Idris2 ABI.
--
-- Tags 0-2 (3 constructors).
data SearchScope
  = BaseObject  -- ^ Tag 0.
  | SingleLevel  -- ^ Tag 1.
  | WholeSubtree  -- ^ Tag 2.
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

-- | ResultCode type matching the Idris2 ABI.
--
-- Tags 0-10 (11 constructors).
data ResultCode
  = Success  -- ^ Tag 0.
  | OperationsError  -- ^ Tag 1.
  | ProtocolError  -- ^ Tag 2.
  | TimeLimitExceeded  -- ^ Tag 3.
  | SizeLimitExceeded  -- ^ Tag 4.
  | AuthMethodNotSupported  -- ^ Tag 5.
  | NoSuchObject  -- ^ Tag 6.
  | InvalidCredentials  -- ^ Tag 7.
  | InsufficientAccessRights  -- ^ Tag 8.
  | Busy  -- ^ Tag 9.
  | Unavailable  -- ^ Tag 10.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'ResultCode' to its ABI tag value.
resultCodeToTag :: ResultCode -> Word8
resultCodeToTag = fromIntegral . fromEnum

-- | Decode a 'ResultCode' from its ABI tag value.
resultCodeFromTag :: Word8 -> Maybe ResultCode
resultCodeFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: ResultCode)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing
