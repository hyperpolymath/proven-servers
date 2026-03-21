-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- | Database protocol types for proven-servers.
--
-- Database server types, mirroring the Idris2 ABI.
-- All tag values match the Idris2 ABI discriminants exactly.
--
-- This is a pure type-definition module with no FFI dependencies.

module ProvenServers.Dbserver
  ( -- * ADT types matching Idris2 ABI
      QueryType(..)
    , DataType(..)
    , IsolationLevel(..)
    , ErrorCode(..)
    , JoinType(..)
    , SessionState(..)
    , queryTypeToTag
    , queryTypeFromTag
    , dataTypeToTag
    , dataTypeFromTag
    , isolationLevelToTag
    , isolationLevelFromTag
    , errorCodeToTag
    , errorCodeFromTag
    , joinTypeToTag
    , joinTypeFromTag
    , sessionStateToTag
    , sessionStateFromTag
  ) where

import Data.Word (Word8)

-- ---------------------------------------------------------------------------
-- QueryType
-- ---------------------------------------------------------------------------

-- | QueryType type matching the Idris2 ABI.
--
-- Tags 0-11 (12 constructors).
data QueryType
  = Select  -- ^ Tag 0.
  | Insert  -- ^ Tag 1.
  | Update  -- ^ Tag 2.
  | Delete  -- ^ Tag 3.
  | CreateTable  -- ^ Tag 4.
  | DropTable  -- ^ Tag 5.
  | AlterTable  -- ^ Tag 6.
  | CreateIndex  -- ^ Tag 7.
  | DropIndex  -- ^ Tag 8.
  | Begin  -- ^ Tag 9.
  | Commit  -- ^ Tag 10.
  | Rollback  -- ^ Tag 11.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'QueryType' to its ABI tag value.
queryTypeToTag :: QueryType -> Word8
queryTypeToTag = fromIntegral . fromEnum

-- | Decode a 'QueryType' from its ABI tag value.
queryTypeFromTag :: Word8 -> Maybe QueryType
queryTypeFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: QueryType)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- DataType
-- ---------------------------------------------------------------------------

-- | DataType type matching the Idris2 ABI.
--
-- Tags 0-8 (9 constructors).
data DataType
  = Integer  -- ^ Tag 0.
  | Float  -- ^ Tag 1.
  | Text  -- ^ Tag 2.
  | Blob  -- ^ Tag 3.
  | Boolean  -- ^ Tag 4.
  | Timestamp  -- ^ Tag 5.
  | Uuid  -- ^ Tag 6.
  | Json  -- ^ Tag 7.
  | Null  -- ^ Tag 8.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'DataType' to its ABI tag value.
dataTypeToTag :: DataType -> Word8
dataTypeToTag = fromIntegral . fromEnum

-- | Decode a 'DataType' from its ABI tag value.
dataTypeFromTag :: Word8 -> Maybe DataType
dataTypeFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: DataType)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- IsolationLevel
-- ---------------------------------------------------------------------------

-- | IsolationLevel type matching the Idris2 ABI.
--
-- Tags 0-3 (4 constructors).
data IsolationLevel
  = ReadUncommitted  -- ^ Tag 0.
  | ReadCommitted  -- ^ Tag 1.
  | RepeatableRead  -- ^ Tag 2.
  | Serializable  -- ^ Tag 3.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'IsolationLevel' to its ABI tag value.
isolationLevelToTag :: IsolationLevel -> Word8
isolationLevelToTag = fromIntegral . fromEnum

-- | Decode a 'IsolationLevel' from its ABI tag value.
isolationLevelFromTag :: Word8 -> Maybe IsolationLevel
isolationLevelFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: IsolationLevel)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- ErrorCode
-- ---------------------------------------------------------------------------

-- | ErrorCode type matching the Idris2 ABI.
--
-- Tags 0-9 (10 constructors).
data ErrorCode
  = SyntaxError  -- ^ Tag 0.
  | TableNotFound  -- ^ Tag 1.
  | ColumnNotFound  -- ^ Tag 2.
  | DuplicateKey  -- ^ Tag 3.
  | ConstraintViolation  -- ^ Tag 4.
  | TypeMismatch  -- ^ Tag 5.
  | DeadlockDetected  -- ^ Tag 6.
  | TransactionAborted  -- ^ Tag 7.
  | DiskFull  -- ^ Tag 8.
  | ConnectionLost  -- ^ Tag 9.
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
-- JoinType
-- ---------------------------------------------------------------------------

-- | JoinType type matching the Idris2 ABI.
--
-- Tags 0-4 (5 constructors).
data JoinType
  = Inner  -- ^ Tag 0.
  | LeftOuter  -- ^ Tag 1.
  | RightOuter  -- ^ Tag 2.
  | FullOuter  -- ^ Tag 3.
  | Cross  -- ^ Tag 4.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'JoinType' to its ABI tag value.
joinTypeToTag :: JoinType -> Word8
joinTypeToTag = fromIntegral . fromEnum

-- | Decode a 'JoinType' from its ABI tag value.
joinTypeFromTag :: Word8 -> Maybe JoinType
joinTypeFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: JoinType)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- SessionState
-- ---------------------------------------------------------------------------

-- | SessionState type matching the Idris2 ABI.
--
-- Tags 0-5 (6 constructors).
data SessionState
  = Idle  -- ^ Tag 0.
  | Connected  -- ^ Tag 1.
  | Transaction  -- ^ Tag 2.
  | Executing  -- ^ Tag 3.
  | Finalising  -- ^ Tag 4.
  | Disconnecting  -- ^ Tag 5.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'SessionState' to its ABI tag value.
sessionStateToTag :: SessionState -> Word8
sessionStateToTag = fromIntegral . fromEnum

-- | Decode a 'SessionState' from its ABI tag value.
sessionStateFromTag :: Word8 -> Maybe SessionState
sessionStateFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: SessionState)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing
