-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- | Triplestore protocol types for proven-servers.
--
-- RDF triple store types, mirroring the Idris2 ABI.
-- All tag values match the Idris2 ABI discriminants exactly.
--
-- This is a pure type-definition module with no FFI dependencies.

module ProvenServers.Triplestore
  ( -- * ADT types matching Idris2 ABI
      Statement(..)
    , IndexOrder(..)
    , StorageBackend(..)
    , ImportFormat(..)
    , TransactionIsolation(..)
    , StoreState(..)
    , statementToTag
    , statementFromTag
    , indexOrderToTag
    , indexOrderFromTag
    , storageBackendToTag
    , storageBackendFromTag
    , importFormatToTag
    , importFormatFromTag
    , transactionIsolationToTag
    , transactionIsolationFromTag
    , storeStateToTag
    , storeStateFromTag
  ) where

import Data.Word (Word8)

-- ---------------------------------------------------------------------------
-- Statement
-- ---------------------------------------------------------------------------

-- | Statement type matching the Idris2 ABI.
--
-- Tags 0-1 (2 constructors).
data Statement
  = Triple  -- ^ Tag 0.
  | Quad  -- ^ Tag 1.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'Statement' to its ABI tag value.
statementToTag :: Statement -> Word8
statementToTag = fromIntegral . fromEnum

-- | Decode a 'Statement' from its ABI tag value.
statementFromTag :: Word8 -> Maybe Statement
statementFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: Statement)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- IndexOrder
-- ---------------------------------------------------------------------------

-- | IndexOrder type matching the Idris2 ABI.
--
-- Tags 0-5 (6 constructors).
data IndexOrder
  = Spo  -- ^ Tag 0.
  | Pos  -- ^ Tag 1.
  | Osp  -- ^ Tag 2.
  | Gspo  -- ^ Tag 3.
  | Gpos  -- ^ Tag 4.
  | Gosp  -- ^ Tag 5.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'IndexOrder' to its ABI tag value.
indexOrderToTag :: IndexOrder -> Word8
indexOrderToTag = fromIntegral . fromEnum

-- | Decode a 'IndexOrder' from its ABI tag value.
indexOrderFromTag :: Word8 -> Maybe IndexOrder
indexOrderFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: IndexOrder)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- StorageBackend
-- ---------------------------------------------------------------------------

-- | StorageBackend type matching the Idris2 ABI.
--
-- Tags 0-3 (4 constructors).
data StorageBackend
  = InMemory  -- ^ Tag 0.
  | BTree  -- ^ Tag 1.
  | Lsm  -- ^ Tag 2.
  | Persistent  -- ^ Tag 3.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'StorageBackend' to its ABI tag value.
storageBackendToTag :: StorageBackend -> Word8
storageBackendToTag = fromIntegral . fromEnum

-- | Decode a 'StorageBackend' from its ABI tag value.
storageBackendFromTag :: Word8 -> Maybe StorageBackend
storageBackendFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: StorageBackend)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- ImportFormat
-- ---------------------------------------------------------------------------

-- | ImportFormat type matching the Idris2 ABI.
--
-- Tags 0-5 (6 constructors).
data ImportFormat
  = NTriples  -- ^ Tag 0.
  | Turtle  -- ^ Tag 1.
  | RdfXml  -- ^ Tag 2.
  | JsonLd  -- ^ Tag 3.
  | NQuads  -- ^ Tag 4.
  | Trig  -- ^ Tag 5.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'ImportFormat' to its ABI tag value.
importFormatToTag :: ImportFormat -> Word8
importFormatToTag = fromIntegral . fromEnum

-- | Decode a 'ImportFormat' from its ABI tag value.
importFormatFromTag :: Word8 -> Maybe ImportFormat
importFormatFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: ImportFormat)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- TransactionIsolation
-- ---------------------------------------------------------------------------

-- | TransactionIsolation type matching the Idris2 ABI.
--
-- Tags 0-2 (3 constructors).
data TransactionIsolation
  = ReadCommitted  -- ^ Tag 0.
  | Serializable  -- ^ Tag 1.
  | Snapshot  -- ^ Tag 2.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'TransactionIsolation' to its ABI tag value.
transactionIsolationToTag :: TransactionIsolation -> Word8
transactionIsolationToTag = fromIntegral . fromEnum

-- | Decode a 'TransactionIsolation' from its ABI tag value.
transactionIsolationFromTag :: Word8 -> Maybe TransactionIsolation
transactionIsolationFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: TransactionIsolation)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- StoreState
-- ---------------------------------------------------------------------------

-- | StoreState type matching the Idris2 ABI.
--
-- Tags 0-4 (5 constructors).
data StoreState
  = Idle  -- ^ Tag 0.
  | Ready  -- ^ Tag 1.
  | InTransaction  -- ^ Tag 2.
  | Importing  -- ^ Tag 3.
  | Closing  -- ^ Tag 4.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'StoreState' to its ABI tag value.
storeStateToTag :: StoreState -> Word8
storeStateToTag = fromIntegral . fromEnum

-- | Decode a 'StoreState' from its ABI tag value.
storeStateFromTag :: Word8 -> Maybe StoreState
storeStateFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: StoreState)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing
