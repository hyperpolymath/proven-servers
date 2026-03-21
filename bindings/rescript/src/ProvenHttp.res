// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// HTTP protocol types for the proven-servers ABI.
//
// Mirrors the Idris2 modules:
// - HTTP.Method          -- request methods (RFC 7231)
// - HTTP.Status          -- status codes and categories (RFC 7231)
// - HTTPABI.Layout       -- C-ABI tag values for methods, versions, content types
// - HTTPABI.Transitions  -- request lifecycle state machine
//
// All tag values match the *ToTag functions in HTTPABI.Layout exactly.

// ===========================================================================
// HTTP Method (HTTPABI.Layout.HttpMethod, tags 0-8)
// ===========================================================================

/// Standard HTTP request methods (RFC 7231 Section 4, RFC 5789).
/// Tag values match httpMethodToTag in HTTPABI.Layout.
type method =
  | @as(0) Get
  | @as(1) Post
  | @as(2) Put
  | @as(3) Delete
  | @as(4) Patch
  | @as(5) Head
  | @as(6) Options
  | @as(7) Trace
  | @as(8) Connect

/// All standard HTTP methods in tag order.
let allMethods: array<method> = [Get, Post, Put, Delete, Patch, Head, Options, Trace, Connect]

/// Parse a method string (case-sensitive) to a Method.
/// Matches parseMethod in HTTP.Method.
let methodParse = (s: string): option<method> =>
  switch s {
  | "GET" => Some(Get)
  | "POST" => Some(Post)
  | "PUT" => Some(Put)
  | "DELETE" => Some(Delete)
  | "PATCH" => Some(Patch)
  | "HEAD" => Some(Head)
  | "OPTIONS" => Some(Options)
  | "TRACE" => Some(Trace)
  | "CONNECT" => Some(Connect)
  | _ => None
  }

/// Decode from the C-ABI tag value.
/// Matches tagToHttpMethod in HTTPABI.Layout.
let methodFromTag = (tag: int): option<method> =>
  switch tag {
  | 0 => Some(Get)
  | 1 => Some(Post)
  | 2 => Some(Put)
  | 3 => Some(Delete)
  | 4 => Some(Patch)
  | 5 => Some(Head)
  | 6 => Some(Options)
  | 7 => Some(Trace)
  | 8 => Some(Connect)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let methodToTag = (m: method): int =>
  switch m {
  | Get => 0
  | Post => 1
  | Put => 2
  | Delete => 3
  | Patch => 4
  | Head => 5
  | Options => 6
  | Trace => 7
  | Connect => 8
  }

/// Canonical string representation (e.g. "GET").
let methodAsStr = (m: method): string =>
  switch m {
  | Get => "GET"
  | Post => "POST"
  | Put => "PUT"
  | Delete => "DELETE"
  | Patch => "PATCH"
  | Head => "HEAD"
  | Options => "OPTIONS"
  | Trace => "TRACE"
  | Connect => "CONNECT"
  }

/// Whether the method is "safe" (RFC 7231 Section 4.2.1).
/// Matches isSafe in HTTP.Method.
let methodIsSafe = (m: method): bool =>
  switch m {
  | Get | Head | Options | Trace => true
  | Post | Put | Delete | Patch | Connect => false
  }

/// Whether the method is idempotent (RFC 7231 Section 4.2.2).
/// Matches isIdempotent in HTTP.Method.
let methodIsIdempotent = (m: method): bool =>
  switch m {
  | Get | Head | Put | Delete | Options | Trace => true
  | Post | Patch | Connect => false
  }

/// Whether the method typically carries a request body.
/// Matches hasRequestBody in HTTP.Method.
let methodHasRequestBody = (m: method): bool =>
  switch m {
  | Post | Put | Patch => true
  | Get | Delete | Head | Options | Trace | Connect => false
  }

// ===========================================================================
// HTTP Version (HTTPABI.Layout.HttpVersion, tags 0-3)
// ===========================================================================

/// HTTP protocol versions.
/// Tag values match httpVersionToTag in HTTPABI.Layout.
type version =
  | @as(0) Http10
  | @as(1) Http11
  | @as(2) Http20
  | @as(3) Http30

/// Decode from the C-ABI tag value.
let versionFromTag = (tag: int): option<version> =>
  switch tag {
  | 0 => Some(Http10)
  | 1 => Some(Http11)
  | 2 => Some(Http20)
  | 3 => Some(Http30)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let versionToTag = (v: version): int =>
  switch v {
  | Http10 => 0
  | Http11 => 1
  | Http20 => 2
  | Http30 => 3
  }

/// Human-readable version string.
let versionAsStr = (v: version): string =>
  switch v {
  | Http10 => "HTTP/1.0"
  | Http11 => "HTTP/1.1"
  | Http20 => "HTTP/2"
  | Http30 => "HTTP/3"
  }

// ===========================================================================
// Status Category (HTTPABI.Layout.StatusCat, tags 0-4)
// ===========================================================================

/// HTTP response status code categories (RFC 7231 Section 6).
/// Tag values match statusCatToTag in HTTPABI.Layout.
type statusCategory =
  | @as(0) Informational
  | @as(1) Success
  | @as(2) Redirect
  | @as(3) ClientError
  | @as(4) ServerError

/// Decode from the C-ABI tag value.
let statusCategoryFromTag = (tag: int): option<statusCategory> =>
  switch tag {
  | 0 => Some(Informational)
  | 1 => Some(Success)
  | 2 => Some(Redirect)
  | 3 => Some(ClientError)
  | 4 => Some(ServerError)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let statusCategoryToTag = (c: statusCategory): int =>
  switch c {
  | Informational => 0
  | Success => 1
  | Redirect => 2
  | ClientError => 3
  | ServerError => 4
  }

// ===========================================================================
// Status Code (HTTPABI.Layout.AbiStatusCode, tags 0-28)
// ===========================================================================

/// Common HTTP status codes (RFC 7231 and related RFCs).
/// Tag values match abiStatusCodeToTag in HTTPABI.Layout.
type statusCode =
  // 1xx Informational
  | @as(0) Continue
  | @as(1) SwitchingProtocols
  // 2xx Success
  | @as(2) StatusOk
  | @as(3) Created
  | @as(4) Accepted
  | @as(5) NoContent
  // 3xx Redirection
  | @as(6) MovedPermanently
  | @as(7) Found
  | @as(8) NotModified
  | @as(9) TemporaryRedirect
  | @as(10) PermanentRedirect
  // 4xx Client Error
  | @as(11) BadRequest
  | @as(12) Unauthorized
  | @as(13) Forbidden
  | @as(14) NotFound
  | @as(15) MethodNotAllowed
  | @as(16) RequestTimeout
  | @as(17) Conflict
  | @as(18) Gone
  | @as(19) LengthRequired
  | @as(20) PayloadTooLarge
  | @as(21) UriTooLong
  | @as(22) UnsupportedMedia
  | @as(23) TooManyRequests
  // 5xx Server Error
  | @as(24) InternalError
  | @as(25) NotImplemented
  | @as(26) BadGateway
  | @as(27) ServiceUnavailable
  | @as(28) GatewayTimeout

/// Decode from the C-ABI tag value.
let statusCodeFromTag = (tag: int): option<statusCode> =>
  switch tag {
  | 0 => Some(Continue)
  | 1 => Some(SwitchingProtocols)
  | 2 => Some(StatusOk)
  | 3 => Some(Created)
  | 4 => Some(Accepted)
  | 5 => Some(NoContent)
  | 6 => Some(MovedPermanently)
  | 7 => Some(Found)
  | 8 => Some(NotModified)
  | 9 => Some(TemporaryRedirect)
  | 10 => Some(PermanentRedirect)
  | 11 => Some(BadRequest)
  | 12 => Some(Unauthorized)
  | 13 => Some(Forbidden)
  | 14 => Some(NotFound)
  | 15 => Some(MethodNotAllowed)
  | 16 => Some(RequestTimeout)
  | 17 => Some(Conflict)
  | 18 => Some(Gone)
  | 19 => Some(LengthRequired)
  | 20 => Some(PayloadTooLarge)
  | 21 => Some(UriTooLong)
  | 22 => Some(UnsupportedMedia)
  | 23 => Some(TooManyRequests)
  | 24 => Some(InternalError)
  | 25 => Some(NotImplemented)
  | 26 => Some(BadGateway)
  | 27 => Some(ServiceUnavailable)
  | 28 => Some(GatewayTimeout)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let statusCodeToTag = (s: statusCode): int =>
  switch s {
  | Continue => 0
  | SwitchingProtocols => 1
  | StatusOk => 2
  | Created => 3
  | Accepted => 4
  | NoContent => 5
  | MovedPermanently => 6
  | Found => 7
  | NotModified => 8
  | TemporaryRedirect => 9
  | PermanentRedirect => 10
  | BadRequest => 11
  | Unauthorized => 12
  | Forbidden => 13
  | NotFound => 14
  | MethodNotAllowed => 15
  | RequestTimeout => 16
  | Conflict => 17
  | Gone => 18
  | LengthRequired => 19
  | PayloadTooLarge => 20
  | UriTooLong => 21
  | UnsupportedMedia => 22
  | TooManyRequests => 23
  | InternalError => 24
  | NotImplemented => 25
  | BadGateway => 26
  | ServiceUnavailable => 27
  | GatewayTimeout => 28
  }

/// The numeric HTTP status code (e.g. 200, 404).
/// Matches statusToCode in HTTP.Status.
let statusNumericCode = (s: statusCode): int =>
  switch s {
  | Continue => 100
  | SwitchingProtocols => 101
  | StatusOk => 200
  | Created => 201
  | Accepted => 202
  | NoContent => 204
  | MovedPermanently => 301
  | Found => 302
  | NotModified => 304
  | TemporaryRedirect => 307
  | PermanentRedirect => 308
  | BadRequest => 400
  | Unauthorized => 401
  | Forbidden => 403
  | NotFound => 404
  | MethodNotAllowed => 405
  | RequestTimeout => 408
  | Conflict => 409
  | Gone => 410
  | LengthRequired => 411
  | PayloadTooLarge => 413
  | UriTooLong => 414
  | UnsupportedMedia => 415
  | TooManyRequests => 429
  | InternalError => 500
  | NotImplemented => 501
  | BadGateway => 502
  | ServiceUnavailable => 503
  | GatewayTimeout => 504
  }

/// Parse from a numeric HTTP status code.
/// Matches fromCode in HTTP.Status.
let statusFromNumeric = (code: int): option<statusCode> =>
  switch code {
  | 100 => Some(Continue)
  | 101 => Some(SwitchingProtocols)
  | 200 => Some(StatusOk)
  | 201 => Some(Created)
  | 202 => Some(Accepted)
  | 204 => Some(NoContent)
  | 301 => Some(MovedPermanently)
  | 302 => Some(Found)
  | 304 => Some(NotModified)
  | 307 => Some(TemporaryRedirect)
  | 308 => Some(PermanentRedirect)
  | 400 => Some(BadRequest)
  | 401 => Some(Unauthorized)
  | 403 => Some(Forbidden)
  | 404 => Some(NotFound)
  | 405 => Some(MethodNotAllowed)
  | 408 => Some(RequestTimeout)
  | 409 => Some(Conflict)
  | 410 => Some(Gone)
  | 411 => Some(LengthRequired)
  | 413 => Some(PayloadTooLarge)
  | 414 => Some(UriTooLong)
  | 415 => Some(UnsupportedMedia)
  | 429 => Some(TooManyRequests)
  | 500 => Some(InternalError)
  | 501 => Some(NotImplemented)
  | 502 => Some(BadGateway)
  | 503 => Some(ServiceUnavailable)
  | 504 => Some(GatewayTimeout)
  | _ => None
  }

/// Standard reason phrase (RFC 7231).
/// Matches reasonPhrase in HTTP.Status.
let statusReasonPhrase = (s: statusCode): string =>
  switch s {
  | Continue => "Continue"
  | SwitchingProtocols => "Switching Protocols"
  | StatusOk => "OK"
  | Created => "Created"
  | Accepted => "Accepted"
  | NoContent => "No Content"
  | MovedPermanently => "Moved Permanently"
  | Found => "Found"
  | NotModified => "Not Modified"
  | TemporaryRedirect => "Temporary Redirect"
  | PermanentRedirect => "Permanent Redirect"
  | BadRequest => "Bad Request"
  | Unauthorized => "Unauthorized"
  | Forbidden => "Forbidden"
  | NotFound => "Not Found"
  | MethodNotAllowed => "Method Not Allowed"
  | RequestTimeout => "Request Timeout"
  | Conflict => "Conflict"
  | Gone => "Gone"
  | LengthRequired => "Length Required"
  | PayloadTooLarge => "Payload Too Large"
  | UriTooLong => "URI Too Long"
  | UnsupportedMedia => "Unsupported Media Type"
  | TooManyRequests => "Too Many Requests"
  | InternalError => "Internal Server Error"
  | NotImplemented => "Not Implemented"
  | BadGateway => "Bad Gateway"
  | ServiceUnavailable => "Service Unavailable"
  | GatewayTimeout => "Gateway Timeout"
  }

/// Categorise this status code.
/// Matches categorise in HTTP.Status.
let statusCategory = (s: statusCode): statusCategory => {
  let tag = statusCodeToTag(s)
  if tag <= 1 {
    Informational
  } else if tag <= 5 {
    Success
  } else if tag <= 10 {
    Redirect
  } else if tag <= 23 {
    ClientError
  } else {
    ServerError
  }
}

/// Whether this is a success code (2xx).
let statusIsSuccess = (s: statusCode): bool => statusCategory(s) == Success

/// Whether this is an error code (4xx or 5xx).
let statusIsError = (s: statusCode): bool =>
  switch statusCategory(s) {
  | ClientError | ServerError => true
  | Informational | Success | Redirect => false
  }

/// Whether this is a redirect code (3xx).
let statusIsRedirect = (s: statusCode): bool => statusCategory(s) == Redirect

// ===========================================================================
// Content Type (HTTPABI.Layout.ContentType, tags 0-7)
// ===========================================================================

/// Common HTTP content types for ABI interchange.
/// Tag values match contentTypeToTag in HTTPABI.Layout.
type contentType =
  | @as(0) TextPlain
  | @as(1) TextHtml
  | @as(2) ApplicationJson
  | @as(3) ApplicationXml
  | @as(4) ApplicationForm
  | @as(5) MultipartForm
  | @as(6) OctetStream
  | @as(7) TextCss

/// Decode from the C-ABI tag value.
let contentTypeFromTag = (tag: int): option<contentType> =>
  switch tag {
  | 0 => Some(TextPlain)
  | 1 => Some(TextHtml)
  | 2 => Some(ApplicationJson)
  | 3 => Some(ApplicationXml)
  | 4 => Some(ApplicationForm)
  | 5 => Some(MultipartForm)
  | 6 => Some(OctetStream)
  | 7 => Some(TextCss)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let contentTypeToTag = (ct: contentType): int =>
  switch ct {
  | TextPlain => 0
  | TextHtml => 1
  | ApplicationJson => 2
  | ApplicationXml => 3
  | ApplicationForm => 4
  | MultipartForm => 5
  | OctetStream => 6
  | TextCss => 7
  }

/// MIME type string.
let contentTypeMime = (ct: contentType): string =>
  switch ct {
  | TextPlain => "text/plain"
  | TextHtml => "text/html"
  | ApplicationJson => "application/json"
  | ApplicationXml => "application/xml"
  | ApplicationForm => "application/x-www-form-urlencoded"
  | MultipartForm => "multipart/form-data"
  | OctetStream => "application/octet-stream"
  | TextCss => "text/css"
  }

// ===========================================================================
// Header Type (HTTPABI.Layout.HeaderType, tags 0-9)
// ===========================================================================

/// Common HTTP header names as an enumeration for ABI interchange.
/// Tag values match headerTypeToTag in HTTPABI.Layout.
type headerType =
  | @as(0) HeaderContentType
  | @as(1) HeaderContentLength
  | @as(2) HeaderHost
  | @as(3) HeaderConnection
  | @as(4) HeaderAccept
  | @as(5) HeaderUserAgent
  | @as(6) HeaderServer
  | @as(7) HeaderLocation
  | @as(8) HeaderCacheControl
  | @as(9) HeaderCustom

/// Decode from the C-ABI tag value.
let headerTypeFromTag = (tag: int): option<headerType> =>
  switch tag {
  | 0 => Some(HeaderContentType)
  | 1 => Some(HeaderContentLength)
  | 2 => Some(HeaderHost)
  | 3 => Some(HeaderConnection)
  | 4 => Some(HeaderAccept)
  | 5 => Some(HeaderUserAgent)
  | 6 => Some(HeaderServer)
  | 7 => Some(HeaderLocation)
  | 8 => Some(HeaderCacheControl)
  | 9 => Some(HeaderCustom)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let headerTypeToTag = (ht: headerType): int =>
  switch ht {
  | HeaderContentType => 0
  | HeaderContentLength => 1
  | HeaderHost => 2
  | HeaderConnection => 3
  | HeaderAccept => 4
  | HeaderUserAgent => 5
  | HeaderServer => 6
  | HeaderLocation => 7
  | HeaderCacheControl => 8
  | HeaderCustom => 9
  }

/// Canonical header name string.
let headerTypeName = (ht: headerType): string =>
  switch ht {
  | HeaderContentType => "Content-Type"
  | HeaderContentLength => "Content-Length"
  | HeaderHost => "Host"
  | HeaderConnection => "Connection"
  | HeaderAccept => "Accept"
  | HeaderUserAgent => "User-Agent"
  | HeaderServer => "Server"
  | HeaderLocation => "Location"
  | HeaderCacheControl => "Cache-Control"
  | HeaderCustom => "X-Custom"
  }

// ===========================================================================
// Request Phase / Lifecycle (HTTPABI.Layout.RequestPhase, tags 0-6)
// ===========================================================================

/// Phases of the HTTP request processing lifecycle.
/// Models the state machine from HTTPABI.Transitions:
///   Idle -> Receiving -> HeadersParsed -> BodyReceiving -> Complete
///        -> Responding -> Sent [-> Idle (keep-alive)]
/// Tag values match requestPhaseToTag in HTTPABI.Layout.
type requestPhase =
  | @as(0) Idle
  | @as(1) Receiving
  | @as(2) HeadersParsed
  | @as(3) BodyReceiving
  | @as(4) Complete
  | @as(5) Responding
  | @as(6) Sent

/// Decode from the C-ABI tag value.
let requestPhaseFromTag = (tag: int): option<requestPhase> =>
  switch tag {
  | 0 => Some(Idle)
  | 1 => Some(Receiving)
  | 2 => Some(HeadersParsed)
  | 3 => Some(BodyReceiving)
  | 4 => Some(Complete)
  | 5 => Some(Responding)
  | 6 => Some(Sent)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let requestPhaseToTag = (p: requestPhase): int =>
  switch p {
  | Idle => 0
  | Receiving => 1
  | HeadersParsed => 2
  | BodyReceiving => 3
  | Complete => 4
  | Responding => 5
  | Sent => 6
  }

/// Named HTTP request lifecycle transition.
/// Each variant corresponds to a constructor of ValidHttpTransition
/// in HTTPABI.Transitions.
type httpTransition =
  | StartReceiving
  | ParseHeaders
  | StartBody
  | NoBodyComplete
  | BodyDone
  | BeginResponse
  | FinishSend
  | KeepAliveRecycle
  | AbortReceiving
  | AbortHeadersParsed
  | AbortBodyReceiving
  | AbortComplete

/// The source phase of this transition.
let transitionFromPhase = (t: httpTransition): requestPhase =>
  switch t {
  | StartReceiving => Idle
  | ParseHeaders | AbortReceiving => Receiving
  | StartBody | NoBodyComplete | AbortHeadersParsed => HeadersParsed
  | BodyDone | AbortBodyReceiving => BodyReceiving
  | BeginResponse | AbortComplete => Complete
  | FinishSend => Responding
  | KeepAliveRecycle => Sent
  }

/// The target phase of this transition.
let transitionToPhase = (t: httpTransition): requestPhase =>
  switch t {
  | StartReceiving => Receiving
  | ParseHeaders => HeadersParsed
  | StartBody => BodyReceiving
  | NoBodyComplete | BodyDone => Complete
  | BeginResponse => Responding
  | FinishSend | AbortReceiving | AbortHeadersParsed | AbortBodyReceiving | AbortComplete => Sent
  | KeepAliveRecycle => Idle
  }

/// Validate whether a transition between two request phases is legal.
/// Mirrors validateHttpTransition in HTTPABI.Transitions.
/// Returns Some(transition) for valid transitions, None for invalid.
let validateHttpTransition = (from: requestPhase, to: requestPhase): option<httpTransition> =>
  switch (from, to) {
  | (Idle, Receiving) => Some(StartReceiving)
  | (Receiving, HeadersParsed) => Some(ParseHeaders)
  | (HeadersParsed, BodyReceiving) => Some(StartBody)
  | (HeadersParsed, Complete) => Some(NoBodyComplete)
  | (BodyReceiving, Complete) => Some(BodyDone)
  | (Complete, Responding) => Some(BeginResponse)
  | (Responding, Sent) => Some(FinishSend)
  | (Sent, Idle) => Some(KeepAliveRecycle)
  | (Receiving, Sent) => Some(AbortReceiving)
  | (HeadersParsed, Sent) => Some(AbortHeadersParsed)
  | (BodyReceiving, Sent) => Some(AbortBodyReceiving)
  | (Complete, Sent) => Some(AbortComplete)
  | _ => None
  }
