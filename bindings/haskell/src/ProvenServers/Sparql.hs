-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- | SPARQL types for the proven-servers ABI.
--
-- All tag values match the Idris2 ABI discriminants exactly.

module ProvenServers.Sparql
  (
    SparqlQueryType(..)
  , sparqlQueryTypeToTag
  , sparqlQueryTypeFromTag
  , UpdateType(..)
  , updateTypeToTag
  , updateTypeFromTag
  , ResultFormat(..)
  , resultFormatToTag
  , resultFormatFromTag
  , SparqlErrorType(..)
  , sparqlErrorTypeToTag
  , sparqlErrorTypeFromTag
  ) where

import Data.Word (Word8)

-- ---------------------------------------------------------------------------
-- SparqlQueryType
-- ---------------------------------------------------------------------------

-- | SPARQL query types.
--
-- Tags 0-3 (4 constructors).
data SparqlQueryType
  = Select  -- ^ Select (tag 0).
  | Construct  -- ^ Construct (tag 1).
  | Ask  -- ^ Ask (tag 2).
  | Describe  -- ^ Describe (tag 3).
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

-- | SPARQL update types.
--
-- Tags 0-5 (6 constructors).
data UpdateType
  = Insert  -- ^ Insert (tag 0).
  | Delete  -- ^ Delete (tag 1).
  | Load  -- ^ Load (tag 2).
  | Clear  -- ^ Clear (tag 3).
  | Create  -- ^ Create (tag 4).
  | Drop  -- ^ Drop (tag 5).
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

-- | SPARQL result formats.
--
-- Tags 0-3 (4 constructors).
data ResultFormat
  = Xml  -- ^ XML (tag 0).
  | Json  -- ^ JSON (tag 1).
  | Csv  -- ^ CSV (tag 2).
  | Tsv  -- ^ TSV (tag 3).
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

-- | SPARQL error types.
--
-- Tags 0-4 (5 constructors).
data SparqlErrorType
  = ParseError  -- ^ ParseError (tag 0).
  | QueryTimeout  -- ^ QueryTimeout (tag 1).
  | ResultsTooLarge  -- ^ ResultsTooLarge (tag 2).
  | UnknownGraph  -- ^ UnknownGraph (tag 3).
  | AccessDenied  -- ^ AccessDenied (tag 4).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'SparqlErrorType' to its ABI tag value.
sparqlErrorTypeToTag :: SparqlErrorType -> Word8
sparqlErrorTypeToTag = fromIntegral . fromEnum

-- | Decode a 'SparqlErrorType' from its ABI tag value.
sparqlErrorTypeFromTag :: Word8 -> Maybe SparqlErrorType
sparqlErrorTypeFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: SparqlErrorType)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing
