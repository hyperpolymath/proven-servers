-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- | WebDAV protocol types for proven-servers.
--
-- WebDAV protocol types, mirroring the Idris2 ABI.
-- All tag values match the Idris2 ABI discriminants exactly.
--
-- This is a pure type-definition module with no FFI dependencies.

module ProvenServers.Webdav
  ( -- * ADT types matching Idris2 ABI
      Method(..)
    , StatusCode(..)
    , LockScope(..)
    , LockType(..)
    , Depth(..)
    , PropertyOp(..)
    , methodToTag
    , methodFromTag
    , statusCodeToTag
    , statusCodeFromTag
    , lockScopeToTag
    , lockScopeFromTag
    , lockTypeToTag
    , lockTypeFromTag
    , depthToTag
    , depthFromTag
    , propertyOpToTag
    , propertyOpFromTag
  ) where

import Data.Word (Word8)

-- ---------------------------------------------------------------------------
-- Method
-- ---------------------------------------------------------------------------

-- | Method type matching the Idris2 ABI.
--
-- Tags 0-6 (7 constructors).
data Method
  = Propfind  -- ^ Tag 0.
  | Proppatch  -- ^ Tag 1.
  | Mkcol  -- ^ Tag 2.
  | Copy  -- ^ Tag 3.
  | Move  -- ^ Tag 4.
  | Lock  -- ^ Tag 5.
  | Unlock  -- ^ Tag 6.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'Method' to its ABI tag value.
methodToTag :: Method -> Word8
methodToTag = fromIntegral . fromEnum

-- | Decode a 'Method' from its ABI tag value.
methodFromTag :: Word8 -> Maybe Method
methodFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: Method)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- StatusCode
-- ---------------------------------------------------------------------------

-- | StatusCode type matching the Idris2 ABI.
--
-- Tags 0-4 (5 constructors).
data StatusCode
  = MultiStatus  -- ^ Tag 0.
  | UnprocessableEntity  -- ^ Tag 1.
  | Locked  -- ^ Tag 2.
  | FailedDependency  -- ^ Tag 3.
  | InsufficientStorage  -- ^ Tag 4.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'StatusCode' to its ABI tag value.
statusCodeToTag :: StatusCode -> Word8
statusCodeToTag = fromIntegral . fromEnum

-- | Decode a 'StatusCode' from its ABI tag value.
statusCodeFromTag :: Word8 -> Maybe StatusCode
statusCodeFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: StatusCode)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- LockScope
-- ---------------------------------------------------------------------------

-- | LockScope type matching the Idris2 ABI.
--
-- Tags 0-1 (2 constructors).
data LockScope
  = Exclusive  -- ^ Tag 0.
  | Shared  -- ^ Tag 1.
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

-- | LockType type matching the Idris2 ABI.
--
-- Tags 0-0 (1 constructors).
data LockType
  = Write  -- ^ Tag 0.
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

-- | Depth type matching the Idris2 ABI.
--
-- Tags 0-2 (3 constructors).
data Depth
  = Zero  -- ^ Tag 0.
  | One  -- ^ Tag 1.
  | Infinity  -- ^ Tag 2.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'Depth' to its ABI tag value.
depthToTag :: Depth -> Word8
depthToTag = fromIntegral . fromEnum

-- | Decode a 'Depth' from its ABI tag value.
depthFromTag :: Word8 -> Maybe Depth
depthFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: Depth)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- PropertyOp
-- ---------------------------------------------------------------------------

-- | PropertyOp type matching the Idris2 ABI.
--
-- Tags 0-1 (2 constructors).
data PropertyOp
  = Set  -- ^ Tag 0.
  | Remove  -- ^ Tag 1.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'PropertyOp' to its ABI tag value.
propertyOpToTag :: PropertyOp -> Word8
propertyOpToTag = fromIntegral . fromEnum

-- | Decode a 'PropertyOp' from its ABI tag value.
propertyOpFromTag :: Word8 -> Maybe PropertyOp
propertyOpFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: PropertyOp)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing
