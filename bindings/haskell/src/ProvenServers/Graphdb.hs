-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- | Graph Database types for the proven-servers ABI.
--
-- All tag values match the Idris2 ABI discriminants exactly.

module ProvenServers.Graphdb
  (
    graphdbPort
  , ElementType(..)
  , elementTypeToTag
  , elementTypeFromTag
  , QueryLanguage(..)
  , queryLanguageToTag
  , queryLanguageFromTag
  , TraversalStrategy(..)
  , traversalStrategyToTag
  , traversalStrategyFromTag
  , Consistency(..)
  , consistencyToTag
  , consistencyFromTag
  , ErrorCode(..)
  , errorCodeToTag
  , errorCodeFromTag
  , SessionState(..)
  , sessionStateToTag
  , sessionStateFromTag
  ) where

import Data.Word (Word16, Word8)

-- | Standard Bolt protocol port.
graphdbPort :: Word16
graphdbPort = 7687

-- ---------------------------------------------------------------------------
-- ElementType
-- ---------------------------------------------------------------------------

-- | Standard Bolt protocol port.
--
-- Tags 0-4 (5 constructors).
data ElementType
  = Node  -- ^ Node (tag 0).
  | Edge  -- ^ Edge (tag 1).
  | Property  -- ^ Property (tag 2).
  | Label  -- ^ Label (tag 3).
  | Index  -- ^ Index (tag 4).
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

-- | Graph query languages.
--
-- Tags 0-3 (4 constructors).
data QueryLanguage
  = Cypher  -- ^ Cypher (tag 0).
  | Gremlin  -- ^ Gremlin (tag 1).
  | Sparql  -- ^ SPARQL (tag 2).
  | GraphQl  -- ^ GraphQL (tag 3).
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

-- | Graph traversal strategies.
--
-- Tags 0-4 (5 constructors).
data TraversalStrategy
  = Bfs  -- ^ Breadth-first search (tag 0).
  | Dfs  -- ^ Depth-first search (tag 1).
  | Dijkstra  -- ^ Dijkstra (tag 2).
  | AStar  -- ^ A* (tag 3).
  | Random  -- ^ Random (tag 4).
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

-- | Consistency levels.
--
-- Tags 0-3 (4 constructors).
data Consistency
  = Strong  -- ^ Strong (tag 0).
  | Eventual  -- ^ Eventual (tag 1).
  | Session  -- ^ Session (tag 2).
  | Causal  -- ^ Causal (tag 3).
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

-- | Graph database error codes.
--
-- Tags 0-6 (7 constructors).
data ErrorCode
  = SyntaxError  -- ^ SyntaxError (tag 0).
  | NodeNotFound  -- ^ NodeNotFound (tag 1).
  | EdgeNotFound  -- ^ EdgeNotFound (tag 2).
  | ConstraintViolation  -- ^ ConstraintViolation (tag 3).
  | IndexExists  -- ^ IndexExists (tag 4).
  | TransactionConflict  -- ^ TransactionConflict (tag 5).
  | OutOfMemory  -- ^ OutOfMemory (tag 6).
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

-- | Graph database session states.
--
-- Tags 0-4 (5 constructors).
data SessionState
  = Idle  -- ^ Idle (tag 0).
  | Connected  -- ^ Connected (tag 1).
  | Querying  -- ^ Querying (tag 2).
  | Traversing  -- ^ Traversing (tag 3).
  | Disconnecting  -- ^ Disconnecting (tag 4).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'SessionState' to its ABI tag value.
sessionStateToTag :: SessionState -> Word8
sessionStateToTag = fromIntegral . fromEnum

-- | Decode a 'SessionState' from its ABI tag value.
sessionStateFromTag :: Word8 -> Maybe SessionState
sessionStateFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: SessionState)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing
