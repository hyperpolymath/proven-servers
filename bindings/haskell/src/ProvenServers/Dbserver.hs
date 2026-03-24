-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- | Database server types for the proven-servers ABI.
--
-- All tag values match the Idris2 ABI discriminants exactly.

module ProvenServers.Dbserver
  (
    dbserverPort
  , QueryType(..)
  , queryTypeToTag
  , queryTypeFromTag
  , isDdl
  , isTransactionControl
  , DataType(..)
  , dataTypeToTag
  , dataTypeFromTag
  , IsolationLevel(..)
  , isolationLevelToTag
  , isolationLevelFromTag
  , ErrorCode(..)
  , errorCodeToTag
  , errorCodeFromTag
  , isRecoverable
  , JoinType(..)
  , joinTypeToTag
  , joinTypeFromTag
  , SessionState(..)
  , sessionStateToTag
  , sessionStateFromTag
  , canQuery
  ) where

import Data.Word (Word16, Word8)

-- | Standard PostgreSQL port.
dbserverPort :: Word16
dbserverPort = 5432

-- ---------------------------------------------------------------------------
-- QueryType
-- ---------------------------------------------------------------------------

-- | Standard PostgreSQL port.
--
-- Tags 0-11 (12 constructors).
data QueryType
  = Select  -- ^ SELECT query (tag 0).
  | Insert  -- ^ INSERT query (tag 1).
  | Update  -- ^ UPDATE query (tag 2).
  | Delete  -- ^ DELETE query (tag 3).
  | CreateTable  -- ^ CREATE TABLE DDL (tag 4).
  | DropTable  -- ^ DROP TABLE DDL (tag 5).
  | AlterTable  -- ^ ALTER TABLE DDL (tag 6).
  | CreateIndex  -- ^ CREATE INDEX DDL (tag 7).
  | DropIndex  -- ^ DROP INDEX DDL (tag 8).
  | Begin  -- ^ BEGIN TRANSACTION (tag 9).
  | Commit  -- ^ COMMIT TRANSACTION (tag 10).
  | Rollback  -- ^ ROLLBACK TRANSACTION (tag 11).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'QueryType' to its ABI tag value.
queryTypeToTag :: QueryType -> Word8
queryTypeToTag = fromIntegral . fromEnum

-- | Decode a 'QueryType' from its ABI tag value.
queryTypeFromTag :: Word8 -> Maybe QueryType
queryTypeFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: QueryType)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- | Whether this is a DDL (schema modification) query.
isDdl :: QueryType -> Bool
isDdl CreateTable = True
isDdl DropTable = True
isDdl AlterTable = True
isDdl CreateIndex = True
isDdl DropIndex = True
isDdl _ = False

-- | Whether this is a transaction control statement.
isTransactionControl :: QueryType -> Bool
isTransactionControl Begin = True
isTransactionControl Commit = True
isTransactionControl Rollback = True
isTransactionControl _ = False

-- ---------------------------------------------------------------------------
-- DataType
-- ---------------------------------------------------------------------------

-- | Database column/value data types.
--
-- Tags 0-8 (9 constructors).
data DataType
  = Integer  -- ^ Integer (tag 0).
  | Float  -- ^ Float (tag 1).
  | Text  -- ^ Text (tag 2).
  | Blob  -- ^ Blob (tag 3).
  | Boolean  -- ^ Boolean (tag 4).
  | Timestamp  -- ^ Timestamp (tag 5).
  | Uuid  -- ^ UUID type (tag 6).
  | Json  -- ^ JSON type (tag 7).
  | Null  -- ^ Null (tag 8).
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

-- | Transaction isolation levels (ANSI SQL).
--
-- Tags 0-3 (4 constructors).
data IsolationLevel
  = ReadUncommitted  -- ^ ReadUncommitted (tag 0).
  | ReadCommitted  -- ^ ReadCommitted (tag 1).
  | RepeatableRead  -- ^ RepeatableRead (tag 2).
  | Serializable  -- ^ Serializable (tag 3).
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

-- | Database error codes.
--
-- Tags 0-9 (10 constructors).
data ErrorCode
  = SyntaxError  -- ^ SyntaxError (tag 0).
  | TableNotFound  -- ^ TableNotFound (tag 1).
  | ColumnNotFound  -- ^ ColumnNotFound (tag 2).
  | DuplicateKey  -- ^ DuplicateKey (tag 3).
  | ConstraintViolation  -- ^ ConstraintViolation (tag 4).
  | TypeMismatch  -- ^ TypeMismatch (tag 5).
  | DeadlockDetected  -- ^ DeadlockDetected (tag 6).
  | TransactionAborted  -- ^ TransactionAborted (tag 7).
  | DiskFull  -- ^ DiskFull (tag 8).
  | ConnectionLost  -- ^ ConnectionLost (tag 9).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'ErrorCode' to its ABI tag value.
errorCodeToTag :: ErrorCode -> Word8
errorCodeToTag = fromIntegral . fromEnum

-- | Decode a 'ErrorCode' from its ABI tag value.
errorCodeFromTag :: Word8 -> Maybe ErrorCode
errorCodeFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: ErrorCode)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- | Whether this error is potentially recoverable.
isRecoverable :: ErrorCode -> Bool
isRecoverable DeadlockDetected = True
isRecoverable TransactionAborted = True
isRecoverable ConnectionLost = True
isRecoverable _ = False

-- ---------------------------------------------------------------------------
-- JoinType
-- ---------------------------------------------------------------------------

-- | SQL JOIN types.
--
-- Tags 0-4 (5 constructors).
data JoinType
  = Inner  -- ^ Inner (tag 0).
  | LeftOuter  -- ^ LeftOuter (tag 1).
  | RightOuter  -- ^ RightOuter (tag 2).
  | FullOuter  -- ^ FullOuter (tag 3).
  | Cross  -- ^ Cross (tag 4).
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

-- | Database session lifecycle states.
--
-- Tags 0-5 (6 constructors).
data SessionState
  = Idle  -- ^ Idle (tag 0).
  | Connected  -- ^ Connected (tag 1).
  | Transaction  -- ^ Transaction (tag 2).
  | Executing  -- ^ Executing (tag 3).
  | Finalising  -- ^ Finalising (tag 4).
  | Disconnecting  -- ^ Disconnecting (tag 5).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'SessionState' to its ABI tag value.
sessionStateToTag :: SessionState -> Word8
sessionStateToTag = fromIntegral . fromEnum

-- | Decode a 'SessionState' from its ABI tag value.
sessionStateFromTag :: Word8 -> Maybe SessionState
sessionStateFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: SessionState)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- | Whether queries can be executed in this state.
canQuery :: SessionState -> Bool
canQuery Connected = True
canQuery Transaction = True
canQuery _ = False
