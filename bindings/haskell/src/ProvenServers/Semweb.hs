-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- | Semantic Web protocol types for proven-servers.
--
-- Semantic Web types, mirroring the Idris2 ABI.
-- All tag values match the Idris2 ABI discriminants exactly.
--
-- This is a pure type-definition module with no FFI dependencies.

module ProvenServers.Semweb
  ( -- * ADT types matching Idris2 ABI
      RdfFormat(..)
    , SemwebResourceType(..)
    , HttpMethod(..)
    , ContentNegotiation(..)
    , SemwebErrorCode(..)
    , rdfFormatToTag
    , rdfFormatFromTag
    , semwebResourceTypeToTag
    , semwebResourceTypeFromTag
    , httpMethodToTag
    , httpMethodFromTag
    , contentNegotiationToTag
    , contentNegotiationFromTag
    , semwebErrorCodeToTag
    , semwebErrorCodeFromTag
  ) where

import Data.Word (Word8)

-- ---------------------------------------------------------------------------
-- RdfFormat
-- ---------------------------------------------------------------------------

-- | RdfFormat type matching the Idris2 ABI.
--
-- Tags 0-5 (6 constructors).
data RdfFormat
  = RdfXml  -- ^ Tag 0.
  | Turtle  -- ^ Tag 1.
  | NTriples  -- ^ Tag 2.
  | NQuads  -- ^ Tag 3.
  | JsonLd  -- ^ Tag 4.
  | Trig  -- ^ Tag 5.
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

-- | SemwebResourceType type matching the Idris2 ABI.
--
-- Tags 0-4 (5 constructors).
data SemwebResourceType
  = Class  -- ^ Tag 0.
  | Property  -- ^ Tag 1.
  | Individual  -- ^ Tag 2.
  | Ontology  -- ^ Tag 3.
  | NamedGraph  -- ^ Tag 4.
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

-- | HttpMethod type matching the Idris2 ABI.
--
-- Tags 0-4 (5 constructors).
data HttpMethod
  = Get  -- ^ Tag 0.
  | Post  -- ^ Tag 1.
  | Put  -- ^ Tag 2.
  | Patch  -- ^ Tag 3.
  | Delete  -- ^ Tag 4.
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

-- | ContentNegotiation type matching the Idris2 ABI.
--
-- Tags 0-3 (4 constructors).
data ContentNegotiation
  = NegRdfXml  -- ^ Tag 0.
  | NegTurtle  -- ^ Tag 1.
  | NegJsonLd  -- ^ Tag 2.
  | NegHtml  -- ^ Tag 3.
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

-- | SemwebErrorCode type matching the Idris2 ABI.
--
-- Tags 0-4 (5 constructors).
data SemwebErrorCode
  = NotFound  -- ^ Tag 0.
  | InvalidUri  -- ^ Tag 1.
  | MalformedRdf  -- ^ Tag 2.
  | UnsupportedFormat  -- ^ Tag 3.
  | ConflictingTriples  -- ^ Tag 4.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'SemwebErrorCode' to its ABI tag value.
semwebErrorCodeToTag :: SemwebErrorCode -> Word8
semwebErrorCodeToTag = fromIntegral . fromEnum

-- | Decode a 'SemwebErrorCode' from its ABI tag value.
semwebErrorCodeFromTag :: Word8 -> Maybe SemwebErrorCode
semwebErrorCodeFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: SemwebErrorCode)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing
