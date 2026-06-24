//// SPDX-License-Identifier: MPL-2.0
//// (MPL-2.0 preferred; MPL-2.0 required for Gleam ecosystem)
//// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
////
//// HTTP protocol types for the proven-servers ABI.
////
//// Mirrors the Idris2 modules:
//// - `HTTP.Method`          -- request methods (RFC 7231)
//// - `HTTP.Status`          -- status codes and categories (RFC 7231)
//// - `HTTPABI.Layout`       -- C-ABI tag values
//// - `HTTPABI.Transitions`  -- request lifecycle state machine

// ===========================================================================
// HTTP Method (HTTPABI.Layout.HttpMethod, tags 0-8)
// ===========================================================================

/// Standard HTTP request methods (RFC 7231 Section 4, RFC 5789).
///
/// Tag values match `httpMethodToTag` in `HTTPABI.Layout`.
pub type Method {
  Get
  Post
  Put
  Delete
  Patch
  Head
  Options
  Trace
  Connect
}

/// Convert a `Method` to its C-ABI tag value.
pub fn method_to_int(method: Method) -> Int {
  case method {
    Get -> 0
    Post -> 1
    Put -> 2
    Delete -> 3
    Patch -> 4
    Head -> 5
    Options -> 6
    Trace -> 7
    Connect -> 8
  }
}

/// Decode from a C-ABI tag value.
pub fn method_from_int(tag: Int) -> Result(Method, Nil) {
  case tag {
    0 -> Ok(Get)
    1 -> Ok(Post)
    2 -> Ok(Put)
    3 -> Ok(Delete)
    4 -> Ok(Patch)
    5 -> Ok(Head)
    6 -> Ok(Options)
    7 -> Ok(Trace)
    8 -> Ok(Connect)
    _ -> Error(Nil)
  }
}

/// Parse a method string (case-sensitive) to a `Method`.
pub fn method_parse(s: String) -> Result(Method, Nil) {
  case s {
    "GET" -> Ok(Get)
    "POST" -> Ok(Post)
    "PUT" -> Ok(Put)
    "DELETE" -> Ok(Delete)
    "PATCH" -> Ok(Patch)
    "HEAD" -> Ok(Head)
    "OPTIONS" -> Ok(Options)
    "TRACE" -> Ok(Trace)
    "CONNECT" -> Ok(Connect)
    _ -> Error(Nil)
  }
}

/// Canonical string representation (e.g. "GET").
pub fn method_to_string(method: Method) -> String {
  case method {
    Get -> "GET"
    Post -> "POST"
    Put -> "PUT"
    Delete -> "DELETE"
    Patch -> "PATCH"
    Head -> "HEAD"
    Options -> "OPTIONS"
    Trace -> "TRACE"
    Connect -> "CONNECT"
  }
}

/// Whether the method is "safe" (RFC 7231 Section 4.2.1).
///
/// Safe methods are read-only and should not cause side effects.
pub fn method_is_safe(method: Method) -> Bool {
  case method {
    Get | Head | Options | Trace -> True
    _ -> False
  }
}

/// Whether the method is idempotent (RFC 7231 Section 4.2.2).
pub fn method_is_idempotent(method: Method) -> Bool {
  case method {
    Get | Head | Put | Delete | Options | Trace -> True
    _ -> False
  }
}

/// Whether the method typically carries a request body.
pub fn method_has_request_body(method: Method) -> Bool {
  case method {
    Post | Put | Patch -> True
    _ -> False
  }
}

// ===========================================================================
// HTTP Version (HTTPABI.Layout.HttpVersion, tags 0-3)
// ===========================================================================

/// HTTP protocol versions.
pub type Version {
  Http10
  Http11
  Http20
  Http30
}

/// Convert a `Version` to its C-ABI tag value.
pub fn version_to_int(version: Version) -> Int {
  case version {
    Http10 -> 0
    Http11 -> 1
    Http20 -> 2
    Http30 -> 3
  }
}

/// Decode from a C-ABI tag value.
pub fn version_from_int(tag: Int) -> Result(Version, Nil) {
  case tag {
    0 -> Ok(Http10)
    1 -> Ok(Http11)
    2 -> Ok(Http20)
    3 -> Ok(Http30)
    _ -> Error(Nil)
  }
}

/// Human-readable version string.
pub fn version_to_string(version: Version) -> String {
  case version {
    Http10 -> "HTTP/1.0"
    Http11 -> "HTTP/1.1"
    Http20 -> "HTTP/2"
    Http30 -> "HTTP/3"
  }
}

// ===========================================================================
// Status Category (HTTPABI.Layout.StatusCat, tags 0-4)
// ===========================================================================

/// HTTP response status code categories (RFC 7231 Section 6).
pub type StatusCategory {
  /// 1xx: request received, continuing process.
  Informational
  /// 2xx: request successfully received, understood, and accepted.
  Success
  /// 3xx: further action needed to complete the request.
  Redirect
  /// 4xx: request contains bad syntax or cannot be fulfilled.
  ClientError
  /// 5xx: server failed to fulfil an apparently valid request.
  ServerError
}

/// Convert a `StatusCategory` to its C-ABI tag value.
pub fn status_category_to_int(cat: StatusCategory) -> Int {
  case cat {
    Informational -> 0
    Success -> 1
    Redirect -> 2
    ClientError -> 3
    ServerError -> 4
  }
}

/// Decode from a C-ABI tag value.
pub fn status_category_from_int(tag: Int) -> Result(StatusCategory, Nil) {
  case tag {
    0 -> Ok(Informational)
    1 -> Ok(Success)
    2 -> Ok(Redirect)
    3 -> Ok(ClientError)
    4 -> Ok(ServerError)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// Status Code (HTTPABI.Layout.AbiStatusCode, tags 0-28)
// ===========================================================================

/// Common HTTP status codes (RFC 7231 and related RFCs).
///
/// Tag values match `abiStatusCodeToTag` in `HTTPABI.Layout`.
pub type StatusCode {
  // 1xx Informational
  Continue
  SwitchingProtocols
  // 2xx Success
  StatusOk
  Created
  Accepted
  NoContent
  // 3xx Redirection
  MovedPermanently
  Found
  NotModified
  TemporaryRedirect
  PermanentRedirect
  // 4xx Client Error
  BadRequest
  Unauthorized
  Forbidden
  NotFound
  MethodNotAllowed
  RequestTimeout
  Conflict
  Gone
  LengthRequired
  PayloadTooLarge
  UriTooLong
  UnsupportedMedia
  TooManyRequests
  // 5xx Server Error
  InternalError
  NotImplemented
  BadGateway
  ServiceUnavailable
  GatewayTimeout
}

/// Convert a `StatusCode` to its C-ABI tag value.
pub fn status_to_int(code: StatusCode) -> Int {
  case code {
    Continue -> 0
    SwitchingProtocols -> 1
    StatusOk -> 2
    Created -> 3
    Accepted -> 4
    NoContent -> 5
    MovedPermanently -> 6
    Found -> 7
    NotModified -> 8
    TemporaryRedirect -> 9
    PermanentRedirect -> 10
    BadRequest -> 11
    Unauthorized -> 12
    Forbidden -> 13
    NotFound -> 14
    MethodNotAllowed -> 15
    RequestTimeout -> 16
    Conflict -> 17
    Gone -> 18
    LengthRequired -> 19
    PayloadTooLarge -> 20
    UriTooLong -> 21
    UnsupportedMedia -> 22
    TooManyRequests -> 23
    InternalError -> 24
    NotImplemented -> 25
    BadGateway -> 26
    ServiceUnavailable -> 27
    GatewayTimeout -> 28
  }
}

/// Decode from a C-ABI tag value.
pub fn status_from_int(tag: Int) -> Result(StatusCode, Nil) {
  case tag {
    0 -> Ok(Continue)
    1 -> Ok(SwitchingProtocols)
    2 -> Ok(StatusOk)
    3 -> Ok(Created)
    4 -> Ok(Accepted)
    5 -> Ok(NoContent)
    6 -> Ok(MovedPermanently)
    7 -> Ok(Found)
    8 -> Ok(NotModified)
    9 -> Ok(TemporaryRedirect)
    10 -> Ok(PermanentRedirect)
    11 -> Ok(BadRequest)
    12 -> Ok(Unauthorized)
    13 -> Ok(Forbidden)
    14 -> Ok(NotFound)
    15 -> Ok(MethodNotAllowed)
    16 -> Ok(RequestTimeout)
    17 -> Ok(Conflict)
    18 -> Ok(Gone)
    19 -> Ok(LengthRequired)
    20 -> Ok(PayloadTooLarge)
    21 -> Ok(UriTooLong)
    22 -> Ok(UnsupportedMedia)
    23 -> Ok(TooManyRequests)
    24 -> Ok(InternalError)
    25 -> Ok(NotImplemented)
    26 -> Ok(BadGateway)
    27 -> Ok(ServiceUnavailable)
    28 -> Ok(GatewayTimeout)
    _ -> Error(Nil)
  }
}

/// The numeric HTTP status code (e.g. 200, 404).
///
/// Matches `statusToCode` in `HTTP.Status`.
pub fn status_numeric_code(code: StatusCode) -> Int {
  case code {
    Continue -> 100
    SwitchingProtocols -> 101
    StatusOk -> 200
    Created -> 201
    Accepted -> 202
    NoContent -> 204
    MovedPermanently -> 301
    Found -> 302
    NotModified -> 304
    TemporaryRedirect -> 307
    PermanentRedirect -> 308
    BadRequest -> 400
    Unauthorized -> 401
    Forbidden -> 403
    NotFound -> 404
    MethodNotAllowed -> 405
    RequestTimeout -> 408
    Conflict -> 409
    Gone -> 410
    LengthRequired -> 411
    PayloadTooLarge -> 413
    UriTooLong -> 414
    UnsupportedMedia -> 415
    TooManyRequests -> 429
    InternalError -> 500
    NotImplemented -> 501
    BadGateway -> 502
    ServiceUnavailable -> 503
    GatewayTimeout -> 504
  }
}

/// Parse from a numeric HTTP status code.
pub fn status_from_numeric(code: Int) -> Result(StatusCode, Nil) {
  case code {
    100 -> Ok(Continue)
    101 -> Ok(SwitchingProtocols)
    200 -> Ok(StatusOk)
    201 -> Ok(Created)
    202 -> Ok(Accepted)
    204 -> Ok(NoContent)
    301 -> Ok(MovedPermanently)
    302 -> Ok(Found)
    304 -> Ok(NotModified)
    307 -> Ok(TemporaryRedirect)
    308 -> Ok(PermanentRedirect)
    400 -> Ok(BadRequest)
    401 -> Ok(Unauthorized)
    403 -> Ok(Forbidden)
    404 -> Ok(NotFound)
    405 -> Ok(MethodNotAllowed)
    408 -> Ok(RequestTimeout)
    409 -> Ok(Conflict)
    410 -> Ok(Gone)
    411 -> Ok(LengthRequired)
    413 -> Ok(PayloadTooLarge)
    414 -> Ok(UriTooLong)
    415 -> Ok(UnsupportedMedia)
    429 -> Ok(TooManyRequests)
    500 -> Ok(InternalError)
    501 -> Ok(NotImplemented)
    502 -> Ok(BadGateway)
    503 -> Ok(ServiceUnavailable)
    504 -> Ok(GatewayTimeout)
    _ -> Error(Nil)
  }
}

/// Standard reason phrase (RFC 7231).
pub fn status_reason_phrase(code: StatusCode) -> String {
  case code {
    Continue -> "Continue"
    SwitchingProtocols -> "Switching Protocols"
    StatusOk -> "OK"
    Created -> "Created"
    Accepted -> "Accepted"
    NoContent -> "No Content"
    MovedPermanently -> "Moved Permanently"
    Found -> "Found"
    NotModified -> "Not Modified"
    TemporaryRedirect -> "Temporary Redirect"
    PermanentRedirect -> "Permanent Redirect"
    BadRequest -> "Bad Request"
    Unauthorized -> "Unauthorized"
    Forbidden -> "Forbidden"
    NotFound -> "Not Found"
    MethodNotAllowed -> "Method Not Allowed"
    RequestTimeout -> "Request Timeout"
    Conflict -> "Conflict"
    Gone -> "Gone"
    LengthRequired -> "Length Required"
    PayloadTooLarge -> "Payload Too Large"
    UriTooLong -> "URI Too Long"
    UnsupportedMedia -> "Unsupported Media Type"
    TooManyRequests -> "Too Many Requests"
    InternalError -> "Internal Server Error"
    NotImplemented -> "Not Implemented"
    BadGateway -> "Bad Gateway"
    ServiceUnavailable -> "Service Unavailable"
    GatewayTimeout -> "Gateway Timeout"
  }
}

// status_category (and the classifiers status_is_success, status_is_error and
// status_is_redirect that delegate to it) removed: unproven reimplementation.
// The verified check lives in the Idris2/Zig core; calling it needs @external
// FFI wiring not yet present here.
// Do not reimplement here. See docs/decisions/0003-keep-bindings-thin-abi-wrappers.md

// ===========================================================================
// Content Type (HTTPABI.Layout.ContentType, tags 0-7)
// ===========================================================================

/// Common HTTP content types for ABI interchange.
pub type ContentType {
  TextPlain
  TextHtml
  ApplicationJson
  ApplicationXml
  ApplicationForm
  MultipartForm
  OctetStream
  TextCss
}

/// Convert a `ContentType` to its C-ABI tag value.
pub fn content_type_to_int(ct: ContentType) -> Int {
  case ct {
    TextPlain -> 0
    TextHtml -> 1
    ApplicationJson -> 2
    ApplicationXml -> 3
    ApplicationForm -> 4
    MultipartForm -> 5
    OctetStream -> 6
    TextCss -> 7
  }
}

/// Decode from a C-ABI tag value.
pub fn content_type_from_int(tag: Int) -> Result(ContentType, Nil) {
  case tag {
    0 -> Ok(TextPlain)
    1 -> Ok(TextHtml)
    2 -> Ok(ApplicationJson)
    3 -> Ok(ApplicationXml)
    4 -> Ok(ApplicationForm)
    5 -> Ok(MultipartForm)
    6 -> Ok(OctetStream)
    7 -> Ok(TextCss)
    _ -> Error(Nil)
  }
}

/// MIME type string.
pub fn content_type_mime(ct: ContentType) -> String {
  case ct {
    TextPlain -> "text/plain"
    TextHtml -> "text/html"
    ApplicationJson -> "application/json"
    ApplicationXml -> "application/xml"
    ApplicationForm -> "application/x-www-form-urlencoded"
    MultipartForm -> "multipart/form-data"
    OctetStream -> "application/octet-stream"
    TextCss -> "text/css"
  }
}

// ===========================================================================
// Request Phase / Lifecycle (HTTPABI.Layout.RequestPhase, tags 0-6)
// ===========================================================================

/// Phases of the HTTP request processing lifecycle.
///
/// Models the state machine from `HTTPABI.Transitions`:
///
/// ```text
/// Idle -> Receiving -> HeadersParsed -> BodyReceiving -> Complete
///      -> Responding -> Sent [-> Idle (keep-alive)]
/// ```
pub type RequestPhase {
  Idle
  Receiving
  HeadersParsed
  BodyReceiving
  PhaseComplete
  Responding
  Sent
}

/// Convert a `RequestPhase` to its C-ABI tag value.
pub fn request_phase_to_int(phase: RequestPhase) -> Int {
  case phase {
    Idle -> 0
    Receiving -> 1
    HeadersParsed -> 2
    BodyReceiving -> 3
    PhaseComplete -> 4
    Responding -> 5
    Sent -> 6
  }
}

/// Decode from a C-ABI tag value.
pub fn request_phase_from_int(tag: Int) -> Result(RequestPhase, Nil) {
  case tag {
    0 -> Ok(Idle)
    1 -> Ok(Receiving)
    2 -> Ok(HeadersParsed)
    3 -> Ok(BodyReceiving)
    4 -> Ok(PhaseComplete)
    5 -> Ok(Responding)
    6 -> Ok(Sent)
    _ -> Error(Nil)
  }
}

/// Named HTTP request lifecycle transitions.
///
/// Each variant corresponds to a constructor of `ValidHttpTransition`
/// in `HTTPABI.Transitions`.
pub type HttpTransition {
  StartReceiving
  ParseHeaders
  StartBody
  NoBodyComplete
  BodyDone
  BeginResponse
  FinishSend
  KeepAliveRecycle
  AbortReceiving
  AbortHeadersParsed
  AbortBodyReceiving
  AbortComplete
}

// validate_http_transition removed: unproven reimplementation. The verified
// check lives in the Idris2/Zig core; calling it needs @external FFI wiring not
// yet present here.
// Do not reimplement here. See docs/decisions/0003-keep-bindings-thin-abi-wrappers.md

/// The source phase of a transition.
pub fn transition_from_phase(transition: HttpTransition) -> RequestPhase {
  case transition {
    StartReceiving -> Idle
    ParseHeaders | AbortReceiving -> Receiving
    StartBody | NoBodyComplete | AbortHeadersParsed -> HeadersParsed
    BodyDone | AbortBodyReceiving -> BodyReceiving
    BeginResponse | AbortComplete -> PhaseComplete
    FinishSend -> Responding
    KeepAliveRecycle -> Sent
  }
}

/// The target phase of a transition.
pub fn transition_to_phase(transition: HttpTransition) -> RequestPhase {
  case transition {
    StartReceiving -> Receiving
    ParseHeaders -> HeadersParsed
    StartBody -> BodyReceiving
    NoBodyComplete | BodyDone -> PhaseComplete
    BeginResponse -> Responding
    FinishSend | AbortReceiving | AbortHeadersParsed | AbortBodyReceiving | AbortComplete ->
      Sent
    KeepAliveRecycle -> Idle
  }
}
