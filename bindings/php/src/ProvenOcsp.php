<?php
// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// OCSP protocol types for proven-servers.

declare(strict_types=1);

namespace ProvenServers;

/** CertStatus matching the Idris2 ABI tags. */
enum CertStatus: int
{
    case Good = 0;
    case Revoked = 1;
    case Unknown = 2;
}

/** ResponseStatus matching the Idris2 ABI tags. */
enum ResponseStatus: int
{
    case Successful = 0;
    case MalformedRequest = 1;
    case InternalError = 2;
    case TryLater = 3;
    case SigRequired = 4;
    case Unauthorized = 5;
}

/** HashAlgorithm matching the Idris2 ABI tags. */
enum HashAlgorithm: int
{
    case Sha1 = 0;
    case Sha256 = 1;
    case Sha384 = 2;
    case Sha512 = 3;
}

/** ResponderState matching the Idris2 ABI tags. */
enum ResponderState: int
{
    case Idle = 0;
    case Ready = 1;
    case Processing = 2;
    case Signing = 3;
    case Closing = 4;
}
