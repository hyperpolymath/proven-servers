-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- HTTPABI.Layout: C-ABI-compatible numeric representations of HTTP types.
--
-- Maps every constructor of the core HTTP sum types (HttpMethod, HttpVersion,
-- StatusCategory, ContentType, HeaderType) to fixed Bits8 values for C interop.
-- Each type gets a total encoder, partial decoder, and roundtrip proof.
--
-- Tag values here MUST match the C header (generated/abi/httpd.h) and the
-- Zig FFI enums (ffi/zig/src/httpd.zig) exactly.

module HTTPABI.Layout

%default total

---------------------------------------------------------------------------
-- HttpMethod (9 constructors, tags 0-8)
---------------------------------------------------------------------------

||| HTTP request methods as a closed sum type for ABI.
public export
data HttpMethod : Type where
  GET     : HttpMethod
  POST    : HttpMethod
  PUT     : HttpMethod
  DELETE  : HttpMethod
  PATCH   : HttpMethod
  HEAD    : HttpMethod
  OPTIONS : HttpMethod
  TRACE   : HttpMethod
  CONNECT : HttpMethod

public export
httpMethodSize : Nat
httpMethodSize = 1

public export
httpMethodToTag : HttpMethod -> Bits8
httpMethodToTag GET     = 0
httpMethodToTag POST    = 1
httpMethodToTag PUT     = 2
httpMethodToTag DELETE  = 3
httpMethodToTag PATCH   = 4
httpMethodToTag HEAD    = 5
httpMethodToTag OPTIONS = 6
httpMethodToTag TRACE   = 7
httpMethodToTag CONNECT = 8

public export
tagToHttpMethod : Bits8 -> Maybe HttpMethod
tagToHttpMethod 0 = Just GET
tagToHttpMethod 1 = Just POST
tagToHttpMethod 2 = Just PUT
tagToHttpMethod 3 = Just DELETE
tagToHttpMethod 4 = Just PATCH
tagToHttpMethod 5 = Just HEAD
tagToHttpMethod 6 = Just OPTIONS
tagToHttpMethod 7 = Just TRACE
tagToHttpMethod 8 = Just CONNECT
tagToHttpMethod _ = Nothing

public export
httpMethodRoundtrip : (m : HttpMethod) -> tagToHttpMethod (httpMethodToTag m) = Just m
httpMethodRoundtrip GET     = Refl
httpMethodRoundtrip POST    = Refl
httpMethodRoundtrip PUT     = Refl
httpMethodRoundtrip DELETE  = Refl
httpMethodRoundtrip PATCH   = Refl
httpMethodRoundtrip HEAD    = Refl
httpMethodRoundtrip OPTIONS = Refl
httpMethodRoundtrip TRACE   = Refl
httpMethodRoundtrip CONNECT = Refl

---------------------------------------------------------------------------
-- HttpVersion (4 constructors, tags 0-3)
---------------------------------------------------------------------------

||| HTTP protocol versions for ABI.
public export
data HttpVersion : Type where
  HTTP10 : HttpVersion
  HTTP11 : HttpVersion
  HTTP20 : HttpVersion
  HTTP30 : HttpVersion

public export
httpVersionSize : Nat
httpVersionSize = 1

public export
httpVersionToTag : HttpVersion -> Bits8
httpVersionToTag HTTP10 = 0
httpVersionToTag HTTP11 = 1
httpVersionToTag HTTP20 = 2
httpVersionToTag HTTP30 = 3

public export
tagToHttpVersion : Bits8 -> Maybe HttpVersion
tagToHttpVersion 0 = Just HTTP10
tagToHttpVersion 1 = Just HTTP11
tagToHttpVersion 2 = Just HTTP20
tagToHttpVersion 3 = Just HTTP30
tagToHttpVersion _ = Nothing

public export
httpVersionRoundtrip : (v : HttpVersion) -> tagToHttpVersion (httpVersionToTag v) = Just v
httpVersionRoundtrip HTTP10 = Refl
httpVersionRoundtrip HTTP11 = Refl
httpVersionRoundtrip HTTP20 = Refl
httpVersionRoundtrip HTTP30 = Refl

---------------------------------------------------------------------------
-- StatusCategory (5 constructors, tags 0-4)
---------------------------------------------------------------------------

||| HTTP status code categories for ABI.
public export
data StatusCat : Type where
  Informational : StatusCat
  Success       : StatusCat
  Redirect      : StatusCat
  ClientError   : StatusCat
  ServerError   : StatusCat

public export
statusCatSize : Nat
statusCatSize = 1

public export
statusCatToTag : StatusCat -> Bits8
statusCatToTag Informational = 0
statusCatToTag Success       = 1
statusCatToTag Redirect      = 2
statusCatToTag ClientError   = 3
statusCatToTag ServerError   = 4

public export
tagToStatusCat : Bits8 -> Maybe StatusCat
tagToStatusCat 0 = Just Informational
tagToStatusCat 1 = Just Success
tagToStatusCat 2 = Just Redirect
tagToStatusCat 3 = Just ClientError
tagToStatusCat 4 = Just ServerError
tagToStatusCat _ = Nothing

public export
statusCatRoundtrip : (c : StatusCat) -> tagToStatusCat (statusCatToTag c) = Just c
statusCatRoundtrip Informational = Refl
statusCatRoundtrip Success       = Refl
statusCatRoundtrip Redirect      = Refl
statusCatRoundtrip ClientError   = Refl
statusCatRoundtrip ServerError   = Refl

---------------------------------------------------------------------------
-- StatusCode (29 constructors, tags 0-28)
-- Grouped: 1xx (0-1), 2xx (2-5), 3xx (6-10), 4xx (11-23), 5xx (24-28)
---------------------------------------------------------------------------

||| HTTP status codes as a closed sum type for ABI.
||| Tag assignment groups codes by category for efficient range checks.
public export
data AbiStatusCode : Type where
  -- 1xx Informational (tags 0-1)
  SC_Continue           : AbiStatusCode  -- 100
  SC_SwitchingProtocols : AbiStatusCode  -- 101
  -- 2xx Success (tags 2-5)
  SC_OK                 : AbiStatusCode  -- 200
  SC_Created            : AbiStatusCode  -- 201
  SC_Accepted           : AbiStatusCode  -- 202
  SC_NoContent          : AbiStatusCode  -- 204
  -- 3xx Redirection (tags 6-10)
  SC_MovedPermanently   : AbiStatusCode  -- 301
  SC_Found              : AbiStatusCode  -- 302
  SC_NotModified        : AbiStatusCode  -- 304
  SC_TemporaryRedirect  : AbiStatusCode  -- 307
  SC_PermanentRedirect  : AbiStatusCode  -- 308
  -- 4xx Client Error (tags 11-23)
  SC_BadRequest         : AbiStatusCode  -- 400
  SC_Unauthorized       : AbiStatusCode  -- 401
  SC_Forbidden          : AbiStatusCode  -- 403
  SC_NotFound           : AbiStatusCode  -- 404
  SC_MethodNotAllowed   : AbiStatusCode  -- 405
  SC_RequestTimeout     : AbiStatusCode  -- 408
  SC_Conflict           : AbiStatusCode  -- 409
  SC_Gone               : AbiStatusCode  -- 410
  SC_LengthRequired     : AbiStatusCode  -- 411
  SC_PayloadTooLarge    : AbiStatusCode  -- 413
  SC_URITooLong         : AbiStatusCode  -- 414
  SC_UnsupportedMedia   : AbiStatusCode  -- 415
  SC_TooManyRequests    : AbiStatusCode  -- 429
  -- 5xx Server Error (tags 24-28)
  SC_InternalError      : AbiStatusCode  -- 500
  SC_NotImplemented     : AbiStatusCode  -- 501
  SC_BadGateway         : AbiStatusCode  -- 502
  SC_ServiceUnavailable : AbiStatusCode  -- 503
  SC_GatewayTimeout     : AbiStatusCode  -- 504

public export
abiStatusCodeSize : Nat
abiStatusCodeSize = 1

public export
abiStatusCodeToTag : AbiStatusCode -> Bits8
abiStatusCodeToTag SC_Continue           = 0
abiStatusCodeToTag SC_SwitchingProtocols = 1
abiStatusCodeToTag SC_OK                 = 2
abiStatusCodeToTag SC_Created            = 3
abiStatusCodeToTag SC_Accepted           = 4
abiStatusCodeToTag SC_NoContent          = 5
abiStatusCodeToTag SC_MovedPermanently   = 6
abiStatusCodeToTag SC_Found              = 7
abiStatusCodeToTag SC_NotModified        = 8
abiStatusCodeToTag SC_TemporaryRedirect  = 9
abiStatusCodeToTag SC_PermanentRedirect  = 10
abiStatusCodeToTag SC_BadRequest         = 11
abiStatusCodeToTag SC_Unauthorized       = 12
abiStatusCodeToTag SC_Forbidden          = 13
abiStatusCodeToTag SC_NotFound           = 14
abiStatusCodeToTag SC_MethodNotAllowed   = 15
abiStatusCodeToTag SC_RequestTimeout     = 16
abiStatusCodeToTag SC_Conflict           = 17
abiStatusCodeToTag SC_Gone               = 18
abiStatusCodeToTag SC_LengthRequired     = 19
abiStatusCodeToTag SC_PayloadTooLarge    = 20
abiStatusCodeToTag SC_URITooLong         = 21
abiStatusCodeToTag SC_UnsupportedMedia   = 22
abiStatusCodeToTag SC_TooManyRequests    = 23
abiStatusCodeToTag SC_InternalError      = 24
abiStatusCodeToTag SC_NotImplemented     = 25
abiStatusCodeToTag SC_BadGateway         = 26
abiStatusCodeToTag SC_ServiceUnavailable = 27
abiStatusCodeToTag SC_GatewayTimeout     = 28

public export
tagToAbiStatusCode : Bits8 -> Maybe AbiStatusCode
tagToAbiStatusCode 0  = Just SC_Continue
tagToAbiStatusCode 1  = Just SC_SwitchingProtocols
tagToAbiStatusCode 2  = Just SC_OK
tagToAbiStatusCode 3  = Just SC_Created
tagToAbiStatusCode 4  = Just SC_Accepted
tagToAbiStatusCode 5  = Just SC_NoContent
tagToAbiStatusCode 6  = Just SC_MovedPermanently
tagToAbiStatusCode 7  = Just SC_Found
tagToAbiStatusCode 8  = Just SC_NotModified
tagToAbiStatusCode 9  = Just SC_TemporaryRedirect
tagToAbiStatusCode 10 = Just SC_PermanentRedirect
tagToAbiStatusCode 11 = Just SC_BadRequest
tagToAbiStatusCode 12 = Just SC_Unauthorized
tagToAbiStatusCode 13 = Just SC_Forbidden
tagToAbiStatusCode 14 = Just SC_NotFound
tagToAbiStatusCode 15 = Just SC_MethodNotAllowed
tagToAbiStatusCode 16 = Just SC_RequestTimeout
tagToAbiStatusCode 17 = Just SC_Conflict
tagToAbiStatusCode 18 = Just SC_Gone
tagToAbiStatusCode 19 = Just SC_LengthRequired
tagToAbiStatusCode 20 = Just SC_PayloadTooLarge
tagToAbiStatusCode 21 = Just SC_URITooLong
tagToAbiStatusCode 22 = Just SC_UnsupportedMedia
tagToAbiStatusCode 23 = Just SC_TooManyRequests
tagToAbiStatusCode 24 = Just SC_InternalError
tagToAbiStatusCode 25 = Just SC_NotImplemented
tagToAbiStatusCode 26 = Just SC_BadGateway
tagToAbiStatusCode 27 = Just SC_ServiceUnavailable
tagToAbiStatusCode 28 = Just SC_GatewayTimeout
tagToAbiStatusCode _  = Nothing

public export
abiStatusCodeRoundtrip : (s : AbiStatusCode) -> tagToAbiStatusCode (abiStatusCodeToTag s) = Just s
abiStatusCodeRoundtrip SC_Continue           = Refl
abiStatusCodeRoundtrip SC_SwitchingProtocols = Refl
abiStatusCodeRoundtrip SC_OK                 = Refl
abiStatusCodeRoundtrip SC_Created            = Refl
abiStatusCodeRoundtrip SC_Accepted           = Refl
abiStatusCodeRoundtrip SC_NoContent          = Refl
abiStatusCodeRoundtrip SC_MovedPermanently   = Refl
abiStatusCodeRoundtrip SC_Found              = Refl
abiStatusCodeRoundtrip SC_NotModified        = Refl
abiStatusCodeRoundtrip SC_TemporaryRedirect  = Refl
abiStatusCodeRoundtrip SC_PermanentRedirect  = Refl
abiStatusCodeRoundtrip SC_BadRequest         = Refl
abiStatusCodeRoundtrip SC_Unauthorized       = Refl
abiStatusCodeRoundtrip SC_Forbidden          = Refl
abiStatusCodeRoundtrip SC_NotFound           = Refl
abiStatusCodeRoundtrip SC_MethodNotAllowed   = Refl
abiStatusCodeRoundtrip SC_RequestTimeout     = Refl
abiStatusCodeRoundtrip SC_Conflict           = Refl
abiStatusCodeRoundtrip SC_Gone               = Refl
abiStatusCodeRoundtrip SC_LengthRequired     = Refl
abiStatusCodeRoundtrip SC_PayloadTooLarge    = Refl
abiStatusCodeRoundtrip SC_URITooLong         = Refl
abiStatusCodeRoundtrip SC_UnsupportedMedia   = Refl
abiStatusCodeRoundtrip SC_TooManyRequests    = Refl
abiStatusCodeRoundtrip SC_InternalError      = Refl
abiStatusCodeRoundtrip SC_NotImplemented     = Refl
abiStatusCodeRoundtrip SC_BadGateway         = Refl
abiStatusCodeRoundtrip SC_ServiceUnavailable = Refl
abiStatusCodeRoundtrip SC_GatewayTimeout     = Refl

---------------------------------------------------------------------------
-- ContentType (8 constructors, tags 0-7)
---------------------------------------------------------------------------

||| Common HTTP content types for ABI.
public export
data ContentType : Type where
  TextPlain       : ContentType
  TextHtml        : ContentType
  ApplicationJson : ContentType
  ApplicationXml  : ContentType
  ApplicationForm : ContentType
  MultipartForm   : ContentType
  OctetStream     : ContentType
  TextCss         : ContentType

public export
contentTypeSize : Nat
contentTypeSize = 1

public export
contentTypeToTag : ContentType -> Bits8
contentTypeToTag TextPlain       = 0
contentTypeToTag TextHtml        = 1
contentTypeToTag ApplicationJson = 2
contentTypeToTag ApplicationXml  = 3
contentTypeToTag ApplicationForm = 4
contentTypeToTag MultipartForm   = 5
contentTypeToTag OctetStream     = 6
contentTypeToTag TextCss         = 7

public export
tagToContentType : Bits8 -> Maybe ContentType
tagToContentType 0 = Just TextPlain
tagToContentType 1 = Just TextHtml
tagToContentType 2 = Just ApplicationJson
tagToContentType 3 = Just ApplicationXml
tagToContentType 4 = Just ApplicationForm
tagToContentType 5 = Just MultipartForm
tagToContentType 6 = Just OctetStream
tagToContentType 7 = Just TextCss
tagToContentType _ = Nothing

public export
contentTypeRoundtrip : (ct : ContentType) -> tagToContentType (contentTypeToTag ct) = Just ct
contentTypeRoundtrip TextPlain       = Refl
contentTypeRoundtrip TextHtml        = Refl
contentTypeRoundtrip ApplicationJson = Refl
contentTypeRoundtrip ApplicationXml  = Refl
contentTypeRoundtrip ApplicationForm = Refl
contentTypeRoundtrip MultipartForm   = Refl
contentTypeRoundtrip OctetStream     = Refl
contentTypeRoundtrip TextCss         = Refl

---------------------------------------------------------------------------
-- HeaderType (10 constructors, tags 0-9)
---------------------------------------------------------------------------

||| Common HTTP header names as a closed enumeration for ABI.
public export
data HeaderType : Type where
  HdrContentType   : HeaderType
  HdrContentLength : HeaderType
  HdrHost          : HeaderType
  HdrConnection    : HeaderType
  HdrAccept        : HeaderType
  HdrUserAgent     : HeaderType
  HdrServer        : HeaderType
  HdrLocation      : HeaderType
  HdrCacheControl  : HeaderType
  HdrCustom        : HeaderType

public export
headerTypeSize : Nat
headerTypeSize = 1

public export
headerTypeToTag : HeaderType -> Bits8
headerTypeToTag HdrContentType   = 0
headerTypeToTag HdrContentLength = 1
headerTypeToTag HdrHost          = 2
headerTypeToTag HdrConnection    = 3
headerTypeToTag HdrAccept        = 4
headerTypeToTag HdrUserAgent     = 5
headerTypeToTag HdrServer        = 6
headerTypeToTag HdrLocation      = 7
headerTypeToTag HdrCacheControl  = 8
headerTypeToTag HdrCustom        = 9

public export
tagToHeaderType : Bits8 -> Maybe HeaderType
tagToHeaderType 0 = Just HdrContentType
tagToHeaderType 1 = Just HdrContentLength
tagToHeaderType 2 = Just HdrHost
tagToHeaderType 3 = Just HdrConnection
tagToHeaderType 4 = Just HdrAccept
tagToHeaderType 5 = Just HdrUserAgent
tagToHeaderType 6 = Just HdrServer
tagToHeaderType 7 = Just HdrLocation
tagToHeaderType 8 = Just HdrCacheControl
tagToHeaderType 9 = Just HdrCustom
tagToHeaderType _ = Nothing

public export
headerTypeRoundtrip : (h : HeaderType) -> tagToHeaderType (headerTypeToTag h) = Just h
headerTypeRoundtrip HdrContentType   = Refl
headerTypeRoundtrip HdrContentLength = Refl
headerTypeRoundtrip HdrHost          = Refl
headerTypeRoundtrip HdrConnection    = Refl
headerTypeRoundtrip HdrAccept        = Refl
headerTypeRoundtrip HdrUserAgent     = Refl
headerTypeRoundtrip HdrServer        = Refl
headerTypeRoundtrip HdrLocation      = Refl
headerTypeRoundtrip HdrCacheControl  = Refl
headerTypeRoundtrip HdrCustom        = Refl

---------------------------------------------------------------------------
-- RequestPhase (7 constructors, tags 0-6) — used by Transitions
---------------------------------------------------------------------------

||| Phases of the HTTP request lifecycle.
||| Used as indices for the state machine in Transitions.idr.
public export
data RequestPhase : Type where
  Idle          : RequestPhase
  Receiving     : RequestPhase
  HeadersParsed : RequestPhase
  BodyReceiving : RequestPhase
  Complete      : RequestPhase
  Responding    : RequestPhase
  Sent          : RequestPhase

public export
requestPhaseSize : Nat
requestPhaseSize = 1

public export
requestPhaseToTag : RequestPhase -> Bits8
requestPhaseToTag Idle          = 0
requestPhaseToTag Receiving     = 1
requestPhaseToTag HeadersParsed = 2
requestPhaseToTag BodyReceiving = 3
requestPhaseToTag Complete      = 4
requestPhaseToTag Responding    = 5
requestPhaseToTag Sent          = 6

public export
tagToRequestPhase : Bits8 -> Maybe RequestPhase
tagToRequestPhase 0 = Just Idle
tagToRequestPhase 1 = Just Receiving
tagToRequestPhase 2 = Just HeadersParsed
tagToRequestPhase 3 = Just BodyReceiving
tagToRequestPhase 4 = Just Complete
tagToRequestPhase 5 = Just Responding
tagToRequestPhase 6 = Just Sent
tagToRequestPhase _ = Nothing

public export
requestPhaseRoundtrip : (p : RequestPhase) -> tagToRequestPhase (requestPhaseToTag p) = Just p
requestPhaseRoundtrip Idle          = Refl
requestPhaseRoundtrip Receiving     = Refl
requestPhaseRoundtrip HeadersParsed = Refl
requestPhaseRoundtrip BodyReceiving = Refl
requestPhaseRoundtrip Complete      = Refl
requestPhaseRoundtrip Responding    = Refl
requestPhaseRoundtrip Sent          = Refl
