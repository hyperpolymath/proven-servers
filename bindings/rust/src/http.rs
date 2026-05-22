// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
//! HTTP protocol types for the proven-servers ABI.
//!
//! Mirrors the Idris2 modules:
//! - `HTTP.Method`          — request methods (RFC 7231)
//! - `HTTP.Status`          — status codes and categories (RFC 7231)
//! - `HTTPABI.Layout`       — C-ABI tag values for methods, versions, content types
//! - `HTTPABI.Transitions`  — request lifecycle state machine
//!
//! All `#[repr(u8)]` discriminants match the `*ToTag` functions in
//! `HTTPABI.Layout` exactly. The request lifecycle is modelled as a
//! typestate pattern using [`RequestPhase`] and [`ValidTransition`].

use std::fmt;

// ===========================================================================
// HTTP Method (HTTPABI.Layout.HttpMethod, tags 0-8)
// ===========================================================================

/// Standard HTTP request methods (RFC 7231 Section 4, RFC 5789).
///
/// Tag values match `httpMethodToTag` in `HTTPABI.Layout`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum Method {
    /// Retrieve a representation of the target resource.
    Get = 0,
    /// Perform resource-specific processing on the request payload.
    Post = 1,
    /// Replace all current representations of the target resource.
    Put = 2,
    /// Remove all current representations of the target resource.
    Delete = 3,
    /// Apply partial modifications to a resource (RFC 5789).
    Patch = 4,
    /// Same as GET but only transfer status line and headers.
    Head = 5,
    /// Describe the communication options for the target resource.
    Options = 6,
    /// Perform a message loop-back test along the path to the target.
    Trace = 7,
    /// Establish a tunnel to the server identified by the target resource.
    Connect = 8,
}

impl Method {
    /// Parse a method string (case-sensitive) to a [`Method`].
    ///
    /// Returns `None` for unrecognised methods, matching `parseMethod`
    /// in `HTTP.Method`.
    pub fn parse(s: &str) -> Option<Self> {
        match s {
            "GET" => Some(Self::Get),
            "POST" => Some(Self::Post),
            "PUT" => Some(Self::Put),
            "DELETE" => Some(Self::Delete),
            "PATCH" => Some(Self::Patch),
            "HEAD" => Some(Self::Head),
            "OPTIONS" => Some(Self::Options),
            "TRACE" => Some(Self::Trace),
            "CONNECT" => Some(Self::Connect),
            _ => None,
        }
    }

    /// Decode from the C-ABI tag value.
    ///
    /// Matches `tagToHttpMethod` in `HTTPABI.Layout`.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Get),
            1 => Some(Self::Post),
            2 => Some(Self::Put),
            3 => Some(Self::Delete),
            4 => Some(Self::Patch),
            5 => Some(Self::Head),
            6 => Some(Self::Options),
            7 => Some(Self::Trace),
            8 => Some(Self::Connect),
            _ => None,
        }
    }

    /// Encode to the C-ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// Canonical string representation (e.g. `"GET"`).
    pub fn as_str(self) -> &'static str {
        match self {
            Self::Get => "GET",
            Self::Post => "POST",
            Self::Put => "PUT",
            Self::Delete => "DELETE",
            Self::Patch => "PATCH",
            Self::Head => "HEAD",
            Self::Options => "OPTIONS",
            Self::Trace => "TRACE",
            Self::Connect => "CONNECT",
        }
    }

    /// Whether the method is "safe" (RFC 7231 Section 4.2.1).
    ///
    /// Safe methods are read-only and should not cause side effects.
    /// Matches `isSafe` in `HTTP.Method`.
    pub fn is_safe(self) -> bool {
        matches!(self, Self::Get | Self::Head | Self::Options | Self::Trace)
    }

    /// Whether the method is idempotent (RFC 7231 Section 4.2.2).
    ///
    /// Matches `isIdempotent` in `HTTP.Method`.
    pub fn is_idempotent(self) -> bool {
        matches!(
            self,
            Self::Get | Self::Head | Self::Put | Self::Delete | Self::Options | Self::Trace
        )
    }

    /// Whether the method typically carries a request body.
    ///
    /// Matches `hasRequestBody` in `HTTP.Method`.
    pub fn has_request_body(self) -> bool {
        matches!(self, Self::Post | Self::Put | Self::Patch)
    }

    /// All standard HTTP methods in tag order.
    pub const ALL: [Method; 9] = [
        Self::Get,
        Self::Post,
        Self::Put,
        Self::Delete,
        Self::Patch,
        Self::Head,
        Self::Options,
        Self::Trace,
        Self::Connect,
    ];
}

impl fmt::Display for Method {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        f.write_str(self.as_str())
    }
}

// ===========================================================================
// HTTP Version (HTTPABI.Layout.HttpVersion, tags 0-3)
// ===========================================================================

/// HTTP protocol versions.
///
/// Tag values match `httpVersionToTag` in `HTTPABI.Layout`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash, PartialOrd, Ord)]
#[repr(u8)]
pub enum Version {
    /// HTTP/1.0 (RFC 1945).
    Http10 = 0,
    /// HTTP/1.1 (RFC 7230).
    Http11 = 1,
    /// HTTP/2 (RFC 7540).
    Http20 = 2,
    /// HTTP/3 (RFC 9114).
    Http30 = 3,
}

impl Version {
    /// Decode from the C-ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Http10),
            1 => Some(Self::Http11),
            2 => Some(Self::Http20),
            3 => Some(Self::Http30),
            _ => None,
        }
    }

    /// Encode to the C-ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// Human-readable version string.
    pub fn as_str(self) -> &'static str {
        match self {
            Self::Http10 => "HTTP/1.0",
            Self::Http11 => "HTTP/1.1",
            Self::Http20 => "HTTP/2",
            Self::Http30 => "HTTP/3",
        }
    }
}

impl fmt::Display for Version {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        f.write_str(self.as_str())
    }
}

// ===========================================================================
// Status Category (HTTPABI.Layout.StatusCat, tags 0-4)
// ===========================================================================

/// HTTP response status code categories (RFC 7231 Section 6).
///
/// Tag values match `statusCatToTag` in `HTTPABI.Layout`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum StatusCategory {
    /// 1xx: request received, continuing process.
    Informational = 0,
    /// 2xx: request successfully received, understood, and accepted.
    Success = 1,
    /// 3xx: further action needed to complete the request.
    Redirect = 2,
    /// 4xx: request contains bad syntax or cannot be fulfilled.
    ClientError = 3,
    /// 5xx: server failed to fulfil an apparently valid request.
    ServerError = 4,
}

impl StatusCategory {
    /// Decode from the C-ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Informational),
            1 => Some(Self::Success),
            2 => Some(Self::Redirect),
            3 => Some(Self::ClientError),
            4 => Some(Self::ServerError),
            _ => None,
        }
    }

    /// Encode to the C-ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }
}

impl fmt::Display for StatusCategory {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        let name = match self {
            Self::Informational => "Informational",
            Self::Success => "Success",
            Self::Redirect => "Redirect",
            Self::ClientError => "ClientError",
            Self::ServerError => "ServerError",
        };
        f.write_str(name)
    }
}

// ===========================================================================
// Status Code (HTTPABI.Layout.AbiStatusCode, tags 0-28)
// ===========================================================================

/// Common HTTP status codes (RFC 7231 and related RFCs).
///
/// Tag values match `abiStatusCodeToTag` in `HTTPABI.Layout`.
/// The tags are grouped by category for efficient range checks:
/// 1xx (0-1), 2xx (2-5), 3xx (6-10), 4xx (11-23), 5xx (24-28).
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum StatusCode {
    // 1xx Informational
    /// 100 Continue.
    Continue = 0,
    /// 101 Switching Protocols.
    SwitchingProtocols = 1,
    // 2xx Success
    /// 200 OK.
    Ok = 2,
    /// 201 Created.
    Created = 3,
    /// 202 Accepted.
    Accepted = 4,
    /// 204 No Content.
    NoContent = 5,
    // 3xx Redirection
    /// 301 Moved Permanently.
    MovedPermanently = 6,
    /// 302 Found.
    Found = 7,
    /// 304 Not Modified.
    NotModified = 8,
    /// 307 Temporary Redirect.
    TemporaryRedirect = 9,
    /// 308 Permanent Redirect.
    PermanentRedirect = 10,
    // 4xx Client Error
    /// 400 Bad Request.
    BadRequest = 11,
    /// 401 Unauthorized.
    Unauthorized = 12,
    /// 403 Forbidden.
    Forbidden = 13,
    /// 404 Not Found.
    NotFound = 14,
    /// 405 Method Not Allowed.
    MethodNotAllowed = 15,
    /// 408 Request Timeout.
    RequestTimeout = 16,
    /// 409 Conflict.
    Conflict = 17,
    /// 410 Gone.
    Gone = 18,
    /// 411 Length Required.
    LengthRequired = 19,
    /// 413 Payload Too Large.
    PayloadTooLarge = 20,
    /// 414 URI Too Long.
    UriTooLong = 21,
    /// 415 Unsupported Media Type.
    UnsupportedMedia = 22,
    /// 429 Too Many Requests.
    TooManyRequests = 23,
    // 5xx Server Error
    /// 500 Internal Server Error.
    InternalError = 24,
    /// 501 Not Implemented.
    NotImplemented = 25,
    /// 502 Bad Gateway.
    BadGateway = 26,
    /// 503 Service Unavailable.
    ServiceUnavailable = 27,
    /// 504 Gateway Timeout.
    GatewayTimeout = 28,
}

impl StatusCode {
    /// Decode from the C-ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Continue),
            1 => Some(Self::SwitchingProtocols),
            2 => Some(Self::Ok),
            3 => Some(Self::Created),
            4 => Some(Self::Accepted),
            5 => Some(Self::NoContent),
            6 => Some(Self::MovedPermanently),
            7 => Some(Self::Found),
            8 => Some(Self::NotModified),
            9 => Some(Self::TemporaryRedirect),
            10 => Some(Self::PermanentRedirect),
            11 => Some(Self::BadRequest),
            12 => Some(Self::Unauthorized),
            13 => Some(Self::Forbidden),
            14 => Some(Self::NotFound),
            15 => Some(Self::MethodNotAllowed),
            16 => Some(Self::RequestTimeout),
            17 => Some(Self::Conflict),
            18 => Some(Self::Gone),
            19 => Some(Self::LengthRequired),
            20 => Some(Self::PayloadTooLarge),
            21 => Some(Self::UriTooLong),
            22 => Some(Self::UnsupportedMedia),
            23 => Some(Self::TooManyRequests),
            24 => Some(Self::InternalError),
            25 => Some(Self::NotImplemented),
            26 => Some(Self::BadGateway),
            27 => Some(Self::ServiceUnavailable),
            28 => Some(Self::GatewayTimeout),
            _ => None,
        }
    }

    /// Encode to the C-ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// The numeric HTTP status code (e.g. 200, 404).
    ///
    /// Matches `statusToCode` in `HTTP.Status`.
    pub fn numeric_code(self) -> u16 {
        match self {
            Self::Continue => 100,
            Self::SwitchingProtocols => 101,
            Self::Ok => 200,
            Self::Created => 201,
            Self::Accepted => 202,
            Self::NoContent => 204,
            Self::MovedPermanently => 301,
            Self::Found => 302,
            Self::NotModified => 304,
            Self::TemporaryRedirect => 307,
            Self::PermanentRedirect => 308,
            Self::BadRequest => 400,
            Self::Unauthorized => 401,
            Self::Forbidden => 403,
            Self::NotFound => 404,
            Self::MethodNotAllowed => 405,
            Self::RequestTimeout => 408,
            Self::Conflict => 409,
            Self::Gone => 410,
            Self::LengthRequired => 411,
            Self::PayloadTooLarge => 413,
            Self::UriTooLong => 414,
            Self::UnsupportedMedia => 415,
            Self::TooManyRequests => 429,
            Self::InternalError => 500,
            Self::NotImplemented => 501,
            Self::BadGateway => 502,
            Self::ServiceUnavailable => 503,
            Self::GatewayTimeout => 504,
        }
    }

    /// Parse from a numeric HTTP status code (e.g. `200`).
    ///
    /// Matches `fromCode` in `HTTP.Status`.
    pub fn from_numeric(code: u16) -> Option<Self> {
        match code {
            100 => Some(Self::Continue),
            101 => Some(Self::SwitchingProtocols),
            200 => Some(Self::Ok),
            201 => Some(Self::Created),
            202 => Some(Self::Accepted),
            204 => Some(Self::NoContent),
            301 => Some(Self::MovedPermanently),
            302 => Some(Self::Found),
            304 => Some(Self::NotModified),
            307 => Some(Self::TemporaryRedirect),
            308 => Some(Self::PermanentRedirect),
            400 => Some(Self::BadRequest),
            401 => Some(Self::Unauthorized),
            403 => Some(Self::Forbidden),
            404 => Some(Self::NotFound),
            405 => Some(Self::MethodNotAllowed),
            408 => Some(Self::RequestTimeout),
            409 => Some(Self::Conflict),
            410 => Some(Self::Gone),
            411 => Some(Self::LengthRequired),
            413 => Some(Self::PayloadTooLarge),
            414 => Some(Self::UriTooLong),
            415 => Some(Self::UnsupportedMedia),
            429 => Some(Self::TooManyRequests),
            500 => Some(Self::InternalError),
            501 => Some(Self::NotImplemented),
            502 => Some(Self::BadGateway),
            503 => Some(Self::ServiceUnavailable),
            504 => Some(Self::GatewayTimeout),
            _ => None,
        }
    }

    /// Standard reason phrase (RFC 7231).
    ///
    /// Matches `reasonPhrase` in `HTTP.Status`.
    pub fn reason_phrase(self) -> &'static str {
        match self {
            Self::Continue => "Continue",
            Self::SwitchingProtocols => "Switching Protocols",
            Self::Ok => "OK",
            Self::Created => "Created",
            Self::Accepted => "Accepted",
            Self::NoContent => "No Content",
            Self::MovedPermanently => "Moved Permanently",
            Self::Found => "Found",
            Self::NotModified => "Not Modified",
            Self::TemporaryRedirect => "Temporary Redirect",
            Self::PermanentRedirect => "Permanent Redirect",
            Self::BadRequest => "Bad Request",
            Self::Unauthorized => "Unauthorized",
            Self::Forbidden => "Forbidden",
            Self::NotFound => "Not Found",
            Self::MethodNotAllowed => "Method Not Allowed",
            Self::RequestTimeout => "Request Timeout",
            Self::Conflict => "Conflict",
            Self::Gone => "Gone",
            Self::LengthRequired => "Length Required",
            Self::PayloadTooLarge => "Payload Too Large",
            Self::UriTooLong => "URI Too Long",
            Self::UnsupportedMedia => "Unsupported Media Type",
            Self::TooManyRequests => "Too Many Requests",
            Self::InternalError => "Internal Server Error",
            Self::NotImplemented => "Not Implemented",
            Self::BadGateway => "Bad Gateway",
            Self::ServiceUnavailable => "Service Unavailable",
            Self::GatewayTimeout => "Gateway Timeout",
        }
    }

    /// Categorise this status code.
    ///
    /// Matches `categorise` in `HTTP.Status`.
    pub fn category(self) -> StatusCategory {
        match self.to_tag() {
            0..=1 => StatusCategory::Informational,
            2..=5 => StatusCategory::Success,
            6..=10 => StatusCategory::Redirect,
            11..=23 => StatusCategory::ClientError,
            24..=28 => StatusCategory::ServerError,
            _ => StatusCategory::ServerError, // unreachable for valid codes
        }
    }

    /// Whether this is a success code (2xx).
    pub fn is_success(self) -> bool {
        self.category() == StatusCategory::Success
    }

    /// Whether this is an error code (4xx or 5xx).
    pub fn is_error(self) -> bool {
        matches!(
            self.category(),
            StatusCategory::ClientError | StatusCategory::ServerError
        )
    }

    /// Whether this is a redirect code (3xx).
    pub fn is_redirect(self) -> bool {
        self.category() == StatusCategory::Redirect
    }
}

impl fmt::Display for StatusCode {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        write!(f, "{} {}", self.numeric_code(), self.reason_phrase())
    }
}

// ===========================================================================
// Content Type (HTTPABI.Layout.ContentType, tags 0-7)
// ===========================================================================

/// Common HTTP content types for ABI interchange.
///
/// Tag values match `contentTypeToTag` in `HTTPABI.Layout`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum ContentType {
    /// `text/plain`.
    TextPlain = 0,
    /// `text/html`.
    TextHtml = 1,
    /// `application/json`.
    ApplicationJson = 2,
    /// `application/xml`.
    ApplicationXml = 3,
    /// `application/x-www-form-urlencoded`.
    ApplicationForm = 4,
    /// `multipart/form-data`.
    MultipartForm = 5,
    /// `application/octet-stream`.
    OctetStream = 6,
    /// `text/css`.
    TextCss = 7,
}

impl ContentType {
    /// Decode from the C-ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::TextPlain),
            1 => Some(Self::TextHtml),
            2 => Some(Self::ApplicationJson),
            3 => Some(Self::ApplicationXml),
            4 => Some(Self::ApplicationForm),
            5 => Some(Self::MultipartForm),
            6 => Some(Self::OctetStream),
            7 => Some(Self::TextCss),
            _ => None,
        }
    }

    /// Encode to the C-ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// MIME type string.
    pub fn mime(self) -> &'static str {
        match self {
            Self::TextPlain => "text/plain",
            Self::TextHtml => "text/html",
            Self::ApplicationJson => "application/json",
            Self::ApplicationXml => "application/xml",
            Self::ApplicationForm => "application/x-www-form-urlencoded",
            Self::MultipartForm => "multipart/form-data",
            Self::OctetStream => "application/octet-stream",
            Self::TextCss => "text/css",
        }
    }
}

impl fmt::Display for ContentType {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        f.write_str(self.mime())
    }
}

// ===========================================================================
// Header Type (HTTPABI.Layout.HeaderType, tags 0-9)
// ===========================================================================

/// Common HTTP header names as an enumeration for ABI interchange.
///
/// Tag values match `headerTypeToTag` in `HTTPABI.Layout`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum HeaderType {
    /// `Content-Type`.
    ContentType = 0,
    /// `Content-Length`.
    ContentLength = 1,
    /// `Host`.
    Host = 2,
    /// `Connection`.
    Connection = 3,
    /// `Accept`.
    Accept = 4,
    /// `User-Agent`.
    UserAgent = 5,
    /// `Server`.
    Server = 6,
    /// `Location`.
    Location = 7,
    /// `Cache-Control`.
    CacheControl = 8,
    /// Custom / unknown header.
    Custom = 9,
}

impl HeaderType {
    /// Decode from the C-ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::ContentType),
            1 => Some(Self::ContentLength),
            2 => Some(Self::Host),
            3 => Some(Self::Connection),
            4 => Some(Self::Accept),
            5 => Some(Self::UserAgent),
            6 => Some(Self::Server),
            7 => Some(Self::Location),
            8 => Some(Self::CacheControl),
            9 => Some(Self::Custom),
            _ => None,
        }
    }

    /// Encode to the C-ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// Canonical header name string.
    pub fn name(self) -> &'static str {
        match self {
            Self::ContentType => "Content-Type",
            Self::ContentLength => "Content-Length",
            Self::Host => "Host",
            Self::Connection => "Connection",
            Self::Accept => "Accept",
            Self::UserAgent => "User-Agent",
            Self::Server => "Server",
            Self::Location => "Location",
            Self::CacheControl => "Cache-Control",
            Self::Custom => "X-Custom",
        }
    }
}

impl fmt::Display for HeaderType {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        f.write_str(self.name())
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
///
/// Tag values match `requestPhaseToTag` in `HTTPABI.Layout`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum RequestPhase {
    /// Waiting for a new request.
    Idle = 0,
    /// Receiving request data.
    Receiving = 1,
    /// Request headers fully parsed.
    HeadersParsed = 2,
    /// Receiving request body.
    BodyReceiving = 3,
    /// Full request received.
    Complete = 4,
    /// Constructing response.
    Responding = 5,
    /// Response fully sent.
    Sent = 6,
}

impl RequestPhase {
    /// Decode from the C-ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Idle),
            1 => Some(Self::Receiving),
            2 => Some(Self::HeadersParsed),
            3 => Some(Self::BodyReceiving),
            4 => Some(Self::Complete),
            5 => Some(Self::Responding),
            6 => Some(Self::Sent),
            _ => None,
        }
    }

    /// Encode to the C-ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }
}

/// Named HTTP request lifecycle transition.
///
/// Each variant corresponds to a constructor of `ValidHttpTransition`
/// in `HTTPABI.Transitions`. The `from` and `to` phases are encoded
/// in the variant semantics.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
pub enum HttpTransition {
    /// Idle -> Receiving.
    StartReceiving,
    /// Receiving -> HeadersParsed.
    ParseHeaders,
    /// HeadersParsed -> BodyReceiving.
    StartBody,
    /// HeadersParsed -> Complete (no body, e.g. GET/HEAD).
    NoBodyComplete,
    /// BodyReceiving -> Complete.
    BodyDone,
    /// Complete -> Responding.
    BeginResponse,
    /// Responding -> Sent.
    FinishSend,
    /// Sent -> Idle (keep-alive recycle).
    KeepAliveRecycle,
    /// Receiving -> Sent (malformed request, send 400).
    AbortReceiving,
    /// HeadersParsed -> Sent (header validation error).
    AbortHeadersParsed,
    /// BodyReceiving -> Sent (body read error, e.g. 413).
    AbortBodyReceiving,
    /// Complete -> Sent (handler error, send 500).
    AbortComplete,
}

impl HttpTransition {
    /// The source phase of this transition.
    pub fn from_phase(self) -> RequestPhase {
        match self {
            Self::StartReceiving => RequestPhase::Idle,
            Self::ParseHeaders | Self::AbortReceiving => RequestPhase::Receiving,
            Self::StartBody | Self::NoBodyComplete | Self::AbortHeadersParsed => {
                RequestPhase::HeadersParsed
            }
            Self::BodyDone | Self::AbortBodyReceiving => RequestPhase::BodyReceiving,
            Self::BeginResponse | Self::AbortComplete => RequestPhase::Complete,
            Self::FinishSend => RequestPhase::Responding,
            Self::KeepAliveRecycle => RequestPhase::Sent,
        }
    }

    /// The target phase of this transition.
    pub fn to_phase(self) -> RequestPhase {
        match self {
            Self::StartReceiving => RequestPhase::Receiving,
            Self::ParseHeaders => RequestPhase::HeadersParsed,
            Self::StartBody => RequestPhase::BodyReceiving,
            Self::NoBodyComplete | Self::BodyDone => RequestPhase::Complete,
            Self::BeginResponse => RequestPhase::Responding,
            Self::FinishSend
            | Self::AbortReceiving
            | Self::AbortHeadersParsed
            | Self::AbortBodyReceiving
            | Self::AbortComplete => RequestPhase::Sent,
            Self::KeepAliveRecycle => RequestPhase::Idle,
        }
    }
}

/// Validate whether a transition between two request phases is legal.
///
/// Mirrors `validateHttpTransition` in `HTTPABI.Transitions`.
/// Returns `Some(transition)` for valid transitions, `None` for invalid.
pub fn validate_http_transition(
    from: RequestPhase,
    to: RequestPhase,
) -> Option<HttpTransition> {
    match (from, to) {
        (RequestPhase::Idle, RequestPhase::Receiving) => Some(HttpTransition::StartReceiving),
        (RequestPhase::Receiving, RequestPhase::HeadersParsed) => {
            Some(HttpTransition::ParseHeaders)
        }
        (RequestPhase::HeadersParsed, RequestPhase::BodyReceiving) => {
            Some(HttpTransition::StartBody)
        }
        (RequestPhase::HeadersParsed, RequestPhase::Complete) => {
            Some(HttpTransition::NoBodyComplete)
        }
        (RequestPhase::BodyReceiving, RequestPhase::Complete) => Some(HttpTransition::BodyDone),
        (RequestPhase::Complete, RequestPhase::Responding) => {
            Some(HttpTransition::BeginResponse)
        }
        (RequestPhase::Responding, RequestPhase::Sent) => Some(HttpTransition::FinishSend),
        (RequestPhase::Sent, RequestPhase::Idle) => Some(HttpTransition::KeepAliveRecycle),
        (RequestPhase::Receiving, RequestPhase::Sent) => Some(HttpTransition::AbortReceiving),
        (RequestPhase::HeadersParsed, RequestPhase::Sent) => {
            Some(HttpTransition::AbortHeadersParsed)
        }
        (RequestPhase::BodyReceiving, RequestPhase::Sent) => {
            Some(HttpTransition::AbortBodyReceiving)
        }
        (RequestPhase::Complete, RequestPhase::Sent) => Some(HttpTransition::AbortComplete),
        _ => None,
    }
}

// ===========================================================================
// Tests
// ===========================================================================

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn method_roundtrip() {
        for method in Method::ALL {
            let tag = method.to_tag();
            let decoded = Method::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, method);
        }
    }

    #[test]
    fn method_parse_roundtrip() {
        for method in Method::ALL {
            let s = method.as_str();
            let parsed = Method::parse(s).expect("valid method string");
            assert_eq!(parsed, method);
        }
    }

    #[test]
    fn method_safety_classification() {
        assert!(Method::Get.is_safe());
        assert!(Method::Head.is_safe());
        assert!(!Method::Post.is_safe());
        assert!(!Method::Delete.is_safe());
    }

    #[test]
    fn method_idempotency() {
        assert!(Method::Get.is_idempotent());
        assert!(Method::Put.is_idempotent());
        assert!(Method::Delete.is_idempotent());
        assert!(!Method::Post.is_idempotent());
        assert!(!Method::Patch.is_idempotent());
    }

    #[test]
    fn status_code_roundtrip() {
        for tag in 0u8..=28 {
            let code = StatusCode::from_tag(tag).expect("valid tag");
            assert_eq!(code.to_tag(), tag);
        }
    }

    #[test]
    fn status_code_numeric() {
        assert_eq!(StatusCode::Ok.numeric_code(), 200);
        assert_eq!(StatusCode::NotFound.numeric_code(), 404);
        assert_eq!(StatusCode::InternalError.numeric_code(), 500);
    }

    #[test]
    fn status_code_from_numeric() {
        assert_eq!(StatusCode::from_numeric(200), Some(StatusCode::Ok));
        assert_eq!(StatusCode::from_numeric(404), Some(StatusCode::NotFound));
        assert_eq!(StatusCode::from_numeric(999), None);
    }

    #[test]
    fn status_category_classification() {
        assert!(StatusCode::Ok.is_success());
        assert!(StatusCode::NotFound.is_error());
        assert!(StatusCode::InternalError.is_error());
        assert!(StatusCode::MovedPermanently.is_redirect());
        assert!(!StatusCode::Ok.is_error());
    }

    #[test]
    fn valid_http_transitions() {
        // All valid transitions from HTTPABI.Transitions should succeed.
        let valid_pairs = [
            (RequestPhase::Idle, RequestPhase::Receiving),
            (RequestPhase::Receiving, RequestPhase::HeadersParsed),
            (RequestPhase::HeadersParsed, RequestPhase::BodyReceiving),
            (RequestPhase::HeadersParsed, RequestPhase::Complete),
            (RequestPhase::BodyReceiving, RequestPhase::Complete),
            (RequestPhase::Complete, RequestPhase::Responding),
            (RequestPhase::Responding, RequestPhase::Sent),
            (RequestPhase::Sent, RequestPhase::Idle),
            // Abort transitions
            (RequestPhase::Receiving, RequestPhase::Sent),
            (RequestPhase::HeadersParsed, RequestPhase::Sent),
            (RequestPhase::BodyReceiving, RequestPhase::Sent),
            (RequestPhase::Complete, RequestPhase::Sent),
        ];
        for (from, to) in valid_pairs {
            assert!(
                validate_http_transition(from, to).is_some(),
                "transition {from:?} -> {to:?} should be valid"
            );
        }
    }

    #[test]
    fn invalid_http_transitions() {
        // These transitions are proven impossible in HTTPABI.Transitions.
        let invalid_pairs = [
            (RequestPhase::Idle, RequestPhase::Complete),       // cannotSkipToComplete
            (RequestPhase::Idle, RequestPhase::Responding),     // cannotSkipToResponding
            (RequestPhase::Complete, RequestPhase::Receiving),  // cannotGoBackwards
            (RequestPhase::Responding, RequestPhase::HeadersParsed), // cannotUndoResponse
            (RequestPhase::Idle, RequestPhase::Idle),           // cannotRecycleFromIdle
        ];
        for (from, to) in invalid_pairs {
            assert!(
                validate_http_transition(from, to).is_none(),
                "transition {from:?} -> {to:?} should be invalid"
            );
        }
    }

    #[test]
    fn content_type_roundtrip() {
        for tag in 0u8..=7 {
            let ct = ContentType::from_tag(tag).expect("valid tag");
            assert_eq!(ct.to_tag(), tag);
        }
    }

    #[test]
    fn header_type_roundtrip() {
        for tag in 0u8..=9 {
            let ht = HeaderType::from_tag(tag).expect("valid tag");
            assert_eq!(ht.to_tag(), tag);
        }
    }

    #[test]
    fn version_ordering() {
        assert!(Version::Http10 < Version::Http11);
        assert!(Version::Http11 < Version::Http20);
        assert!(Version::Http20 < Version::Http30);
    }
}
