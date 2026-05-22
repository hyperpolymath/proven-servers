-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- | WebDAV protocol types for the proven-servers ABI.
--
-- All tag values match the Idris2 ABI discriminants exactly.

module ProvenServers.Webdav
  (
    webdavDefaultPort
  , webdavTlsPort
  , Method(..)
  , methodToTag
  , methodFromTag
  , isWrite
  , isLockRelated
  , name
  , StatusCode(..)
  , statusCodeToTag
  , statusCodeFromTag
  , isError
  , LockScope(..)
  , lockScopeToTag
  , lockScopeFromTag
  , LockType(..)
  , lockTypeToTag
  , lockTypeFromTag
  , Depth(..)
  , depthToTag
  , depthFromTag
  , headerValue
  , PropertyOp(..)
  , propertyOpToTag
  , propertyOpFromTag
  ) where

import Data.Word (Word16, Word8)

-- | WebDAV uses standard HTTP/HTTPS ports.
webdavDefaultPort :: Word16
webdavDefaultPort = 80

-- | WebDAV over TLS uses standard HTTPS port.
webdavTlsPort :: Word16
webdavTlsPort = 443

-- ---------------------------------------------------------------------------
-- Method
-- ---------------------------------------------------------------------------

-- | WebDAV HTTP extension methods (RFC 4918).
--
-- Tags 0-6 (7 constructors).
data Method
  = Propfind  -- ^ Retrieve properties of a resource (tag 0).
  | Proppatch  -- ^ Set or remove properties on a resource (tag 1).
  | Mkcol  -- ^ Create a new collection (directory) (tag 2).
  | Copy  -- ^ Copy a resource (tag 3).
  | Move  -- ^ Move a resource (tag 4).
  | Lock  -- ^ Lock a resource (tag 5).
  | Unlock  -- ^ Unlock a resource (tag 6).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'Method' to its ABI tag value.
methodToTag :: Method -> Word8
methodToTag = fromIntegral . fromEnum

-- | Decode a 'Method' from its ABI tag value.
methodFromTag :: Word8 -> Maybe Method
methodFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: Method)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- | Whether this method modifies server state.
isWrite :: Method -> Bool
isWrite Proppatch = True
isWrite Mkcol = True
isWrite Copy = True
isWrite Move = True
isWrite _ = False

-- | Whether this method relates to locking.
isLockRelated :: Method -> Bool
isLockRelated Lock = True
isLockRelated Unlock = True
isLockRelated _ = False

-- | The HTTP method name string.
name :: Method -> String
name Propfind = "PROPFIND"
name Proppatch = "PROPPATCH"
name Mkcol = "MKCOL"
name Copy = "COPY"
name Move = "MOVE"
name Lock = "LOCK"
name Unlock = "UNLOCK"

-- ---------------------------------------------------------------------------
-- StatusCode
-- ---------------------------------------------------------------------------

-- | WebDAV-specific HTTP status codes (RFC 4918).
--
-- Tags 0-4 (5 constructors).
data StatusCode
  = MultiStatus  -- ^ 207 Multi-Status (tag 0).
  | UnprocessableEntity  -- ^ 422 Unprocessable Entity (tag 1).
  | Locked  -- ^ 423 Locked (tag 2).
  | FailedDependency  -- ^ 424 Failed Dependency (tag 3).
  | InsufficientStorage  -- ^ 507 Insufficient Storage (tag 4).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'StatusCode' to its ABI tag value.
statusCodeToTag :: StatusCode -> Word8
statusCodeToTag = fromIntegral . fromEnum

-- | Decode a 'StatusCode' from its ABI tag value.
statusCodeFromTag :: Word8 -> Maybe StatusCode
statusCodeFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: StatusCode)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- | Whether this status is an error (4xx or 5xx).
isError :: StatusCode -> Bool
isError MultiStatus = False
isError _ = True

-- ---------------------------------------------------------------------------
-- LockScope
-- ---------------------------------------------------------------------------

-- | WebDAV lock scope (RFC 4918 Section 14.13).
--
-- Tags 0-1 (2 constructors).
data LockScope
  = Exclusive  -- ^ Exclusive lock — only the lock owner can modify (tag 0).
  | Shared  -- ^ Shared lock — multiple users can hold the lock (tag 1).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'LockScope' to its ABI tag value.
lockScopeToTag :: LockScope -> Word8
lockScopeToTag = fromIntegral . fromEnum

-- | Decode a 'LockScope' from its ABI tag value.
lockScopeFromTag :: Word8 -> Maybe LockScope
lockScopeFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: LockScope)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- LockType
-- ---------------------------------------------------------------------------

-- | WebDAV lock type (RFC 4918 Section 14.15).
--
-- Tags 0-0 (1 constructors).
data LockType
  = Write  -- ^ Write lock — prevents modification by non-owners (tag 0).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'LockType' to its ABI tag value.
lockTypeToTag :: LockType -> Word8
lockTypeToTag = fromIntegral . fromEnum

-- | Decode a 'LockType' from its ABI tag value.
lockTypeFromTag :: Word8 -> Maybe LockType
lockTypeFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: LockType)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- Depth
-- ---------------------------------------------------------------------------

-- | WebDAV Depth header values (RFC 4918 Section 10.2).
--
-- Tags 0-2 (3 constructors).
data Depth
  = Zero  -- ^ Depth 0 — resource only (tag 0).
  | One  -- ^ Depth 1 — resource and immediate children (tag 1).
  | Infinity  -- ^ Depth infinity — resource and all descendants (tag 2).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'Depth' to its ABI tag value.
depthToTag :: Depth -> Word8
depthToTag = fromIntegral . fromEnum

-- | Decode a 'Depth' from its ABI tag value.
depthFromTag :: Word8 -> Maybe Depth
depthFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: Depth)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- | The HTTP header string for this depth value.
headerValue :: Depth -> String
headerValue Zero = "0"
headerValue One = "1"
headerValue Infinity = "infinity"

-- ---------------------------------------------------------------------------
-- PropertyOp
-- ---------------------------------------------------------------------------

-- | WebDAV PROPPATCH operations (RFC 4918 Section 14.23/14.26).
--
-- Tags 0-1 (2 constructors).
data PropertyOp
  = Set  -- ^ Set (create or update) a property (tag 0).
  | Remove  -- ^ Remove a property (tag 1).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'PropertyOp' to its ABI tag value.
propertyOpToTag :: PropertyOp -> Word8
propertyOpToTag = fromIntegral . fromEnum

-- | Decode a 'PropertyOp' from its ABI tag value.
propertyOpFromTag :: Word8 -> Maybe PropertyOp
propertyOpFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: PropertyOp)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing
