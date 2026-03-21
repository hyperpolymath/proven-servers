-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- | Graph DB protocol types for proven-servers.
--
-- Graph database types, mirroring the Idris2 ABI.
-- All tag values match the Idris2 ABI discriminants exactly.
--
-- This is a pure type-definition module with no FFI dependencies.

module ProvenServers.Graphdb
  ( -- * ADT types matching Idris2 ABI
      ElementType(..)
    , QueryLanguage(..)
    , TraversalStrategy(..)
    , Consistency(..)
    , ErrorCode(..)
    , SessionState(..)
    , elementTypeToTag
    , elementTypeFromTag
    , queryLanguageToTag
    , queryLanguageFromTag
    , traversalStrategyToTag
    , traversalStrategyFromTag
    , consistencyToTag
    , consistencyFromTag
    , errorCodeToTag
    , errorCodeFromTag
    , sessionStateToTag
    , sessionStateFromTag
  ) where

import Data.Word (Word8)

-- ---------------------------------------------------------------------------
-- ElementType
-- ---------------------------------------------------------------------------

-- | ElementType type matching the Idris2 ABI.
--
-- Tags 0-4 (5 constructors).
data ElementType
  = Node  -- ^ Tag 0.
  | Edge  -- ^ Tag 1.
  | Property  -- ^ Tag 2.
  | Label  -- ^ Tag 3.
  | Index  -- ^ Tag 4.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'ElementType' to its ABI tag value.
elementTypeToTag :: ElementType -> Word8
elementTypeToTag = fromIntegral . fromEnum

-- | Decode a 'ElementType' from its ABI tag value.
elementTypeFromTag :: Word8 -> Maybe ElementType
elementTypeFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: ElementType)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- QueryLanguage
-- ---------------------------------------------------------------------------

-- | QueryLanguage type matching the Idris2 ABI.
--
-- Tags 0-3 (4 constructors).
data QueryLanguage
  = Cypher  -- ^ Tag 0.
  | Gremlin  -- ^ Tag 1.
  | Sparql  -- ^ Tag 2.
  | GraphQl  -- ^ Tag 3.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'QueryLanguage' to its ABI tag value.
queryLanguageToTag :: QueryLanguage -> Word8
queryLanguageToTag = fromIntegral . fromEnum

-- | Decode a 'QueryLanguage' from its ABI tag value.
queryLanguageFromTag :: Word8 -> Maybe QueryLanguage
queryLanguageFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: QueryLanguage)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- TraversalStrategy
-- ---------------------------------------------------------------------------

-- | TraversalStrategy type matching the Idris2 ABI.
--
-- Tags 0-4 (5 constructors).
data TraversalStrategy
  = Bfs  -- ^ Tag 0.
  | Dfs  -- ^ Tag 1.
  | Dijkstra  -- ^ Tag 2.
  | AStar  -- ^ Tag 3.
  | Random  -- ^ Tag 4.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'TraversalStrategy' to its ABI tag value.
traversalStrategyToTag :: TraversalStrategy -> Word8
traversalStrategyToTag = fromIntegral . fromEnum

-- | Decode a 'TraversalStrategy' from its ABI tag value.
traversalStrategyFromTag :: Word8 -> Maybe TraversalStrategy
traversalStrategyFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: TraversalStrategy)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- Consistency
-- ---------------------------------------------------------------------------

-- | Consistency type matching the Idris2 ABI.
--
-- Tags 0-3 (4 constructors).
data Consistency
  = Strong  -- ^ Tag 0.
  | Eventual  -- ^ Tag 1.
  | Session  -- ^ Tag 2.
  | Causal  -- ^ Tag 3.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'Consistency' to its ABI tag value.
consistencyToTag :: Consistency -> Word8
consistencyToTag = fromIntegral . fromEnum

-- | Decode a 'Consistency' from its ABI tag value.
consistencyFromTag :: Word8 -> Maybe Consistency
consistencyFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: Consistency)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- ErrorCode
-- ---------------------------------------------------------------------------

-- | ErrorCode type matching the Idris2 ABI.
--
-- Tags 0-6 (7 constructors).
data ErrorCode
  = SyntaxError  -- ^ Tag 0.
  | NodeNotFound  -- ^ Tag 1.
  | EdgeNotFound  -- ^ Tag 2.
  | ConstraintViolation  -- ^ Tag 3.
  | IndexExists  -- ^ Tag 4.
  | TransactionConflict  -- ^ Tag 5.
  | OutOfMemory  -- ^ Tag 6.
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
-- SessionState
-- ---------------------------------------------------------------------------

-- | SessionState type matching the Idris2 ABI.
--
-- Tags 0-4 (5 constructors).
data SessionState
  = Idle  -- ^ Tag 0.
  | Connected  -- ^ Tag 1.
  | Querying  -- ^ Tag 2.
  | Traversing  -- ^ Tag 3.
  | Disconnecting  -- ^ Tag 4.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'SessionState' to its ABI tag value.
sessionStateToTag :: SessionState -> Word8
sessionStateToTag = fromIntegral . fromEnum

-- | Decode a 'SessionState' from its ABI tag value.
sessionStateFromTag :: Word8 -> Maybe SessionState
sessionStateFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: SessionState)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing
