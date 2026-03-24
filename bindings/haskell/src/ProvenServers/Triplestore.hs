-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- | Triple Store types for the proven-servers ABI.
--
-- All tag values match the Idris2 ABI discriminants exactly.

module ProvenServers.Triplestore
  (
    Statement(..)
  , statementToTag
  , statementFromTag
  , IndexOrder(..)
  , indexOrderToTag
  , indexOrderFromTag
  , StorageBackend(..)
  , storageBackendToTag
  , storageBackendFromTag
  , ImportFormat(..)
  , importFormatToTag
  , importFormatFromTag
  , TransactionIsolation(..)
  , transactionIsolationToTag
  , transactionIsolationFromTag
  , StoreState(..)
  , storeStateToTag
  , storeStateFromTag
  ) where

import Data.Word (Word8)

-- ---------------------------------------------------------------------------
-- Statement
-- ---------------------------------------------------------------------------

-- | RDF statement types.
--
-- Tags 0-1 (2 constructors).
data Statement
  = Triple  -- ^ Triple (tag 0).
  | Quad  -- ^ Quad (tag 1).
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

-- | Triple index orderings.
--
-- Tags 0-5 (6 constructors).
data IndexOrder
  = Spo  -- ^ SPO (tag 0).
  | Pos  -- ^ POS (tag 1).
  | Osp  -- ^ OSP (tag 2).
  | Gspo  -- ^ GSPO (tag 3).
  | Gpos  -- ^ GPOS (tag 4).
  | Gosp  -- ^ GOSP (tag 5).
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

-- | Triple store storage backends.
--
-- Tags 0-3 (4 constructors).
data StorageBackend
  = InMemory  -- ^ InMemory (tag 0).
  | BTree  -- ^ BTree (tag 1).
  | Lsm  -- ^ LSM (tag 2).
  | Persistent  -- ^ Persistent (tag 3).
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

-- | RDF import formats.
--
-- Tags 0-5 (6 constructors).
data ImportFormat
  = NTriples  -- ^ NTriples (tag 0).
  | Turtle  -- ^ Turtle (tag 1).
  | RdfXml  -- ^ RDF/XML (tag 2).
  | JsonLd  -- ^ JSON-LD (tag 3).
  | NQuads  -- ^ NQuads (tag 4).
  | Trig  -- ^ Trig (tag 5).
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

-- | Triple store transaction isolation.
--
-- Tags 0-2 (3 constructors).
data TransactionIsolation
  = ReadCommitted  -- ^ ReadCommitted (tag 0).
  | Serializable  -- ^ Serializable (tag 1).
  | Snapshot  -- ^ Snapshot (tag 2).
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

-- | Triple store states.
--
-- Tags 0-4 (5 constructors).
data StoreState
  = Idle  -- ^ Idle (tag 0).
  | Ready  -- ^ Ready (tag 1).
  | InTransaction  -- ^ In transaction (tag 2).
  | Importing  -- ^ Importing (tag 3).
  | Closing  -- ^ Closing (tag 4).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'StoreState' to its ABI tag value.
storeStateToTag :: StoreState -> Word8
storeStateToTag = fromIntegral . fromEnum

-- | Decode a 'StoreState' from its ABI tag value.
storeStateFromTag :: Word8 -> Maybe StoreState
storeStateFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: StoreState)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing
