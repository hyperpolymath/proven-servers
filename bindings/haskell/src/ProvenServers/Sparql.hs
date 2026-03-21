-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- | SPARQL protocol types for proven-servers.
--
-- SPARQL endpoint types, mirroring the Idris2 ABI.
-- All tag values match the Idris2 ABI discriminants exactly.
--
-- This is a pure type-definition module with no FFI dependencies.

module ProvenServers.Sparql
  ( -- * ADT types matching Idris2 ABI
      SparqlQueryType(..)
    , UpdateType(..)
    , ResultFormat(..)
    , SparqlErrorType(..)
    , sparqlQueryTypeToTag
    , sparqlQueryTypeFromTag
    , updateTypeToTag
    , updateTypeFromTag
    , resultFormatToTag
    , resultFormatFromTag
    , sparqlErrorTypeToTag
    , sparqlErrorTypeFromTag
  ) where

import Data.Word (Word8)

-- ---------------------------------------------------------------------------
-- SparqlQueryType
-- ---------------------------------------------------------------------------

-- | SparqlQueryType type matching the Idris2 ABI.
--
-- Tags 0-3 (4 constructors).
data SparqlQueryType
  = Select  -- ^ Tag 0.
  | Construct  -- ^ Tag 1.
  | Ask  -- ^ Tag 2.
  | Describe  -- ^ Tag 3.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'SparqlQueryType' to its ABI tag value.
sparqlQueryTypeToTag :: SparqlQueryType -> Word8
sparqlQueryTypeToTag = fromIntegral . fromEnum

-- | Decode a 'SparqlQueryType' from its ABI tag value.
sparqlQueryTypeFromTag :: Word8 -> Maybe SparqlQueryType
sparqlQueryTypeFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: SparqlQueryType)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- UpdateType
-- ---------------------------------------------------------------------------

-- | UpdateType type matching the Idris2 ABI.
--
-- Tags 0-5 (6 constructors).
data UpdateType
  = Insert  -- ^ Tag 0.
  | Delete  -- ^ Tag 1.
  | Load  -- ^ Tag 2.
  | Clear  -- ^ Tag 3.
  | Create  -- ^ Tag 4.
  | Drop  -- ^ Tag 5.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'UpdateType' to its ABI tag value.
updateTypeToTag :: UpdateType -> Word8
updateTypeToTag = fromIntegral . fromEnum

-- | Decode a 'UpdateType' from its ABI tag value.
updateTypeFromTag :: Word8 -> Maybe UpdateType
updateTypeFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: UpdateType)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- ResultFormat
-- ---------------------------------------------------------------------------

-- | ResultFormat type matching the Idris2 ABI.
--
-- Tags 0-3 (4 constructors).
data ResultFormat
  = Xml  -- ^ Tag 0.
  | Json  -- ^ Tag 1.
  | Csv  -- ^ Tag 2.
  | Tsv  -- ^ Tag 3.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'ResultFormat' to its ABI tag value.
resultFormatToTag :: ResultFormat -> Word8
resultFormatToTag = fromIntegral . fromEnum

-- | Decode a 'ResultFormat' from its ABI tag value.
resultFormatFromTag :: Word8 -> Maybe ResultFormat
resultFormatFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: ResultFormat)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- SparqlErrorType
-- ---------------------------------------------------------------------------

-- | SparqlErrorType type matching the Idris2 ABI.
--
-- Tags 0-4 (5 constructors).
data SparqlErrorType
  = ParseError  -- ^ Tag 0.
  | QueryTimeout  -- ^ Tag 1.
  | ResultsTooLarge  -- ^ Tag 2.
  | UnknownGraph  -- ^ Tag 3.
  | AccessDenied  -- ^ Tag 4.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'SparqlErrorType' to its ABI tag value.
sparqlErrorTypeToTag :: SparqlErrorType -> Word8
sparqlErrorTypeToTag = fromIntegral . fromEnum

-- | Decode a 'SparqlErrorType' from its ABI tag value.
sparqlErrorTypeFromTag :: Word8 -> Maybe SparqlErrorType
sparqlErrorTypeFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: SparqlErrorType)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing
