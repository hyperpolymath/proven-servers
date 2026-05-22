// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
/// @file http.hpp
/// @brief HTTP protocol types for proven-servers.

#ifndef PROVEN_HTTP_HPP
#define PROVEN_HTTP_HPP

#include <cstdint>

namespace proven {

/// @brief Method matching the Idris2 ABI tags.
enum class Method : uint8_t {
    Get = 0,
    Post = 1,
    Put = 2,
    Delete = 3,
    Patch = 4,
    Head = 5,
    Options = 6,
    Trace = 7,
    Connect = 8
};

/// @brief Version matching the Idris2 ABI tags.
enum class Version : uint8_t {
    Http10 = 0,
    Http11 = 1,
    Http20 = 2,
    Http30 = 3
};

/// @brief StatusCategory matching the Idris2 ABI tags.
enum class StatusCategory : uint8_t {
    Informational = 0,
    Success = 1,
    Redirect = 2,
    ClientError = 3,
    ServerError = 4
};

/// @brief StatusCode matching the Idris2 ABI tags.
enum class StatusCode : uint8_t {
    Continue = 0,
    SwitchingProtocols = 1,
    Ok = 2,
    Created = 3,
    Accepted = 4,
    NoContent = 5,
    MovedPermanently = 6,
    Found = 7,
    NotModified = 8,
    TemporaryRedirect = 9,
    PermanentRedirect = 10,
    BadRequest = 11,
    Unauthorized = 12,
    Forbidden = 13,
    NotFound = 14,
    MethodNotAllowed = 15,
    RequestTimeout = 16,
    Conflict = 17,
    Gone = 18,
    LengthRequired = 19,
    PayloadTooLarge = 20,
    UriTooLong = 21,
    UnsupportedMedia = 22,
    TooManyRequests = 23,
    InternalError = 24,
    NotImplemented = 25,
    BadGateway = 26,
    ServiceUnavailable = 27,
    GatewayTimeout = 28
};

/// @brief ContentType matching the Idris2 ABI tags.
enum class ContentType : uint8_t {
    TextPlain = 0,
    TextHtml = 1,
    ApplicationJson = 2,
    ApplicationXml = 3,
    ApplicationForm = 4,
    MultipartForm = 5,
    OctetStream = 6,
    TextCss = 7
};

/// @brief HeaderType matching the Idris2 ABI tags.
enum class HeaderType : uint8_t {
    ContentType = 0,
    ContentLength = 1,
    Host = 2,
    Connection = 3,
    Accept = 4,
    UserAgent = 5,
    Server = 6,
    Location = 7,
    CacheControl = 8,
    Custom = 9
};

/// @brief RequestPhase matching the Idris2 ABI tags.
enum class RequestPhase : uint8_t {
    Idle = 0,
    Receiving = 1,
    HeadersParsed = 2,
    BodyReceiving = 3,
    Complete = 4,
    Responding = 5,
    Sent = 6
};

} // namespace proven

#endif // PROVEN_HTTP_HPP
