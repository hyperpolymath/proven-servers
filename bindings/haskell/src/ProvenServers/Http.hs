-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- | HTTP protocol types for the proven-servers ABI.
--
-- All tag values match the Idris2 ABI discriminants exactly.

module ProvenServers.Http
  (
    Method(..)
  , methodToTag
  , methodFromTag
  , isSafe
  , isIdempotent
  , hasRequestBody
  , asStr
  , Version(..)
  , versionToTag
  , versionFromTag
  , StatusCategory(..)
  , statusCategoryToTag
  , statusCategoryFromTag
  , StatusCode(..)
  , statusCodeToTag
  , statusCodeFromTag
  , isSuccess
  , isError
  , isRedirect
  , reasonPhrase
  , ContentType(..)
  , contentTypeToTag
  , contentTypeFromTag
  , mime
  , HeaderType(..)
  , headerTypeToTag
  , headerTypeFromTag
  , name
  , RequestPhase(..)
  , requestPhaseToTag
  , requestPhaseFromTag
  ) where

import Data.Word (Word8)

-- ---------------------------------------------------------------------------
-- Method
-- ---------------------------------------------------------------------------

-- | Standard HTTP request methods (RFC 7231 Section 4, RFC 5789).
--
-- Tags 0-8 (9 constructors).
data Method
  = Get  -- ^ Retrieve a representation of the target resource.
  | Post  -- ^ Perform resource-specific processing on the request payload.
  | Put  -- ^ Replace all current representations of the target resource.
  | Delete  -- ^ Remove all current representations of the target resource.
  | Patch  -- ^ Apply partial modifications to a resource (RFC 5789).
  | Head  -- ^ Same as GET but only transfer status line and headers.
  | Options  -- ^ Describe the communication options for the target resource.
  | Trace  -- ^ Perform a message loop-back test along the path to the target.
  | Connect  -- ^ Establish a tunnel to the server identified by the target resource.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'Method' to its ABI tag value.
methodToTag :: Method -> Word8
methodToTag = fromIntegral . fromEnum

-- | Decode a 'Method' from its ABI tag value.
methodFromTag :: Word8 -> Maybe Method
methodFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: Method)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- | Matches `isSafe` in `HTTP.Method`.
isSafe :: Method -> Bool
isSafe Get = True
isSafe Head = True
isSafe Options = True
isSafe Trace = True
isSafe _ = False

-- | /// Matches `isIdempotent` in `HTTP.Method`.
isIdempotent :: Method -> Bool
isIdempotent Get = True
isIdempotent Head = True
isIdempotent Put = True
isIdempotent Delete = True
isIdempotent Options = True
isIdempotent Trace = True
isIdempotent _ = False

-- | /// Matches `hasRequestBody` in `HTTP.Method`.
hasRequestBody :: Method -> Bool
hasRequestBody Post = True
hasRequestBody Put = True
hasRequestBody Patch = True
hasRequestBody _ = False

-- | Canonical string representation (e.g. `"GET"`).
asStr :: Method -> String
asStr Get = "GET"
asStr Post = "POST"
asStr Put = "PUT"
asStr Delete = "DELETE"
asStr Patch = "PATCH"
asStr Head = "HEAD"
asStr Options = "OPTIONS"
asStr Trace = "TRACE"
asStr Connect = "CONNECT"

-- ---------------------------------------------------------------------------
-- Version
-- ---------------------------------------------------------------------------

-- | HTTP protocol versions.
--
-- Tags 0-3 (4 constructors).
data Version
  = Http10  -- ^ HTTP/1.0 (RFC 1945).
  | Http11  -- ^ HTTP/1.1 (RFC 7230).
  | Http20  -- ^ HTTP/2 (RFC 7540).
  | Http30  -- ^ HTTP/3 (RFC 9114).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'Version' to its ABI tag value.
versionToTag :: Version -> Word8
versionToTag = fromIntegral . fromEnum

-- | Decode a 'Version' from its ABI tag value.
versionFromTag :: Word8 -> Maybe Version
versionFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: Version)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- | Human-readable version string.
asStr :: Version -> String
asStr Http10 = "HTTP/1.0"
asStr Http11 = "HTTP/1.1"
asStr Http20 = "HTTP/2"
asStr Http30 = "HTTP/3"

-- ---------------------------------------------------------------------------
-- StatusCategory
-- ---------------------------------------------------------------------------

-- | HTTP response status code categories (RFC 7231 Section 6).
--
-- Tags 0-4 (5 constructors).
data StatusCategory
  = Informational  -- ^ 1xx: request received, continuing process.
  | Success  -- ^ 2xx: request successfully received, understood, and accepted.
  | Redirect  -- ^ 3xx: further action needed to complete the request.
  | ClientError  -- ^ 4xx: request contains bad syntax or cannot be fulfilled.
  | ServerError  -- ^ 5xx: server failed to fulfil an apparently valid request.
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

-- | Common HTTP status codes (RFC 7231 and related RFCs).
--
-- Tags 0-28 (29 constructors).
data StatusCode
  = Continue  -- ^ 100 Continue.
  | SwitchingProtocols  -- ^ 101 Switching Protocols.
  | Ok  -- ^ 200 OK.
  | Created  -- ^ 201 Created.
  | Accepted  -- ^ 202 Accepted.
  | NoContent  -- ^ 204 No Content.
  | MovedPermanently  -- ^ 301 Moved Permanently.
  | Found  -- ^ 302 Found.
  | NotModified  -- ^ 304 Not Modified.
  | TemporaryRedirect  -- ^ 307 Temporary Redirect.
  | PermanentRedirect  -- ^ 308 Permanent Redirect.
  | BadRequest  -- ^ 400 Bad Request.
  | Unauthorized  -- ^ 401 Unauthorized.
  | Forbidden  -- ^ 403 Forbidden.
  | NotFound  -- ^ 404 Not Found.
  | MethodNotAllowed  -- ^ 405 Method Not Allowed.
  | RequestTimeout  -- ^ 408 Request Timeout.
  | Conflict  -- ^ 409 Conflict.
  | Gone  -- ^ 410 Gone.
  | LengthRequired  -- ^ 411 Length Required.
  | PayloadTooLarge  -- ^ 413 Payload Too Large.
  | UriTooLong  -- ^ 414 URI Too Long.
  | UnsupportedMedia  -- ^ 415 Unsupported Media Type.
  | TooManyRequests  -- ^ 429 Too Many Requests.
  | InternalError  -- ^ 500 Internal Server Error.
  | NotImplemented  -- ^ 501 Not Implemented.
  | BadGateway  -- ^ 502 Bad Gateway.
  | ServiceUnavailable  -- ^ 503 Service Unavailable.
  | GatewayTimeout  -- ^ 504 Gateway Timeout.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'StatusCode' to its ABI tag value.
statusCodeToTag :: StatusCode -> Word8
statusCodeToTag = fromIntegral . fromEnum

-- | Decode a 'StatusCode' from its ABI tag value.
statusCodeFromTag :: Word8 -> Maybe StatusCode
statusCodeFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: StatusCode)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- | Whether this is a success code (2xx).
isSuccess :: StatusCode -> Bool
isSuccess _ = False

-- | Whether this is an error code (4xx or 5xx).
isError :: StatusCode -> Bool
isError _ = False

-- | Whether this is a redirect code (3xx).
isRedirect :: StatusCode -> Bool
isRedirect _ = False

-- | /// Matches `reasonPhrase` in `HTTP.Status`.
reasonPhrase :: StatusCode -> String
reasonPhrase Continue = "Continue"
reasonPhrase SwitchingProtocols = "Switching Protocols"
reasonPhrase Ok = "OK"
reasonPhrase Created = "Created"
reasonPhrase Accepted = "Accepted"
reasonPhrase NoContent = "No Content"
reasonPhrase MovedPermanently = "Moved Permanently"
reasonPhrase Found = "Found"
reasonPhrase NotModified = "Not Modified"
reasonPhrase TemporaryRedirect = "Temporary Redirect"
reasonPhrase PermanentRedirect = "Permanent Redirect"
reasonPhrase BadRequest = "Bad Request"
reasonPhrase Unauthorized = "Unauthorized"
reasonPhrase Forbidden = "Forbidden"
reasonPhrase NotFound = "Not Found"
reasonPhrase MethodNotAllowed = "Method Not Allowed"
reasonPhrase RequestTimeout = "Request Timeout"
reasonPhrase Conflict = "Conflict"
reasonPhrase Gone = "Gone"
reasonPhrase LengthRequired = "Length Required"
reasonPhrase PayloadTooLarge = "Payload Too Large"
reasonPhrase UriTooLong = "URI Too Long"
reasonPhrase UnsupportedMedia = "Unsupported Media Type"
reasonPhrase TooManyRequests = "Too Many Requests"
reasonPhrase InternalError = "Internal Server Error"
reasonPhrase NotImplemented = "Not Implemented"
reasonPhrase BadGateway = "Bad Gateway"
reasonPhrase ServiceUnavailable = "Service Unavailable"
reasonPhrase GatewayTimeout = "Gateway Timeout"

-- ---------------------------------------------------------------------------
-- ContentType
-- ---------------------------------------------------------------------------

-- | Common HTTP content types for ABI interchange.
--
-- Tags 0-7 (8 constructors).
data ContentType
  = TextPlain  -- ^ `text/plain`.
  | TextHtml  -- ^ `text/html`.
  | ApplicationJson  -- ^ `application/json`.
  | ApplicationXml  -- ^ `application/xml`.
  | ApplicationForm  -- ^ `application/x-www-form-urlencoded`.
  | MultipartForm  -- ^ `multipart/form-data`.
  | OctetStream  -- ^ `application/octet-stream`.
  | TextCss  -- ^ `text/css`.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'ContentType' to its ABI tag value.
contentTypeToTag :: ContentType -> Word8
contentTypeToTag = fromIntegral . fromEnum

-- | Decode a 'ContentType' from its ABI tag value.
contentTypeFromTag :: Word8 -> Maybe ContentType
contentTypeFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: ContentType)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- | MIME type string.
mime :: ContentType -> String
mime TextPlain = "text/plain"
mime TextHtml = "text/html"
mime ApplicationJson = "application/json"
mime ApplicationXml = "application/xml"
mime ApplicationForm = "application/x-www-form-urlencoded"
mime MultipartForm = "multipart/form-data"
mime OctetStream = "application/octet-stream"
mime TextCss = "text/css"

-- ---------------------------------------------------------------------------
-- HeaderType
-- ---------------------------------------------------------------------------

-- | Common HTTP header names as an enumeration for ABI interchange.
--
-- Tags 0-9 (10 constructors).
data HeaderType
  = ContentType  -- ^ `Content-Type`.
  | ContentLength  -- ^ `Content-Length`.
  | Host  -- ^ `Host`.
  | Connection  -- ^ `Connection`.
  | Accept  -- ^ `Accept`.
  | UserAgent  -- ^ `User-Agent`.
  | Server  -- ^ `Server`.
  | Location  -- ^ `Location`.
  | CacheControl  -- ^ `Cache-Control`.
  | Custom  -- ^ Custom / unknown header.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'HeaderType' to its ABI tag value.
headerTypeToTag :: HeaderType -> Word8
headerTypeToTag = fromIntegral . fromEnum

-- | Decode a 'HeaderType' from its ABI tag value.
headerTypeFromTag :: Word8 -> Maybe HeaderType
headerTypeFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: HeaderType)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- | Canonical header name string.
name :: HeaderType -> String
name ContentType = "Content-Type"
name ContentLength = "Content-Length"
name Host = "Host"
name Connection = "Connection"
name Accept = "Accept"
name UserAgent = "User-Agent"
name Server = "Server"
name Location = "Location"
name CacheControl = "Cache-Control"
name Custom = "X-Custom"

-- ---------------------------------------------------------------------------
-- RequestPhase
-- ---------------------------------------------------------------------------

-- | Phases of the HTTP request processing lifecycle.
--
-- Tags 0-6 (7 constructors).
data RequestPhase
  = Idle  -- ^ Waiting for a new request.
  | Receiving  -- ^ Receiving request data.
  | HeadersParsed  -- ^ Request headers fully parsed.
  | BodyReceiving  -- ^ Receiving request body.
  | Complete  -- ^ Full request received.
  | Responding  -- ^ Constructing response.
  | Sent  -- ^ Response fully sent.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'RequestPhase' to its ABI tag value.
requestPhaseToTag :: RequestPhase -> Word8
requestPhaseToTag = fromIntegral . fromEnum

-- | Decode a 'RequestPhase' from its ABI tag value.
requestPhaseFromTag :: Word8 -> Maybe RequestPhase
requestPhaseFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: RequestPhase)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing
