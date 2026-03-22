<?php
// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// HTTP protocol types for proven-servers.

declare(strict_types=1);

namespace ProvenServers;

/** Method matching the Idris2 ABI tags. */
enum Method: int
{
    case Get = 0;
    case Post = 1;
    case Put = 2;
    case Delete = 3;
    case Patch = 4;
    case Head = 5;
    case Options = 6;
    case Trace = 7;
    case Connect = 8;
}

/** Version matching the Idris2 ABI tags. */
enum Version: int
{
    case Http10 = 0;
    case Http11 = 1;
    case Http20 = 2;
    case Http30 = 3;
}

/** StatusCategory matching the Idris2 ABI tags. */
enum StatusCategory: int
{
    case Informational = 0;
    case Success = 1;
    case Redirect = 2;
    case ClientError = 3;
    case ServerError = 4;
}

/** StatusCode matching the Idris2 ABI tags. */
enum StatusCode: int
{
    case Continue = 0;
    case SwitchingProtocols = 1;
    case Ok = 2;
    case Created = 3;
    case Accepted = 4;
    case NoContent = 5;
    case MovedPermanently = 6;
    case Found = 7;
    case NotModified = 8;
    case TemporaryRedirect = 9;
    case PermanentRedirect = 10;
    case BadRequest = 11;
    case Unauthorized = 12;
    case Forbidden = 13;
    case NotFound = 14;
    case MethodNotAllowed = 15;
    case RequestTimeout = 16;
    case Conflict = 17;
    case Gone = 18;
    case LengthRequired = 19;
    case PayloadTooLarge = 20;
    case UriTooLong = 21;
    case UnsupportedMedia = 22;
    case TooManyRequests = 23;
    case InternalError = 24;
    case NotImplemented = 25;
    case BadGateway = 26;
    case ServiceUnavailable = 27;
    case GatewayTimeout = 28;
}

/** ContentType matching the Idris2 ABI tags. */
enum ContentType: int
{
    case TextPlain = 0;
    case TextHtml = 1;
    case ApplicationJson = 2;
    case ApplicationXml = 3;
    case ApplicationForm = 4;
    case MultipartForm = 5;
    case OctetStream = 6;
    case TextCss = 7;
}

/** HeaderType matching the Idris2 ABI tags. */
enum HeaderType: int
{
    case ContentType = 0;
    case ContentLength = 1;
    case Host = 2;
    case Connection = 3;
    case Accept = 4;
    case UserAgent = 5;
    case Server = 6;
    case Location = 7;
    case CacheControl = 8;
    case Custom = 9;
}

/** RequestPhase matching the Idris2 ABI tags. */
enum RequestPhase: int
{
    case Idle = 0;
    case Receiving = 1;
    case HeadersParsed = 2;
    case BodyReceiving = 3;
    case Complete = 4;
    case Responding = 5;
    case Sent = 6;
}
