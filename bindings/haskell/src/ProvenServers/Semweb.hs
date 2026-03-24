-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- | Semantic Web types for the proven-servers ABI.
--
-- All tag values match the Idris2 ABI discriminants exactly.

module ProvenServers.Semweb
  (
    RdfFormat(..)
  , rdfFormatToTag
  , rdfFormatFromTag
  , SemwebResourceType(..)
  , semwebResourceTypeToTag
  , semwebResourceTypeFromTag
  , HttpMethod(..)
  , httpMethodToTag
  , httpMethodFromTag
  , ContentNegotiation(..)
  , contentNegotiationToTag
  , contentNegotiationFromTag
  , SemwebErrorCode(..)
  , semwebErrorCodeToTag
  , semwebErrorCodeFromTag
  ) where

import Data.Word (Word8)

-- ---------------------------------------------------------------------------
-- RdfFormat
-- ---------------------------------------------------------------------------

-- | RDF serialization formats.
--
-- Tags 0-5 (6 constructors).
data RdfFormat
  = RdfXml  -- ^ RDF/XML (tag 0).
  | Turtle  -- ^ Turtle (tag 1).
  | NTriples  -- ^ NTriples (tag 2).
  | NQuads  -- ^ NQuads (tag 3).
  | JsonLd  -- ^ JSON-LD (tag 4).
  | Trig  -- ^ Trig (tag 5).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'RdfFormat' to its ABI tag value.
rdfFormatToTag :: RdfFormat -> Word8
rdfFormatToTag = fromIntegral . fromEnum

-- | Decode a 'RdfFormat' from its ABI tag value.
rdfFormatFromTag :: Word8 -> Maybe RdfFormat
rdfFormatFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: RdfFormat)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- SemwebResourceType
-- ---------------------------------------------------------------------------

-- | Semantic web resource types.
--
-- Tags 0-4 (5 constructors).
data SemwebResourceType
  = Class  -- ^ Class (tag 0).
  | Property  -- ^ Property (tag 1).
  | Individual  -- ^ Individual (tag 2).
  | Ontology  -- ^ Ontology (tag 3).
  | NamedGraph  -- ^ NamedGraph (tag 4).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'SemwebResourceType' to its ABI tag value.
semwebResourceTypeToTag :: SemwebResourceType -> Word8
semwebResourceTypeToTag = fromIntegral . fromEnum

-- | Decode a 'SemwebResourceType' from its ABI tag value.
semwebResourceTypeFromTag :: Word8 -> Maybe SemwebResourceType
semwebResourceTypeFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: SemwebResourceType)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- HttpMethod
-- ---------------------------------------------------------------------------

-- | Semantic web HTTP methods.
--
-- Tags 0-4 (5 constructors).
data HttpMethod
  = Get  -- ^ Get (tag 0).
  | Post  -- ^ Post (tag 1).
  | Put  -- ^ Put (tag 2).
  | Patch  -- ^ Patch (tag 3).
  | Delete  -- ^ Delete (tag 4).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'HttpMethod' to its ABI tag value.
httpMethodToTag :: HttpMethod -> Word8
httpMethodToTag = fromIntegral . fromEnum

-- | Decode a 'HttpMethod' from its ABI tag value.
httpMethodFromTag :: Word8 -> Maybe HttpMethod
httpMethodFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: HttpMethod)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- ContentNegotiation
-- ---------------------------------------------------------------------------

-- | Content negotiation preferences.
--
-- Tags 0-3 (4 constructors).
data ContentNegotiation
  = NegRdfXml  -- ^ RDF/XML (tag 0).
  | NegTurtle  -- ^ Turtle (tag 1).
  | NegJsonLd  -- ^ JSON-LD (tag 2).
  | NegHtml  -- ^ HTML (tag 3).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'ContentNegotiation' to its ABI tag value.
contentNegotiationToTag :: ContentNegotiation -> Word8
contentNegotiationToTag = fromIntegral . fromEnum

-- | Decode a 'ContentNegotiation' from its ABI tag value.
contentNegotiationFromTag :: Word8 -> Maybe ContentNegotiation
contentNegotiationFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: ContentNegotiation)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- SemwebErrorCode
-- ---------------------------------------------------------------------------

-- | Semantic web error codes.
--
-- Tags 0-4 (5 constructors).
data SemwebErrorCode
  = NotFound  -- ^ NotFound (tag 0).
  | InvalidUri  -- ^ Invalid URI (tag 1).
  | MalformedRdf  -- ^ Malformed RDF (tag 2).
  | UnsupportedFormat  -- ^ UnsupportedFormat (tag 3).
  | ConflictingTriples  -- ^ ConflictingTriples (tag 4).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'SemwebErrorCode' to its ABI tag value.
semwebErrorCodeToTag :: SemwebErrorCode -> Word8
semwebErrorCodeToTag = fromIntegral . fromEnum

-- | Decode a 'SemwebErrorCode' from its ABI tag value.
semwebErrorCodeFromTag :: Word8 -> Maybe SemwebErrorCode
semwebErrorCodeFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: SemwebErrorCode)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing
