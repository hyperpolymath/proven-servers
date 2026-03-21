-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- | HTTP protocol types for proven-servers.
--
-- HTTP protocol types, mirroring the Idris2 ABI.
-- All tag values match the Idris2 ABI discriminants exactly.
--
-- This is a pure type-definition module with no FFI dependencies.

module ProvenServers.Http
  ( -- * ADT types matching Idris2 ABI
      Method(..)
    , Version(..)
    , StatusCategory(..)
    , StatusCode(..)
    , ContentType(..)
    , HeaderType(..)
    , RequestPhase(..)
    , methodToTag
    , methodFromTag
    , versionToTag
    , versionFromTag
    , statusCategoryToTag
    , statusCategoryFromTag
    , statusCodeToTag
    , statusCodeFromTag
    , contentTypeToTag
    , contentTypeFromTag
    , headerTypeToTag
    , headerTypeFromTag
    , requestPhaseToTag
    , requestPhaseFromTag
  ) where

import Data.Word (Word8)

-- ---------------------------------------------------------------------------
-- Method
-- ---------------------------------------------------------------------------

-- | Method type matching the Idris2 ABI.
--
-- Tags 0-8 (9 constructors).
data Method
  = Get  -- ^ Tag 0.
  | Post  -- ^ Tag 1.
  | Put  -- ^ Tag 2.
  | Delete  -- ^ Tag 3.
  | Patch  -- ^ Tag 4.
  | Head  -- ^ Tag 5.
  | Options  -- ^ Tag 6.
  | Trace  -- ^ Tag 7.
  | Connect  -- ^ Tag 8.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'Method' to its ABI tag value.
methodToTag :: Method -> Word8
methodToTag = fromIntegral . fromEnum

-- | Decode a 'Method' from its ABI tag value.
methodFromTag :: Word8 -> Maybe Method
methodFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: Method)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- Version
-- ---------------------------------------------------------------------------

-- | Version type matching the Idris2 ABI.
--
-- Tags 0-3 (4 constructors).
data Version
  = Http10  -- ^ Tag 0.
  | Http11  -- ^ Tag 1.
  | Http20  -- ^ Tag 2.
  | Http30  -- ^ Tag 3.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'Version' to its ABI tag value.
versionToTag :: Version -> Word8
versionToTag = fromIntegral . fromEnum

-- | Decode a 'Version' from its ABI tag value.
versionFromTag :: Word8 -> Maybe Version
versionFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: Version)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- StatusCategory
-- ---------------------------------------------------------------------------

-- | StatusCategory type matching the Idris2 ABI.
--
-- Tags 0-4 (5 constructors).
data StatusCategory
  = Informational  -- ^ Tag 0.
  | Success  -- ^ Tag 1.
  | Redirect  -- ^ Tag 2.
  | ClientError  -- ^ Tag 3.
  | ServerError  -- ^ Tag 4.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'StatusCategory' to its ABI tag value.
statusCategoryToTag :: StatusCategory -> Word8
statusCategoryToTag = fromIntegral . fromEnum

-- | Decode a 'StatusCategory' from its ABI tag value.
statusCategoryFromTag :: Word8 -> Maybe StatusCategory
statusCategoryFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: StatusCategory)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- StatusCode
-- ---------------------------------------------------------------------------

-- | StatusCode type matching the Idris2 ABI.
--
-- Tags 0-28 (29 constructors).
data StatusCode
  = Continue  -- ^ Tag 0.
  | SwitchingProtocols  -- ^ Tag 1.
  | Ok  -- ^ Tag 2.
  | Created  -- ^ Tag 3.
  | Accepted  -- ^ Tag 4.
  | NoContent  -- ^ Tag 5.
  | MovedPermanently  -- ^ Tag 6.
  | Found  -- ^ Tag 7.
  | NotModified  -- ^ Tag 8.
  | TemporaryRedirect  -- ^ Tag 9.
  | PermanentRedirect  -- ^ Tag 10.
  | BadRequest  -- ^ Tag 11.
  | Unauthorized  -- ^ Tag 12.
  | Forbidden  -- ^ Tag 13.
  | NotFound  -- ^ Tag 14.
  | MethodNotAllowed  -- ^ Tag 15.
  | RequestTimeout  -- ^ Tag 16.
  | Conflict  -- ^ Tag 17.
  | Gone  -- ^ Tag 18.
  | LengthRequired  -- ^ Tag 19.
  | PayloadTooLarge  -- ^ Tag 20.
  | UriTooLong  -- ^ Tag 21.
  | UnsupportedMedia  -- ^ Tag 22.
  | TooManyRequests  -- ^ Tag 23.
  | InternalError  -- ^ Tag 24.
  | NotImplemented  -- ^ Tag 25.
  | BadGateway  -- ^ Tag 26.
  | ServiceUnavailable  -- ^ Tag 27.
  | GatewayTimeout  -- ^ Tag 28.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'StatusCode' to its ABI tag value.
statusCodeToTag :: StatusCode -> Word8
statusCodeToTag = fromIntegral . fromEnum

-- | Decode a 'StatusCode' from its ABI tag value.
statusCodeFromTag :: Word8 -> Maybe StatusCode
statusCodeFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: StatusCode)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- ContentType
-- ---------------------------------------------------------------------------

-- | ContentType type matching the Idris2 ABI.
--
-- Tags 0-7 (8 constructors).
data ContentType
  = TextPlain  -- ^ Tag 0.
  | TextHtml  -- ^ Tag 1.
  | ApplicationJson  -- ^ Tag 2.
  | ApplicationXml  -- ^ Tag 3.
  | ApplicationForm  -- ^ Tag 4.
  | MultipartForm  -- ^ Tag 5.
  | OctetStream  -- ^ Tag 6.
  | TextCss  -- ^ Tag 7.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'ContentType' to its ABI tag value.
contentTypeToTag :: ContentType -> Word8
contentTypeToTag = fromIntegral . fromEnum

-- | Decode a 'ContentType' from its ABI tag value.
contentTypeFromTag :: Word8 -> Maybe ContentType
contentTypeFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: ContentType)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- HeaderType
-- ---------------------------------------------------------------------------

-- | HeaderType type matching the Idris2 ABI.
--
-- Tags 0-9 (10 constructors).
data HeaderType
  = ContentType  -- ^ Tag 0.
  | ContentLength  -- ^ Tag 1.
  | Host  -- ^ Tag 2.
  | Connection  -- ^ Tag 3.
  | Accept  -- ^ Tag 4.
  | UserAgent  -- ^ Tag 5.
  | Server  -- ^ Tag 6.
  | Location  -- ^ Tag 7.
  | CacheControl  -- ^ Tag 8.
  | Custom  -- ^ Tag 9.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'HeaderType' to its ABI tag value.
headerTypeToTag :: HeaderType -> Word8
headerTypeToTag = fromIntegral . fromEnum

-- | Decode a 'HeaderType' from its ABI tag value.
headerTypeFromTag :: Word8 -> Maybe HeaderType
headerTypeFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: HeaderType)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- RequestPhase
-- ---------------------------------------------------------------------------

-- | RequestPhase type matching the Idris2 ABI.
--
-- Tags 0-6 (7 constructors).
data RequestPhase
  = Idle  -- ^ Tag 0.
  | Receiving  -- ^ Tag 1.
  | HeadersParsed  -- ^ Tag 2.
  | BodyReceiving  -- ^ Tag 3.
  | Complete  -- ^ Tag 4.
  | Responding  -- ^ Tag 5.
  | Sent  -- ^ Tag 6.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'RequestPhase' to its ABI tag value.
requestPhaseToTag :: RequestPhase -> Word8
requestPhaseToTag = fromIntegral . fromEnum

-- | Decode a 'RequestPhase' from its ABI tag value.
requestPhaseFromTag :: Word8 -> Maybe RequestPhase
requestPhaseFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: RequestPhase)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing
